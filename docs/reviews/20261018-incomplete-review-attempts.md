# Incomplete independent attempts — not review approvals

These four reports were delivered as **failed / INCOMPLETE** after tool-call
limits. None is counted as a completed review or approval; absence of a reported
finding is not a clean verdict. All were read-only, with no reviewer builds.

| Scope | Retained run | Stop | Disposition |
|---|---|---|---|
| Householder regression source exploration | sa_fd630e43-b87a-44eb-b618-18f4d05395de |24 tools|Partial declarations only; no completed root-cause deliverable. Main traced source independently.|
| Copy candidated6358ca POST | sa_e179b147-f902-4101-8e42-30b147c3dec4 |22 tools|Candidate-specific correctness unverified. Retry with a fixed23KB source/caller/test bundle, same model.|
| Householderad9f2ef POST | sa_7a768dc4-515f-4843-a107-50b41608f30d |18 tools|No completed code review. Candidate separately declined on its measured guard; no adoption. Review must complete if revived.|
| Native strict-extent PRE | sa_b3f144b9-df23-4c1d-93af-968424f57dbb |14 tools|Not sufficient to implement. Replaced by a completed bounded source-bundle consultation, followed by a separate completed K=0 addendum PRE.|

No unsupported partial finding triggered a speculative implementation. The main
agent's own N=1/N=3 negative tests establish the native extent defect, and a
separate K=0 test establishes the Replace defect. Completed bounded PRE verdicts
and limitations are recorded in `20261018-native-gemm-empty-pre-review.md`.

Failed retained agents were closed. Subsequent bounded POST attempts use immutable
source bundles from cwd `/tmp`, not a broad repository/instruction discovery.
Native POST: `/root/native_empty_bounds_post`; copy POST:
`/root/owned_copy_post_bounded`. Until their completed reports arrive they remain
pending, not passed. Model remains openai/gpt-6.1-sol; no silent substitution.
