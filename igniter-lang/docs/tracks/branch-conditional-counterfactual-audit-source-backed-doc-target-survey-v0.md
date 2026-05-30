# Branch Conditional Counterfactual Audit Source-Backed Doc Target Survey v0

Card: S3-R212-C2-P1
Agent: [Archive/Form Expert]
Role: archive-form-expert
Track: branch-conditional-counterfactual-audit-source-backed-doc-target-survey-v0
Route: UPDATE
Status: done
Date: 2026-05-30

Depends on:
- S3-R211-C5-S

---

## Route Statement

Route: UPDATE
Card: S3-R212-C2-P1
Role: archive-form-expert
Stage/Round observed: Stage 3 / Round 211 accepted; R212 source-backed
vocabulary/spec boundary exists as design-only context.

This survey does not edit docs/spec, does not authorize implementation, and does
not authorize public/runtime/report/API claims.

Affected neighbor roles:

- Compiler/Grammar Expert: owns vocabulary/spec boundary design.
- Status Curator / Meta Expert: owns current-status and map sync.
- Runtime / Release owners: own runtime/report/API/public claim fences.
- Assumptions owner: owns PROP-032 premise-capsule wording.

---

## Inputs Read

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/spec/README.md`
- `igniter-lang/docs/README.md`
- `igniter-lang/docs/dev/semantic-governance-heat-map.md`
- `igniter-lang/docs/proposals/PROP-032-assumptions-block-v0.md`
- `igniter-lang/docs/tracks/stage3-round211-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-spec-boundary-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-evidence-boundary-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-current-source-evidence-surface-survey-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-dry-run-concept-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-doc-target-survey-v0.md`

Suggested `chapter-*` files checked:

- `igniter-lang/docs/spec/chapter-02-compiler.md` is not present.
- `igniter-lang/docs/spec/chapter-05-runtime.md` is not present.
- `igniter-lang/docs/spec/chapter-06-reports.md` is not present.
- `igniter-lang/docs/spec/chapter-07-temporal.md` is not present.

Current equivalent body chapters are:

- `igniter-lang/docs/spec/ch2-source-surface.md`
- `igniter-lang/docs/spec/ch5-compiler-pipeline.md`
- `igniter-lang/docs/spec/ch6-semanticir.md`
- `igniter-lang/docs/spec/ch7-runtime.md`

These equivalents should remain untouched for this docs-sync step.

---

## Accepted Fixed Point

R211 accepts:

```text
source-backed proof-local Level 2 counterfactual dry-run evidence
```

Accepted maximum evidence posture:

- proof-owned SemanticIR-shaped source artifacts;
- SHA-256 digest-addressed `source_branch_intention_ref`,
  `input_snapshot_ref`, and `premise_set_ref`;
- frozen input snapshots;
- explicit premise sets;
- no-authority projection envelopes;
- generated output may be called only source-backed proof-local Level 2
  counterfactual dry-run evidence.

Binding non-equivalences:

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
source evidence from proof-owned SemanticIR-shaped artifacts != canonical schema
source_branch_intention_ref != CompilerResult or CompilationReport field
dry_run_projection != public_runtime_support
Level2_source_backed_proof != public_counterfactual_support
Tier 0 hand-authored fixtures are legacy fallback only; not primary source authority
Assumptions-shaped premise refs are proof-local labels only; not PROP-032 branch syntax or receipt assumption_refs
```

---

## Safe Target Table

| Target | Safety | Recommended action | Boundary wording |
| --- | --- | --- | --- |
| `docs/tracks/*source-backed-vocabulary-docs-sync*` | Safe | Required for any sync. | Track docs may carry the full vocabulary, scan results, and no-claim boundaries. |
| `docs/dev/semantic-governance-heat-map.md` | Safe low-authority map | Preferred smallest sync target. | Add a Domain 2 row or footnote for source-backed Level 2 as proof-local/non-canonical evidence; all pipeline/runtime/report columns gated. |
| `docs/spec/README.md` | Safe as index only | Allowed as a one-line coverage pointer. | "No spec chapter; proof-local source-backed Level 2 evidence; non-canonical; body chapters held." |
| `docs/current-status.md` | Safe but likely already enough | Optional polish only; no required edit. | Current R211/R212 wording already carries detailed no-claim boundaries. Edit only if Status Curator wants a compact pointer. |

Smallest safe docs-sync option:

```text
docs/dev/semantic-governance-heat-map.md
docs/spec/README.md
docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md
```

`docs/current-status.md` can remain unchanged unless a Status Curator sees
wording ambiguity.

---

## Unsafe / Held Target Table

| Target | Status | Reason |
| --- | --- | --- |
| `docs/spec/ch2-source-surface.md` | Held | No parser/grammar/source syntax change; branch-level `uses assumptions` remains closed. |
| `docs/spec/ch5-compiler-pipeline.md` | Held | No compiler pipeline, `CompilerResult`, or `CompilationReport` authority. |
| `docs/spec/ch6-semanticir.md` | Held/high-risk | Source artifacts are SemanticIR-shaped proof artifacts, not canonical SemanticIR schema. |
| `docs/spec/ch7-runtime.md` | Held/highest-risk | Live runtime remains lazy; no runtime counterfactual, cache, TBackend, receipt, or CompatibilityReport support. |
| `docs/language-spec.md` | Held | Higher-authority readable synthesis; too easy to imply language canon. |
| `docs/proposals/PROP-032-assumptions-block-v0.md` | Held | Assumptions remain premise capsule only; no PROP-032 amendment or branch syntax. |
| `docs/README.md` | Closed for now | Public-facing navigation should not mention source-backed Level 2 until a public wording gate exists. |
| `docs/ruby-api.md` / CLI docs | Closed | No public API/CLI support. |
| release notes / release docs | Closed | R211 does not update release evidence or public support wording. |
| report/result/receipt/CompatibilityReport docs | Closed | Shape mutation remains explicitly closed. |

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Should body spec chapters remain untouched? | Yes. Ch2/Ch5/Ch6/Ch7 equivalents should remain untouched for this step. |
| Does `current-status.md` already carry enough detail? | Yes. It records R206-R211 sequence, accepted maximum claim, no-claim boundaries, and next R212 route. Optional polish only. |
| May `spec/README.md` safely mention the vocabulary? | Yes, only as a proof-local coverage/index pointer with "no spec chapter/body held" wording. |
| May the docs index `docs/README.md` safely mention it? | Not yet. Keep public-facing navigation closed. |
| Should PROP-032 remain untouched? | Yes. Proof-local premise refs do not amend `assumptions {}` grammar, branch syntax, or receipt `assumption_refs`. |
| Should public-facing README/docs remain closed? | Yes. No public runtime/report/API/counterfactual support claim is accepted. |
| Is a future docs-sync recommended or should it hold? | Proceed only with the smallest low-authority sync, or hold if no map discoverability is needed. Do not open spec-body sync. |

---

## Recommended Smallest Docs-Sync Option

Recommendation: proceed with a tiny low-authority sync only if discoverability is
needed; otherwise hold.

If proceeding, use:

```text
Option A-min:
  - docs/dev/semantic-governance-heat-map.md
  - docs/spec/README.md
  - docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md
```

Do not include:

```text
docs/spec/ch2-source-surface.md
docs/spec/ch5-compiler-pipeline.md
docs/spec/ch6-semanticir.md
docs/spec/ch7-runtime.md
docs/language-spec.md
docs/proposals/PROP-032-assumptions-block-v0.md
docs/README.md
public API/CLI/release docs
```

`current-status.md` is optional and should be left untouched if the sync can be
made discoverable via Heat Map + spec README.

---

## Exact No-Claim Wording

Safe long form:

```text
Source-backed Level 2 vocabulary names proof-local counterfactual dry-run
evidence derived from proof-owned SemanticIR-shaped artifacts, frozen input
snapshots, explicit premise sets, SHA-256 digest-addressed refs, and
no-authority projection envelopes. It is not source syntax, not canonical
SemanticIR schema, not CompilerResult or CompilationReport shape, not
report/result/receipt/CompatibilityReport shape, not runtime behavior, not live
non-selected branch evaluation, and not public counterfactual audit support.
```

Safe short form:

```text
source-backed proof-local Level 2 evidence; non-canonical; no runtime/report/API authority
```

Safe index wording:

```text
No spec chapter: source-backed Level 2 counterfactual dry-run evidence is
proof-local and non-canonical; body spec chapters, PROP-032, runtime/report/API,
and public claims remain closed.
```

PROP-032-safe wording:

```text
Assumptions-shaped premise refs may appear only as proof-local premise labels in
`premise_set` records; they are not branch-level `uses assumptions`, not a
PROP-032 grammar extension, and not receipt `assumption_refs`.
```

---

## Forbidden Phrase Scan Set

Future docs-sync should scan the exact touched files for these terms. Matches
are allowed only in explicit forbidden, non-claim, negative-disambiguation, or
closed-surface sections.

Forbidden as positive projection/canon/public vocabulary:

```text
would_result
would_output
would_fail
counterfactual result
counterfactual output
counterfactual failure
latent runtime value
latent runtime failure
latent execution
latent branch execution
simulated branch result
dry-run result
branch replay
replayed branch value
symbolic_execution
causal_estimate
alternate_actual_output
```

Forbidden or over-broad as positive claims:

```text
counterfactual audit support
counterfactual audit support landed
runtime counterfactual support
public counterfactual support
counterfactual runtime
runtime can evaluate latent branches
runtime can dry-run latent branches
SemanticIR emits branch_intention
SemanticIR emits source_branch_intention_ref
source-backed branch intentions are SemanticIR
source_branch_intention_ref is a CompilationReport field
source_branch_intention_ref is a CompilerResult field
dry_run_projection is a CompatibilityReport field
receipt contains counterfactual
public API supports counterfactual dry-run
CLI supports counterfactual dry-run
branch-level uses assumptions
PROP-032 branch syntax
```

Suggested scan skeleton for a later sync:

```bash
rg -n "would_result|would_output|would_fail|counterfactual result|counterfactual output|counterfactual failure|latent runtime value|latent runtime failure|latent execution|latent branch execution|simulated branch result|dry-run result|branch replay|replayed branch value|symbolic_execution|causal_estimate|alternate_actual_output" <touched-files>
rg -n "counterfactual audit support landed|runtime counterfactual support|public counterfactual support|counterfactual runtime|runtime can evaluate latent branches|runtime can dry-run latent branches|SemanticIR emits branch_intention|SemanticIR emits source_branch_intention_ref|source-backed branch intentions are SemanticIR|source_branch_intention_ref is a CompilationReport field|source_branch_intention_ref is a CompilerResult field|dry_run_projection is a CompatibilityReport field|receipt contains counterfactual|public API supports counterfactual dry-run|CLI supports counterfactual dry-run|branch-level uses assumptions|PROP-032 branch syntax" <touched-files>
```

---

## Target Boundary Recommendation

Recommended next boundary:

```text
Open a docs-only low-authority vocabulary sync if discoverability is needed.
Authorize only Heat Map + spec README + track doc.
Treat current-status as optional/no-op.
Hold all spec-body chapters, PROP-032, public docs, public API/CLI, release docs,
runtime/report/receipt/CompatibilityReport docs, and implementation.
```

Hold recommendation:

```text
If the sole goal is status awareness, hold. `current-status.md` already carries
enough detail after R211 and the R212-C1 design boundary.
```

---

## Compact Handoff

[D] Survey complete. R211 source-backed Level 2 evidence is proof-local,
non-canonical, and no-authority.

[S] Smallest safe sync target set is Heat Map + spec README + track doc.
`current-status.md` already has enough detail and can be left untouched.

[T] Body spec chapters, PROP-032, public docs/API/CLI/release docs, runtime
docs, report/result/receipt/CompatibilityReport docs remain held/closed.

[R] Proceed only with docs-only low-authority vocabulary sync if discoverability
is needed; otherwise hold.

[Next] If a sync opens, require forbidden-phrase scans and exact no-claim wording
before acceptance.
