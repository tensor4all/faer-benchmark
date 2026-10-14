//! The timing policy: time-based priming, then the best of `reps`.
//!
//! Priming is a wall-clock duration, not a call count: after an idle gate this
//! host reads low for the first second or two of sustained AVX-512 work, and a
//! fixed count would not cover it. `prepare` is called outside every clocked
//! region, so restoring the caller-visible inputs is never charged to the
//! provider, and the same priming runs on every arm.

use std::time::{Duration, Instant};

use crate::op::Op;

/// Prime for `prime_ms`, then return the best of `reps` timed runs, in
/// milliseconds. The op's `check` runs once afterwards, outside the clock.
pub fn measure(op: &mut Op, prime_ms: u64, reps: usize) -> Result<f64, String> {
    let until = Instant::now() + Duration::from_millis(prime_ms);
    while Instant::now() < until {
        op.prepare()?;
        op.run()?;
    }
    let mut best = Duration::MAX;
    for _ in 0..reps.max(1) {
        op.prepare()?;
        let start = Instant::now();
        op.run()?;
        best = best.min(start.elapsed());
    }
    op.check()?;
    op.prepare()?;
    Ok(best.as_secs_f64() * 1e3)
}
