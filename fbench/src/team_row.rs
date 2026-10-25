//! The `faer-fork-team` row (stage 2 of tensor4all/faer-benchmark#24): the fork's `Par::Team` route
//! on a threadteam team, held for the whole timed session.
//!
//! `with_session(threads, f)` builds a pool of `threads` workers with QoS `UserInitiated`, turns it
//! into a team of width `threads` (the calling thread is participant 0, so `threads - 1` workers are
//! reserved and one pool worker stays unused; `into_team(width)` counts the leader and clamps to the
//! pool width), raises the calling thread to `UserInitiated`, installs the team on the calling thread
//! with `faer::utils::team::with_team` and runs `f`. Nothing is started per call: faer's
//! `Par::Team(threads)` regions dispatch to the reserved members.

use std::cell::Cell;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::time::Duration;
use threadteam::{raise_current_thread_qos, Pool, Qos, TeamExec};

/// The thread budget of this process (set by `configure_threads`), so `ops_for` can set the fork's
/// global parallelism per row.
pub static THREADS: AtomicUsize = AtomicUsize::new(1);

pub fn threads() -> usize {
    THREADS.load(Ordering::Relaxed)
}

thread_local! {
    /// The session's team, for the thread that opened it. The harness's `Op`s are `'static`, so they
    /// cannot borrow the `TeamExec` that lives in the session frame; they ask for a `Par` per call
    /// ([`par`]) and the session hands out reborrows of this one authority. The pointer is set
    /// inside [`with_session`] and cleared before it returns, and only the opening thread reads it.
    static CURRENT: Cell<*mut TeamExec<'static>> = const { Cell::new(std::ptr::null_mut()) };
}

/// A `Par` over the session's team for one call: a reborrow, so the session keeps the authority.
/// Outside a session it is sequential.
pub fn par() -> faer_fork::Par<'static> {
    let p = CURRENT.with(|c| c.get());
    if p.is_null() {
        faer_fork::Par::Seq
    } else {
        // SAFETY: `p` points at the `TeamExec` of the open session on this thread; the returned
        // value is used for one call that ends before the session does, and nothing else uses the
        // team meanwhile (the harness drives one op at a time).
        faer_fork::Par::Team(unsafe { (*p).reborrow() })
    }
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
    let mut f = Some(f);
    exec.team(|mut t| {
        assert_eq!(t.size().get(), threads);
        CURRENT.with(|c| c.set((&mut t as *mut TeamExec<'_>).cast::<TeamExec<'static>>()));
        let r = (f.take().unwrap())();
        CURRENT.with(|c| c.set(std::ptr::null_mut()));
        r
    })
    .map_err(|e| format!("cannot enter the team: {e:?}"))
}

/// One flat section of `n` participants on the session's team (the dispatch probe).
pub fn run_flat(n: usize, body: &(dyn Fn(usize, usize) + Sync)) {
    let p = CURRENT.with(|c| c.get());
    assert!(!p.is_null(), "no open team session");
    // SAFETY: as in `par`.
    let team = unsafe { (*p).reborrow() };
    let size = team.size().get();
    if n >= size {
        team.run(|i, k| body(i, k));
    } else {
        let _ = team.split(&[n], |_c, child| child.run(|i, k| body(i, k)));
    }
}

#[cfg(test)]
mod tests {
    /// The QoS class of the leader and of every reserved member, read on the participants' own
    /// threads (`pthread_get_qos_class_np`): all `QOS_CLASS_USER_INITIATED` (0x19).
    #[cfg(target_os = "macos")]
    #[test]
    fn team_participants_run_at_user_initiated() {
        extern "C" {
            fn pthread_get_qos_class_np(t: libc::pthread_t, c: *mut u32, p: *mut i32) -> i32;
        }
        let classes = std::sync::Mutex::new(Vec::new());
        super::with_session(6, || {
            super::run_flat(6, &|_i, _n| {
                let mut c = 0u32;
                let mut p = 0i32;
                unsafe { pthread_get_qos_class_np(libc::pthread_self(), &mut c, &mut p) };
                classes.lock().unwrap().push(c);
            });
        })
        .unwrap();
        let classes = classes.into_inner().unwrap();
        eprintln!("team qos classes: {classes:x?}");
        assert_eq!(classes.len(), 6);
        assert!(classes.iter().all(|c| *c == 0x19), "{classes:x?}");
    }

    #[test]
    fn session_has_the_requested_width() {
        let n = super::with_session(4, || super::par().degree()).unwrap();
        assert_eq!(n, 4);
    }
}
