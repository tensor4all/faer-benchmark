# Harness dtype axis: `f32` and `c32`, and a 64-cell default

## Decisions

**Why now.** `fbench` declares `Dtype::{F64, C64}`; `backend::ops` dispatches on it and `svd_values_op`
stores its output as `f64`, so the campaign cannot measure `f32`/`c32` at all. The fork's column-slab change admitted those two
dtypes on a standalone driver (`probes/dtype-gemm`) and there is no campaign cell to confirm it, which
is exactly the hole the harness should close. faer's native kernel serves all four dtypes, so the two
unmeasured ones are real paths, not hypotheticals.

**Scope of this change.** Two things, and nothing else:

1. `fbench` grows the two dtypes: `Dtype::F32`/`Dtype::C32`, `Scalar` for `f32`/`Complex32`, a
   per-dtype residual tolerance, the fork and upstream adapters dispatch to them, and the vendor arm
   gets `cblas_sgemm`/`cblas_cgemm`.
2. **The harness's default benchmark measures the 64 cell only.** With no `--n`, `run` and `verify`
   default the shape list to the single raw shape `64`, which `RawShape::case` turns into the gemm
   triple `64x64x64` and leaves as `64` for every other family. The recorder always names its shapes
   from the suite (`--n` in `record_run.py`), so a recorded run cannot shrink silently.

**Staging, because the vendor half is large.** `lapack.rs` writes its bindings out per dtype rather
than through a macro (1200 lines), so the LAPACK drivers for `s`/`c` prefixes are a second slice. This
change ships `gemm` for the vendor arm and leaves every other vendor family without an `f32`/`c32`
route. The GEMM capability is therefore its own trait (`LapackGemm`) and `LapackScalar: LapackGemm`
carries the drivers, so a dtype with only `?gemm` is not made to supply dummy drivers; the vendor
adapter returns an error carrying the dtype and the reason, which the harness records as `skipped`.
Coverage is *declaration-relative* (`campaign.py` compares declared axes, not skip status), so a page
is `partial` because its declaration is a subset, not because a cell was skipped; a skipped vendor
cell is legal v2 evidence and the report marks the missing measurement.

**Rejected.**

- Rewriting `lapack.rs` as a prefix macro first: a large diff in the file that carries the vendor
  identity, for no gain over adding two bindings now. The four driver prefixes can be added family by
  family.
- Adding `f32`/`c32` to the published `dtypes:` declaration in this change: that doubles every future
  arm's wall clock (the full MKL arm is ~2.5 h) and makes every current page `declaration-changed`.
  The axis exists; when the pages should carry it is a coverage decision, not a harness one.
- A new suite or a toolkit schema key for "default shapes": the default belongs to the harness's own
  argument handling, and the recorder already names its grid.

**Policy this implements** (and which the campaign's rules gain in the same change): an optimization
iteration targets the **64** cell of every family and confirms **32** is unmoved, then stops. That pair
is the iteration, not the adoption: adoption still runs the blast-radius arm in
`docs/merge-procedure.md` (affected families at every declared shape, collateral controls, the
comparator). The 64/32 pair is cheap because it is one cell per family and decisive because the floor
that decides whether a product is threaded is 1.18 Mflops, so `32^3` (131 ki) and `64^3` (524 ki) sit
below it and any movement there is a real change in the un-threaded path rather than a scaling story.

## Verification conclusions and constraints

- `fbench verify` must report a clean grid for the new dtypes at the 64 default, for every family and
  thread count, before any timing. A wrong tolerance also shows up in the timing path's own result
  check, so the census is the first place to look, not the only one.
- The census has to be read, not just its banner: an operation that cannot be built is a successful
  skip, and the banner prints either way. The check is that the `ok` cells per dtype match the families
  the harness claims, with only the declared skips (`eig`, `upgrade_factor` for the faer arms) missing.
- The tolerance is one constant per dtype (`Scalar::TOL`), scaled by the case size for the `f64` pair
  exactly as before and **flat** for the `f32` pair. Scaling at f32 is what a percent-level spectrum
  error would hide behind at the tall sizes the suite declares, so the f32 floor is `1e-5` at every
  size, still applied over the existing `max(frob, 1)` scale. That floor is provisional in the honest
  sense: no family needed anything looser, and the census plus a deliberately corrupted output is what
  would settle it.
- The default-shape change must not touch the recorder: the shapes it passes are explicit, and the
  proof is that a recorded run's `run.yaml` and `run_spec` are byte-identical in shape terms to one
  taken before the change.
- The vendor arm's `f32`/`c32` pages cover `gemm` only until the driver slice lands. The reason is in
  the raw CSV's skip row; the generated report reduces skips to `family/shape`, so it names the family
  but not the dtype or the reason, and this change does not widen that renderer.
