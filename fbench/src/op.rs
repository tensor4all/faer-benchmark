//! The uniform operation a measurement loop drives, independent of provider.
//!
//! A provider arm builds an `Op` for a case out of three closures over its own
//! state: `prepare` restores the caller-visible inputs, `run` performs the
//! measured operation, and `check` verifies the result against that provider's
//! own contract. Keeping the three separate is what lets the timing loop clock
//! only `run`, prepare and restore outside the clock, and still verify the exact
//! state the timed call left behind.

use std::cell::RefCell;
use std::rc::Rc;

/// One step of an operation: `Ok(())` or a message explaining the failure.
pub type Step = Box<dyn FnMut() -> Result<(), String>>;

/// A provider operation for one case.
pub struct Op {
    /// A truthful note recorded in the CSV (`block`, or why a route differs).
    pub note: String,
    prepare: Step,
    run: Step,
    check: Step,
}

impl Op {
    pub fn prepare(&mut self) -> Result<(), String> {
        (self.prepare)()
    }
    pub fn run(&mut self) -> Result<(), String> {
        (self.run)()
    }
    pub fn check(&mut self) -> Result<(), String> {
        (self.check)()
    }
}

/// Build an [`Op`] whose three closures share one state.
pub fn op_from<S: 'static>(
    state: S,
    note: String,
    prepare: impl Fn(&mut S) -> Result<(), String> + 'static,
    run: impl Fn(&mut S) -> Result<(), String> + 'static,
    check: impl Fn(&mut S) -> Result<(), String> + 'static,
) -> Op {
    let state = Rc::new(RefCell::new(state));
    let (a, b, c) = (state.clone(), state.clone(), state);
    Op {
        note,
        prepare: Box::new(move || prepare(&mut a.borrow_mut())),
        run: Box::new(move || run(&mut b.borrow_mut())),
        check: Box::new(move || check(&mut c.borrow_mut())),
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
                            op.run().unwrap();
                            op.check().unwrap();
                            op.run = Box::new(|| Ok(()));
                            op.prepare().unwrap();
                            op.run().unwrap();
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
