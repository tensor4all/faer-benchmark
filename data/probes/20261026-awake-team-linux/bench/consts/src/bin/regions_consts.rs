//! Serial constants and 1T/plain/team tables of the remaining gates (Linux port of qr128-regions bench-tbl; use `consts <group>` only).
//! `consts <group>`: serial ns per unit (bsvd, tevd, tinv, spmm). `tbl <family> <n>`: median ns serial,
//! plain (Par::rayon(6) from outside the pool) and team(6) in interleaved rounds. No feature of the fork
//! beyond `threadteam` is used, so one source builds against any revision.
use faer::dyn_stack::{MemBuffer, MemStack};
use faer::linalg::evd::{self, ComputeEigenvectors};
use faer::linalg::svd::{self as lsvd, ComputeSvdVectors};
use faer::linalg::triangular_inverse::invert_lower_triangular;
use faer::sparse::linalg::matmul::{
    sparse_sparse_matmul_numeric, sparse_sparse_matmul_numeric_scratch, sparse_sparse_matmul_symbolic,
};
use faer::reborrow::ReborrowMut;
use faer::sparse::SparseColMat;
use faer::{c64, Accum, Mat, Par, Spec};
use std::time::{Duration, Instant};
use threadteam::{raise_current_thread_qos, Pool, Qos};

struct Rng(u64);
impl Rng {
    fn next(&mut self) -> f64 {
        self.0 ^= self.0 << 13;
        self.0 ^= self.0 >> 7;
        self.0 ^= self.0 << 17;
        (self.0 >> 11) as f64 / (1u64 << 53) as f64 - 0.5
    }
}
fn rand_mat(m: usize, n: usize, seed: u64) -> Mat<f64> {
    let mut r = Rng(seed | 1);
    Mat::from_fn(m, n, |_, _| r.next())
}

pub fn with_team<R>(threads: usize, f: impl FnOnce(Par) -> R) -> R {
    raise_current_thread_qos(Qos::UserInitiated);
    let pool = Pool::builder().threads(threads).qos(Qos::UserInitiated).acquire_timeout(Duration::from_secs(30)).build().unwrap();
    let team = pool.into_team(threads).unwrap();
    let mut exec = team.exec(threads);
    let mut f = Some(f);
    exec.team(|mut t| (f.take().unwrap())(Par::Team(t.reborrow()))).unwrap()
}

fn prime(ms: u128, mut f: impl FnMut()) {
    let t = Instant::now();
    while t.elapsed().as_millis() < ms {
        f();
    }
}
fn median_ns(prime_ms: u128, window_ms: u128, mut f: impl FnMut()) -> f64 {
    prime(prime_ms, &mut f);
    let mut v = vec![];
    let t = Instant::now();
    while v.len() < 15 || (t.elapsed().as_millis() < window_ms && v.len() < 5000) {
        let s = Instant::now();
        f();
        v.push(s.elapsed().as_nanos() as f64);
    }
    v.sort_by(|a, b| a.partial_cmp(b).unwrap());
    v[v.len() / 2]
}

/// the operation of one family at size n, as a closure over the parallelism
trait Op {
    fn run(&mut self, par: Par);
}

struct SvdOp { a0: Mat<f64>, a: Mat<f64>, s: Mat<f64>, u: Mat<f64>, v: Mat<f64>, mem: MemBuffer }
impl SvdOp {
    fn new(n: usize) -> Self {
        let a0 = rand_mat(n, n, 11);
        let mem = MemBuffer::new(lsvd::svd_scratch::<f64>(n, n, ComputeSvdVectors::Full, ComputeSvdVectors::Full, faer::ParShape::Seq, Spec::default()));
        Self { a: a0.clone(), a0, s: Mat::zeros(n, 1), u: Mat::zeros(n, n), v: Mat::zeros(n, n), mem }
    }
}
impl Op for SvdOp {
    fn run(&mut self, par: Par) {
        self.a.as_mut().copy_from(self.a0.as_ref());
        lsvd::svd(self.a.as_ref(), self.s.as_mut().col_mut(0).as_diagonal_mut(), Some(self.u.as_mut()), Some(self.v.as_mut()), par, MemStack::new(&mut self.mem), Spec::default()).unwrap();
    }
}
struct EvdOp { a0: Mat<f64>, s: Mat<f64>, u: Mat<f64>, mem: MemBuffer }
impl EvdOp {
    fn new(n: usize) -> Self {
        let g = rand_mat(n, n, 12);
        let a0 = Mat::from_fn(n, n, |i, j| g[(i, j)] + g[(j, i)]);
        let mem = MemBuffer::new(evd::self_adjoint_evd_scratch::<f64>(n, ComputeEigenvectors::Yes, faer::ParShape::Seq, Spec::default()));
        Self { a0, s: Mat::zeros(n, 1), u: Mat::zeros(n, n), mem }
    }
}
impl Op for EvdOp {
    fn run(&mut self, par: Par) {
        evd::self_adjoint_evd(self.a0.as_ref(), self.s.as_mut().col_mut(0).as_diagonal_mut(), Some(self.u.as_mut()), par, MemStack::new(&mut self.mem), Spec::default()).unwrap();
    }
}
struct TinvOp { src: Mat<f64>, dst: Mat<f64> }
impl TinvOp {
    fn new(n: usize) -> Self {
        let mut src = rand_mat(n, n, 13);
        for i in 0..n { src[(i, i)] = 2.0 + src[(i, i)].abs(); }
        Self { src, dst: Mat::zeros(n, n) }
    }
}
impl Op for TinvOp {
    fn run(&mut self, par: Par) {
        invert_lower_triangular(self.dst.as_mut(), self.src.as_ref(), par);
    }
}
struct QrOp { a0: Mat<f64>, a: Mat<f64>, qc: Mat<f64>, mem: MemBuffer }
impl QrOp {
    fn new(n: usize) -> Self {
        use faer::linalg::qr::no_pivoting::factor as qrf;
        let bs = qrf::recommended_block_size::<f64>(n, n);
        let a0 = rand_mat(n, n, 7);
        let mem = MemBuffer::new(qrf::qr_in_place_scratch::<f64>(n, n, bs, faer::ParShape::Seq, Default::default()));
        Self { a: a0.clone(), a0, qc: Mat::zeros(bs, n), mem }
    }
}
impl Op for QrOp {
    fn run(&mut self, par: Par) {
        use faer::linalg::qr::no_pivoting::factor as qrf;
        self.a.as_mut().copy_from(self.a0.as_ref());
        self.qc.as_mut().fill(0.0);
        qrf::qr_in_place(self.a.as_mut(), self.qc.as_mut(), par, MemStack::new(&mut self.mem), Default::default());
    }
}

fn sparse_rand<T: Clone>(m: usize, n: usize, per_col: usize, seed: u64, val: impl Fn(&mut Rng) -> T) -> SparseColMat<usize, T>
where T: faer::traits::ComplexField {
    let mut r = Rng(seed | 1);
    let mut trips = vec![];
    for j in 0..n {
        for _ in 0..per_col {
            let i = ((r.next() + 0.5) * m as f64) as usize % m;
            trips.push(faer::sparse::Triplet::new(i, j, val(&mut r)));
        }
    }
    SparseColMat::try_new_from_triplets(m, n, &trips).unwrap()
}
struct SpmmOp<T: faer::traits::ComplexField> { a: SparseColMat<usize, T>, b: SparseColMat<usize, T>, c: SparseColMat<usize, T>, info: faer::sparse::linalg::matmul::SparseMatMulInfo, mem: MemBuffer, flops: f64 }
impl<T: faer::traits::ComplexField + Clone> SpmmOp<T> {
    fn new(n: usize, per_col: usize, val: impl Fn(&mut Rng) -> T + Copy, one: T) -> Self {
        let a = sparse_rand::<T>(n, n, per_col, 21, val);
        let b = sparse_rand::<T>(n, n, per_col, 22, val);
        let (sym, info) = sparse_sparse_matmul_symbolic(a.symbolic(), b.symbolic()).unwrap();
        let nnz = sym.row_idx().len();
        let c = SparseColMat::new(sym, vec![faer::traits::math_utils::zero::<T>(); nnz]);
        let mem = MemBuffer::new(sparse_sparse_matmul_numeric_scratch::<usize, T>(c.symbolic(), faer::ParShape::Rayon(std::num::NonZeroUsize::new(6).unwrap())));
        let _ = one;
        let cp = a.symbolic().col_ptr();
        let flops: f64 = b.symbolic().row_idx().iter().map(|&k| (cp[k + 1] - cp[k]) as f64).sum();
        Self { a, b, c, info, mem, flops }
    }
}

impl Op for SpmmOp<f64> {
    fn run(&mut self, par: Par) {
        sparse_sparse_matmul_numeric(self.c.rb_mut(), Accum::Replace, self.a.as_ref(), self.b.as_ref(), 1.0, &self.info, par, MemStack::new(&mut self.mem));
    }
}

fn report(name: &str, n: usize, ns: f64, units: f64) {
    println!("{name},{n},{ns:.0},{units:.0},{:.5}", ns / units);
}

fn consts(group: &str) {
    println!("group,n,ns,units,ns_per_unit");
    let ms = 250;
    match group {
        "bsvd" => {
            // whole serial SVD is dominated by the bidiagonal solve for large n; the bidiagonal solve itself:
            for &m in &[64usize, 96, 128, 192, 256, 384, 512] {
                use faer::linalg::svd::bidiagonal_svd;
                let mut r = Rng(5);
                // bidiagonal of a Gaussian matrix: chi-like entries sqrt(m - i) (no deflation)
                let d0: Vec<f64> = (0..m).map(|i| ((m - i) as f64).sqrt() * (1.0 + 0.2 * r.next())).collect();
                let e: Vec<f64> = (0..m - 1).map(|i| ((m - 1 - i) as f64).sqrt() * (1.0 + 0.2 * r.next())).collect();
                let mut u = Mat::<f64>::zeros(m, m);
                let mut v = Mat::<f64>::zeros(m, m);
                let mut mem = MemBuffer::new(lsvd::bidiagonal_svd_scratch::<f64>(m, faer::ParShape::Seq, Spec::default()));
                let ns = median_ns(ms, 600, || {
                    let mut d = d0.clone();
                    bidiagonal_svd(&mut d, &e, true, u.as_mut(), v.as_mut(), Par::Seq, MemStack::new(&mut mem), Spec::default()).unwrap();
                });
                report("bsvd_f64", m, ns, (m * m * m) as f64);
            }
        }
        "tevd" => {
            for &m in &[64usize, 96, 128, 192, 256, 384, 512] {
                let mut r = Rng(6);
                // tridiagonal of a Gaussian symmetric matrix: N(0, 2) diagonal, chi-like off diagonal
                let d0: Vec<f64> = (0..m).map(|_| 2.0 * r.next()).collect();
                let e0: Vec<f64> = (0..m - 1).map(|i| ((m - 1 - i) as f64).sqrt() * (1.0 + 0.2 * r.next())).collect();
                let mut u = Mat::<f64>::zeros(m, m);
                let mut s = Mat::<f64>::zeros(m, 1);
                let mut mem = MemBuffer::new(evd::tridiagonal_self_adjoint_evd_scratch::<f64>(m, ComputeEigenvectors::Yes, faer::ParShape::Seq, Spec::default()));
                let ns = median_ns(ms, 600, || {
                    use faer::diag::{DiagRef, DiagMut};
                    let d = faer::col::ColRef::from_slice(&d0);
                    let e = faer::col::ColRef::from_slice(&e0);
                    // subdiagonal has m entries in the API; pad
                    let mut ep = e0.clone();
                    ep.push(0.0);
                    let ep = faer::col::ColRef::from_slice(&ep);
                    let _ = e;
                    evd::tridiagonal_self_adjoint_evd(d.as_diagonal(), ep.as_diagonal(), s.as_mut().col_mut(0).as_diagonal_mut(), Some(u.as_mut()), Par::Seq, MemStack::new(&mut mem), Spec::default()).unwrap();
                    let _: Option<(DiagRef<f64>, DiagMut<f64>)> = None;
                });
                report("tevd_f64", m, ns, (m * m * m) as f64);
            }
        }
        "tinv" => {
            for &m in &[64usize, 96, 128, 192, 256, 384, 512] {
                let mut op = TinvOp::new(m);
                let ns = median_ns(ms, 600, || op.run(Par::Seq));
                report("tinv_f64", m, ns, (m * m * m) as f64);
                let mut r = Rng(13);
                let mut src = Mat::<c64>::from_fn(m, m, |_, _| c64::new(r.next(), r.next()));
                for i in 0..m { src[(i, i)] = c64::new(2.0 + src[(i, i)].re.abs(), 0.1); }
                let mut dst = Mat::<c64>::zeros(m, m);
                let ns = median_ns(ms, 600, || invert_lower_triangular(dst.as_mut(), src.as_ref(), Par::Seq));
                report("tinv_c64", m, ns, (m * m * m) as f64);
            }
        }
        "spmm" => {
            for &(n, per) in &[(2000usize, 4usize), (2000, 12), (8000, 6), (8000, 16), (20000, 8), (4000, 40)] {
                let mut op = SpmmOp::<f64>::new(n, per, |r| r.next(), 1.0);
                let ns = median_ns(ms, 500, || {
                    sparse_sparse_matmul_numeric(op.c.rb_mut(), Accum::Replace, op.a.as_ref(), op.b.as_ref(), 1.0, &op.info, Par::Seq, MemStack::new(&mut op.mem));
                });
                report(&format!("spmm_f64_n{n}_d{per}"), n, ns, op.flops);
                let mut op = SpmmOp::<c64>::new(n, per, |r| c64::new(r.next(), r.next()), c64::new(1.0, 0.0));
                let ns = median_ns(ms, 500, || {
                    sparse_sparse_matmul_numeric(op.c.rb_mut(), Accum::Replace, op.a.as_ref(), op.b.as_ref(), c64::new(1.0, 0.0), &op.info, Par::Seq, MemStack::new(&mut op.mem));
                });
                report(&format!("spmm_c64_n{n}_d{per}"), n, ns, op.flops);
            }
        }
        _ => panic!("group"),
    }
}

fn rounds(op: &mut dyn Op, plain: Par, team: &mut Par) -> [f64; 3] {
    let mut res: [Vec<f64>; 3] = [vec![], vec![], vec![]];
    for _ in 0..7 {
        for slot in 0..3 {
            let mut one = |op: &mut dyn Op, par: Par| {
                prime(40, || op.run(par_clone(&par)));
                let mut v = vec![];
                let t0 = Instant::now();
                while v.len() < 15 || (t0.elapsed().as_millis() < 120 && v.len() < 400) {
                    let s = Instant::now();
                    op.run(par_clone(&par));
                    v.push(s.elapsed().as_nanos() as f64);
                }
                v.sort_by(|a, b| a.partial_cmp(b).unwrap());
                v[v.len() / 2]
            };
            let t = match slot {
                0 => one(op, Par::Seq),
                1 => one(op, par_clone(&plain)),
                _ => {
                    let mut tt = team.reborrow();
                    prime(40, || op.run(tt.reborrow()));
                    let mut v = vec![];
                    let t0 = Instant::now();
                    while v.len() < 15 || (t0.elapsed().as_millis() < 120 && v.len() < 400) {
                        let s = Instant::now();
                        op.run(tt.reborrow());
                        v.push(s.elapsed().as_nanos() as f64);
                    }
                    v.sort_by(|a, b| a.partial_cmp(b).unwrap());
                    v[v.len() / 2]
                },
            };
            res[slot].push(t);
        }
    }
    let med = |v: &mut Vec<f64>| { v.sort_by(|a, b| a.partial_cmp(b).unwrap()); v[v.len() / 2] };
    [med(&mut res[0]), med(&mut res[1]), med(&mut res[2])]
}
fn par_clone<'a>(p: &Par<'_>) -> Par<'a> {
    match p {
        Par::Seq => Par::Seq,
        Par::Rayon(n) => Par::Rayon(*n),
        _ => panic!("clone of a team"),
    }
}

fn tbl(family: &str, n: usize) {
    let plain = Par::rayon(6);
    with_team(6, |mut team| {
        let r = match family {
            "qr" => rounds(&mut QrOp::new(n), par_clone(&plain), &mut team),
            "svd" => rounds(&mut SvdOp::new(n), par_clone(&plain), &mut team),
            "evd" => rounds(&mut EvdOp::new(n), par_clone(&plain), &mut team),
            "tinv" => rounds(&mut TinvOp::new(n), par_clone(&plain), &mut team),
            // `n` is the dimension; 4 entries per column: 16 n flops
            "spmm" => rounds(&mut SpmmOp::<f64>::new(n, 4, |r| r.next(), 1.0), par_clone(&plain), &mut team),
            _ => panic!("family"),
        };
        println!("{family},{n},{:.0},{:.0},{:.0}", r[0], r[1], r[2]);
    });
}

fn main() {
    raise_current_thread_qos(Qos::UserInitiated);
    let a: Vec<String> = std::env::args().collect();
    match a[1].as_str() {
        "consts" => consts(&a[2]),
        "tbl" => tbl(&a[2], a[3].parse().unwrap()),
        _ => panic!(),
    }
}
