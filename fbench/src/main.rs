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
mod shared;
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

const USAGE: &str = "usage: fbench info | verify --threads N --n LIST [--batch LIST] [--dtype LIST] [--family LIST] [--regime R] | run --threads N --n LIST [--batch LIST] [--dtype LIST] [--family LIST] [--regime R] [--reps M] [--prime-ms MS] --csv PATH";

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
            csv: None,
        });
    }
    if command != "run" && command != "verify" {
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
            "--reps" => a.reps = value()?.parse().map_err(|_| USAGE.to_owned())?,
            "--prime-ms" => a.prime_ms = value()?.parse().map_err(|_| USAGE.to_owned())?,
            "--csv" => a.csv = Some(value()?),
            _ => return Err(USAGE.to_owned()),
        }
        i += 1;
    }
    if a.threads.is_none() || a.shapes.is_empty() {
        return Err(USAGE.to_owned());
    }
    if a.threads == Some(0) {
        return Err("--threads must be positive".to_owned());
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

fn ops_for(
    row: &str,
    dtype: Dtype,
    family: &str,
    case: Case,
    order: Order,
) -> Result<Vec<op::Op>, String> {
    match row {
        "faer-fork" => backend::fork::ops(dtype, family, case, order),
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
    }
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
    total_ms: Option<f64>,
    status: &'static str,
    note: String,
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
    if args.command == "info" {
        info(args.threads);
        return ExitCode::SUCCESS;
    }
    let threads = args.threads.expect("verify and run require --threads");
    if let Err(e) = vendor::set_threads(threads) {
        eprintln!("{e}");
        return ExitCode::from(2);
    }
    backend::fork::set_threads(threads);
    backend::upstream::set_threads(threads);

    let rows = engine_rows();
    let orders = [Order::C, Order::F];
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
                            for order in orders {
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
                                        run,
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
                    for order in orders {
                        for row in &rows {
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
                                        run,
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
                                    match timing::measure(&mut ops, args.prime_ms, args.reps) {
                                        Ok(ms) => {
                                            let note = ops.note.clone();
                                            emit(
                                                &mut records,
                                                true,
                                                &args,
                                                threads,
                                                dtype,
                                                family,
                                                case,
                                                order,
                                                row,
                                                Some(ms),
                                                "ok",
                                                note,
                                            );
                                        }
                                        Err(e) => {
                                            emit(
                                                &mut records,
                                                true,
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
                                        Ok(()) => println!("ok {label} {}", ops.note),
                                        Err(e) => {
                                            println!("MISMATCH {label} {e}");
                                            all_ok = false;
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

    if !run {
        if all_ok {
            println!("all comparisons within tolerance");
            return ExitCode::SUCCESS;
        }
        return ExitCode::from(1);
    }

    let path = args.csv.as_ref().expect("run validated --csv");
    let mut text = String::from(
        "regime,family,dtype,order,m,n,k,batch,row,threads,total_ms,per_item_us,status,note\n",
    );
    for record in &records {
        text.push_str(&record.line());
        text.push('\n');
    }
    if let Err(e) = std::fs::write(path, text) {
        eprintln!("cannot write {path}: {e}");
        return ExitCode::from(2);
    }
    ExitCode::SUCCESS
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
    run: bool,
    args: &Args,
    threads: usize,
    dtype: &Dtype,
    family: &str,
    case: Case,
    order: Order,
    row: &str,
    total_ms: Option<f64>,
    status: &'static str,
    note: String,
) {
    let note = if run { note } else { String::new() };
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
        total_ms,
        status,
        note,
    });
}
