//! Decision trace and region timings (M5, QoS UserInitiated). Modes: `trace`, `qr`.
use faer::dyn_stack::{MemBuffer, MemStack};
use faer::linalg::qr::no_pivoting::factor as qrf;
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
        _ => panic!("mode"),
    }
}
