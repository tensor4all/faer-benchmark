//! Linux port of threadteam-rs `docs/design/thresholds-data/src/confirm.rs` (the 6760aa1 confirmation sweep):
//! strided copy/map/exp/sum, a tcontract matmul and a small cpueinsum chain, serial vs plain token (outside and
//! inside the pool) vs team token at width `W`. `thr-confirm ROUNDS W` prints CSV: family,shape,mode,round,ns.
use stack_probe::{sweep, Work};
use strided_basic::execution::KernelClass;
use strided_basic::{copy_into, map_into, sum};
use strided_view::{StridedView, StridedViewMut};
use tcontract::api::{CSpec, DType, Labels, LayoutSpec, Op, OperandSpec, Problem};
use tcontract::{Plan, PlanConfig};
use tcontract_exec::{ArenaProvider, BatchPolicy};
use threadteam::Exec;

fn strided(kind: &'static str, n: usize) -> Work {
    let src: Vec<f64> = (0..n).map(|i| (i % 97) as f64 * 0.01).collect();
    let mut dst = vec![0f64; n];
    let run: Box<dyn FnMut(Exec<'_>) + Send> = match kind {
        "copy" => Box::new(move |exec| {
            let s: StridedView<f64> = StridedView::new(&src, &[n], &[1], 0).unwrap();
            let mut d = StridedViewMut::new(&mut dst, &[n], &[1], 0).unwrap();
            copy_into(&mut d, &s, exec).unwrap();
        }),
        "map" => Box::new(move |exec| {
            let s: StridedView<f64> = StridedView::new(&src, &[n], &[1], 0).unwrap();
            let mut d = StridedViewMut::new(&mut dst, &[n], &[1], 0).unwrap();
            map_into(&mut d, &s, |x: f64| x * 2.0 + 1.0, exec).unwrap();
        }),
        "exp" => Box::new(move |exec| {
            let s: StridedView<f64> = StridedView::new(&src, &[n], &[1], 0).unwrap();
            let mut d = StridedViewMut::new(&mut dst, &[n], &[1], 0).unwrap();
            map_into(&mut d, &s, KernelClass::Transcendental.with(|x: f64| x.exp()), exec).unwrap();
        }),
        "sum" => Box::new(move |exec| {
            let s: StridedView<f64> = StridedView::new(&src, &[n], &[1], 0).unwrap();
            std::hint::black_box(sum(&s, exec).unwrap());
        }),
        _ => unreachable!(),
    };
    Work { family: kind, shape: format!("{n}"), run }
}

fn col_major(dims: &[usize]) -> OperandSpec {
    let mut strides = Vec::new();
    let mut acc = 1isize;
    for &d in dims {
        strides.push(acc);
        acc *= d as isize;
    }
    OperandSpec::new(LayoutSpec::new(dims, &strides, 0).unwrap()).with_op(Op::Identity)
}

fn tcontract_matmul(n: usize, arena: &'static ArenaProvider) -> Work {
    let (ia, ib, id): (Vec<i64>, Vec<i64>, Vec<i64>) = (vec![105, 107], vec![107, 106], vec![105, 106]);
    let dims = [n, n];
    let problem = Problem::from_labels(
        DType::F64,
        col_major(&dims),
        col_major(&dims),
        CSpec::Absent,
        col_major(&dims),
        &Labels::new(&ia, &ib, &id),
    )
    .unwrap();
    let plan = Plan::<f64>::new(&problem, &PlanConfig::default()).unwrap();
    let a: Vec<f64> = (0..n * n).map(|i| (i % 13) as f64 * 0.1).collect();
    let b: Vec<f64> = (0..n * n).map(|i| (i % 7) as f64 * 0.1).collect();
    let mut d = vec![0f64; n * n];
    let st = [1isize, n as isize];
    Work {
        family: "tc_matmul",
        shape: format!("{n}"),
        run: Box::new(move |tok| {
            let mut exec = tcontract_exec::Exec::from_token(tok, Some(arena), BatchPolicy::default());
            let va = StridedView::new(&a, &dims, &st, 0).unwrap();
            let vb = StridedView::new(&b, &dims, &st, 0).unwrap();
            let mut vd = StridedViewMut::new(&mut d, &dims, &st, 0).unwrap();
            plan.execute_into(&mut exec, 1.0, &va, &vb, &mut vd).unwrap();
        }),
    }
}

/// `D[i,l] = A[i,j] B[j,k] C[k,l]` through cpueinsum: two pairwise steps on `n x n` matrices.
fn einsum_chain(n: usize, arena: &'static ArenaProvider) -> Work {
    use cpueinsum::{EinsumPlan, EinsumSpec, Layout, Scratch};
    let spec = EinsumSpec::new(&[&[0, 1], &[1, 2], &[2, 3]], &[0, 3], &[[0, 1], [2, 3]]).unwrap();
    let dims = [n, n];
    let st = [1isize, n as isize];
    let a: Vec<f64> = (0..n * n).map(|i| (i % 13) as f64 * 0.1).collect();
    let b: Vec<f64> = (0..n * n).map(|i| (i % 7) as f64 * 0.1).collect();
    let c: Vec<f64> = (0..n * n).map(|i| (i % 5) as f64 * 0.1).collect();
    let mut d = vec![0f64; n * n];
    let la = Layout::new(&dims, &st).unwrap();
    let plan = EinsumPlan::<f64>::new(&spec, &[la, la, la], la).unwrap();
    let mut scratch = Scratch::with_len(plan.scratch_len());
    Work {
        family: "einsum_chain",
        shape: format!("{n}"),
        run: Box::new(move |tok| {
            let mut exec = tcontract_exec::Exec::from_token(tok, Some(arena), BatchPolicy::default());
            let va = StridedView::new(&a, &dims, &st, 0).unwrap();
            let vb = StridedView::new(&b, &dims, &st, 0).unwrap();
            let vc = StridedView::new(&c, &dims, &st, 0).unwrap();
            let mut vd = StridedViewMut::new(&mut d, &dims, &st, 0).unwrap();
            plan.execute_into(&mut exec, &[va, vb, vc], &mut vd, &mut scratch).unwrap();
        }),
    }
}

fn main() {
    let mut args = std::env::args().skip(1);
    let rounds: usize = args.next().and_then(|s| s.parse().ok()).unwrap_or(3);
    let w: usize = args.next().and_then(|s| s.parse().ok()).unwrap_or(8);
    let arena: &'static ArenaProvider = Box::leak(Box::new(ArenaProvider::new()));
    let mut works = Vec::new();
    for kind in ["copy", "map", "exp", "sum"] {
        for e in 10..=21 {
            works.push(strided(kind, 1usize << e));
        }
    }
    for n in [32, 48, 64, 96, 128, 192, 256] {
        works.push(tcontract_matmul(n, arena));
    }
    for n in [32, 48, 64, 96, 128, 192] {
        works.push(einsum_chain(n, arena));
    }
    sweep(&mut works, rounds, w);
}
