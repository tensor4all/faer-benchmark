//! tlinalg batched small LU (packed) and QR, serial vs plain token (outside / inside the pool) vs team
//! token at width `W`, same harness as `thr-confirm`. `tl-probe ROUNDS W` prints CSV: family,shape,mode,round,ns.
//! Shapes are `n x batch` (LU) and `n x n x batch` (QR), f64; the provider chooses its batch lanes from the
//! token (`BatchPolicy::default()`, Auto). Fixtures are tlinalg-bench's `Batch`.
use stack_probe::{sweep, Work};
use tcontract_exec::BatchPolicy;
use threadteam::Exec;
use tlinalg::Op;
use tlinalg_bench::Batch;

fn lu(n: usize, batch: usize) -> Work {
    let a = Batch::<f64>::general(n, n, batch);
    let (mut lu, mut piv, mut parity) = (a.data.clone(), vec![0i32; n * batch], vec![0f64; batch]);
    Work {
        family: "tl_lu",
        shape: format!("n{n}xb{batch}"),
        run: Box::new(move |tok: Exec<'_>| {
            let mut par = tcontract_exec::Exec::from_token(tok, None, BatchPolicy::default());
            lu.copy_from_slice(&a.data);
            tlinalg::packed_lu::factor(Op::LuFactor, n, n, &mut lu, &mut piv, &mut parity, &mut par).unwrap();
        }),
    }
}

fn qr(n: usize, batch: usize) -> Work {
    let a = Batch::<f64>::general(n, n, batch);
    let (mut q, mut r) = (Vec::new(), Vec::new());
    Work {
        family: "tl_qr",
        shape: format!("n{n}xb{batch}"),
        run: Box::new(move |tok: Exec<'_>| {
            let mut par = tcontract_exec::Exec::from_token(tok, None, BatchPolicy::default());
            tlinalg::qr::qr(Op::Qr, a.view(), &mut q, &mut r, &mut par).unwrap();
        }),
    }
}

fn main() {
    let mut args = std::env::args().skip(1);
    let rounds: usize = args.next().and_then(|s| s.parse().ok()).unwrap_or(3);
    let w: usize = args.next().and_then(|s| s.parse().ok()).unwrap_or(8);
    let mut works = Vec::new();
    for n in [4usize, 8, 16, 32, 64, 128] {
        for b in [1usize, 8, 64, 256] {
            works.push(lu(n, b));
        }
    }
    for n in [8usize, 16, 32, 64, 128] {
        for b in [1usize, 8, 64, 256] {
            works.push(qr(n, b));
        }
    }
    sweep(&mut works, rounds, w);
}
