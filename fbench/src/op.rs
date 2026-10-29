//! The uniform operation a measurement loop drives, independent of provider.
//!
//! A provider arm builds an `Op` for a case out of three closures over its own
//! state: `prepare` restores the caller-visible inputs, `run` performs the
//! measured operation, and `check` verifies the result against that provider's
//! own contract. Keeping the three separate is what lets the timing loop clock
//! only `run`, prepare and restore outside the clock, and still verify the exact
//! state the timed call left behind.

/// The parallelism of the measured call, lent to the loop's `run` closures.
///
/// The measured library's `Par` is not `Copy` from 0.25 on (a team is exclusive authority over
/// reserved members), so a row cannot build one per call from a copyable configuration: the timing
/// loop owns the row's parallelism and lends it. `None` is a row with no team (a budget of one
/// thread, or any provider that is not the fork); the fork's `run` closures hand it a
/// [`Token::Fork`] when the harness was built for the team API (`fork-team`, see
/// `scripts/build_for_faer_rev.sh`).
pub enum Token<'a> {
    /// no team: the row's call is sequential (a budget of one thread, a provider that is not the
    /// fork, or a harness built for a fork without the team API)
    None(core::marker::PhantomData<&'a ()>),
    #[cfg(feature = "fork-team")]
    Fork(faer_fork::Par<'a>),
}

impl Token<'_> {
    /// The token of a row that carries no team.
    pub fn none() -> Token<'static> {
        Token::None(core::marker::PhantomData)
    }

    pub fn reborrow(&mut self) -> Token<'_> {
        match self {
            Token::None(_) => Token::none(),
            #[cfg(feature = "fork-team")]
            Token::Fork(par) => Token::Fork(par.reborrow()),
        }
    }
}

/// The three steps of an operation over one state, type-erased. `Send` because the timing loop
/// may run inside a held spindle worker group, whose entry requires it; every provider's state is
/// plain buffers.
trait Steps: Send {
    fn prepare(&mut self) -> Result<(), String>;
    fn run(&mut self, token: Token<'_>) -> Result<(), String>;
    fn check(&mut self) -> Result<(), String>;
}

struct Closures<S, P, R, C> {
    state: S,
    prepare: P,
    run: R,
    check: C,
}

impl<S, P, R, C> Steps for Closures<S, P, R, C>
where
    S: Send,
    P: Fn(&mut S) -> Result<(), String> + Send,
    R: for<'a> Fn(&mut S, Token<'a>) -> Result<(), String> + Send,
    C: Fn(&mut S) -> Result<(), String> + Send,
{
    fn prepare(&mut self) -> Result<(), String> {
        (self.prepare)(&mut self.state)
    }
    fn run(&mut self, token: Token<'_>) -> Result<(), String> {
        (self.run)(&mut self.state, token)
    }
    fn check(&mut self) -> Result<(), String> {
        (self.check)(&mut self.state)
    }
}

/// A provider operation for one case.
pub struct Op {
    /// A truthful note recorded in the CSV (`block`, or why a route differs).
    pub note: String,
    steps: Box<dyn Steps>,
}

impl Op {
    /// The same operation with `run` replaced by a no-op: the test that proves every `check`
    /// rejects a result that was never computed.
    #[cfg(test)]
    pub fn without_run(self) -> Op {
        struct NoRun(Box<dyn Steps>);
        impl Steps for NoRun {
            fn prepare(&mut self) -> Result<(), String> {
                self.0.prepare()
            }
            fn run(&mut self, _token: Token<'_>) -> Result<(), String> {
                Ok(())
            }
            fn check(&mut self) -> Result<(), String> {
                self.0.check()
            }
        }
        Op {
            note: self.note,
            steps: Box::new(NoRun(self.steps)),
        }
    }
    pub fn prepare(&mut self) -> Result<(), String> {
        self.steps.prepare()
    }
    pub fn run(&mut self, token: Token<'_>) -> Result<(), String> {
        self.steps.run(token)
    }
    pub fn check(&mut self) -> Result<(), String> {
        self.steps.check()
    }
}

/// Build an [`Op`] whose three closures share one state.
pub fn op_from<S: Send + 'static>(
    state: S,
    note: String,
    prepare: impl Fn(&mut S) -> Result<(), String> + Send + 'static,
    run: impl for<'a> Fn(&mut S, Token<'a>) -> Result<(), String> + Send + 'static,
    check: impl Fn(&mut S) -> Result<(), String> + Send + 'static,
) -> Op {
    Op {
        note,
        steps: Box::new(Closures {
            state,
            prepare,
            run,
            check,
        }),
    }
}

#[cfg(test)]
mod tests {
    use crate::{
        backend,
        shared::{Case, Dtype, Order},
        vendor,
    };
    use std::panic::{catch_unwind, AssertUnwindSafe};

    #[test]
    fn checks_reject_a_missing_execution() {
        backend::fork::set_threads(1);
        backend::upstream::set_threads(1);
        if vendor::NAME != "none" {
            vendor::set_threads(1).unwrap();
        }
        for row in crate::engine_rows() {
            for family in [
                "gemm",
                "qr_factor",
                "qr",
                "lu",
                "full_piv_lu",
                "cholesky",
                "solve",
                "triangular_solve",
                "svd_values",
                "svd_thin",
                "eigh",
                "householder_apply",
            ] {
                if !row.starts_with("faer-")
                    && matches!(
                        family,
                        "full_piv_lu" | "triangular_solve" | "householder_apply"
                    )
                {
                    continue;
                }
                for dtype in [Dtype::F64, Dtype::C64] {
                    for order in [Order::C, Order::F] {
                        let case = Case {
                            m: 8,
                            n: 8,
                            k: if family == "gemm" { Some(8) } else { None },
                            batch: 2,
                        };
                        let ops = crate::ops_for(&row, dtype, family, case, order).unwrap();
                        assert_eq!(ops.len(), if family == "householder_apply" { 2 } else { 1 });
                        for mut op in ops {
                            op.prepare().unwrap();
                            op.run(crate::op::Token::none()).unwrap();
                            op.check().unwrap();
                            let mut op = op.without_run();
                            op.prepare().unwrap();
                            op.run(crate::op::Token::none()).unwrap();
                            // Missing retained output may fail with Err or bounds panic;
                            // recomputing a fresh correct answer must never pass.
                            let result = catch_unwind(AssertUnwindSafe(|| op.check()));
                            assert!(
                                !matches!(result, Ok(Ok(()))),
                                "{row} {family} {} {} {} checked a replacement result",
                                dtype.label(),
                                order.label(),
                                op.note
                            );
                        }
                    }
                }
            }
        }
    }
}
