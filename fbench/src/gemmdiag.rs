//! `fbench diag-gemm`: which threads run a GEMM under each row (x86_64 product path diagnostic of
//! tensor4all-meta#51, item e).
//!
//! On x86_64 the fork's `Par::Rayon(w)` GEMM goes through `t4a-private-gemm-x86`, which fans out
//! with `spindle::for_each`: inside `spindle::with_lock` (row `faer-fork`) onto the held group,
//! otherwise (rows `-hot`, `-free`) onto the Rayon pool. `Par::Team` tiles the product over the
//! team's members (`utils::team::gemm_tiled`, the `gemm` crate per tile). This subcommand shows it
//! without a profiler: per row it
//!
//! 1. probes the participant threads of the row (the tid set of 200 fan-out calls whose body
//!    busy-waits 50 us, so every participant takes a share), through the row's own fan-out entry
//!    (`spindle::for_each_raw`, `rayon` `par_iter`, `Team::run`);
//! 2. snapshots the on-CPU time of every thread of the process (`/proc/self/task/<tid>/schedstat`);
//! 3. runs square f64 GEMMs of each size for `--reps` seconds through the row's `Par`;
//! 4. snapshots again and prints, per size, the CPU milliseconds on the probed participants, on other
//!    threads of the process, and the number of probed participants that were busy for more than
//!    half of the wall time. The team row also prints the fork's team counters (`gemm_tiled`,
//!    `gemm_below_floor`, `gemm_one_tile`, `run` histogram).
//!
//! Output is CSV on stdout: `row,n,threads,calls,wall_ms,per_call_ms,participants,busy_participants,
//! cpu_ms_participants,cpu_ms_other,cpu_ms_leader,busy_other_threads,team_stats`, plus `#tid` comment lines with the
//! per-thread detail.

use crate::{backend::fork_par, backend::ParCfg, team};
use faer_fork::linalg::matmul::matmul;
use faer_fork::{Accum, Mat};
use rayon::prelude::*;
use std::collections::BTreeMap;
use std::collections::BTreeSet;
use std::process::ExitCode;
use std::sync::Mutex;
use std::time::{Duration, Instant};

#[cfg(feature = "team")]
const ROWS: &[&str] = &["faer-fork", "faer-fork-hot", "faer-fork-free", "faer-fork-team"];
#[cfg(not(feature = "team"))]
const ROWS: &[&str] = &["faer-fork", "faer-fork-hot", "faer-fork-free"];

fn gettid() -> u64 {
    unsafe { libc::syscall(libc::SYS_gettid) as u64 }
}

fn spin(d: Duration) {
    let end = Instant::now() + d;
    while Instant::now() < end {
        std::hint::spin_loop();
    }
}

/// tid -> on-CPU ns, from schedstat (first field), for every thread of this process.
fn snapshot() -> BTreeMap<u64, u64> {
    let mut m = BTreeMap::new();
    if let Ok(rd) = std::fs::read_dir("/proc/self/task") {
        for e in rd.flatten() {
            let tid: u64 = match e.file_name().to_string_lossy().parse() {
                Ok(t) => t,
                Err(_) => continue,
            };
            if let Ok(s) = std::fs::read_to_string(e.path().join("schedstat")) {
                if let Some(ns) = s.split_whitespace().next().and_then(|x| x.parse().ok()) {
                    m.insert(tid, ns);
                }
            }
        }
    }
    m
}

fn rnd(n: usize, seed: u64) -> Mat<f64> {
    let mut x = seed.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
    Mat::from_fn(n, n, |_, _| {
        x = x.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
        ((x >> 11) as f64 / (1u64 << 53) as f64) - 0.5
    })
}

fn probe(row: &str, threads: usize) -> BTreeSet<u64> {
    let set = Mutex::new(BTreeSet::new());
    set.lock().unwrap().insert(gettid());
    for _ in 0..200 {
        let body = |_i: usize| {
            set.lock().unwrap().insert(gettid());
            spin(Duration::from_micros(50));
        };
        match row {
            "faer-fork" => spindle::for_each_raw(threads, body),
            #[cfg(feature = "team")]
            "faer-fork-team" => team_probe(threads, &body),
            _ => (0..threads).into_par_iter().for_each(body),
        }
    }
    set.into_inner().unwrap()
}

#[cfg(feature = "team")]
fn team_probe(threads: usize, body: &(dyn Fn(usize) + Sync)) {
    crate::team_row::run_flat(threads, &|i, _| body(i));
}

fn session(row: &str, threads: usize, fams: &[String], sizes: &[usize], secs: f64, out: &mut Vec<String>) {
    let par_cfg = if row == "faer-fork-team" { ParCfg::Team } else { ParCfg::Rayon(threads) };
    let tag = |s: String| out.push(s);
    let _ = &tag;
    let parts = probe(row, threads);
    let leader = gettid();
    for fam in fams {
    for &n in sizes {
        let a = rnd(n, 1);
        let b = rnd(n, 2);
        let mut c = Mat::<f64>::zeros(n, n);
        // other families go through the harness's own op builders (the code the fbench rows time); each step is
        // `prepare` (restores the input) then `run`, so the loop's CPU includes the restore copy
        let mut ops = if fam == "gemm" {
            Vec::new()
        } else {
            let shape = crate::RawShape { m: n, n, k: None };
            let case = shape.case(fam, 1).expect("case");
            crate::ops_for(row, crate::shared::Dtype::F64, fam, case, crate::shared::Order::F).expect("ops")
        };
        let mut step = |a: &Mat<f64>, b: &Mat<f64>, c: &mut Mat<f64>| {
            if fam == "gemm" {
                matmul(c.as_mut(), Accum::Replace, a.as_ref(), b.as_ref(), 1.0, fork_par::mk(par_cfg));
            } else {
                for op in ops.iter_mut() {
                    op.prepare().unwrap();
                    op.run().unwrap();
                }
            }
        };
        for _ in 0..5 {
            step(&a, &b, &mut c);
        }
        #[cfg(feature = "team")]
        let team_on = row == "faer-fork-team";
        #[cfg(feature = "team")]
        if team_on {
            faer_fork::utils::team::stats::enable(true);
            let _ = faer_fork::utils::team::stats::take();
        }
        let before = snapshot();
        let t0 = Instant::now();
        let mut calls = 0usize;
        while t0.elapsed().as_secs_f64() < secs {
            step(&a, &b, &mut c);
            calls += 1;
        }
        let wall = t0.elapsed().as_secs_f64() * 1e3;
        let after = snapshot();
        #[allow(unused_mut)]
        let mut stats = String::new();
        #[cfg(feature = "team")]
        if team_on {
            faer_fork::utils::team::stats::enable(false);
            let s = faer_fork::utils::team::stats::take();
            let h = |v: &[usize]| v.iter().enumerate().filter(|(_, c)| **c > 0).map(|(i, c)| format!("{i}:{c}")).collect::<Vec<_>>().join(" ");
            stats = format!("gemm_tiled={} gemm_below_floor={} gemm_one_tile={} run[{}] split[{}]", s.gemm_tiled, s.gemm_below_floor, s.gemm_one_tile, h(&s.run), h(&s.split));
        }
        let (mut cp, mut co, mut busy, mut busy_other) = (0.0, 0.0, 0usize, 0usize);
        let mut leader_ms = 0.0;
        for (tid, a1) in &after {
            let d = (a1 - before.get(tid).copied().unwrap_or(0)) as f64 * 1e-6;
            if *tid == leader {
                leader_ms = d;
            }
            if parts.contains(tid) {
                cp += d;
                if d > 0.5 * wall {
                    busy += 1;
                }
            } else {
                co += d;
                if d > 0.1 * wall {
                    busy_other += 1;
                }
            }
            out.push(format!("#tid,{row},{fam},{n},{tid},{},{:.1}", if parts.contains(tid) { "participant" } else if *tid == leader { "leader" } else { "other" }, d));
        }
        out.push(format!(
            "{row},{fam}{n},{threads},{calls},{wall:.1},{:.4},{},{busy},{cp:.1},{co:.1},{leader_ms:.1},{busy_other},\"{stats}\"",
            wall / calls as f64,
            parts.len()
        ));
    }
    }
}

pub fn main(rows: &[String], threads: usize, fams: &[String], sizes: &[usize], secs: f64) -> ExitCode {
    let rows: Vec<String> = if rows.is_empty() { ROWS.iter().map(|r| (*r).to_owned()).collect() } else { rows.to_vec() };
    let mut out = Vec::new();
    for row in &rows {
        if !ROWS.contains(&row.as_str()) {
            eprintln!("diag-gemm measures {ROWS:?}, not {row:?}");
            return ExitCode::from(2);
        }
        let f = |o: &mut Vec<String>| session(row, threads, fams, sizes, secs, o);
        if threads > 1 && row == "faer-fork" {
            spindle::with_lock(threads, || f(&mut out));
        } else if threads > 1 && row == "faer-fork-hot" {
            if let Err(e) = team::with_team(threads, || f(&mut out)) {
                eprintln!("{row}: {e}");
                return ExitCode::from(2);
            }
        } else if threads > 1 && row == "faer-fork-team" {
            #[cfg(feature = "team")]
            if let Err(e) = crate::team_row::with_session(threads, || f(&mut out)) {
                eprintln!("{row}: {e}");
                return ExitCode::from(2);
            }
        } else {
            f(&mut out);
        }
    }
    println!("row,n,threads,calls,wall_ms,per_call_ms,participants,busy_participants,cpu_ms_participants,cpu_ms_other,cpu_ms_leader,busy_other_threads,team_stats");
    for l in out {
        println!("{l}");
    }
    ExitCode::SUCCESS
}
