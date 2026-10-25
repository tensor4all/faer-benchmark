//! macOS quality of service for the benchmark threads (tensor4all/faer-benchmark#24, stage 1 baseline).
//!
//! macOS cannot pin threads. Setting `QOS_CLASS_USER_INITIATED` on every thread the process runs
//! work on (the main thread and every Rayon worker, which are also the spindle workers and the
//! awake team's members) asks the scheduler to keep them on the fastest cores. It is opt-in:
//! `FBENCH_QOS=user-initiated` turns it on, anything else leaves the threads at the default.
//! `report` verifies the class with `pthread_get_qos_class_np` on the main thread and on every
//! pool worker and prints one `qos.*` line per fact on stderr.

#[cfg(target_os = "macos")]
mod imp {
    use std::os::raw::c_int;

    pub const QOS_CLASS_USER_INITIATED: u32 = 0x19;

    extern "C" {
        fn pthread_set_qos_class_self_np(qos_class: u32, relative_priority: c_int) -> c_int;
        fn pthread_get_qos_class_np(
            thread: libc::pthread_t,
            qos_class: *mut u32,
            relative_priority: *mut c_int,
        ) -> c_int;
    }

    pub fn enabled() -> bool {
        std::env::var("FBENCH_QOS").map(|v| v == "user-initiated").unwrap_or(false)
    }

    /// Set the calling thread's class. Returns the pthread error code (0 on success).
    pub fn set_self() -> i32 {
        unsafe { pthread_set_qos_class_self_np(QOS_CLASS_USER_INITIATED, 0) }
    }

    /// The calling thread's class (0 when it cannot be read).
    pub fn get_self() -> u32 {
        let mut class = 0u32;
        let mut prio: c_int = 0;
        let rc = unsafe { pthread_get_qos_class_np(libc::pthread_self(), &mut class, &mut prio) };
        if rc == 0 {
            class
        } else {
            0
        }
    }
}

#[cfg(not(target_os = "macos"))]
mod imp {
    pub fn enabled() -> bool {
        false
    }
    pub fn set_self() -> i32 {
        0
    }
    pub fn get_self() -> u32 {
        0
    }
}

pub use imp::enabled;

/// Set the main thread's class when `FBENCH_QOS=user-initiated`.
pub fn init_main() {
    if enabled() {
        let rc = imp::set_self();
        if rc != 0 {
            eprintln!("qos.main_set_error={rc}");
        }
    }
}

/// The Rayon `start_handler` body: set the class on a pool thread as it starts.
pub fn init_worker() {
    if enabled() {
        let _ = imp::set_self();
    }
}

/// Print the verified classes (`stage` is `before` or `after` the timed work).
pub fn report(stage: &str) {
    let main = imp::get_self();
    let pool: Vec<u32> = rayon::broadcast(|_| imp::get_self()).into_iter().collect();
    let all = !pool.is_empty() && pool.iter().all(|c| *c == main) && main != 0;
    eprintln!("qos.requested={}", if enabled() { "user-initiated" } else { "default" });
    eprintln!("qos.{stage}.main=0x{main:x}");
    eprintln!("qos.{stage}.pool=[{}]", pool.iter().map(|c| format!("0x{c:x}")).collect::<Vec<_>>().join(","));
    eprintln!("qos.{stage}.pool_threads={}", pool.len());
    eprintln!("qos.{stage}.all_same_as_main={all}");
    eprintln!("qos.{stage}.all_user_initiated={}", main == 0x19 && pool.iter().all(|c| *c == 0x19));
}
