//! `fbench`: the measurement harness for the faer benchmark campaign.
//!
//! Three subcommands, at the contract `scripts/record_run.py` reads:
//!
//! * `info` prints one `key=value` per line, naming the vendor library the binary
//!   actually linked and how;
//! * `verify` checks every requested case, on every arm, and ends with exactly
//!   `all comparisons within tolerance` when every case passed;
//! * `run` measures and writes the CSV the report reads.
//!
//! One binary links one vendor library, so the LAPACK row's name (`lapack-mkl`
//! or `lapack-openblas`) is derived from what was linked, and a family a provider
//! cannot take is written as `skipped` rather than omitted.

// The numerical reference math and the adapters index matrices by `(row, column)`
// through an explicit linear index because the layout is a measured axis; iterators
// would obscure the stride arithmetic that is the point of those loops.
#![allow(clippy::needless_range_loop)]

mod backend;
mod lapack;
mod op;
mod qos;
mod dispatch;
mod shared;
mod team;
mod timing;
mod vendor;

// The vendor source crates only carry native link directives; refer to them so the
// linker keeps the `-l` flags their build scripts emit instead of pruning an unused
// dependency. Without this a build succeeds but the CBLAS/LAPACKE symbols are absent.
#[cfg(any(feature = "link-mkl", feature = "link-openblas"))]
use blas_src as _;
#[cfg(any(feature = "link-mkl", feature = "link-openblas"))]
use lapack_src as _;

use shared::{Case, Dtype, Order};
use std::process::ExitCode;

const USAGE: &str = "usage: fbench info [--threads N] | verify --threads N --n LIST [--batch LIST] [--dtype LIST] [--family LIST] [--regime R] [--rows LIST] [--csv PATH] | run --threads N --n LIST [--batch LIST] [--dtype LIST] [--family LIST] [--regime R] [--rows LIST] [--orders LIST] [--check-max-dim N] [--reps M] [--prime-ms MS] [--rotate-rows K] [--statistic best|median] --csv PATH | dispatch --threads N [--rows LIST] [--reps M] --csv PATH";

/// Every family name the suite declares, in the harness's priority order.
const ALL_FAMILIES: &[&str] = &[
    "gemm",
    "qr_factor",
    "qr",
    "lu",
    "cholesky",
    "solve",
    "triangular_solve",
    "svd_values",
    "svd_thin",
    "eigh",
    "full_piv_lu",
    "upgrade_factor",
    "householder_apply",
    // Declared by the suite and not implemented yet: every `run` emits a `skipped` row
    // for it rather than omitting it, which is the contract the recorder reads. It has
    // to be *known* here for that to happen -- an unrecognised name is a usage error.
    "eig",
];

#[derive(Clone, Copy)]
struct RawShape {
    m: usize,
    n: usize,
    k: Option<usize>,
}

impl RawShape {
    fn parse(text: &str) -> Result<Self, String> {
        let parts: Vec<&str> = text.split('x').collect();
        let num = |s: &str| {
            s.parse::<usize>()
                .map_err(|_| format!("invalid shape {text:?}"))
        };
        match parts.as_slice() {
            [n] => {
                let n = num(n)?;
                Ok(RawShape { m: n, n, k: None })
            }
            [m, n] => Ok(RawShape {
                m: num(m)?,
                n: num(n)?,
                k: None,
            }),
            [m, k, n] => Ok(RawShape {
                m: num(m)?,
                n: num(n)?,
                k: Some(num(k)?),
            }),
            _ => Err(format!("invalid shape {text:?}")),
        }
    }

    fn case(self, family: &str, batch: usize) -> Result<Case, String> {
        if family == "gemm" {
            if self.k.is_none() && self.m != self.n {
                return Err(format!(
                    "gemm needs MxKxN; {} is a rectangular MxN shape",
                    self.shape_text()
                ));
            }
            Ok(Case {
                m: self.m,
                n: self.n,
                k: Some(self.k.unwrap_or(self.m)),
                batch,
            })
        } else if self.k.is_some() {
            Err(format!(
                "{} is a three-index shape, which only gemm declares; {} takes MxN",
                self.shape_text(),
                family
            ))
        } else {
            Ok(Case {
                m: self.m,
                n: self.n,
                k: None,
                batch,
            })
        }
    }

    fn shape_text(self) -> String {
        match self.k {
            Some(k) => format!("{}x{}x{}", self.m, k, self.n),
            None if self.m == self.n => self.n.to_string(),
            None => format!("{}x{}", self.m, self.n),
        }
    }
}

#[derive(Clone, Copy)]
enum Statistic {
    Best,
    Median,
}

/// The faer rows that differ only in how the timed loop is wrapped (tensor4all/faer-benchmark#24).
/// All three link the fork and take the same code path at one thread.
///
/// * `faer-fork`: the spindle worker group is held (`spindle::with_lock`) around the loop;
/// * `faer-fork-hot`: an awake borrowed Rayon team ([`team::with_team`]) is held around the loop;
/// * `faer-fork-free`: nothing is held, which is the behaviour before the group was held.
///
/// The hot and free rows are opt-in through `--rows`; the default row set is unchanged.
const TEAM_ROWS: &[&str] = &["faer-fork-hot", "faer-fork-free"];

/// The timed loop of one row.
///
/// The faer rows `faer-fork` and `faer-upstream` run it with the spindle worker group held
/// (`spindle::with_lock`) when the budget is more than one thread: that is how a caller with a
/// thread budget is meant to call faer (the fork's crate docs, *parallelism*), and without it every
/// parallel region inside the call is a plain rayon fork/join that wakes the workers and partitions
/// the work afresh. The lock is taken once around priming, every repetition and the check, as a
/// session would, so its setup is outside every clocked region. `faer-fork-hot` holds an awake
/// Rayon team the same way and `faer-fork-free` holds nothing. The vendor rows own their threading
/// and are not touched.
fn measure_row(
    row: &str,
    threads: usize,
    ops: &mut op::Op,
    prime_ms: u64,
    reps: usize,
    check: bool,
) -> Result<timing::Measured, String> {
    let mut f = move || timing::measure_full(ops, prime_ms, reps, check);
    if threads > 1 && (row == "faer-fork" || row == "faer-upstream") {
        spindle::with_lock(threads, f)
    } else if threads > 1 && row == "faer-fork-hot" {
        team::with_team(threads, f)?
    } else {
        f()
    }
}

fn summarize(samples: &[f64], statistic: Statistic) -> Option<f64> {
    if samples.is_empty() {
        return None;
    }
    match statistic {
        Statistic::Best => samples.iter().copied().reduce(f64::min),
        Statistic::Median => {
            let mut ordered = samples.to_vec();
            ordered.sort_by(f64::total_cmp);
            let middle = ordered.len() / 2;
            Some(if ordered.len() % 2 == 0 {
                (ordered[middle - 1] + ordered[middle]) * 0.5
            } else {
                ordered[middle]
            })
        }
    }
}

struct Args {
    command: String,
    threads: Option<usize>,
    shapes: Vec<RawShape>,
    batches: Vec<usize>,
    dtypes: Vec<Dtype>,
    families: Vec<String>,
    regime: String,
    reps: usize,
    prime_ms: u64,
    /// Explicit row-order probe, not a guarantee of equivalent conditions.
    rotate_rows: usize,
    /// Which engine rows this run measures. A campaign may declare a subset per arm
    /// (an arm that carries an unchanged faer row twice does not have to pay for both).
    rows: Vec<String>,
    /// Memory orders to measure; both by default.
    orders: Vec<Order>,
    /// `run` checks a result only when the case's largest extent is at most this (default: always).
    check_max_dim: usize,
    statistic: Statistic,
    csv: Option<String>,
}

fn parse(args: &[String]) -> Result<Args, String> {
    if args.len() < 2 {
        return Err(USAGE.to_owned());
    }
    let command = args[1].clone();
    if command == "info" {
        let mut threads = None;
        let mut i = 2;
        while i < args.len() {
            if args[i] == "--threads" {
                i += 1;
                threads = Some(
                    args.get(i)
                        .ok_or(USAGE)?
                        .parse()
                        .map_err(|_| USAGE.to_owned())?,
                );
            } else {
                return Err(USAGE.to_owned());
            }
            i += 1;
        }
        return Ok(Args {
            command,
            threads,
            shapes: vec![],
            batches: vec![],
            dtypes: vec![],
            families: vec![],
            regime: "unspecified".to_owned(),
            reps: 5,
            prime_ms: 500,
            rotate_rows: 0,
            rows: Vec::new(),
            orders: vec![Order::C, Order::F],
            check_max_dim: usize::MAX,
            statistic: Statistic::Best,
            csv: None,
        });
    }
    if command != "run" && command != "verify" && command != "dispatch" {
        return Err(USAGE.to_owned());
    }
    let mut a = Args {
        command,
        threads: None,
        shapes: vec![],
        batches: vec![1],
        dtypes: vec![Dtype::F64],
        families: ALL_FAMILIES.iter().map(|f| (*f).to_owned()).collect(),
        regime: "unspecified".to_owned(),
        reps: 5,
        prime_ms: 500,
        rotate_rows: 0,
        rows: Vec::new(),
        orders: vec![Order::C, Order::F],
        check_max_dim: usize::MAX,
        statistic: Statistic::Best,
        csv: None,
    };
    let mut i = 2;
    while i < args.len() {
        let flag = args[i].clone();
        let mut value = || -> Result<String, String> {
            i += 1;
            args.get(i).cloned().ok_or_else(|| USAGE.to_owned())
        };
        match flag.as_str() {
            "--threads" => {
                a.threads = Some(value()?.parse().map_err(|_| USAGE.to_owned())?);
            }
            "--n" => {
                a.shapes = value()?
                    .split(',')
                    .map(RawShape::parse)
                    .collect::<Result<_, _>>()?;
            }
            "--batch" => {
                a.batches = value()?
                    .split(',')
                    .map(|v| v.parse::<usize>().map_err(|_| USAGE.to_owned()))
                    .collect::<Result<_, _>>()?;
            }
            "--dtype" => {
                a.dtypes = value()?
                    .split(',')
                    .map(|d| match d {
                        "f64" => Ok(Dtype::F64),
                        "c64" => Ok(Dtype::C64),
                        "f32" => Ok(Dtype::F32),
                        "c32" => Ok(Dtype::C32),
                        other => Err(format!("unknown dtype {other:?}")),
                    })
                    .collect::<Result<_, _>>()?;
            }
            "--family" => {
                a.families = value()?.split(',').map(str::to_owned).collect();
                for family in &a.families {
                    if !ALL_FAMILIES.contains(&family.as_str()) {
                        return Err(format!("unknown family {family:?}"));
                    }
                }
            }
            "--regime" => a.regime = value()?,
            "--rows" => {
                a.rows = value()?
                    .split(',')
                    .filter(|s| !s.is_empty())
                    .map(str::to_owned)
                    .collect();
                let known = known_rows();
                for row in &a.rows {
                    if !known.contains(row) {
                        return Err(format!(
                            "unknown row {row:?}; this binary carries {known:?}"
                        ));
                    }
                }
            }
            "--check-max-dim" => {
                a.check_max_dim = value()?.parse().map_err(|_| USAGE.to_owned())?;
            }
            "--orders" => {
                a.orders = value()?
                    .split(',')
                    .map(|o| match o {
                        "C" | "c" => Ok(Order::C),
                        "F" | "f" => Ok(Order::F),
                        other => Err(format!("unknown order {other:?}")),
                    })
                    .collect::<Result<_, _>>()?;
            }
            "--rotate-rows" => {
                a.rotate_rows = value()?.parse().map_err(|e| format!("{e}"))?;
            }
            "--statistic" => {
                a.statistic = match value()?.as_str() {
                    "best" => Statistic::Best,
                    "median" => Statistic::Median,
                    _ => return Err("--statistic must be best or median".to_owned()),
                };
            }
            "--reps" => a.reps = value()?.parse().map_err(|_| USAGE.to_owned())?,
            "--prime-ms" => a.prime_ms = value()?.parse().map_err(|_| USAGE.to_owned())?,
            "--csv" => a.csv = Some(value()?),
            _ => return Err(USAGE.to_owned()),
        }
        i += 1;
    }
    if a.shapes.is_empty() {
        // No `--n` means the default benchmark: the 64 cell of every family. `RawShape::case`
        // turns `64` into `64x64x64` for `gemm`, so one raw shape covers both shapes.
        a.shapes = vec![RawShape::parse("64").expect("64 is a shape")];
    }
    if a.threads.is_none() {
        return Err(USAGE.to_owned());
    }
    if a.threads == Some(0) {
        return Err("--threads must be positive".to_owned());
    }
    if a.reps == 0 {
        return Err("--reps must be positive".to_owned());
    }
    if a.command == "run" && a.csv.is_none() {
        return Err("run needs --csv PATH".to_owned());
    }
    Ok(a)
}

/// The engine rows this binary carries: the two faer crates plus this build's
/// vendor. The vendor row is absent without a `link-*` feature, never guessed.
fn engine_rows() -> Vec<String> {
    let mut rows = vec!["faer-fork".to_owned(), "faer-upstream".to_owned()];
    if vendor::NAME != "none" {
        rows.push(lapack::row_name().to_owned());
    }
    rows
}

/// Every row name `--rows` accepts: the default rows plus the opt-in team rows.
fn known_rows() -> Vec<String> {
    let mut rows = engine_rows();
    rows.extend(TEAM_ROWS.iter().map(|r| (*r).to_owned()));
    rows
}

fn ops_for(
    row: &str,
    dtype: Dtype,
    family: &str,
    case: Case,
    order: Order,
) -> Result<Vec<op::Op>, String> {
    match row {
        "faer-fork" | "faer-fork-hot" | "faer-fork-free" => backend::fork::ops(dtype, family, case, order),
        "faer-upstream" => backend::upstream::ops(dtype, family, case, order),
        _ => lapack::ops(dtype, family, case, order),
    }
}

fn info(threads: Option<usize>) {
    for (key, value) in vendor::identity().lines() {
        println!("{key}={value}");
    }
    println!("harness.name=fbench");
    println!(
        "host.logical_cpus={}",
        std::thread::available_parallelism().map_or(0, |n| n.get())
    );
    if let Some(n) = threads {
        println!("threads.requested={n}");
        if n == 1 {
            println!("threads.faer=sequential");
        }
    }
    if threads.is_some() {
        println!("threads.rayon_observed={}", rayon::current_num_threads());
    }
    if let Some(n) = vendor::reported_threads() {
        println!("threads.vendor_reported={n}");
    }
}

fn configure_threads(n: usize) -> Result<(), String> {
    if n == 0 {
        return Err("--threads must be positive".to_owned());
    }
    qos::init_main();
    rayon::ThreadPoolBuilder::new()
        .num_threads(n)
        .start_handler(|_| qos::init_worker())
        .build_global()
        .map_err(|e| format!("cannot create the owned {n}-worker Rayon pool: {e}"))?;
    vendor::set_threads(n)?;
    backend::fork::set_threads(n);
    backend::upstream::set_threads(n);
    require_threads(n)
}

fn require_threads(n: usize) -> Result<(), String> {
    let observed = rayon::current_num_threads();
    if observed != n {
        return Err(format!("Rayon reports {observed} workers, expected {n}"));
    }
    vendor::require_threads(n)
}

fn csv_field(value: &str) -> String {
    if value.contains([',', '"', '\n']) {
        format!("\"{}\"", value.replace('"', "\"\""))
    } else {
        value.to_owned()
    }
}

struct Record {
    regime: String,
    family: String,
    dtype: &'static str,
    order: &'static str,
    m: usize,
    n: usize,
    k: Option<usize>,
    batch: usize,
    row: String,
    threads: usize,
    rayon_threads: usize,
    vendor_threads: Option<usize>,
    total_ms: Option<f64>,
    samples_ms: Vec<f64>,
    status: &'static str,
    note: String,
    /// Process CPU time of each timed call (all threads), ms; empty for rows that do not record it.
    cpu_samples_ms: Vec<f64>,
    loop_wall_ms: Option<f64>,
    loop_cpu_ms: Option<f64>,
}

impl Record {
    fn line(&self) -> String {
        let per_item = self
            .total_ms
            .map(|ms| format!("{:.6}", ms * 1000.0 / self.batch as f64))
            .unwrap_or_default();
        let total = self
            .total_ms
            .map(|ms| format!("{ms:.6}"))
            .unwrap_or_default();
        let fields = [
            self.regime.clone(),
            self.family.clone(),
            self.dtype.to_owned(),
            self.order.to_owned(),
            self.m.to_string(),
            self.n.to_string(),
            self.k.map(|k| k.to_string()).unwrap_or_default(),
            self.batch.to_string(),
            self.row.clone(),
            self.threads.to_string(),
            total,
            per_item,
            self.status.to_owned(),
            self.note.clone(),
            if self.samples_ms.is_empty() {
                String::new()
            } else {
                format!("{:?}", self.samples_ms)
            },
            self.rayon_threads.to_string(),
            self.vendor_threads
                .map(|n| n.to_string())
                .unwrap_or_default(),
            if self.cpu_samples_ms.is_empty() {
                String::new()
            } else {
                format!("{:?}", self.cpu_samples_ms)
            },
            self.loop_wall_ms
                .map(|v| format!("{v:.6}"))
                .unwrap_or_default(),
            self.loop_cpu_ms
                .map(|v| format!("{v:.6}"))
                .unwrap_or_default(),
        ];
        fields
            .iter()
            .map(|f| csv_field(f))
            .collect::<Vec<_>>()
            .join(",")
    }
}

fn main() -> ExitCode {
    let argv: Vec<String> = std::env::args().collect();
    let args = match parse(&argv) {
        Ok(a) => a,
        Err(e) => {
            eprintln!("{e}\n{USAGE}");
            return ExitCode::from(2);
        }
    };
    if let Some(n) = args.threads {
        if let Err(e) = configure_threads(n) {
            eprintln!("{e}");
            return ExitCode::from(2);
        }
    }
    if args.command == "info" {
        info(args.threads);
        return ExitCode::SUCCESS;
    }
    let threads = args.threads.expect("verify and run require --threads");
    qos::report("before");
    if args.command == "dispatch" {
        let code = dispatch::main(&args.rows, threads, args.reps, args.csv.as_deref());
        qos::report("after");
        return code;
    }

    let mut rows = if args.rows.is_empty() {
        engine_rows()
    } else {
        let mut rows = known_rows();
        rows.retain(|row| args.rows.contains(row));
        rows
    };
    let n_rows = rows.len();
    if n_rows > 0 {
        rows.rotate_left(args.rotate_rows % n_rows);
    }
    let orders = args.orders.clone();
    let run = args.command == "run";
    let mut records = Vec::new();
    let mut all_ok = true;

    for dtype in &args.dtypes {
        for family in &args.families {
            for shape in &args.shapes {
                for batch in &args.batches {
                    let case = match shape.case(family, *batch) {
                        Ok(case) => case,
                        Err(note) => {
                            for order in orders.iter().copied() {
                                for row in &rows {
                                    if !run {
                                        println!(
                                            "skip {row} {} {} {} {} {note}",
                                            family,
                                            dtype.label(),
                                            order.label(),
                                            case_for_note(*shape, family, *batch).shape()
                                        );
                                    }
                                    emit(
                                        &mut records,
                                        &args,
                                        threads,
                                        dtype,
                                        family,
                                        case_for_note(*shape, family, *batch),
                                        order,
                                        row,
                                        None,
                                        "skipped",
                                        note.clone(),
                                    );
                                }
                            }
                            continue;
                        }
                    };
                    for order in orders.iter().copied() {
                        for row in &rows {
                            if let Err(e) = require_threads(threads) {
                                eprintln!("{e}");
                                return ExitCode::from(2);
                            }
                            let ops = match ops_for(row, *dtype, family, case, order) {
                                Ok(ops) => ops,
                                Err(note) => {
                                    if !run {
                                        println!(
                                            "skip {row} {} {} {} {} {note}",
                                            family,
                                            dtype.label(),
                                            order.label(),
                                            case.shape()
                                        );
                                    }
                                    emit(
                                        &mut records,
                                        &args,
                                        threads,
                                        dtype,
                                        family,
                                        case,
                                        order,
                                        row,
                                        None,
                                        "skipped",
                                        note,
                                    );
                                    continue;
                                }
                            };
                            for mut ops in ops {
                                if run {
                                    match measure_row(
                                        row,
                                        threads,
                                        &mut ops,
                                        args.prime_ms,
                                        args.reps,
                                        case.m.max(case.n).max(case.k.unwrap_or(0)) <= args.check_max_dim,
                                    ) {
                                        Ok(measured) => {
                                            let note = ops.note.clone();
                                            emit(
                                                &mut records,
                                                &args,
                                                threads,
                                                dtype,
                                                family,
                                                case,
                                                order,
                                                row,
                                                Some(measured.samples_ms),
                                                "ok",
                                                note,
                                            );
                                            let last = records.last_mut().expect("just emitted");
                                            last.cpu_samples_ms = measured.cpu_samples_ms;
                                            last.loop_wall_ms = Some(measured.loop_wall_ms);
                                            last.loop_cpu_ms = Some(measured.loop_cpu_ms);
                                        }
                                        Err(e) => {
                                            let e = format!("{}; {e}", ops.note);
                                            all_ok = false;
                                            emit(
                                                &mut records,
                                                &args,
                                                threads,
                                                dtype,
                                                family,
                                                case,
                                                order,
                                                row,
                                                None,
                                                "failed",
                                                e,
                                            );
                                        }
                                    }
                                } else {
                                    let label = format!(
                                        "{row} {} {} {} {}",
                                        family,
                                        dtype.label(),
                                        order.label(),
                                        case.shape()
                                    );
                                    let outcome = ops
                                        .prepare()
                                        .and_then(|()| ops.run())
                                        .and_then(|()| ops.check());
                                    match outcome {
                                        Ok(()) => {
                                            println!("ok {label} {}", ops.note);
                                            emit(
                                                &mut records,
                                                &args,
                                                threads,
                                                dtype,
                                                family,
                                                case,
                                                order,
                                                row,
                                                None,
                                                "ok",
                                                ops.note.clone(),
                                            );
                                        }
                                        Err(e) => {
                                            let e = format!("{}; {e}", ops.note);
                                            println!("MISMATCH {label} {e}");
                                            all_ok = false;
                                            emit(
                                                &mut records,
                                                &args,
                                                threads,
                                                dtype,
                                                family,
                                                case,
                                                order,
                                                row,
                                                None,
                                                "failed",
                                                e,
                                            );
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    qos::report("after");
    if !run {
        if all_ok {
            println!("all comparisons within tolerance");
        }
        if args.csv.is_none() {
            return if all_ok {
                ExitCode::SUCCESS
            } else {
                ExitCode::from(1)
            };
        }
    }

    let path = args
        .csv
        .as_ref()
        .expect("run or verification census needs --csv");
    let mut text = String::from(
        "regime,family,dtype,order,m,n,k,batch,row,threads,total_ms,per_item_us,status,note,samples_ms,rayon_threads,vendor_threads,cpu_samples_ms,loop_wall_ms,loop_cpu_ms\n",
    );
    for record in &records {
        text.push_str(&record.line());
        text.push('\n');
    }
    if let Err(e) = std::fs::write(path, text) {
        eprintln!("cannot write {path}: {e}");
        return ExitCode::from(2);
    }
    if all_ok {
        ExitCode::SUCCESS
    } else {
        ExitCode::from(1)
    }
}

/// The case used only to name a shape in a skipped row when the shape itself
/// could not be turned into a case.
fn case_for_note(shape: RawShape, family: &str, batch: usize) -> Case {
    shape.case(family, batch).unwrap_or(Case {
        m: shape.m,
        n: shape.n,
        k: shape.k,
        batch,
    })
}

#[allow(clippy::too_many_arguments)]
fn emit(
    records: &mut Vec<Record>,
    args: &Args,
    threads: usize,
    dtype: &Dtype,
    family: &str,
    case: Case,
    order: Order,
    row: &str,
    samples: Option<Vec<f64>>,
    status: &'static str,
    note: String,
) {
    records.push(Record {
        regime: args.regime.clone(),
        family: family.to_owned(),
        dtype: dtype.label(),
        order: order.label(),
        m: case.m,
        n: case.n,
        k: case.k,
        batch: case.batch,
        row: row.to_owned(),
        threads,
        rayon_threads: rayon::current_num_threads(),
        vendor_threads: vendor::reported_threads(),
        total_ms: samples.as_ref().and_then(|s| summarize(s, args.statistic)),
        samples_ms: samples.unwrap_or_default(),
        status,
        note,
        cpu_samples_ms: Vec::new(),
        loop_wall_ms: None,
        loop_cpu_ms: None,
    });
}

#[cfg(test)]
mod tests {
    use super::*;

    fn cli(extra: &[&str]) -> Result<Args, String> {
        let mut args: Vec<String> = [
            "fbench",
            "run",
            "--threads",
            "1",
            "--n",
            "2",
            "--csv",
            "out.csv",
        ]
        .into_iter()
        .map(str::to_owned)
        .collect();
        args.extend(extra.iter().map(|s| (*s).to_owned()));
        parse(&args)
    }

    #[test]
    fn probe_flags_and_ordered_csv_samples() {
        assert_eq!(cli(&[]).unwrap().rotate_rows, 0);
        assert_eq!(cli(&["--rotate-rows", "2"]).unwrap().rotate_rows, 2);
        assert!(matches!(
            cli(&["--statistic", "median"]).unwrap().statistic,
            Statistic::Median
        ));
        for extra in [
            &["--rotate-rows"][..],
            &["--rotate-rows", "bad"],
            &["--reps", "0"],
            &["--statistic", "unknown"],
        ] {
            assert!(cli(extra).is_err());
        }
        assert!(parse(&["fbench", "info", "--rotate-rows", "1"].map(str::to_owned)).is_err());
        let mut records = Vec::new();
        emit(
            &mut records,
            &cli(&[]).unwrap(),
            1,
            &Dtype::F64,
            "gemm",
            Case {
                m: 2,
                n: 2,
                k: Some(2),
                batch: 1,
            },
            Order::C,
            "faer-fork",
            Some(vec![3.0, 1.0, 2.0]),
            "ok",
            String::new(),
        );
        assert_eq!(records[0].total_ms, Some(1.0));
        assert!(records[0].line().contains(",ok,,\"[3.0, 1.0, 2.0]\","));
        assert_eq!(summarize(&[3.0, 1.0, 2.0], Statistic::Median), Some(2.0));
        assert_eq!(
            summarize(&[4.0, 1.0, 3.0, 2.0], Statistic::Median),
            Some(2.5)
        );
        assert_eq!(summarize(&[], Statistic::Median), None);
        assert_eq!(records[0].samples_ms, [3.0, 1.0, 2.0]);
        records[0].rayon_threads = 17;
        records[0].vendor_threads = Some(19);
        assert!(records[0].line().contains(",17,19,"));
    }
}
