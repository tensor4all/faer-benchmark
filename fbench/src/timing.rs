//! Time-based priming followed by every timed repetition, in execution order.
//!
//! `prepare` is outside each clocked region. All providers use this loop;
//! equivalent work inside their `run` closures must be audited separately.

use std::time::{Duration, Instant};

use crate::op::Op;

/// Prime for `prime_ms`, then return all `reps` times in milliseconds.
/// The op's `check` runs once afterwards, outside the clock.
pub fn measure(op: &mut Op, prime_ms: u64, reps: usize) -> Result<Vec<f64>, String> {
    if reps == 0 {
        return Err("--reps must be positive".to_owned());
    }
    let mut samples = Vec::with_capacity(reps);
    let until = Instant::now() + Duration::from_millis(prime_ms);
    while Instant::now() < until {
        op.prepare()?;
        op.run()?;
    }
    for _ in 0..reps {
        op.prepare()?;
        let start = Instant::now();
        op.run()?;
        let elapsed = start.elapsed();
        samples.push(elapsed.as_secs_f64() * 1e3);
    }
    op.check()?;
    op.prepare()?;
    Ok(samples)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::op::op_from;
    use std::sync::{Arc, Mutex};

    #[test]
    fn retains_repetitions_and_checks_the_last_run() {
        let events = Arc::new(Mutex::new(Vec::new()));
        let mut op = op_from(
            events.clone(),
            String::new(),
            |e| {
                e.lock().unwrap().push("prepare");
                Ok(())
            },
            |e| {
                e.lock().unwrap().push("run");
                Ok(())
            },
            |e| {
                e.lock().unwrap().push("check");
                Ok(())
            },
        );
        assert!(measure(&mut op, 0, 0).is_err());
        assert!(events.lock().unwrap().is_empty());
        let samples = measure(&mut op, 0, 3).unwrap();
        assert_eq!(samples.len(), 3);
        assert!(samples.iter().all(|v| v.is_finite() && *v >= 0.0));
        assert_eq!(
            *events.lock().unwrap(),
            ["prepare", "run", "prepare", "run", "prepare", "run", "check", "prepare"]
        );
        let mut failed = op_from(
            (),
            String::new(),
            |_| Ok(()),
            |_| Ok(()),
            |_| Err("bad result".to_owned()),
        );
        assert_eq!(measure(&mut failed, 0, 3).unwrap_err(), "bad result");
    }
}
