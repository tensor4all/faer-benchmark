//! Decision trace and region timings (M5, QoS UserInitiated). Modes: `trace`, `qr`.
use faer::dyn_stack::{MemBuffer, MemStack};
use faer::linalg::qr::no_pivoting::factor as qrf;
use faer::utils::cost::trace;
use faer::{Mat, Par};
use std::collections::BTreeMap;
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
pub fn rand_mat(m: usize, n: usize, seed: u64) -> Mat<f64> {
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
pub fn median_ns(prime_ms: u128, mut f: impl FnMut()) -> f64 {
    prime(prime_ms, &mut f);
    let mut v = vec![];
    let t = Instant::now();
    while v.len() < 21 || (t.elapsed().as_millis() < 400 && v.len() < 4000) {
        let s = Instant::now();
        f();
        v.push(s.elapsed().as_nanos() as f64);
    }
    v.sort_by(|a, b| a.partial_cmp(b).unwrap());
    v[v.len() / 2]
}

fn qr_once(n: usize, par: Par, a0: &Mat<f64>, a: &mut Mat<f64>, qc: &mut Mat<f64>, mem: &mut MemBuffer) {
    a.as_mut().copy_from(a0.as_ref());
    qc.as_mut().fill(0.0);
    qrf::qr_in_place(a.as_mut(), qc.as_mut(), par, MemStack::new(mem), Default::default());
    let _ = n;
}

pub trait Gen: faer::traits::ComplexField + Clone {
    fn gen(r: &mut Rng) -> Self;
    fn diag(i: usize) -> Self;
}
impl Gen for f64 {
    fn gen(r: &mut Rng) -> Self { r.next() }
    fn diag(i: usize) -> Self { 2.0 + i as f64 * 0.01 }
}
impl Gen for faer::c64 {
    fn gen(r: &mut Rng) -> Self { faer::c64::new(r.next(), r.next()) }
    fn diag(i: usize) -> Self { faer::c64::new(2.0 + i as f64 * 0.01, 0.1) }
}
fn gmat<T: Gen>(m: usize, n: usize, seed: u64) -> Mat<T> {
    let mut r = Rng(seed | 1);
    Mat::from_fn(m, n, |_, _| T::gen(&mut r))
}

/// serial and forced-parallel time of a block apply, copy of the target subtracted
fn apply_times<T: Gen>(m: usize, nb: usize, k: usize, par: &mut Par, prime_ms: u128) -> (f64, f64) {
    use faer::linalg::householder::*;
    use faer::Conj;
    use std::sync::atomic::Ordering;
    let basis = gmat::<T>(m, nb, 1);
    let mut factor = gmat::<T>(nb, nb, 2);
    for i in 0..nb { factor[(i, i)] = T::diag(i); }
    let t0 = gmat::<T>(m, k, 3);
    let mut t = t0.clone();
    let mut tc = t0.clone();
    let mut mem = MemBuffer::new(apply_block_householder_on_the_left_in_place_scratch::<T>(m, nb, k));
    let copy = median_ns(prime_ms, || tc.as_mut().copy_from(t0.as_ref()));
    trace::N_TASKS_MODE.store(0, Ordering::SeqCst);
    let s = median_ns(prime_ms, || {
        t.as_mut().copy_from(t0.as_ref());
        apply_block_householder_on_the_left_in_place_with_conj(basis.as_ref(), factor.as_ref(), Conj::No, t.as_mut(), Par::Seq, MemStack::new(&mut mem));
    }) - copy;
    trace::N_TASKS_MODE.store(2, Ordering::SeqCst);
    let p = median_ns(prime_ms, || {
        t.as_mut().copy_from(t0.as_ref());
        apply_block_householder_on_the_left_in_place_with_conj(basis.as_ref(), factor.as_ref(), Conj::No, t.as_mut(), par.reborrow(), MemStack::new(&mut mem));
    }) - copy;
    trace::N_TASKS_MODE.store(0, Ordering::SeqCst);
    (s, p)
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let mode = args.get(1).map(String::as_str).unwrap_or("trace");
    let n: usize = args.get(2).and_then(|s| s.parse().ok()).unwrap_or(128);
    let prime_ms: u128 = args.iter().position(|a| a == "--prime-ms").map(|i| args[i + 1].parse().unwrap()).unwrap_or(250);
    let bs = qrf::recommended_block_size::<f64>(n, n);
    let a0 = rand_mat(n, n, 7);
    let mut a = a0.clone();
    let mut qc = Mat::<f64>::zeros(bs, n);
    let par_dummy = Par::Seq;
    let mut mem = MemBuffer::new(qrf::qr_in_place_scratch::<f64>(n, n, bs, par_dummy.shape(), Default::default()));
    match mode {
        "trace" => with_team(6, |mut par| {
            for _ in 0..20 {
                qr_once(n, par.reborrow(), &a0, &mut a, &mut qc, &mut mem);
            }
            trace::enable(true);
            qr_once(n, par.reborrow(), &a0, &mut a, &mut qc, &mut mem);
            trace::enable(false);
            let log = trace::take();
            println!("block_size={bs} records={}", log.len());
            println!("site,dims,count,parallel,units,sections,estimate_ns,dispatch_ns");
            let mut agg: BTreeMap<(String, [usize; 3]), (usize, usize, usize, u32, f64, f64)> = BTreeMap::new();
            for r in &log {
                let e = agg.entry((r.site.to_string(), r.dims)).or_default();
                e.0 += 1;
                e.1 += r.parallel as usize;
                e.2 = r.units;
                e.3 = r.sections;
                e.4 = r.estimate_ns;
                e.5 = r.dispatch_ns;
            }
            for ((site, d), v) in agg {
                println!("{site},{}x{}x{},{},{},{},{},{:.0},{:.0}", d[0], d[1], d[2], v.0, v.1, v.2, v.3, v.4, v.5);
            }
        }),
        "qr" => {
            let s = median_ns(prime_ms, || qr_once(n, Par::Seq, &a0, &mut a, &mut qc, &mut mem));
            println!("qr,{n},serial,{:.0}", s);
            let t = with_team(6, |mut par| {
                let mut best = vec![];
                for _ in 0..9 {
                    best.push(median_ns(prime_ms.min(60), || qr_once(n, par.reborrow(), &a0, &mut a, &mut qc, &mut mem)));
                }
                best.sort_by(|a, b| a.partial_cmp(b).unwrap());
                best[best.len() / 2]
            });
            println!("qr,{n},team6,{:.0}", t);
        }
        "modes" => {
            // whole QR on a team of 6 under the gate modes, interleaved, plus serial
            use std::sync::atomic::Ordering;
            let rounds = 9;
            let mut res: Vec<Vec<f64>> = vec![vec![]; 4];
            with_team(6, |mut par| {
                prime(prime_ms, || qr_once(n, par.reborrow(), &a0, &mut a, &mut qc, &mut mem));
                for _ in 0..rounds {
                    for (slot, mode) in [(0usize, 0usize), (1, 1), (2, 3)] {
                        trace::N_TASKS_MODE.store(mode, Ordering::SeqCst);
                        prime(40, || qr_once(n, par.reborrow(), &a0, &mut a, &mut qc, &mut mem));
                        let mut v = vec![];
                        for _ in 0..200 {
                            let t = Instant::now();
                            qr_once(n, par.reborrow(), &a0, &mut a, &mut qc, &mut mem);
                            v.push(t.elapsed().as_nanos() as f64);
                        }
                        v.sort_by(|a, b| a.partial_cmp(b).unwrap());
                        res[slot].push(v[v.len() / 2]);
                    }
                    prime(40, || qr_once(n, Par::Seq, &a0, &mut a, &mut qc, &mut mem));
                    let mut v = vec![];
                    for _ in 0..200 {
                        let t = Instant::now();
                        qr_once(n, Par::Seq, &a0, &mut a, &mut qc, &mut mem);
                        v.push(t.elapsed().as_nanos() as f64);
                    }
                    v.sort_by(|a, b| a.partial_cmp(b).unwrap());
                    res[3].push(v[v.len() / 2]);
                }
            });
            for (name, v) in ["team_rule", "team_prev_rule", "team_never_ntasks", "serial"].iter().zip(res.iter_mut()) {
                v.sort_by(|a, b| a.partial_cmp(b).unwrap());
                println!("qrmodes,{n},{name},{:.0},min {:.0},max {:.0}", v[v.len() / 2], v[0], v[v.len() - 1]);
            }
        }
        "apply" => {
            use faer::linalg::householder::*;
            use faer::Conj;
            use std::sync::atomic::Ordering;
            println!("region,M,N,K,serial_ns,team_forced_ns,team_never_ns,estimate_ns,dispatch_ns,rule");
            let shapes: Vec<(usize, usize, usize)> = (3..=16).map(|i| (8 * i, 8, 8 * i - 8)).collect();
            with_team(6, |mut par| {
                for (m, nb, k) in shapes {
                    let basis = rand_mat(m, nb, 1);
                    let mut factor = rand_mat(nb, nb, 2);
                    for i in 0..nb { factor[(i, i)] = 2.0 + i as f64 * 0.01; }
                    let t0 = rand_mat(m, k, 3);
                    let mut t = t0.clone();
                    let mut mem = MemBuffer::new(apply_block_householder_on_the_left_in_place_scratch::<f64>(m, nb, k));
                    let mut run = |mut par: Par, mode: usize, ms: u128| {
                        trace::N_TASKS_MODE.store(mode, Ordering::SeqCst);
                        median_ns(ms, || {
                            t.as_mut().copy_from(t0.as_ref());
                            apply_block_householder_on_the_left_in_place_with_conj(basis.as_ref(), factor.as_ref(), Conj::No, t.as_mut(), par.reborrow(), MemStack::new(&mut mem));
                        })
                    };
                    let _ = &mut par;
                    // the copy of the target is in every time; measure it alone and subtract
                    let mut tc = t0.clone();
                    let copy = median_ns(prime_ms, || tc.as_mut().copy_from(t0.as_ref()));
                    let s = run(Par::Seq, 0, prime_ms) - copy;
                    let p = run(par.reborrow(), 2, prime_ms) - copy;
                    let q = run(par.reborrow(), 3, prime_ms) - copy;
                    drop(run);
                    trace::enable(true);
                    trace::N_TASKS_MODE.store(0, Ordering::SeqCst);
                    t.as_mut().copy_from(t0.as_ref());
                    apply_block_householder_on_the_left_in_place_with_conj(basis.as_ref(), factor.as_ref(), Conj::No, t.as_mut(), par.reborrow(), MemStack::new(&mut mem));
                    trace::enable(false);
                    let log = trace::take();
                    let r = log.iter().find(|r| r.site == "n_tasks");
                    let (e, d, dec) = r.map(|r| (r.estimate_ns, r.dispatch_ns, r.parallel)).unwrap_or((0.0, 0.0, false));
                    println!("block_apply,{m},{nb},{k},{s:.0},{p:.0},{q:.0},{e:.0},{d:.0},{dec}");
                }
            });
        }
        "applyrate" => {
            println!("dtype,M,N,K,serial_ns,team_forced_ns,ns_per_2MNK");
            with_team(6, |mut par| {
                for &nb in &[2usize, 4, 8, 16, 32] {
                    for &m in &[64usize, 128, 256, 512] {
                        let k = m - nb;
                        let (s, p) = apply_times::<f64>(m, nb, k, &mut par, 100);
                        println!("f64,{m},{nb},{k},{s:.0},{p:.0},{:.4}", s / (2.0 * (m * nb * k) as f64));
                        let (s, p) = apply_times::<faer::c64>(m, nb, k, &mut par, 100);
                        println!("c64,{m},{nb},{k},{s:.0},{p:.0},{:.4}", s / (2.0 * (m * nb * k) as f64));
                    }
                }
            });
        }
        "trimm" => {
            use faer::linalg::matmul::triangular::{matmul, BlockStructure};
            println!("m,n,units,est_ns,serial_ns,team_ns");
            with_team(6, |mut par| {
                for &sz in &[48usize, 56, 64, 72, 80, 96, 112, 128, 192] {
                    let lhs = rand_mat(sz, sz, 1);
                    let rhs = rand_mat(sz, sz, 2);
                    let mut dst = Mat::<f64>::zeros(sz, sz);
                    let s = median_ns(150, || matmul(dst.as_mut(), BlockStructure::Rectangular, faer::Accum::Replace, lhs.as_ref(), BlockStructure::Rectangular, rhs.as_ref(), BlockStructure::TriangularLower, 1.0, Par::Seq));
                    let t = median_ns(150, || matmul(dst.as_mut(), BlockStructure::Rectangular, faer::Accum::Replace, lhs.as_ref(), BlockStructure::Rectangular, rhs.as_ref(), BlockStructure::TriangularLower, 1.0, par.reborrow()));
                    let units = sz * sz * sz / 2;
                    println!("{sz},{sz},{units},{:.0},{s:.0},{t:.0}", units as f64 * 0.0364);
                }
            });
        }
        "tinv" => {
            use faer::linalg::triangular_inverse::invert_lower_triangular;
            let mut src = rand_mat(n, n, 13);
            for i in 0..n { src[(i, i)] = 2.0 + src[(i, i)].abs(); }
            let mut dst = Mat::<f64>::zeros(n, n);
            with_team(6, |mut par| {
                for _ in 0..200 { invert_lower_triangular(dst.as_mut(), src.as_ref(), par.reborrow()); }
                trace::enable(true);
                invert_lower_triangular(dst.as_mut(), src.as_ref(), par.reborrow());
                trace::enable(false);
                for r in trace::take() {
                    println!("{},{},{},{:.0},{:.0},{}", r.site, r.units, r.sections, r.estimate_ns, r.dispatch_ns, r.parallel);
                }
            });
        }
        _ => panic!("mode"),
    }
}
