//! The `faer-fork-team` row (stage 2 of tensor4all/faer-benchmark#24): the fork's `Par::Team` route
//! on a threadteam team, held for the whole timed session.
//!
//! `with_session(threads, f)` builds a pool of `threads` workers with QoS `UserInitiated`, turns it
//! into a team of width `threads` (the calling thread is participant 0, so `threads - 1` workers are
//! reserved and one pool worker stays unused; `into_team(width)` counts the leader and clamps to the
//! pool width), raises the calling thread to `UserInitiated`, installs the team on the calling thread
//! with `faer::utils::team::with_team` and runs `f`. Nothing is started per call: faer's
//! `Par::Team(threads)` regions dispatch to the reserved members.

use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::Duration;
use threadteam::{raise_current_thread_qos, Pool, Qos};

/// The thread budget of this process (set by `configure_threads`), so `ops_for` can set the fork's
/// global parallelism per row.
pub static THREADS: AtomicUsize = AtomicUsize::new(1);

pub fn threads() -> usize {
    THREADS.load(Ordering::Relaxed)
}

pub fn with_session<R>(threads: usize, f: impl FnOnce() -> R) -> Result<R, String> {
    raise_current_thread_qos(Qos::UserInitiated);
    let pool = Pool::builder()
        .threads(threads)
        .qos(Qos::UserInitiated)
        .acquire_timeout(Duration::from_secs(30))
        .build()
        .map_err(|e| format!("cannot build the team pool: {e}"))?;
    let team = pool
        .into_team(threads)
        .map_err(|e| format!("cannot reserve the team: {e}"))?;
    if team.size().get() != threads {
        return Err(format!("the team has {} participants, expected {threads}", team.size()));
    }
    let mut exec = team.exec(threads);
    Ok(faer_fork::utils::team::with_team(&mut exec, f))
}

#[cfg(test)]
mod tests {
    #[test]
    fn session_has_the_requested_width() {
        let n = super::with_session(4, || faer_fork::utils::team::available(4)).unwrap();
        assert_eq!(n, 4);
    }
}
