//! `fbench smallops`: the workload the team is meant for, many small matrix operations issued one
//! after another from the leader with the parallel route active for each call (stage 2 of
//! tensor4all/faer-benchmark#24, coordinator request).
//!
//! Sequences (f64, column-major):
//!
//! * `gemm{32,64,128}`: 2000 independent square GEMMs over a pool of 16 operand triples;
//! * `lu{64,128}`: 500 partial-pivoting LU factorizations, each on its own matrix (the inputs are
//!   restored outside the timed loop);
//! * `chain`: 1000 GEMMs alternating `(128x32)(32x128)` and `(128x128)(128x32)`, each reading the
//!   previous result.
//!
//! Rows: `faer-fork` (spindle group held, `Par::Rayon`), `faer-fork-hot` (awake Rayon team,
//! `Par::Rayon`), `faer-fork-free` (nothing held, `Par::Rayon`), `faer-fork-team` (`Par::Team`).
//! At one thread every row is `Par::Seq`. The engagement pass of the team row counts, untimed, how
//! many participants each team region used.

use crate::{team, timing};
use faer_fork::dyn_stack::{MemBuffer, MemStack};
use faer_fork::linalg::lu::partial_pivoting::factor as lu;
use faer_fork::linalg::matmul::matmul;
use faer_fork::{Accum, Mat, Par};
use std::process::ExitCode;
use std::time::Instant;

const ROWS: &[&str] = &["faer-fork", "faer-fork-hot", "faer-fork-free", "faer-fork-team"];

fn rnd(m: usize, n: usize, seed: u64) -> Mat<f64> {
    let mut x = seed.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
    Mat::from_fn(m, n, |_, _| {
        x = x.wrapping_mul(6364136223846793005).wrapping_add(1442695040888963407);
        ((x >> 11) as f64 / (1u64 << 53) as f64) - 0.5
    })
}

pub struct Seq {
    pub name: String,
    pub calls: usize,
    run: Box<dyn FnMut(Par)>,
    reset: Box<dyn FnMut()>,
}

fn gemm_seq(n: usize) -> Seq {
    let a: Vec<Mat<f64>> = (0..16).map(|i| rnd(n, n, i)).collect();
    let b: Vec<Mat<f64>> = (0..16).map(|i| rnd(n, n, 100 + i)).collect();
    let mut c: Vec<Mat<f64>> = (0..16).map(|_| Mat::zeros(n, n)).collect();
    let calls = 2000;
    Seq {
        name: format!("gemm{n}"),
        calls,
        run: Box::new(move |par| {
            for i in 0..calls {
                let k = i % 16;
                matmul(c[k].as_mut(), Accum::Replace, a[k].as_ref(), b[k].as_ref(), 1.0, par);
            }
        }),
        reset: Box::new(|| {}),
    }
}

fn lu_seq(n: usize) -> Seq {
    let calls = 500;
    let src: Vec<Mat<f64>> = (0..calls).map(|i| rnd(n, n, 7 + i as u64)).collect();
    let work = std::rc::Rc::new(std::cell::RefCell::new(src.clone()));
    let w2 = work.clone();
    let mut perm = vec![0usize; n];
    let mut perm_inv = vec![0usize; n];
    let scratch = lu::lu_in_place_scratch::<usize, f64>(n, n, Par::Seq, Default::default());
    let mut mem = MemBuffer::new(scratch);
    Seq {
        name: format!("lu{n}"),
        calls,
        run: Box::new(move |par| {
            let mut w = work.borrow_mut();
            // the scratch of the parallel routes is no larger than the sequential one's requirement
            // by more than a small amount; request it per route once
            let req = lu::lu_in_place_scratch::<usize, f64>(n, n, par, Default::default());
            if mem.len() < req.unaligned_bytes_required() {
                mem = MemBuffer::new(req);
            }
            for m in w.iter_mut() {
                lu::lu_in_place(m.as_mut(), &mut perm, &mut perm_inv, par, MemStack::new(&mut mem), Default::default());
            }
        }),
        reset: Box::new(move || {
            let mut w = w2.borrow_mut();
            for (d, s) in w.iter_mut().zip(src.iter()) {
                d.as_mut().copy_from(s.as_ref());
            }
        }),
    }
}

fn chain_seq() -> Seq {
    let calls = 1000;
    let b = rnd(32, 128, 1);
    let e = rnd(128, 32, 2);
    let mut x = rnd(128, 32, 3);
    let x0 = x.clone();
    let mut c = Mat::<f64>::zeros(128, 128);
    let x_cell = std::rc::Rc::new(std::cell::RefCell::new(x0));
    let xc2 = x_cell.clone();
    let _ = &mut x;
    Seq {
        name: "chain".into(),
        calls,
        run: Box::new(move |par| {
            let mut x = x_cell.borrow_mut();
            for _ in 0..calls / 2 {
                // c = x * b: (128x32)(32x128); x = c * e: (128x128)(128x32); scaled to stay bounded
                matmul(c.as_mut(), Accum::Replace, x.as_ref(), b.as_ref(), 0.1, par);
                let mut next = Mat::<f64>::zeros(128, 32);
                matmul(next.as_mut(), Accum::Replace, c.as_ref(), e.as_ref(), 0.1, par);
                *x = next;
            }
        }),
        reset: Box::new(move || {
            *xc2.borrow_mut() = rnd(128, 32, 3);
        }),
    }
}

fn sequences() -> Vec<Seq> {
    vec![gemm_seq(32), gemm_seq(64), gemm_seq(128), lu_seq(64), lu_seq(128), chain_seq()]
}

fn quantile(s: &[f64], q: f64) -> f64 {
    s[((s.len() - 1) as f64 * q).round() as usize]
}

fn session(row: &str, threads: usize, reps: usize, engage: bool, out: &mut Vec<String>) {
    let par = if threads <= 1 {
        Par::Seq
    } else if row == "faer-fork-team" {
        #[cfg(feature = "team")]
        {
            Par::team(threads)
        }
        #[cfg(not(feature = "team"))]
        {
            unreachable!()
        }
    } else {
        Par::rayon(threads)
    };
    for mut seq in sequences() {
        // warm-up
        for _ in 0..3 {
            (seq.reset)();
            (seq.run)(par);
        }
        let mut wall = Vec::new();
        let mut cpu = Vec::new();
        for _ in 0..reps {
            (seq.reset)();
            let c0 = timing::process_cpu_ns();
            let t = Instant::now();
            (seq.run)(par);
            wall.push(t.elapsed().as_secs_f64() * 1e3);
            cpu.push(timing::process_cpu_ns().saturating_sub(c0) as f64 * 1e-6);
        }
        wall.sort_by(f64::total_cmp);
        let med = quantile(&wall, 0.5);
        let cw = cpu.iter().sum::<f64>() / wall.iter().sum::<f64>();
        #[allow(unused_mut)]
        let mut eng = String::new();
        #[cfg(feature = "team")]
        if engage && row == "faer-fork-team" && threads > 1 {
            faer_fork::utils::team::stats::enable(true);
            let _ = faer_fork::utils::team::stats::take();
            (seq.reset)();
            (seq.run)(par);
            faer_fork::utils::team::stats::enable(false);
            let s = faer_fork::utils::team::stats::take();
            let h = |v: &[usize]| {
                v.iter().enumerate().filter(|(_, c)| **c > 0).map(|(i, c)| format!("{i}:{c}")).collect::<Vec<_>>().join(" ")
            };
            eng = format!(
                "gemm_below_floor={} gemm_one_tile={} gemm_tiled={} run[{}] split[{}]",
                s.gemm_below_floor, s.gemm_one_tile, s.gemm_tiled, h(&s.run), h(&s.split)
            );
        }
        let _ = engage;
        out.push(format!(
            "{},{},{},{},{},{:.4},{:.4},{:.4},{:.4},{:.3},\"{}\"",
            row, threads, seq.name, seq.calls, wall.len(), med, med * 1e3 / seq.calls as f64,
            wall[0], quantile(&wall, 0.9), cw, eng
        ));
    }
}

pub fn main(rows: &[String], threads: usize, reps: usize, csv: Option<&str>) -> ExitCode {
    let rows: Vec<String> = if rows.is_empty() { ROWS.iter().map(|r| (*r).to_owned()).collect() } else { rows.to_vec() };
    let mut out = Vec::new();
    for row in &rows {
        if !ROWS.contains(&row.as_str()) {
            eprintln!("smallops measures {ROWS:?}, not {row:?}");
            return ExitCode::from(2);
        }
        let f = |o: &mut Vec<String>| session(row, threads, reps, true, o);
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
    let mut text = String::from("row,threads,seq,calls,reps,median_ms,per_call_us,min_ms,p90_ms,cpu_over_wall,engagement\n");
    for l in out {
        text.push_str(&l);
        text.push('\n');
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
