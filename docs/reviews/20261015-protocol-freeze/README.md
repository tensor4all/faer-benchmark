# Protocol-freeze review receipts (timing v2 baseline)

`openai/gpt-6.1-sol`, fresh `pi --print` process, read-only tools, one review of the
design before implementation and one of the finished report diff after it.

| report | verdict | disposition |
| --- | --- | --- |
| [pre-review.md](pre-review.md) | must change before implementation | Accepted in full. The averaged ratio is now labelled rotation-averaged and model-qualified; unbalanced cells (an engine has no row) get `*` and are not presented as position-balanced; the design's ratio formula was corrected; the budget accounting was fixed (5,148 base engine-cells -> 3,756 successful base cells + 192 variant rows = 3,948 primed rows; 1,392 skips; 5,340 emitted rows); the control `guards.attempts: 1` artifact is documented as not the policy in force; the recorder default of three attempts, not eight, is stated. |
| [post-review.md](post-review.md) | changes needed | Accepted. The first implementation measured engine-to-engine spread for `!`; it now measures each engine's own between-start range (the review's false negative and false positive both reproduce the fix: OpenBLAS 4T c64 C-order GEMM is flagged, MKL 8T `qr_factor` is not), the missing position-effect warning is implemented as `p` on balanced cells, and an unbalanced cell without any ratio is marked `*`. The two delete-list items were taken. |

Raw reports are stored byte-exact; `receipts.json` pins their SHA-256. Neither
reviewer executed the tests, builds or measurements, so their reported verdicts are
source reviews only.
