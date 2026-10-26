//! QR 128 on Linux: decision trace, section counters, gate-mode timings (tensor4all-meta#51).
//!
//! Usage:
//!   qr128 trace  <team|rayon> <width> [n] [--table linux|generic] [--detail]
//!   qr128 counts <width> [n] [--table linux|generic|scale:<f>]      (team section counters per factorization)
//!   qr128 time   <width> [n] [--ms <window ms>] [--modes m1,m2,..]   (timing; the coordinator runs this)
//!   qr128 apply  <width> [--ms <ms>] [--table ..]                    (block apply M x 8 x (M-8): serial / never / forced; --only M)
//!   qr128 anatomy <width> [--m 128] [--reps 1500] [--leader-writes 0|1]  (wake / compute / join of one hand split apply)
//! Modes of `time`: seq, rayon, team-linux, team-generic, team-serial (every gate false), team-par (every gate true),
//! team-pays1 (PAYS = 1: costs / 3), team-ntasks-always, team-ntasks-never (block apply column split forced).
use faer::dyn_stack::{MemBuffer, MemStack};
use faer::linalg::qr::no_pivoting::factor as qrf;
use faer::utils::cost::trace;
use faer::utils::team::stats;
use faer::{Mat, Par};
use std::collections::BTreeMap;
use std::time::{Duration, Instant};
use threadteam::{DispatchCosts, DispatchKind, Pool, Qos, WidthCosts};

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

fn us(x: f64) -> Duration {
    Duration::from_secs_f64(x * 1e-6)
}
/// costs of the team kind: Linux row (2.8/2.2/1.7 us), generic (3 us flat), scaled Linux row
fn table(spec: &str) -> DispatchCosts {
    let base = DispatchCosts::linux_x86();
    match spec {
        "linux" => base,
        "generic" => DispatchCosts::generic(),
        s if s.starts_with("scale:") => {
            let f: f64 = s[6..].parse().unwrap();
            base.with(DispatchKind::Team, WidthCosts::new([us(2.8 * f), us(2.2 * f), us(1.7 * f)]))
        }
        _ => panic!("table {spec}"),
    }
}

fn with_team<R>(threads: usize, costs: DispatchCosts, f: impl FnOnce(Par) -> R) -> R {
    let pool = Pool::builder()
        .threads(threads)
        .qos(Qos::UserInitiated)
        .dispatch_costs(costs)
        .acquire_timeout(Duration::from_secs(30))
        .build()
        .unwrap();
    let team = pool.into_team(threads).unwrap();
    let mut exec = team.exec(threads);
    let mut f = Some(f);
    exec.team(|mut t| (f.take().unwrap())(Par::Team(t.reborrow()))).unwrap()
}

struct Qr {
    n: usize,
    a0: Mat<f64>,
    a: Mat<f64>,
    qc: Mat<f64>,
    mem: MemBuffer,
}
impl Qr {
    fn new(n: usize) -> Self {
        let bs = qrf::recommended_block_size::<f64>(n, n);
        let a0 = rand_mat(n, n, 7);
        let mem = MemBuffer::new(qrf::qr_in_place_scratch::<f64>(n, n, bs, Par::Seq.shape(), Default::default()));
        Qr { n, a: a0.clone(), a0, qc: Mat::zeros(bs, n), mem }
    }
    fn once(&mut self, par: Par) {
        self.a.as_mut().copy_from(self.a0.as_ref());
        self.qc.as_mut().fill(0.0);
        qrf::qr_in_place(self.a.as_mut(), self.qc.as_mut(), par, MemStack::new(&mut self.mem), Default::default());
        let _ = self.n;
    }
}

fn median_ns(window_ms: u128, mut f: impl FnMut()) -> f64 {
    let t = Instant::now();
    while t.elapsed().as_millis() < window_ms / 2 {
        f();
    }
    let mut v = vec![];
    let t = Instant::now();
    while v.len() < 21 || (t.elapsed().as_millis() < window_ms && v.len() < 20000) {
        let s = Instant::now();
        f();
        v.push(s.elapsed().as_nanos() as f64);
    }
    v.sort_by(|a, b| a.partial_cmp(b).unwrap());
    v[v.len() / 2]
}

fn flag(args: &[String], name: &str) -> Option<String> {
    args.iter().position(|a| a == name).map(|i| args[i + 1].clone())
}

fn print_trace(log: &[trace::Record], detail: bool) {
    // (site, dims) aggregate
    let mut agg: BTreeMap<(String, [usize; 3]), (usize, usize, usize, u32, f64, f64)> = BTreeMap::new();
    let mut by_site: BTreeMap<String, (usize, usize, f64, f64)> = BTreeMap::new();
    for r in log {
        let e = agg.entry((r.site.to_string(), r.dims)).or_default();
        e.0 += 1;
        e.1 += r.parallel as usize;
        e.2 = r.units;
        e.3 = r.sections;
        e.4 = r.estimate_ns;
        e.5 = r.dispatch_ns;
        let s = by_site.entry(r.site.to_string()).or_default();
        s.0 += 1;
        s.1 += r.parallel as usize;
        s.2 += r.estimate_ns;
        if r.parallel {
            s.3 += r.estimate_ns;
        }
    }
    println!("# per site: decisions, parallel, sum of all estimates (us), sum of estimates of parallel ones (us)");
    println!("site,decisions,parallel,sum_est_us,sum_est_parallel_us");
    for (s, v) in &by_site {
        println!("{s},{},{},{:.2},{:.2}", v.0, v.1, v.2 / 1e3, v.3 / 1e3);
    }
    // recomputed decisions under other tables: est >= 3 * sections * D
    let mut gen_team = 0;
    let mut gen_out = 0;
    for r in log {
        if r.estimate_ns >= 3.0 * r.sections as f64 * 3000.0 {
            gen_team += 1;
        }
        if r.estimate_ns >= 3.0 * r.sections as f64 * 40000.0 {
            gen_out += 1;
        }
    }
    println!(
        "# records={} parallel_now={} would_be_parallel: generic team 3us flat={} generic outside 40us flat={}",
        log.len(),
        log.iter().filter(|r| r.parallel).count(),
        gen_team,
        gen_out
    );
    if detail {
        println!("site,dims,count,parallel,units,sections,estimate_ns,dispatch_ns,est_over_3D");
        for ((site, d), v) in agg {
            println!(
                "{site},{}x{}x{},{},{},{},{},{:.0},{:.0},{:.2}",
                d[0], d[1], d[2], v.0, v.1, v.2, v.3, v.4, v.5, v.4 / (3.0 * v.3 as f64 * v.5)
            );
        }
    }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let mode = args.get(1).map(String::as_str).unwrap_or("trace");
    let detail = args.iter().any(|a| a == "--detail");
    match mode {
        "trace" => {
            let kind = args[2].as_str();
            let w: usize = args[3].parse().unwrap();
            let n: usize = args.get(4).and_then(|s| s.parse().ok()).filter(|_| !args[4].starts_with("--")).unwrap_or(128);
            let tbl = flag(&args, "--table").unwrap_or("linux".into());
            let mut q = Qr::new(n);
            let run = |q: &mut Qr, mut par: Par| {
                for _ in 0..20 {
                    q.once(par.reborrow());
                }
                trace::enable(true);
                q.once(par.reborrow());
                trace::enable(false);
                trace::take()
            };
            let log = match kind {
                "team" => with_team(w, table(&tbl), |par| run(&mut q, par)),
                "rayon" => run(&mut q, Par::rayon(w)),
                _ => panic!("kind"),
            };
            println!("# QR {n} {kind} width {w} table {tbl}");
            print_trace(&log, detail);
        }
        "counts" => {
            let w: usize = args[2].parse().unwrap();
            let n: usize = args.get(3).and_then(|s| s.parse().ok()).filter(|_| !args[3].starts_with("--")).unwrap_or(128);
            let tbl = flag(&args, "--table").unwrap_or("linux".into());
            let reps = 200usize;
            let mut q = Qr::new(n);
            with_team(w, table(&tbl), |mut par| {
                for _ in 0..20 {
                    q.once(par.reborrow());
                }
                stats::take();
                stats::enable(true);
                for _ in 0..reps {
                    q.once(par.reborrow());
                }
                stats::enable(false);
                let s = stats::take();
                let per = |v: &Vec<usize>| {
                    v.iter()
                        .enumerate()
                        .filter(|(_, c)| **c > 0)
                        .map(|(i, c)| format!("{i}:{:.2}", *c as f64 / reps as f64))
                        .collect::<Vec<_>>()
                        .join(" ")
                };
                println!(
                    "# per factorization (QR {n}, team width {w}, table {tbl}, {reps} reps): run[{}] split[{}] gemm_tiled={:.2} gemm_one_tile={:.2} gemm_below_floor={:.2}",
                    per(&s.run),
                    per(&s.split),
                    s.gemm_tiled as f64 / reps as f64,
                    s.gemm_one_tile as f64 / reps as f64,
                    s.gemm_below_floor as f64 / reps as f64
                );
                let flat: usize = s.run.iter().enumerate().filter(|(i, _)| *i >= 2).map(|(_, c)| *c).sum();
                let spl: usize = s.split.iter().enumerate().filter(|(i, _)| *i >= 2).map(|(_, c)| *c).sum();
                println!("flat_sections_per_qr={:.2} splits_per_qr={:.2}", flat as f64 / reps as f64, spl as f64 / reps as f64);
            });
        }
        "time" => {
            let w: usize = args[2].parse().unwrap();
            let n: usize = args.get(3).and_then(|s| s.parse().ok()).filter(|_| !args[3].starts_with("--")).unwrap_or(128);
            let ms: u128 = flag(&args, "--ms").map(|s| s.parse().unwrap()).unwrap_or(300);
            let modes = flag(&args, "--modes").unwrap_or("seq,rayon,team-linux,team-generic,team-serial,team-par,team-pays1".into());
            for m in modes.split(',') {
                let mut q = Qr::new(n);
                trace::N_TASKS_MODE.store(0, std::sync::atomic::Ordering::SeqCst);
                let t = match m {
                    "seq" => median_ns(ms, || q.once(Par::Seq)),
                    "rayon" => median_ns(ms, || q.once(Par::rayon(w))),
                    other => {
                        let (tbl, nt) = match other {
                            "team-linux" => ("linux", 0),
                            "team-generic" => ("generic", 0),
                            "team-serial" => ("scale:1000000", 0),
                            "team-par" => ("scale:0", 0),
                            "team-pays1" => ("scale:0.3333333", 0),
                            "team-ntasks-always" => ("linux", 2),
                            "team-ntasks-never" => ("linux", 3),
                            _ => panic!("mode {other}"),
                        };
                        trace::N_TASKS_MODE.store(nt, std::sync::atomic::Ordering::SeqCst);
                        with_team(w, table(tbl), |mut par| median_ns(ms, || q.once(par.reborrow())))
                    }
                };
                println!("qr{n},{w}T,{m},{:.0} ns", t);
            }
        }
        "apply" => {
            // block apply M x 8 x (M-8) on a team: serial, team with the column split forbidden (n_tasks = 1: the
            // whole apply on the leader with the team token, so the GEMM route of the token is in it), and forced
            // parallel (n_tasks = width); copy of the target subtracted. One process, window per cell.
            use faer::linalg::householder::*;
            use faer::Conj;
            use std::sync::atomic::Ordering;
            let w: usize = args[2].parse().unwrap();
            let ms: u128 = flag(&args, "--ms").map(|s| s.parse().unwrap()).unwrap_or(150);
            let tbl = flag(&args, "--table").unwrap_or("linux".into());
            println!("# block apply, team width {w}, table {tbl}; ns");
            println!("M,N,K,serial_ns,team_never_ns,team_forced_ns,gain_forced_vs_serial_ns,estimate_ns,dispatch_ns,rule");
            with_team(w, table(&tbl), |mut par| {
                let only: Option<usize> = flag(&args, "--only").map(|s| s.parse().unwrap());
                for i in 3..=16usize {
                    if only.map_or(false, |o| o != 8 * i) {
                        continue;
                    }
                    let (m, nb, k) = (8 * i, 8usize, 8 * i - 8);
                    let basis = rand_mat(m, nb, 1);
                    let mut factor = rand_mat(nb, nb, 2);
                    for d in 0..nb {
                        factor[(d, d)] = 2.0 + d as f64 * 0.01;
                    }
                    let t0 = rand_mat(m, k, 3);
                    let mut t = t0.clone();
                    let mut mem = MemBuffer::new(apply_block_householder_on_the_left_in_place_scratch::<f64>(m, nb, k));
                    let mut tc = t0.clone();
                    let copy = median_ns(ms, || tc.as_mut().copy_from(t0.as_ref()));
                    let mut run = |par: Par, mode: usize| {
                        trace::N_TASKS_MODE.store(mode, Ordering::SeqCst);
                        let mut par = par;
                        median_ns(ms, || {
                            t.as_mut().copy_from(t0.as_ref());
                            apply_block_householder_on_the_left_in_place_with_conj(basis.as_ref(), factor.as_ref(), Conj::No, t.as_mut(), par.reborrow(), MemStack::new(&mut mem));
                        }) - copy
                    };
                    let s = run(Par::Seq, 0);
                    let nv = run(par.reborrow(), 3);
                    let fp = run(par.reborrow(), 2);
                    trace::N_TASKS_MODE.store(0, Ordering::SeqCst);
                    trace::enable(true);
                    t.as_mut().copy_from(t0.as_ref());
                    apply_block_householder_on_the_left_in_place_with_conj(basis.as_ref(), factor.as_ref(), Conj::No, t.as_mut(), par.reborrow(), MemStack::new(&mut mem));
                    trace::enable(false);
                    let log = trace::take();
                    let (e, d, dec) = log.iter().find(|r| r.site == "n_tasks").map(|r| (r.estimate_ns, r.dispatch_ns, r.parallel)).unwrap_or((0.0, 0.0, false));
                    println!("{m},{nb},{k},{s:.0},{nv:.0},{fp:.0},{:.0},{e:.0},{d:.0},{dec}", s - fp);
                }
            });
        }
        "anatomy" => {
            // One block apply M x 8 x (M-8), column split by hand over `Team::run` (one member per slice of columns, each
            // running the faer apply on its slice with Par::Seq). Per repetition: the leader writes the target (as the
            // panel/copy before a region does), then the region runs. Prints medians of: wake (member start - leader
            // start), compute (member end - member start), join (leader back - last member end), total, and the serial
            // apply on the leader and the apply of a 1/w slice on the leader alone (the ideal per-member compute).
            use faer::linalg::householder::*;
            use faer::Conj;
            use std::sync::atomic::{AtomicU64, Ordering};
            use std::sync::Mutex;
            let w: usize = args[2].parse().unwrap();
            let m: usize = flag(&args, "--m").map(|s| s.parse().unwrap()).unwrap_or(128);
            let reps: usize = flag(&args, "--reps").map(|s| s.parse().unwrap()).unwrap_or(1500);
            let touch = flag(&args, "--leader-writes").map(|s| s != "0").unwrap_or(true);
            let tbl = flag(&args, "--table").unwrap_or("linux".into());
            let (nb, k) = (8usize, m - 8);
            let basis = rand_mat(m, nb, 1);
            let mut factor = rand_mat(nb, nb, 2);
            for d in 0..nb {
                factor[(d, d)] = 2.0 + d as f64 * 0.01;
            }
            let t0 = rand_mat(m, k, 3);
            let mut t = t0.clone();
            let mems: Vec<Mutex<MemBuffer>> = (0..w).map(|_| Mutex::new(MemBuffer::new(apply_block_householder_on_the_left_in_place_scratch::<f64>(m, nb, k)))).collect();
            let base = Instant::now();
            let now = || base.elapsed().as_nanos() as u64;
            let z = || AtomicU64::new(0);
            let (st, en): (Vec<AtomicU64>, Vec<AtomicU64>) = ((0..w).map(|_| z()).collect(), (0..w).map(|_| z()).collect());
            let tp = t.as_ptr_mut() as usize;
            let cs = t.col_stride() as usize;
            let mut rows: Vec<[f64; 6]> = vec![];
            let mut serial = vec![];
            let mut slice1 = vec![];
            with_team(w, table(&tbl), |mut par| {
                for rep in 0..reps + 200 {
                    // leader writes the target
                    let tw = if touch { t.as_mut().copy_from(t0.as_ref()); 0 } else { 0 };
                    let _ = tw;
                    let t_start = now();
                    if let Par::Team(te) = par.reborrow() {
                        let chunk = k.div_ceil(w);
                        te.run(|i, parts| {
                            let _ = parts;
                            st[i].store(now(), Ordering::Relaxed);
                            let lo = i * chunk;
                            let hi = k.min(lo + chunk);
                            if hi > lo {
                                let mut mem = mems[i].lock().unwrap();
                                let ptr = tp as *mut f64;
                                let sub = unsafe { faer::MatMut::from_raw_parts_mut(ptr.add(lo * cs), m, hi - lo, 1, cs as isize) };
                                apply_block_householder_on_the_left_in_place_with_conj(basis.as_ref(), factor.as_ref(), Conj::No, sub, Par::Seq, MemStack::new(&mut mem));
                            }
                            en[i].store(now(), Ordering::Relaxed);
                        });
                    }
                    let t_end = now();
                    if rep >= 200 {
                        let s0: Vec<u64> = st.iter().map(|a| a.load(Ordering::Relaxed)).collect();
                        let e0: Vec<u64> = en.iter().map(|a| a.load(Ordering::Relaxed)).collect();
                        let wake = (1..w).map(|i| s0[i].saturating_sub(t_start)).max().unwrap() as f64;
                        let comp_max = (0..w).map(|i| e0[i] - s0[i]).max().unwrap() as f64;
                        let comp_lead = (e0[0] - s0[0]) as f64;
                        let comp_other = (1..w).map(|i| e0[i] - s0[i]).max().unwrap() as f64;
                        let last = *e0.iter().max().unwrap();
                        rows.push([wake, comp_max, comp_lead, comp_other, t_end.saturating_sub(last) as f64, (t_end - t_start) as f64]);
                    }
                    // serial references on the leader, interleaved
                    if rep % 8 == 0 && rep >= 200 {
                        if touch { t.as_mut().copy_from(t0.as_ref()); }
                        let a = now();
                        let mut mem = mems[0].lock().unwrap();
                        apply_block_householder_on_the_left_in_place_with_conj(basis.as_ref(), factor.as_ref(), Conj::No, t.as_mut(), Par::Seq, MemStack::new(&mut mem));
                        serial.push((now() - a) as f64);
                        if touch { t.as_mut().copy_from(t0.as_ref()); }
                        let chunk = k.div_ceil(w);
                        let a = now();
                        let sub = t.as_mut().subcols_mut(0, chunk);
                        apply_block_householder_on_the_left_in_place_with_conj(basis.as_ref(), factor.as_ref(), Conj::No, sub, Par::Seq, MemStack::new(&mut mem));
                        slice1.push((now() - a) as f64);
                    }
                    // gap as in a QR: a little serial work
                    if rep % 3 == 0 {
                        let mut x = 0.0f64;
                        for q in 0..2000 { x += (q as f64).sqrt(); }
                        std::hint::black_box(x);
                    }
                }
            });
            let med = |v: &mut Vec<f64>| { v.sort_by(|a, b| a.partial_cmp(b).unwrap()); v[v.len() / 2] };
            let names = ["wake_max_member_start", "compute_max", "compute_leader", "compute_slowest_member_nonleader", "join_after_last_end", "total_region"];
            println!("# anatomy M={m} N=8 K={k} width {w} table {tbl} leader_writes={touch}, medians over {reps} reps, ns");
            for (j, nm) in names.iter().enumerate() {
                let mut v: Vec<f64> = rows.iter().map(|r| r[j]).collect();
                println!("{nm},{:.0}", med(&mut v));
            }
            println!("serial_apply_leader,{:.0}", med(&mut serial));
            println!("apply_of_1/w_slice_leader_alone,{:.0}", med(&mut slice1));
        }
        "ops" => {
            // the four operations of one block apply at M x 8 x (M-8), Seq against a team token whose gates are all serial
            use faer::linalg::matmul::{matmul, triangular};
            use faer::linalg::matmul::triangular::BlockStructure;
            use faer::linalg::triangular_solve;
            use faer::Accum;
            let w: usize = args[2].parse().unwrap();
            let m: usize = args.get(3).and_then(|s| s.parse().ok()).unwrap_or(128);
            let ms: u128 = flag(&args, "--ms").map(|s| s.parse().unwrap()).unwrap_or(200);
            let (nb, k) = (8usize, m - 8);
            let v = rand_mat(m - nb, nb, 1);
            let vt = v.transpose().to_owned();
            let top = rand_mat(nb, nb, 4);
            let c = rand_mat(m - nb, k, 3);
            let mut tmp = rand_mat(nb, k, 5);
            let mut bot = rand_mat(m - nb, k, 6);
            let mut tri = rand_mat(nb, k, 7);
            let mut bench = |par: Par| -> [f64; 5] {
                let mut par = par;
                let a = median_ns(ms, || { matmul(tmp.as_mut(), Accum::Add, vt.as_ref(), c.as_ref(), 1.0, par.reborrow()); });
                let b = median_ns(ms, || { matmul(bot.as_mut(), Accum::Add, v.as_ref(), tmp.as_ref(), -1.0, par.reborrow()); });
                let cc = median_ns(ms, || { triangular::matmul(tri.as_mut(), BlockStructure::Rectangular, Accum::Replace, top.as_ref(), BlockStructure::UnitTriangularLower, tmp.as_ref(), BlockStructure::Rectangular, 1.0, par.reborrow()); });
                let d = median_ns(ms, || { triangular_solve::solve_upper_triangular_in_place(top.as_ref(), tmp.as_mut(), par.reborrow()); tmp.as_mut().fill(1.0); });
                let e = 0.0;
                [a, b, cc, d, e]
            };
            let seq = bench(Par::Seq);
            let team = with_team(w, table("scale:1000000"), |par| bench(par));
            let rayon = bench(Par::rayon(w));
            println!("# ops M={m} N=8 K={k}: matmul_reduce, matmul_update, tri_matmul, tri_solve (ns)");
            println!("seq,{:?}", &seq[..4]);
            println!("team_serial,{:?}", &team[..4]);
            println!("rayon,{:?}", &rayon[..4]);
        }
        "gates" => {
            use std::hint::black_box;
            use std::num::NonZeroUsize;
            let w: usize = args[2].parse().unwrap();
            let n = 1_000_000u64;
            with_team(w, table("scale:1000000"), |par| {
                let shape = par.shape();
                let nz = NonZeroUsize::new(w).unwrap();
                let t = Instant::now();
                let mut c = 0u64;
                for i in 0..n { c += shape.pays_full(black_box(Duration::from_nanos(1000 + i % 7)), 1) as u64; }
                println!("ParShape::pays_full  {:.1} ns/call ({c})", t.elapsed().as_nanos() as f64 / n as f64);
                let t = Instant::now();
                for i in 0..n { c += shape.pays(black_box(Duration::from_nanos(1000 + i % 7)), 1, nz) as u64; }
                println!("ParShape::pays       {:.1} ns/call ({c})", t.elapsed().as_nanos() as f64 / n as f64);
                let t = Instant::now();
                for _ in 0..n { black_box(black_box(&par).shape()); }
                println!("par.shape()          {:.1} ns/call", t.elapsed().as_nanos() as f64 / n as f64);
                if let Par::Team(te) = &par {
                    let t = Instant::now();
                    for i in 0..n { c += te.width_for(black_box(Duration::from_nanos(1000 + i % 7)), 2).get() as u64; }
                    println!("TeamExec::width_for  {:.1} ns/call ({c})", t.elapsed().as_nanos() as f64 / n as f64);
                    let t = Instant::now();
                    for i in 0..n { c += te.pays(black_box(Duration::from_nanos(1000 + i % 7)), 2, nz) as u64; }
                    println!("TeamExec::pays       {:.1} ns/call ({c})", t.elapsed().as_nanos() as f64 / n as f64);
                }
                let t = Instant::now();
                for _ in 0..n { black_box(black_box(&par).degree()); }
                println!("par.degree()         {:.1} ns/call", t.elapsed().as_nanos() as f64 / n as f64);
            });
        }
        _ => panic!("mode"),
    }
}
