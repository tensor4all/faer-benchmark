//! Diagnosis of "tlinalg batched QR/LU is ~1.1x slower on a team token than on a plain one" (n = 128).
//!
//! `tl-team-diag count [W]`  counters only (no timing): per `n x batch`, the faer team regions
//!   (`utils::team::stats`) and, when built with `--features trace`, the gate decisions
//!   (`utils::cost::trace`) per factorization, for the team token and the plain token at width `W`.
//! `tl-team-diag solo [ROUNDS]` single-thread A/B, the batch of `b` items on ONE core:
//!   serial token (`Par::Seq`) vs plain token of width 1 vs team token of width 1 (`Par::Team(1)`).
//!   Same lane layout (one lane, every item sequential), so the difference is the cost of handing faer a
//!   one-member team instead of `Par::Seq`; it is per item and does not depend on any dispatch.
//!   Run it under `taskset -c 0` (any single core).
use stack_probe::build;
use std::time::{Duration, Instant};
use tcontract_exec::BatchPolicy;
use threadteam::{Exec, Pool, Team};
use tlinalg::Op;
use tlinalg_bench::Batch;

type Run = Box<dyn FnMut(Exec<'_>)>;

fn qr(n: usize, batch: usize) -> Run {
    let a = Batch::<f64>::general(n, n, batch);
    let (mut q, mut r) = (Vec::new(), Vec::new());
    Box::new(move |tok| {
        let mut par = tcontract_exec::Exec::from_token(tok, None, BatchPolicy::default());
        tlinalg::qr::qr(Op::Qr, a.view(), &mut q, &mut r, &mut par).unwrap();
    })
}

fn lu(n: usize, batch: usize) -> Run {
    let a = Batch::<f64>::general(n, n, batch);
    let (mut lu, mut piv, mut parity) = (a.data.clone(), vec![0i32; n * batch], vec![0f64; batch]);
    Box::new(move |tok| {
        let mut par = tcontract_exec::Exec::from_token(tok, None, BatchPolicy::default());
        lu.copy_from_slice(&a.data);
        tlinalg::packed_lu::factor(Op::LuFactor, n, n, &mut lu, &mut piv, &mut parity, &mut par).unwrap();
    })
}

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
        if t.elapsed() >= Duration::from_millis(20) || n >= 1 << 16 {
            break;
        }
        n *= 2;
    }
    median(
        (0..9)
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

fn count(w: usize) {
    faer::utils::team::stats::enable(true);
    let plain_pool: Pool = build(w);
    let team: Team = build(w).into_team(w).expect("team");
    for (fam, n, b) in [("qr", 128, 8), ("qr", 128, 64), ("lu", 128, 8), ("lu", 128, 64), ("qr", 64, 64)] {
        for mode in ["team", "plain"] {
            let mut run = if fam == "qr" { qr(n, b) } else { lu(n, b) };
            // warm once (workspace growth), then count one call
            let call = |run: &mut Run| match mode {
                "team" => run(team.exec(w)),
                _ => run(Exec::new(&plain_pool, w).unwrap()),
            };
            call(&mut run);
            faer::utils::team::stats::take();
            #[cfg(feature = "trace")]
            faer::utils::cost::trace::enable(true);
            call(&mut run);
            #[cfg(feature = "trace")]
            faer::utils::cost::trace::enable(false);
            let s = faer::utils::team::stats::take();
            println!("== {fam} n{n} b{b} {mode} width {w}");
            println!(
                "   team stats: run(by participants)={:?} split(by parts)={:?} gemm below_floor={} one_tile={} tiled={}",
                s.run, s.split, s.gemm_below_floor, s.gemm_one_tile, s.gemm_tiled
            );
            #[cfg(feature = "trace")]
            {
                let recs = faer::utils::cost::trace::take();
                let par = recs.iter().filter(|r| r.parallel).count();
                println!(
                    "   gate decisions: {} total, {} per item, {} parallel",
                    recs.len(),
                    recs.len() as f64 / b as f64,
                    par
                );
                let mut by: std::collections::BTreeMap<&str, (usize, usize)> = Default::default();
                for r in &recs {
                    let e = by.entry(r.site).or_default();
                    e.0 += 1;
                    e.1 += r.parallel as usize;
                }
                for (site, (all, p)) in by {
                    println!("     {site}: {all} asked, {p} parallel");
                }
            }
        }
    }
}

fn solo(rounds: usize) {
    let pool1: Pool = build(1);
    let team1: Team = build(1).into_team(1).expect("team of one");
    println!("family,shape,mode,round,ns");
    for round in 0..rounds {
        for (fam, n, b) in [("qr", 128, 8), ("qr", 128, 64), ("lu", 128, 64), ("qr", 64, 64)] {
            let mut works: Vec<(&str, Run)> = Vec::new();
            for mode in ["seq", "plain1", "team1"] {
                works.push((mode, if fam == "qr" { qr(n, b) } else { lu(n, b) }));
            }
            for (mode, run) in works.iter_mut() {
                std::thread::sleep(Duration::from_millis(100));
                let ns = match *mode {
                    "seq" => time_calls(|| run(Exec::serial())),
                    "plain1" => {
                        let mut t = Exec::new(&pool1, 1).unwrap();
                        time_calls(|| run(t.reborrow()))
                    }
                    _ => {
                        let mut t = team1.exec(1);
                        time_calls(|| run(t.reborrow()))
                    }
                };
                println!("t{fam},n{n}xb{b},{mode},{round},{ns:.1}");
            }
        }
    }
}

fn main() {
    let mut args = std::env::args().skip(1);
    match args.next().as_deref() {
        Some("count") => count(args.next().and_then(|s| s.parse().ok()).unwrap_or(8)),
        Some("solo") => solo(args.next().and_then(|s| s.parse().ok()).unwrap_or(3)),
        _ => eprintln!("usage: tl-team-diag count [W] | solo [ROUNDS]"),
    }
}
