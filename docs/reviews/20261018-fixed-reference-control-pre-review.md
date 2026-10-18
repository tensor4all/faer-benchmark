# Bounded independent PRE-review — gpt-6.1-sol

Status: COMPLETED via read-only reviewer-gpt consultation. No gate change or
adoption approved. Proposal: `20261018-fixed-reference-control-proposal.md`.

Scope: proposal, library adoption-protocol summary, campaign-toolkit candidate.py,
fixed-binary ABBA README/comparison/code-comparison, and ponytail-review skill.
No edits, builds or timing. Full long-form frozen contract, raw diagnostic logs,
CLI protections, disassembly/call tracing and referenced bytes were not reviewed.
The supplied adoption-protocol summary has no labelled4/5b sections; exact
version-suffix requirements therefore remain unverified.

## Findings

- **BLOCKER (acceptance, not diagnosis):** proposal lines55–59 require linked
  uncertainty to be bounded/explained but do not define an operational bound for
  BOTH target and fork-guard deltas. Library adoption-protocol lines59–60 still
  require target gains and no guard regression beyond spread. Keep original
  refusal or obtain approval for a predeclared conservative revised rule.
- **IMPORTANT:** candidate.py lines126–143 intersects available cells, selects by
  substring, skips cells with fewer than two starts, and may return true with no
  evaluated rows. Actual control band is baseline min/max expanded5%, lines137–138.
  Audit returned full identities/start counts against the declaration. This is a
  helper limitation; caller-side protections were not reviewed, so no demonstrated
  end-to-end bypass is asserted.

## Four questions answered

1. Fixed-reference comparison is meaningful as an additional host diagnostic:
   executable bytes stay fixed. It is insufficient to bound independent layout,
   data or dispatch effects in rebuilt fork targets/guards. Opposite f64/c64
   shifts contradict one uniform speed multiplier, not all possible host effects.
2. Smallest next step: statically resolve normalized-away RIP references and
   compare referenced bytes for f64 leaf plus c64 contrast. No rebuild/timing.
   Equal constants narrow explanations but do not isolate alignment causality.
3. Existing provision permits a future genuinely predeclared overlap set
   (candidate.py9–13; adoption-protocol32–34). Choosing cells because they passed
   current observations is not cured by declaring them before another run.
   Replacing/overriding the current gate changes the contract and needs approval.
4. Complete static check, keep reference optional/diagnostic, then either remain
   under unchanged contract or seek approval for an explicit uncertainty rule.
   Both old pairs remain inconclusive. No third identical pair or framework.

## Delete list and disposition

- Shrink proposal's “for development acceptance” to “as a diagnostic sidecar”:
  accepted, no rule for acceptance implemented.
- Reuse original executable, sidecar and helpers; no provider layer, dependency
  or policy framework: accepted.
- Delete no failed observation, guard, verification or retained sample.

Review is not approval of adoption, is not a completed review of any future
implementation, and does not imply remaining upstream regressions are artifacts.
