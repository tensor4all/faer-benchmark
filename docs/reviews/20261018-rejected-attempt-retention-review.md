# Rejected-attempt retention: completed independent reviews

Summaries of the completed bounded PRE and POST reports, both read-only on
openai/gpt-6.1-sol. These are static reviews, not independent test execution,
benchmark acceptance, validation of old records, or approval of a new policy.

## PRE findings and resolution

- IMPORTANT: a token scan for --csv could choose the wrong repeated option or
  confuse a value with an option. Resolved without a parser: record_run supplies
  the effective output explicitly through PINNED_CSV, overriding it for every
  call and clearing it for no-CSV v1 verification. Arguments stay unchanged.
- IMPORTANT: enabling retention after mkdir/cp is too late under set-e/EXIT.
  Resolved: keep=1 precedes command execution and stays set through the post-
  check and archival. Any archive failure stops execution, keeps partial archives
  plus source temporaries, reports their paths, and does not launch another run.
- Nested archives are already excluded by the canonical result_files list;
  no new schema, discovery/filtering layer, provider or dependency is needed.

## POST result

COMPLETED, no BLOCKER/IMPORTANT/MINOR correctness findings in the paired change.
All requested paths traced: campaign shim -> actual toolkit record_run -> owned
pinned.sh -> idle checker, explicit CSV declaration, quoted paths/repeated CSV
arguments, command failure versus bounded guard retry, partial archive failure,
accepted-output cleanup and exclusion from report/candidate medians.

Reviewed files include the complete tracked diff across the two repos, the NEW
scripts/test_pinned.py (not in that diff), design, fbench's actual CSV parser and
write path, toolkit candidate/report/timing readers, tests and existing notices.
Existing MIT lineage notices remain; new code/tests are original. This is notice
preservation in the diff, not a new audit of historical distribution compliance.
Delete list: lean already; no implementation lines identified for deletion.

## Local verification / delivery evidence

- Original-wrapper reproducer: all9 fixture subcases fail as expected.
- Corrected wrapper: one stdlib fixture with9 subcases passes, no real pinning,
  sleeps or timing;3 harness script tests pass in total.
- Toolkit53 tests pass; changed toolkit files pass Ruff; bash syntax and source
  diff whitespace checks pass. Raw historical logs retain original whitespace.
- The POST report flagged the old requirements pin as an unverified delivery
  limitation. Resolved: toolkit8484fb54d611b1d5e1fdc6aafda631d53b12351d is clean,
  the effective imported module resolves to that checkout, its new CSV wiring is
  present, the remote feature branch advertises that SHA, and requirements.txt
  pins it. Toolkit main was not merged; no package release or upstream post.

## Limits

No real post-fix measurement yet, no numerical timing-loop/threshold/retry change,
no claim of performance neutrality from static inspection alone. Signal/power-
loss durability and non-Linux behavior were not dynamically tested. Historical
lost samples remain lost. Rejected archives must never enter accepted medians.
