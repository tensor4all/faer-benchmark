//! Serial throughput constants for `faer::utils::cost::rate` (one thread; Linux port of the M5 recalibration probe: no QoS, plus f32/c32 GEMM and the partial pivoting LU rate).
//! Every number is ns per unit of work of the gate of the family: the whole serial operation
//! divided by the sum of the per-step units. Median of timed repetitions after a priming loop.
use faer::dyn_stack::{MemBuffer, MemStack};
use faer::linalg::cholesky::lblt::factor as bk;
use faer::linalg::evd::{hessenberg, tridiag};
use faer::linalg::householder;
use faer::linalg::lu::full_pivoting::factor as fplu;
use faer::linalg::matmul;
use faer::linalg::qr::col_pivoting::factor as cpqr;
use faer::linalg::svd::bidiag;
use faer::{c32, c64, Accum, Auto, Conj, Mat, MatRef, Par, Spec};
use std::time::Instant;


struct Rng(u64);
impl Rng {
    fn next(&mut self) -> f64 {
        self.0 ^= self.0 << 13;
        self.0 ^= self.0 >> 7;
        self.0 ^= self.0 << 17;
        (self.0 >> 11) as f64 / (1u64 << 53) as f64 - 0.5
    }
}
trait Gen: faer::traits::ComplexField + Clone {
    fn gen(r: &mut Rng) -> Self;
}
impl Gen for f64 {
    fn gen(r: &mut Rng) -> Self {
        r.next()
    }
}
impl Gen for c64 {
    fn gen(r: &mut Rng) -> Self {
        c64::new(r.next(), r.next())
    }
}
impl Gen for f32 {
    fn gen(r: &mut Rng) -> Self {
        r.next() as f32
    }
}
impl Gen for c32 {
    fn gen(r: &mut Rng) -> Self {
        c32::new(r.next() as f32, r.next() as f32)
    }
}
fn rand_mat<T: Gen>(m: usize, n: usize, seed: u64) -> Mat<T> {
    let mut r = Rng(seed | 1);
    Mat::from_fn(m, n, |_, _| T::gen(&mut r))
}

/// median ns of the timed part: `f` does its own reset and returns the ns of the operation
fn time_with(mut f: impl FnMut() -> f64) -> f64 {
    let t0 = Instant::now();
    while t0.elapsed().as_millis() < 250 {
        f();
    }
    let mut v = vec![];
    let t0 = Instant::now();
    while v.len() < 9 || (t0.elapsed().as_millis() < 600 && v.len() < 400) {
        v.push(f());
    }
    v.sort_by(|a, b| a.partial_cmp(b).unwrap());
    v[v.len() / 2]
}
macro_rules! time {
    ($reset:expr, $op:expr) => {
        time_with(|| {
            $reset;
            let s = Instant::now();
            $op;
            s.elapsed().as_nanos() as f64
        })
    };
}

fn sumsq(n: usize) -> f64 {
    // sum over steps of (n-k-1)^2
    (1..n).map(|r| (r * r) as f64).sum()
}

fn row(name: &str, ty: &str, n: usize, ns: f64, units: f64) {
    println!("{name},{ty},{n},{:.1},{:.0},{:.4}", ns, units, ns / units);
}

fn lu_full<T: Gen>(ty: &str, n: usize) {
    let a0 = rand_mat::<T>(n, n, 1);
    let mut a = a0.clone();
    let mut p = vec![0usize; 4 * n];
    let mut stack = MemBuffer::new(fplu::lu_in_place_scratch::<usize, T>(n, n, Par::Seq.shape(), Default::default()));
    let ns = time!(a.copy_from(&a0), {
        let (r, rest) = p.split_at_mut(n);
        let (ri, rest) = rest.split_at_mut(n);
        let (c, ci) = rest.split_at_mut(n);
        fplu::lu_in_place(a.as_mut(), r, ri, c, &mut ci[..n], Par::Seq, MemStack::new(&mut stack), Default::default());
    });
    row("lu_full_pivot", ty, n, ns, sumsq(n));
}
fn bk_full<T: Gen>(ty: &str, n: usize) {
    let a0 = {
        let m = rand_mat::<T>(n, n, 2);
        &m + m.adjoint()
    };
    let mut a = a0.clone();
    let mut perm = vec![0usize; n];
    let mut perm_inv = vec![0usize; n];
    let mut sub = Mat::<T>::zeros(n, 1);
    let mut params: bk::LbltParams = Auto::<T>::auto();
    params.pivoting = bk::PivotingStrategy::Full;
    let mut stack = MemBuffer::new(bk::cholesky_in_place_scratch::<usize, T>(n, Par::Seq.shape(), params.into()));
    let ns = time!(a.copy_from(&a0), {
        bk::cholesky_in_place(a.as_mut(), sub.as_mut().col_mut(0).as_diagonal_mut(), &mut perm, &mut perm_inv, Par::Seq, MemStack::new(&mut stack), params.into());
    });
    row("bunch_kaufman_full", ty, n, ns, sumsq(n));
}
fn qr_cp<T: Gen>(ty: &str, n: usize) {
    let a0 = rand_mat::<T>(n, n, 3);
    let mut a = a0.clone();
    let bs = 32;
    let mut h = Mat::<T>::zeros(bs, n);
    let mut p = vec![0usize; n];
    let mut pi = vec![0usize; n];
    let mut stack = MemBuffer::new(cpqr::qr_in_place_scratch::<usize, T>(n, n, bs, Par::Seq.shape(), Default::default()));
    let ns = time!(a.copy_from(&a0), {
        cpqr::qr_in_place(a.as_mut(), h.as_mut(), &mut p, &mut pi, Par::Seq, MemStack::new(&mut stack), Default::default());
    });
    row("qr_col_pivot", ty, n, ns, sumsq(n));
}
fn bidiag_t<T: Gen>(ty: &str, n: usize) {
    let a0 = rand_mat::<T>(n, n, 4);
    let mut a = a0.clone();
    let bs = 16;
    let mut hl = Mat::<T>::zeros(bs, n);
    let mut hr = Mat::<T>::zeros(bs, n - 1);
    let mut stack = MemBuffer::new(bidiag::bidiag_in_place_scratch::<T>(n, n, Par::Seq.shape(), Default::default()));
    let ns = time!(a.copy_from(&a0), {
        bidiag::bidiag_in_place(a.as_mut(), hl.as_mut(), hr.as_mut(), Par::Seq, MemStack::new(&mut stack), Default::default());
    });
    row("bidiag", ty, n, ns, sumsq(n));
}
fn hess<T: Gen>(ty: &str, n: usize) {
    let a0 = rand_mat::<T>(n, n, 5);
    let mut a = a0.clone();
    let bs = 16;
    let mut h = Mat::<T>::zeros(bs, n - 1);
    let mut params: hessenberg::HessenbergParams = Auto::<T>::auto();
    params.blocking_threshold = usize::MAX; // unblocked reduction, the one with the gate
    let mut stack = MemBuffer::new(hessenberg::hessenberg_in_place_scratch::<T>(n, bs, Par::Seq.shape(), params.into()));
    let ns = time!(a.copy_from(&a0), {
        hessenberg::hessenberg_in_place(a.as_mut(), h.as_mut(), Par::Seq, MemStack::new(&mut stack), params.into());
    });
    row("hessenberg_unblocked", ty, n, ns, sumsq(n));
}
fn trid<T: Gen>(ty: &str, n: usize) {
    let a0 = {
        let m = rand_mat::<T>(n, n, 6);
        &m + m.adjoint()
    };
    let mut a = a0.clone();
    let bs = 16;
    let mut h = Mat::<T>::zeros(bs, n - 1);
    let mut stack = MemBuffer::new(tridiag::tridiag_in_place_scratch::<T>(n, Par::Seq.shape(), Default::default()));
    let ns = time!(a.copy_from(&a0), {
        tridiag::tridiag_in_place(a.as_mut(), h.as_mut(), Par::Seq, MemStack::new(&mut stack), Default::default());
    });
    row("tridiag", ty, n, ns, sumsq(n) / 2.0);
}
fn matvec<T: Gen>(ty: &str, n: usize, rowmajor: bool) {
    let a = rand_mat::<T>(n, n, 7);
    let x = rand_mat::<T>(n, 1, 8);
    let mut y = Mat::<T>::zeros(n, 1);
    let one = T::one_impl();
    let ns = time!((), {
        let lhs: MatRef<'_, T> = if rowmajor { a.as_ref().transpose() } else { a.as_ref() };
        matmul::matmul(y.as_mut(), Accum::Replace, lhs, x.as_ref(), one.clone(), Par::Seq);
    });
    row(if rowmajor { "matvec_rowmajor" } else { "matvec_colmajor" }, ty, n, ns, (n * n) as f64);
}
fn rank_one<T: Gen>(ty: &str, m: usize, k: usize) {
    // N == 1 block Householder apply from the left, M x K target
    let basis = rand_mat::<T>(m, 1, 9);
    let mut fac = Mat::<T>::zeros(1, 1);
    fac[(0, 0)] = T::one_impl() + T::one_impl();
    let t0 = rand_mat::<T>(m, k, 10);
    let mut t = t0.clone();
    let mut stack = MemBuffer::new(householder::apply_block_householder_on_the_left_in_place_scratch::<T>(m, 1, k));
    let ns = time!(t.copy_from(&t0), {
        householder::apply_block_householder_on_the_left_in_place_with_conj(basis.as_ref(), fac.as_ref(), Conj::No, t.as_mut(), Par::Seq, MemStack::new(&mut stack));
    });
    row("householder_rank_one", ty, m * 1000 + k, ns, (m * k) as f64);
}
fn block_apply<T: Gen>(ty: &str, m: usize, nb: usize, k: usize) {
    // N = nb block apply, to compare against the GEMM rate: 2*M*N*K multiply-adds
    let basis = rand_mat::<T>(m, nb, 11);
    let fac = {
        let mut f = Mat::<T>::zeros(nb, nb);
        for i in 0..nb { for j in i..nb { f[(i, j)] = if i == j { T::one_impl() + T::one_impl() } else { T::zero_impl() }; } }
        f
    };
    let t0 = rand_mat::<T>(m, k, 12);
    let mut t = t0.clone();
    let mut stack = MemBuffer::new(householder::apply_block_householder_on_the_left_in_place_scratch::<T>(m, nb, k));
    let ns = time!(t.copy_from(&t0), {
        householder::apply_block_householder_on_the_left_in_place_with_conj(basis.as_ref(), fac.as_ref(), Conj::No, t.as_mut(), Par::Seq, MemStack::new(&mut stack));
    });
    row("block_apply_per_mac", ty, m * 1000000 + nb * 1000 + k, ns, 2.0 * (m * nb * k) as f64);
}
fn tri_mat<T: Gen>(ty: &str, n: usize) {
    use faer::linalg::matmul::triangular::{matmul as tmatmul, BlockStructure};
    let l = rand_mat::<T>(n, n, 13);
    let b = rand_mat::<T>(n, n, 14);
    let mut c = Mat::<T>::zeros(n, n);
    let ns = time!((), {
        tmatmul(c.as_mut(), BlockStructure::Rectangular, Accum::Replace, l.as_ref(), BlockStructure::TriangularLower, b.as_ref(), BlockStructure::Rectangular, T::one_impl(), Par::Seq);
    });
    row("triangular_matmul_per_mac", ty, n, ns, (n * n * n) as f64 / 2.0);
}
fn tri_solve<T: Gen>(ty: &str, n: usize, k: usize) {
    use faer::linalg::triangular_solve::solve_lower_triangular_in_place;
    let mut l = rand_mat::<T>(n, n, 15);
    for i in 0..n { l[(i, i)] = T::from_f64_impl(n as f64); }
    let b0 = rand_mat::<T>(n, k, 16);
    let mut b = b0.clone();
    let ns = time!(b.copy_from(&b0), {
        solve_lower_triangular_in_place(l.as_ref(), b.as_mut(), Par::Seq);
    });
    row("triangular_solve_per_mac", ty, n * 1000 + k, ns, (n * n * k) as f64 / 2.0);
}
/// Partial pivoting LU, the whole serial factorization, units = flops `2/3 n^3` (thresholds.md 2.3 "faer LU f64").
fn lu_partial<T: Gen>(ty: &str, n: usize) {
    use faer::linalg::lu::partial_pivoting::factor as pplu;
    let a0 = rand_mat::<T>(n, n, 19);
    let mut a = a0.clone();
    let mut p = vec![0usize; n];
    let mut pi = vec![0usize; n];
    let mut stack = MemBuffer::new(pplu::lu_in_place_scratch::<usize, T>(n, n, Par::Seq.shape(), Default::default()));
    let ns = time!(a.copy_from(&a0), {
        pplu::lu_in_place(a.as_mut(), &mut p, &mut pi, Par::Seq, MemStack::new(&mut stack), Default::default());
    });
    row("lu_partial_per_flop", ty, n, ns, 2.0 / 3.0 * (n * n * n) as f64);
}
fn gemm<T: Gen>(ty: &str, n: usize) {
    let a = rand_mat::<T>(n, n, 17);
    let b = rand_mat::<T>(n, n, 18);
    let mut c = Mat::<T>::zeros(n, n);
    let ns = time!((), {
        matmul::matmul(c.as_mut(), Accum::Replace, a.as_ref(), b.as_ref(), T::one_impl(), Par::Seq);
    });
    row("gemm_per_mac", ty, n, ns, (n * n * n) as f64);
}

fn main() {
    let only: Vec<String> = std::env::args().skip(1).collect();
    let want = |s: &str| only.is_empty() || only.iter().any(|o| o == s);
    println!("name,type,shape,ns_per_call,units,ns_per_unit");
    macro_rules! both { ($f:ident, $($a:expr),*) => { $f::<f64>("f64", $($a),*); $f::<c64>("c64", $($a),*); } }
    if want("gemm") { for n in [64, 96, 128, 256] { both!(gemm, n); gemm::<f32>("f32", n); gemm::<c32>("c32", n); } }
    if want("lu_partial") { for n in [64, 128, 256, 768] { both!(lu_partial, n); } }
    if want("lu_full") { for n in [96, 128, 192, 256, 384] { both!(lu_full, n); } }
    if want("bk") { for n in [96, 128, 192, 256, 384] { both!(bk_full, n); } }
    if want("qr_cp") { for n in [96, 128, 192, 256, 384] { both!(qr_cp, n); } }
    if want("bidiag") { for n in [96, 128, 192, 256, 384] { both!(bidiag_t, n); } }
    if want("hess") { for n in [96, 128, 192, 224] { both!(hess, n); } }
    if want("tridiag") { for n in [96, 128, 192, 256, 384] { both!(trid, n); } }
    if want("matvec") { for n in [128, 256, 384, 512, 768] { both!(matvec, n, false); both!(matvec, n, true); } }
    if want("rank_one") { for (m, k) in [(256, 256), (512, 256), (1024, 128), (2048, 64)] { both!(rank_one, m, k); } }
    if want("block_apply") { for (m, nb, k) in [(512, 16, 256), (1024, 32, 256), (512, 32, 512)] { both!(block_apply, m, nb, k); } }
    if want("tri") { for n in [128, 256, 384] { both!(tri_mat, n); } for (n, k) in [(64, 256), (128, 512)] { both!(tri_solve, n, k); } }
}
