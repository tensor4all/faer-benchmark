//! `fbench dispatch`: what one tiny parallel region costs under each waiting policy, and what the
//! policy costs in CPU time (stage 1 of tensor4all/faer-benchmark#24).
//!
//! Every faer kernel forks through `spindle::for_each`; outside a spindle region that is a Rayon
//! `par_iter`, inside one it is a dispatch to the spinning group. The `gemm` crate forks through a
//! plain Rayon `par_iter`. This subcommand times both with a region body of a few nanoseconds, so
//! the number is the dispatch, not the work, under the three wrappers the timed loops use:
//!
//! * `faer-fork`: `spindle::with_lock(threads)` held around everything below;
//! * `faer-fork-hot`: the awake Rayon team held around everything below;
//! * `faer-fork-free`: nothing held.
//!
//! Two shapes are measured:
//!
//! * `b2b_*`: dispatches back to back, as the mean of blocks of 1000, so the timer's own cost is
//!   amortised. This is the cost with every worker awake.
//! * `gap_*`: the leader works serially for `gap_us` microseconds (a busy wait), then times one
//!   dispatch. This is the wake latency after the team has been idle for the gap, and the
//!   `cpu_over_wall` column is the process CPU time over wall time across the whole loop, the number
//!   of cores kept busy, which is what spinning costs. The leader's own core counts as 1.

use crate::{team, timing};
use rayon::prelude::*;
use std::process::ExitCode;
use std::sync::atomic::{AtomicU64, Ordering};
use std::time::{Duration, Instant};

#[cfg(not(feature = "team"))]
const ROWS: &[&str] = &["faer-fork", "faer-fork-hot", "faer-fork-free"];
#[cfg(feature = "team")]
const ROWS: &[&str] = &["faer-fork", "faer-fork-hot", "faer-fork-free", "faer-fork-team"];
const GAPS_US: &[u64] = &[0, 1, 10, 30, 100, 1_000, 10_000, 100_000];
const BLOCK: usize = 1000;

static SLOTS: [AtomicU64; 64] = [const { AtomicU64::new(0) }; 64];

#[inline(never)]
fn body(i: usize) {
    SLOTS[i % 64].fetch_add(1, Ordering::Relaxed);
}

#[inline(never)]
fn spindle_dispatch(n: usize) {
    spindle::for_each(n, (0..n).into_par_iter(), body);
}

#[inline(never)]
fn rayon_dispatch(n: usize) {
    (0..n).into_par_iter().for_each(body);
}

/// The team row's dispatch: one flat section of `n` participants, the call faer's `Par::Team`
/// regions make (the section a `Par::Team` region dispatches), with the same few-nanosecond body.
#[cfg(feature = "team")]
#[inline(never)]
fn team_dispatch(n: usize) {
    crate::team_row::run_flat(n, &|i, _| body(i));
}

#[cfg(feature = "team")]
fn session_team(row: &str, threads: usize, blocks: usize) -> Vec<Line> {
    let mut out = Vec::new();
    for _ in 0..20_000 {
        team_dispatch(threads);
    }
    let (ns, ratio) = timed(|| {
        (0..blocks)
            .map(|_| {
                let t = Instant::now();
                for _ in 0..BLOCK {
                    team_dispatch(threads);
                }
                t.elapsed().as_secs_f64() * 1e9 / BLOCK as f64
            })
            .collect::<Vec<f64>>()
    });
    out.push(line(row, threads, "b2b_team_run", 0, ns, ratio));
    for &gap in GAPS_US {
        let cycles = (400_000 / (gap + 2)).clamp(100, 20_000) as usize;
        let (ns, ratio) = timed(|| {
            let mut ns = Vec::with_capacity(cycles);
            for _ in 0..cycles {
                busy_wait(Duration::from_micros(gap));
                let t = Instant::now();
                team_dispatch(threads);
                ns.push(t.elapsed().as_secs_f64() * 1e9);
            }
            ns
        });
        out.push(line(row, threads, "gap_team_run", gap, ns, ratio));
    }
    out
}

struct Line {
    row: String,
    threads: usize,
    test: String,
    gap_us: u64,
    samples: usize,
    median_ns: f64,
    p10_ns: f64,
    p90_ns: f64,
    max_ns: f64,
    cpu_over_wall: f64,
}

fn quantile(sorted: &[f64], q: f64) -> f64 {
    let idx = ((sorted.len() - 1) as f64 * q).round() as usize;
    sorted[idx]
}

fn line(row: &str, threads: usize, test: &str, gap_us: u64, mut ns: Vec<f64>, cpu_over_wall: f64) -> Line {
    ns.sort_by(f64::total_cmp);
    Line {
        row: row.to_owned(),
        threads,
        test: test.to_owned(),
        gap_us,
        samples: ns.len(),
        median_ns: quantile(&ns, 0.5),
        p10_ns: quantile(&ns, 0.1),
        p90_ns: quantile(&ns, 0.9),
        max_ns: *ns.last().unwrap(),
        cpu_over_wall,
    }
}

fn busy_wait(d: Duration) {
    let end = Instant::now() + d;
    while Instant::now() < end {
        std::hint::spin_loop();
    }
}

/// Run `body` and return its samples and the process CPU over wall ratio across it.
fn timed<R>(f: impl FnOnce() -> R) -> (R, f64) {
    let cpu0 = timing::process_cpu_ns();
    let t0 = Instant::now();
    let r = f();
    let wall = t0.elapsed().as_secs_f64();
    let cpu = timing::process_cpu_ns().saturating_sub(cpu0) as f64 * 1e-9;
    (r, cpu / wall)
}

fn session(row: &str, threads: usize, blocks: usize) -> Vec<Line> {
    let mut out = Vec::new();
    // warm the pool and every cache the first dispatch would otherwise pay for
    for _ in 0..20_000 {
        spindle_dispatch(threads);
        rayon_dispatch(threads);
    }
    for (name, dispatch) in [
        ("b2b_spindle_for_each", spindle_dispatch as fn(usize)),
        ("b2b_rayon_par_iter", rayon_dispatch as fn(usize)),
    ] {
        let (ns, ratio) = timed(|| {
            (0..blocks)
                .map(|_| {
                    let t = Instant::now();
                    for _ in 0..BLOCK {
                        dispatch(threads);
                    }
                    t.elapsed().as_secs_f64() * 1e9 / BLOCK as f64
                })
                .collect::<Vec<f64>>()
        });
        out.push(line(row, threads, name, 0, ns, ratio));
    }
    for &gap in GAPS_US {
        // about 0.4 s of wall time per gap, at least 100 and at most 20000 cycles
        let cycles = (400_000 / (gap + 2)).clamp(100, 20_000) as usize;
        let (ns, ratio) = timed(|| {
            let mut ns = Vec::with_capacity(cycles);
            for _ in 0..cycles {
                busy_wait(Duration::from_micros(gap));
                let t = Instant::now();
                spindle_dispatch(threads);
                ns.push(t.elapsed().as_secs_f64() * 1e9);
            }
            ns
        });
        out.push(line(row, threads, "gap_spindle_for_each", gap, ns, ratio));
    }
    out
}

pub fn main(rows: &[String], threads: usize, reps: usize, csv: Option<&str>) -> ExitCode {
    let rows: Vec<String> = if rows.is_empty() {
        ROWS.iter().map(|r| (*r).to_owned()).collect()
    } else {
        rows.to_vec()
    };
    for row in &rows {
        if !ROWS.contains(&row.as_str()) {
            eprintln!("dispatch measures {ROWS:?}, not {row:?}");
            return ExitCode::from(2);
        }
    }
    let blocks = reps.max(10);
    let mut lines = Vec::new();
    for row in &rows {
        let f = || session(row, threads, blocks);
        #[cfg(feature = "team")]
        if threads > 1 && row == "faer-fork-team" {
            match crate::team_row::with_session(threads, || session_team(row, threads, blocks)) {
                Ok(mut l) => lines.append(&mut l),
                Err(e) => {
                    eprintln!("{row}: {e}");
                    return ExitCode::from(2);
                }
            }
            continue;
        }
        let result = if threads > 1 && row == "faer-fork" {
            Ok(spindle::with_lock(threads, f))
        } else if threads > 1 && row == "faer-fork-hot" {
            team::with_team(threads, f)
        } else {
            Ok(f())
        };
        match result {
            Ok(mut l) => lines.append(&mut l),
            Err(e) => {
                eprintln!("{row}: {e}");
                return ExitCode::from(2);
            }
        }
    }
    let mut text = String::from(
        "row,threads,test,gap_us,samples,median_ns,p10_ns,p90_ns,max_ns,cpu_over_wall\n",
    );
    for l in &lines {
        text.push_str(&format!(
            "{},{},{},{},{},{:.1},{:.1},{:.1},{:.1},{:.3}\n",
            l.row, l.threads, l.test, l.gap_us, l.samples, l.median_ns, l.p10_ns, l.p90_ns, l.max_ns, l.cpu_over_wall
        ));
    }
    match csv {
        Some(path) => {
            if let Err(e) = std::fs::write(path, &text) {
                eprintln!("cannot write {path}: {e}");
                return ExitCode::from(2);
            }
        }
        None => print!("{text}"),
    }
    ExitCode::SUCCESS
}
