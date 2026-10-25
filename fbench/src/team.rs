//! The awake borrowed Rayon team (stage 1 of tensor4all/faer-benchmark#24).
//!
//! `with_team(threads, f)` borrows `threads - 1` workers of the global Rayon pool through a top
//! level `rayon::scope`, so the caller of `f` (the leader) is itself a pool worker, as it is under
//! `spindle::with_lock`. While `f` runs, each member loops over `rayon::yield_now()` and
//! `spin_loop`, never sleeping, so any Rayon job the leader or faer forks (a `par_iter`, a `join`,
//! `spindle::for_each` outside a region, the `gemm` crate's `par_for_each`) is picked up at once.
//!
//! This is the compatibility form of the candidate, not a reserved team: `yield_now` runs the job it
//! takes to completion, nested work included, before the member returns to its loop, so no member
//! is promised to a barrier-bearing kernel. No thread-local state is kept; members exit when `f`
//! returns.
//!
//! Start-up is acknowledged: a member that has started does not call `yield_now` until every
//! member has started, because a member that yielded early could take another member's loop job and
//! run two loops on one thread, leaving the team a worker short. The leader checks that the members
//! sit on distinct pool threads before `f` begins.

use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};
use std::sync::Mutex;

struct State {
    started: AtomicUsize,
    ready: AtomicBool,
    stop: AtomicBool,
    ids: Mutex<Vec<usize>>,
}

/// Releases the members on every exit, a panic in `f` included, so the scope can end.
struct Release<'a>(&'a AtomicBool);

impl Drop for Release<'_> {
    fn drop(&mut self) {
        self.0.store(true, Ordering::Release);
    }
}

fn member(state: &State) {
    let id = rayon::current_thread_index().unwrap_or(usize::MAX);
    state.ids.lock().unwrap().push(id);
    state.started.fetch_add(1, Ordering::AcqRel);
    while !state.ready.load(Ordering::Acquire) {
        if state.stop.load(Ordering::Acquire) {
            return;
        }
        std::hint::spin_loop();
    }
    while !state.stop.load(Ordering::Acquire) {
        rayon::yield_now();
        std::hint::spin_loop();
    }
}

/// Run `f` as the leader of an awake team of `threads` (the leader plus `threads - 1` members).
/// `threads == 1` runs `f` directly, as every row does at one thread.
pub fn with_team<R: Send>(threads: usize, f: impl FnOnce() -> R + Send) -> Result<R, String> {
    if threads <= 1 {
        return Ok(f());
    }
    let pool = rayon::current_num_threads();
    if pool < threads {
        return Err(format!("the pool has {pool} workers, the team needs {threads}"));
    }
    let members = threads - 1;
    let state = State {
        started: AtomicUsize::new(0),
        ready: AtomicBool::new(false),
        stop: AtomicBool::new(false),
        ids: Mutex::new(Vec::new()),
    };
    let state = &state;
    rayon::scope(|scope| {
        for _ in 0..members {
            scope.spawn(move |_| member(state));
        }
        // The leader waits without taking work: the member loops sit in its deque until the other
        // workers steal them.
        while state.started.load(Ordering::Acquire) < members {
            std::hint::spin_loop();
        }
        let _release = Release(&state.stop);
        let verdict = {
            let mut ids = state.ids.lock().unwrap().clone();
            ids.push(rayon::current_thread_index().unwrap_or(usize::MAX));
            ids.sort_unstable();
            ids.dedup();
            if ids.len() == threads && !ids.contains(&usize::MAX) {
                Ok(())
            } else {
                Err(format!(
                    "the team of {threads} sits on {} distinct pool threads",
                    ids.len()
                ))
            }
        };
        let result = match &verdict {
            Ok(()) => {
                state.ready.store(true, Ordering::Release);
                Some(f())
            }
            Err(_) => None,
        };
        match (verdict, result) {
            (Ok(()), Some(r)) => Ok(r),
            (Err(e), _) => Err(e),
            _ => unreachable!(),
        }
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn team_serves_rayon_jobs_and_exits() {
        use rayon::prelude::*;
        let pool = rayon::ThreadPoolBuilder::new().num_threads(4).build().unwrap();
        pool.install(|| {
            let sum: usize = with_team(4, || (0..1000usize).into_par_iter().sum()).unwrap();
            assert_eq!(sum, 499500);
            // the team can be formed again once it has been returned
            let again = with_team(4, || 7).unwrap();
            assert_eq!(again, 7);
        });
    }

    #[test]
    fn one_thread_runs_directly() {
        assert_eq!(with_team(1, || 3).unwrap(), 3);
    }
}
