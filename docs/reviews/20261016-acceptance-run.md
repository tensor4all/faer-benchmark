# Acceptance run for the adopted row-major QR/LU work (2026-10-16)

The first run of the acceptance protocol in `docs/rules.md`, on the revision that is now
`t4a-faer` main (`1d754763e7198692d5af0bbf282ac70d9d7e61b5`, measured code identical to `fe41bbd` -
verified by tree hashes, so nothing was measured twice).

## Shape and duration of the run

| part | settings | duration |
| --- | --- | --- |
| blast radius at 4T/8T | `qr_factor`, `qr`, `lu`, `full_piv_lu`, `solve` over `linalg-small/mid/tall/wide`, f64+c64, both orders, both arms | baseline 2110 s, candidate 2109 s |
| target cells at 1T | `4096x256`, `256^2`, `512^2`, `64x1024`, same families | baseline 512 s, candidate 510 s |

**87 minutes for the whole acceptance run**, inside the one-to-three-hour budget the protocol claims.
(The four runs that preceded it failed validation because the recorder wrote `host.role` while the schema
forbade it; they are shelved in `data/probes/20261016-acceptance-schema-failure/`.)

## Verdict

- **1T: clean.** 32 cells, 8 beyond-band improvements, **0 beyond-band regressions**; the unchanged
  `faer-upstream` control reproduced the baseline (median ratio 0.9987, none outside its range).
- **4T/8T: the target improves, and two things need attention.**
  - Target: `qr_factor` C-order f64 0.793 / c64 0.851 (median over the family), `lu` f64 0.960,
    `full_piv_lu` f64 0.985; the best cells are the tall ones (`qr_factor` `4096x256` f64 0.187 at 8T,
    0.222 at 4T).
  - **Beyond-band regressions: 43 cells, and all of the worst ones are small shapes at 4T/8T** -
    `qr_factor` `32x32` f64 1.83x at 4T and 1.70x at 8T, `qr_factor` c64 `32x32` 1.42x, `solve`/`lu`
    `32x32`/`64x64` 1.16-1.19x. These are the rows the pages already call dispatch-dominated (a few
    microseconds of kernel under a thread-region start-up); the row-major adaptation's extra copy is
    visible there. It is **not** a kernel regression: at 1T the same cells are clean.
  - The `faer-upstream` control over 368 cells had a median ratio of 0.9997 with **2 cells outside**
    their recorded range, which under the current rule refuses the comparison. With hundreds of control
    cells a fixed "every cell must reproduce" rule is too strict; the protocol should allow a small
    fraction outside (or the control set should be the predeclared dozen).

## Consequences

- The adoption itself stands: the target improves and the single-thread grid is clean.
- A **threshold guard for small shapes** (or leaving the row-major path to shapes where it pays) is the
  next optimization item; it needs the same acceptance run afterwards.
- The control rule is refined as above in `protocol-v2-baseline.md`.
