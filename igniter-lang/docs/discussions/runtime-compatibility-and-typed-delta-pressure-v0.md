# Discussion: Runtime Compatibility and Typed Delta Pressure

Card: S3-R7-X1-S
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: user
Borrowed lens: runtime-pressure
Track: runtime-compatibility-and-typed-delta-pressure-v0
Date: 2026-05-08
Status: complete — routed

---

## Question

Are S3-R7 C1–C3 results safe to treat as a stable boundary layer for TEMPORAL
runtime, or are there silent production bugs in the capability check, the
parity record, or the smoke coverage?

## Scope

- C1: `runtime-compatibility-report-temporal-load-check-v0` (S3-R7-C1-P)
- C2: `invariant-typed-shape-discharge-v0` (S3-R7-C2-P)
- C3: `runtime-smoke-temporal-post-switch-v0` (S3-R7-C3-P)

Focus: silent production risks — cache/time/capability mistakes, not doc gaps.

---

## Evidence Base

Files read:

```text
igniter-lang/docs/tracks/runtime-compatibility-report-temporal-load-check-v0.md
igniter-lang/docs/tracks/invariant-typed-shape-discharge-v0.md
igniter-lang/docs/tracks/runtime-smoke-temporal-post-switch-v0.md
igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/
  runtime_compatibility_report_temporal_load_check.rb
igniter-lang/experiments/typed_emission_main_path_parity/
  typed_emission_main_path_parity.json
igniter-lang/docs/current-status.md
igniter-lang/docs/agent-context.md
```

---

## [Agree]

**C1 CompatibilityReport shape is structurally correct.**

The critical design decision — separating `bundle_load` from
`evaluation_readiness` as two independent decisions — is the right abstraction.
A caller can inspect a TEMPORAL artifact without being blocked; the block lands
only at evaluation time and is explicitly structured:

```json
{
  "bundle_load": { "decision": "accept_for_inspection", "blocked": false },
  "evaluation_readiness": { "decision": "blocked", "guard_at": "evaluate" }
}
```

This means the refusal is not a crash, a nil return, or a silent no-op. It is
a typed result that a future production RuntimeMachine can act on. `report_only:
true` and `runtime_enforced: false` are honest; the proof does not overstate
what it authorizes.

The 16 PASS cases cover both temporal axes (valid-time History, bitemporal
BiHistory), both failure modes (missing capability, metadata-present but no
executor), and confirm that missing TBackend capability blocks evaluation
readiness without blocking bundle loading.

**C2 invariant discharge is correct and expected.**

The `invariant_valid` delta is a capability difference, not a regression:

```text
parsed path:  compute node only (Stage 1 emitter, no invariant lowering)
typed path:   compute + 4 invariant_node entries + top-level invariants[]
              + invariant_coverage in CompilationReport
```

This is exactly what `emit_typed` is for. The typed path surfaces the Stage 2
invariant lowering surface that the parsed emitter never reached. Accepting
this delta is the correct decision. The 12 remaining `legacy_parity_delta_items`
are all parsed-path-OOF vs typed-OK cases across `olap_point`, `stream_fold`,
`history_access`, and `sparkcrm_bihistory` — confirmed from the parity JSON
evidence directly. None of the remaining FAIL cases are valid-to-different
regressions.

The `classifier_oof → typechecker_oof` category shift acceptance is also
correct: the typed production path carries more structure before rejection, so
an unresolved-symbol OOF moves one stage later. This is expected, not a bug.

**C3 smoke establishes a valid two-surface baseline.**

CORE (Add contract) and TEMPORAL (BiHistory) are the two extremes of the
fragment class hierarchy in production. Both behave as expected:

```text
CORE:     compile ok → load ok → evaluate ok → sum=42 → compatibility trusted
TEMPORAL: compile ok → load (inspection) ok → evaluate → structured refusal
                                               reason: temporal_execution_unsupported
```

The structured refusal (`evaluation_refusal` kind, `blocked` status,
`guard_at: evaluate`, explicit `reason_code`) is the correct shape for a
future production RuntimeMachine to enforce. It does not crash, swallow the
refusal, or return a nil result.

---

## [Challenge]

### C-1a. No test for an executor that *claims* to be present

The C1 proof tests only two runtime profiles:
- `missing_tbackend_capability` (capability absent)
- `metadata_capability_no_executor` (capability present in metadata, no live executor)

There is no case for a profile where:

```ruby
"temporal_executor" => true,
"live_tbackend_binding" => true
```

This matters because the guard policy (`load_accept_evaluate_refuse`) is stored
in `compatibility_metadata.json` **inside the artifact**. If a production
RuntimeMachine implements a future temporal executor, the guard logic must
check both the capability AND the artifact's declared guard policy. If only the
capability check passes and the artifact's `guard_policy` field is ignored,
evaluation could proceed incorrectly on an artifact that was assembled before
the executor was approved.

In the current state, this is a non-issue (no executor exists). But the C1
proof establishes the report shape that production code will eventually be
built from. A "positive temporal execution" case should be in the proof so
the trust boundary is explicit before Gate 3 work begins.

**Severity**: low now; medium at Gate 3 design time. Not a current blocker.

### C-1b. Two enforcement paths that do not cross-reference each other

After C1, there are now two independent ways a TEMPORAL evaluate can be
blocked:

1. `compatibility_metadata.runtime_execution.guard_policy` — in the artifact,
   read by the proof-local GuardedRuntimeMachine (S3-R5-C2).
2. `evaluation_readiness.decision: blocked` — in the CompatibilityReport,
   produced by the new C1 proof.

These are decoupled. The C1 report is built by reading `compatibility_metadata`
and applying its own logic. But there is no test that validates:

```text
if artifact has guard_policy: load_accept_evaluate_refuse
  → C1 report must always produce evaluation_readiness: blocked
     regardless of runtime profile
```

An implementation error could produce a C1 report with
`evaluation_readiness: blocked` from a different code path (e.g., capability
check) while accidentally passing on `guard_policy` mismatch. The two
evidence paths are both correct but their consistency is not tested together.

**Severity**: low — both paths give the same answer today. Gap becomes
concrete if the production RuntimeMachine implementation splits the code paths.

### C-2a. 12 legacy delta items unnamed

The parity proof now reports:

```text
legacy_parity_delta_items: 12
accepted_delta_items: 2
```

The 12 remaining items are deltas inside 4 FAIL cases (`olap_point`,
`stream_fold`, `history_access`, `sparkcrm_bihistory`). From the parity JSON
they are all OOF-to-OK cases — the typed path succeeds where the parsed path
OOFed. No valid-to-different regressions are present.

However, the track document does not name the 12 items. A future agent reading
the track without the parity JSON will see "12 legacy delta items, do not treat
as blockers" without understanding what the 12 items actually are. If a future
slice modifies the typed emitter and introduces a new delta, the count shifts
from 12 to 13 — and it's not obvious whether the addition is an accepted OOF
or a regression.

**Severity**: low — the JSON is readable, the parity harness is the primary
evidence record. But the track should name at least the case IDs and a one-line
classification. Not a production risk today.

### C-2b. `accepted_delta_items: 2` — second accepted item not named

The track names one of the two accepted items (the `invariant_valid` shape
delta). The second accepted item is visible in the JSON (`$.invariant_coverage`
addition to CompilationReport) but not mentioned in the track text.

Both items are from the same `invariant_valid` case — they are the two
structural additions (`$.invariants` and `$.invariant_coverage`) accepted
under the same reason string. This is fine, but the track says
`accepted_delta_items: 2` without clarifying that both items come from the
same case and acceptance reason. A reader might assume two different cases
were accepted.

**Severity**: minimal — terminology confusion, no production risk.

### C-3a. Smoke covers only two of six proven emit_typed surfaces

After the S3-R5-C4 emit_typed switch, the production compiler lowers all of:

```text
CORE contracts (Add, Decimal, struct)        → compute_node
stream fold contracts                        → stream_input_node, fold_stream_node
OLAPPoint access                             → olap_access_node
History[T] temporal access                   → temporal_input_node + temporal_access_node
BiHistory[T] temporal access                 → temporal_input_node + temporal_access_node (bitemporal)
invariant severity contracts                 → compute_node + invariant_node (C2 discharged)
```

The C3 smoke tests two: CORE (Add) and TEMPORAL (BiHistory). It does not
include:

- `stream fold` contract post-switch (regression exposure: fold_stream_node)
- `OLAPPoint` access post-switch (regression exposure: olap_access_node)
- `History[T]` single-axis temporal (regression exposure: valid_time axis only)
- `invariant severity` contract post-switch (regression exposure: invariant_node — just discharged in C2)

If the emit_typed switch introduced any regression in these surfaces, neither
C3 nor any other S3-R7 track catches it. The Stage 2 close candidate covers
these, but Stage 2 close candidate was run against the switch state in R5 —
not re-run as part of the C3 smoke.

**Severity**: medium. The Stage 1/2 close candidates PASS at R5-C4 already
serve as regression evidence. But the C3 smoke is labeled "post-switch runtime
smoke" — its scope implies broader coverage than it delivers. An agent tasked
with checking post-switch behavior will read C3 and assume the smoke ran all
emit_typed surfaces. It did not.

### C-3b. TEMPORAL smoke uses BiHistory only; History[T] single-axis not covered

The TEMPORAL smoke fixture is `sparkcrm_bihistory_source.ig`. This exercises
`bihistory_read` capability, bitemporal axes, and `transaction_time`
coordinate. It does not test History[T] with `history_read` capability and
valid_time axis only.

The two axes have different `required_capabilities`, different `contract_index`
entries, and different `cache_key_schema_hint` shapes. A regression in the
History[T] single-axis path would not appear in the C3 smoke.

**Severity**: low-medium. The temporal assembler boundary proof (S3-R5-C1)
covers both axes separately. But C3 is the smoke specifically written to
validate post-switch behavior — it should include both temporal axis shapes.

### C-3c. TEMPORAL compatibility report status not checked in smoke

The C3 CORE smoke returns `compatibility_report_status: trusted`. The C3
TEMPORAL smoke checks `load_for_inspection.status: loaded` and
`evaluate_without_executor.status: blocked`. It does not check what
CompatibilityReport status the TEMPORAL artifact receives.

After C1 added `evaluation_readiness.decision: blocked` to the
CompatibilityReport shape, the smoke should confirm that a TEMPORAL artifact
produces the expected C1 report shape. Currently, C1 and C3 are parallel
proof fixtures that do not cross-validate each other.

**Severity**: low — C1 tests the report shape separately. But if an agent
asks "what does a TEMPORAL artifact's CompatibilityReport look like in the
full compile-load-report path?" neither C1 nor C3 answers that question
end-to-end.

---

## [Missing]

### M-1. Positive temporal execution case for the C1 report boundary

A "live executor + live TBackend binding" capability profile case is absent
from the C1 proof. This case should be added before Gate 3 work begins —
not as a blocker today, but as a named gap in the proof fixture.

Needed: one additional case in
`runtime_compatibility_report_temporal_load_check.rb` for a profile with
`temporal_executor: true, live_tbackend_binding: true`, with explicit assertion
that `evaluation_readiness.decision` depends on both the capability profile AND
the artifact's declared `guard_policy`. This case will initially fail correctly
(no real executor) but establishes the boundary contract for Gate 3.

### M-2. Post-switch regression smoke for all six emit_typed surfaces

The C3 smoke should expand to include:

```text
stream_fold    → compile, load, C3 evaluation (CORE fragment, executes)
olap_point     → compile, load, C3 evaluation (CORE fragment, executes)
history_valid  → compile, load (inspection), evaluate refusal (temporal)
invariant_valid → compile, load, evaluate (CORE fragment + invariant_node)
```

This makes "runtime smoke temporal post switch" live up to its name. It also
cross-validates the C2 discharge for invariant_valid through the full runtime
path, not just the parity harness.

### M-3. Cross-validation of C1 report shape inside the full smoke path

The smoke currently validates the C1 guard refusal shape (load/evaluate) and
C1 validates the CompatibilityReport shape (bundle_load/evaluation_readiness),
but no test confirms both produce consistent results for the same TEMPORAL
artifact in the same proof run.

Needed: one end-to-end check that takes a TEMPORAL artifact through:

```text
compile → assemble → CompatibilityReport (C1 shape) → GuardedRuntimeMachine load
```

and asserts `evaluation_readiness.decision == blocked` matches
`GuardedRuntimeMachine.evaluate_result.kind == evaluation_refusal`.

This is a single assertion, not a full new proof.

---

## [Sharper Question]

Not: "Are there bugs in C1, C2, C3?"

There are no current production bugs. All three tracks are correct for their
stated scope. The sharper question is:

> **Is the current three-proof architecture (CompatibilityReport shape,
> parity delta acceptance, runtime smoke) a sufficient pre-Gate-3 safety
> net, or are there integration gaps that only appear when a live temporal
> executor is introduced?**

Proposed answer:

The three proofs collectively establish:
1. What a TEMPORAL artifact carries (manifest, contract_index, guard_policy)
2. What the CompatibilityReport says about it (load accepted, eval blocked)
3. That the production compiler path produces a loadable TEMPORAL artifact
   that refuses evaluation gracefully

What they do NOT establish:
1. That a future executor cannot accidentally bypass the guard policy
2. That the CompatibilityReport and the GuardedRuntimeMachine guard produce
   consistent answers for the same artifact
3. That all six emit_typed surfaces (not just Add and BiHistory) survive the
   post-switch runtime path

These three gaps are not production bugs today — they are pre-conditions for
safe Gate 3 work. Addressing them before any live executor is introduced is
lower cost than discovering them after.

---

## [Route]

→ **PROCEED** (no hold): C1, C2, C3 are safe to treat as the current Stage 3
  runtime boundary layer. No production bug detected. No formal PROP needed for
  any of C1–C3.

→ **track** → Research Agent: expand C3 smoke (`runtime-smoke-post-switch-full-coverage-v0`)
  to include stream_fold, olap_point, history_valid, invariant_valid surfaces.
  Priority: medium — run before any Gate 3 executor work begins.

→ **track** → Research Agent: add positive-executor C1 case
  (`runtime-compatibility-report-executor-boundary-v0`) with explicit
  guard_policy + capability consistency assertion. Priority: low now, HIGH
  before Gate 3.

→ **backlog**: C1 + C3 cross-validation (end-to-end compile → report →
  GuardedRuntimeMachine single assertion). Can be folded into either of the
  two tracks above rather than a standalone track.

→ **backlog**: C2 track — add one-line case-ID summary of the 12 remaining
  legacy delta items for future agent readability. Not a separate track; a
  minor doc update by next Status Curator pass.

---

## Compact Risks Table

| Risk | Found in | Severity | Current blocking? | Recommended action |
|------|----------|----------|-------------------|--------------------|
| No live-executor test case in C1 report proof | C1 | Low now / Medium at Gate 3 | No | Add before Gate 3 executor work |
| guard_policy and evaluation_readiness not cross-validated | C1 | Low | No | Fold into smoke expansion |
| 12 legacy delta items unnamed in C2 track | C2 | Low | No | Doc note by Status Curator |
| `accepted_delta_items: 2` — second item unnamed | C2 | Minimal | No | Clarification only |
| C3 smoke covers only 2 of 6 emit_typed surfaces | C3 | Medium | No | `runtime-smoke-post-switch-full-coverage-v0` |
| C3 smoke uses BiHistory only — History[T] single-axis absent | C3 | Low-Medium | No | Include in smoke expansion |
| C3 + C1 do not cross-validate TEMPORAL CompatibilityReport | C1/C3 | Low | No | Single assertion in smoke expansion |

**Overall verdict: PROCEED.** All three tracks are correct and well-scoped.
No current production bugs. Three integration gaps should be closed before
Gate 3 temporal executor work begins — not before S3-R7 closes.
