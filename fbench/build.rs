//! Make the MKL arm link and run the way the campaign requires.
//!
//! Two things `intel-mkl-src` does not do, both of which matter because the
//! recorder executes the harness binary directly with no loader search path to
//! arrange and no environment of its own:
//!
//! * it emits `-L`/`-l` for the dynamic MKL interface, threading layer and core
//!   plus the Intel OpenMP runtime, but no rpath, so the versioned directories
//!   `scripts/build_for_faer_rev.sh` resolved have to be recorded here;
//! * the linker's `--as-needed` default drops `mkl_intel_thread`, `mkl_core` and
//!   `iomp5`, because the harness's own undefined symbols (`cblas_?gemm`,
//!   `LAPACKE_*`) are all defined by `mkl_intel_lp64`. The interface layer then
//!   fails to relocate its own `mkl_blas_*` references at load time. The three
//!   are forced back in after `--no-as-needed`.
//!
//! Nothing here follows a moving `latest` symlink: `MKLROOT` and
//! `MKL_THREADING_LIB` are the versioned paths the build script exports, and the
//! binary records what was linked. The OpenBLAS arm is linked statically
//! (`openblas-src/static`), so it needs neither of these and this does nothing.

use std::path::PathBuf;

fn main() {
    println!("cargo:rerun-if-env-changed=MKLROOT");
    println!("cargo:rerun-if-env-changed=MKL_THREADING_LIB");
    if std::env::var_os("CARGO_FEATURE_LINK_MKL").is_none() {
        return;
    }
    let mut dirs = Vec::new();
    if let Some(root) = std::env::var_os("MKLROOT") {
        dirs.push(PathBuf::from(root).join("lib"));
    }
    if let Some(threading) = std::env::var_os("MKL_THREADING_LIB") {
        if let Some(parent) = PathBuf::from(threading).parent() {
            dirs.push(parent.to_path_buf());
        }
    }
    for dir in &dirs {
        if dir.is_dir() {
            println!("cargo:rustc-link-search=native={}", dir.display());
            println!("cargo:rustc-link-arg=-Wl,-rpath,{}", dir.display());
        }
    }
    // The `link-mkl` feature selects LP64 + Intel OpenMP, so the chain is fixed.
    println!("cargo:rustc-link-arg=-Wl,--no-as-needed");
    for lib in ["mkl_intel_lp64", "mkl_intel_thread", "mkl_core", "iomp5"] {
        println!("cargo:rustc-link-arg=-l{lib}");
    }
    println!("cargo:rustc-link-arg=-Wl,--as-needed");
}
