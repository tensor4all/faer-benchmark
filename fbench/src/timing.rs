//! Time-based priming followed by every timed repetition, in execution order.
//!
//! `prepare` is outside each clocked region. All providers use this loop;
//! equivalent work inside their `run` closures must be audited separately.

use std::time::{Duration, Instant};

use crate::op::Op;

/// CPU time consumed by every thread of this process, in nanoseconds (user plus system).
///
/// Read around a call, the difference over the call's wall time is how many cores the process kept
/// busy while it ran, which is what a waiting policy that spins costs and one that sleeps does not.
pub fn process_cpu_ns() -> u64 {
    let mut ts = libc::timespec {
        tv_sec: 0,
        tv_nsec: 0,
    };
    // SAFETY: `ts` is a valid out-pointer for the duration of the call.
    let rc = unsafe { libc::clock_gettime(libc::CLOCK_PROCESS_CPUTIME_ID, &mut ts) };
    if rc != 0 {
        return 0;
    }
    ts.tv_sec as u64 * 1_000_000_000 + ts.tv_nsec as u64
}

/// Everything one timed loop records.
pub struct Measured {
    /// Wall time of each `run`, in milliseconds, in execution order.
    pub samples_ms: Vec<f64>,
    /// Process CPU time (all threads) consumed during each `run`, in milliseconds. The two clock
    /// reads sit outside the wall clock's window.
    pub cpu_samples_ms: Vec<f64>,
    /// Wall time of the whole repetition phase, `prepare` included, in milliseconds.
    pub loop_wall_ms: f64,
    /// Process CPU time of the same phase, in milliseconds.
    pub loop_cpu_ms: f64,
}

/// Prime for `prime_ms`, then return all `reps` times in milliseconds.
/// The op's `check` runs once afterwards, outside the clock.
pub fn measure(op: &mut Op, prime_ms: u64, reps: usize) -> Result<Vec<f64>, String> {
    measure_full(op, prime_ms, reps).map(|m| m.samples_ms)
}

/// As [`measure`], and also the process CPU time of every repetition and of the whole phase.
pub fn measure_full(op: &mut Op, prime_ms: u64, reps: usize) -> Result<Measured, String> {
    if reps == 0 {
        return Err("--reps must be positive".to_owned());
    }
    let mut samples = Vec::with_capacity(reps);
    let mut cpu_samples = Vec::with_capacity(reps);
    let until = Instant::now() + Duration::from_millis(prime_ms);
    while Instant::now() < until {
        op.prepare()?;
        op.run()?;
    }
    let loop_cpu0 = process_cpu_ns();
    let loop_start = Instant::now();
    for _ in 0..reps {
        op.prepare()?;
        let cpu0 = process_cpu_ns();
        let start = Instant::now();
        op.run()?;
        let elapsed = start.elapsed();
        let cpu1 = process_cpu_ns();
        samples.push(elapsed.as_secs_f64() * 1e3);
        cpu_samples.push(cpu1.saturating_sub(cpu0) as f64 * 1e-6);
    }
    let loop_wall = loop_start.elapsed();
    let loop_cpu = process_cpu_ns().saturating_sub(loop_cpu0);
    op.check()?;
    op.prepare()?;
    Ok(Measured {
        samples_ms: samples,
        cpu_samples_ms: cpu_samples,
        loop_wall_ms: loop_wall.as_secs_f64() * 1e3,
        loop_cpu_ms: loop_cpu as f64 * 1e-6,
    })
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
