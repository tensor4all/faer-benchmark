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
