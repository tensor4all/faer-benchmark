//! Harness of the confirmation sweeps (from threadteam-rs `docs/design/thresholds-data/src/confirm.rs`, d08b3e7):
//! one workload run serially, through a plain token from outside the pool, from inside it, and through a team
//! token, at width `w` (the M5 file hard-codes 6). A 300 ms settle precedes every cell, so the team's members
//! have parked and the plain pool is cold, as in a program that issues the operation now and then.
use std::sync::Mutex;
use std::time::{Duration, Instant};
use threadteam::{Exec, Pool, Qos, Team};

fn median(mut v: Vec<f64>) -> f64 {
    v.sort_by(f64::total_cmp);
    v[v.len() / 2]
}

fn time_calls(mut call: impl FnMut()) -> f64 {
    let mut n = 1usize;
    loop {
        let t = Instant::now();
        for _ in 0..n {
            call();
        }
        if t.elapsed() >= Duration::from_millis(4) || n >= 1 << 22 {
            break;
        }
        n *= 2;
    }
    median(
        (0..11)
            .map(|_| {
                let t = Instant::now();
                for _ in 0..n {
                    call();
                }
                t.elapsed().as_nanos() as f64 / n as f64
            })
            .collect(),
    )
}

pub struct Work {
    pub family: &'static str,
    pub shape: String,
    pub run: Box<dyn FnMut(Exec<'_>) + Send>,
}

#[derive(Clone, Copy, PartialEq)]
pub enum Mode {
    Seq,
    PlainOut,
    PlainIn,
    Team,
}

static POOL: Mutex<Option<Pool>> = Mutex::new(None);
static TEAM: Mutex<Option<Team>> = Mutex::new(None);

pub fn measure(w_: usize, mode: Mode, w: &mut Work) -> f64 {
    match mode {
        Mode::Seq => time_calls(|| (w.run)(Exec::serial())),
        Mode::PlainOut => {
            let g = POOL.lock().unwrap();
            let pool = g.as_ref().unwrap();
            let mut tok = Exec::new(pool, w_).unwrap();
            time_calls(|| (w.run)(tok.reborrow()))
        }
        Mode::PlainIn => {
            let g = POOL.lock().unwrap();
            let pool = g.as_ref().unwrap();
            let tok = Exec::new(pool, w_).unwrap();
            tok.external(|_| {
                let mut t = Exec::new(pool, w_).unwrap();
                time_calls(|| (w.run)(t.reborrow()))
            })
        }
        Mode::Team => {
            let g = TEAM.lock().unwrap();
            let team = g.as_ref().unwrap();
            let mut tok = team.exec(w_);
            time_calls(|| (w.run)(tok.reborrow()))
        }
    }
}

pub fn build(w_: usize) -> Pool {
    Pool::builder().threads(w_).qos(Qos::UserInitiated).acquire_timeout(Duration::from_secs(30)).build().unwrap()
}


/// `family,shape,mode,round,ns` on stdout, `rounds` rounds over `works`, width `w`.
pub fn sweep(works: &mut [Work], rounds: usize, w: usize) {
    threadteam::raise_current_thread_qos(Qos::UserInitiated);
    println!("family,shape,mode,round,ns");
    for round in 0..rounds {
        for (mode, name) in [(Mode::Seq, "seq"), (Mode::PlainOut, "plain_out"), (Mode::PlainIn, "plain_in"), (Mode::Team, "team")] {
            match mode {
                Mode::PlainOut | Mode::PlainIn => *POOL.lock().unwrap() = Some(build(w)),
                Mode::Team => *TEAM.lock().unwrap() = Some(build(w).into_team(w).expect("team")),
                Mode::Seq => {}
            }
            for wk in works.iter_mut() {
                std::thread::sleep(Duration::from_millis(300));
                let ns = measure(w, mode, wk);
                println!("{},{},{},{},{:.1}", wk.family, wk.shape, name, round, ns);
            }
            *POOL.lock().unwrap() = None;
            *TEAM.lock().unwrap() = None;
        }
    }
}
