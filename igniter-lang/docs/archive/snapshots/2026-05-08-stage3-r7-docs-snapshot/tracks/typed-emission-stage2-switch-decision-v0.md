# Track: Typed Emission Stage 2 Switch Decision v0

Card: S3-R4-C4-S
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: typed-emission-stage2-switch-decision-v0
Date: 2026-05-08
Status: done

Depends on:
- S3-R1-C3-P: typed-emission-main-path-parity-v0
- S3-R2-C1-P: typed-emission-canonical-shape-v0
- S3-R3-C1-P: typed-emission-stage2-source-lowering-parity-v0

---

## Purpose

Make a governance decision on switching `CompilerOrchestrator` from:

```ruby
# current production path (since S2-R10)
compilation = @emitter.emit(parsed, sample_input: resolved_sample_input)
```

to:

```ruby
# candidate path
compilation = @emitter.emit_typed(typed_program)
```

Three rounds of evidence are now in place. This document:

1. Explains what the parity proof metrics mean.
2. Frames the three decision options with a decision matrix.
3. Makes the governance recommendation.
4. Defines the exact next implementation card.
5. States the risks of switching too early.

No code changes in this slice.

---

## I. What The Parity Metrics Mean

Current state after S3-R3-C1-P:

```
PASS typed_emission_main_path_parity
verdict:                          blocked
safe_to_switch_production_path:   false
cases_run:                        5
package_facade_add:               PASS
invariant_valid:                  FAIL
olap_point:                       FAIL
stream_fold:                      FAIL
history_access:                   FAIL
sparkcrm_bihistory:               NOT_COMPARABLE
ledger_tbackend_descriptor:       NOT_COMPARABLE
blocked_items:                    13
typed_source_blocked_items:       0
legacy_parity_delta_items:        11
```

### `typed_source_blocked_items: 0`

The typed emission path (`emit_typed`) has no remaining source-path blockers.
For all four Stage 2 surfaces — invariant, OLAP, stream, history — the typed
path can receive a source `.ig` file, parse it, classify it, typecheck it, and
produce a valid SemanticIR output. The typed path is **complete** for these
surfaces.

This is positive evidence. It means the investment in typed emission is paying
off: the new path handles Stage 2 language features that the legacy parsed path
does not.

### `legacy_parity_delta_items: 11`

The **legacy parsed path** still differs from the typed path on 11 specific
items across 4 cases. These are not defects in typed emission. They are a
precise description of the capability gap between the two paths.

Breakdown of the 11 legacy deltas:

```
Case              Count  Nature
──────────────────────────────────────────────────────────────────────────
invariant_valid     2    parsed path: missing $.invariants; nodes 1 vs 5
                         missing $.invariant_coverage in report
olap_point          3    parsed path: pass_result=oof, semantic_ir absent;
                         report shows OOF diagnostics, classify=oof
stream_fold         3    parsed path: pass_result=oof, semantic_ir absent;
                         report shows OOF diagnostic, classify=oof
history_access      3    parsed path: pass_result=oof, semantic_ir absent;
                         report shows OOF diagnostics, classify/typecheck=oof
──────────────────────────────────────────────────────────────────────────
```

For **OLAP, stream, and history**: the parsed legacy path reaches OOF for these
sources. This is not a regression — it reflects that the legacy parsed emitter
was built in Stage 1 and was never updated to handle Stage 2 constructs.

For **invariant**: the parsed path produces a SemanticIR but misses the
`$.invariants` top-level section and `$.invariant_coverage` in the report.
These are typed-emission improvements that were added during Stage 2 formalization
but never backported to the parsed path.

[D] The `legacy_parity_delta_items` are not defects to be fixed in the legacy
path. They are the description of what the legacy path intentionally lacks.

### `safe_to_switch_production_path: false`

The gate condition `safe_to_switch = false` means that switching
`CompilerOrchestrator` to `emit_typed` **right now** would produce observable
behavioral differences for any source that triggers OLAP, stream, history, or
invariant emission: those sources would change from `pass_result: oof` to
`pass_result: ok` with a full SemanticIR output. This is a semantically correct
improvement, but it is a **breaking change in public behavior**.

The switch is not unsafe in the sense of producing wrong output. It is unsafe
in the sense of **producing different output than clients and tests currently
expect**.

The proof's `safe_to_switch_production_path` gate is conservative by design:
it measures whether the two paths produce identical outputs for the same source,
not whether the typed path is correct.

---

## II. Decision Options

Three options were posed in the S3-R3-C1-P track handoff.

### Option A: Legacy parsed emission parity required

*Bring the parsed path to full Stage 2 feature parity before switching.*

This means:
- Implement `invariant_node` emission in the legacy parsed emitter.
- Implement OLAP, stream, and history lowering in the parsed path.
- Bring the 11 legacy deltas to zero.
- Only then flip the orchestrator.

**Analysis:**

This is the highest-cost, lowest-value option. The legacy parsed path was the
Stage 1 implementation. It was never designed to carry Stage 2 semantics. Adding
Stage 2 nodes to it is backward investment in a deprecated path — every line
added to the parsed path will be thrown away when the orchestrator eventually
switches. There is no architectural rationale for this.

The only legitimate reason to prefer Option A is if there are external consumers
of the parsed emission path that must not observe any behavioral change. In the
current `igniter-lang` research context (no production consumers), that reason
does not apply.

**Verdict: rejected.**

### Option B: Typed emission becomes the sole Stage 2+ lowering path

*Accept that parsed emission handles Stage 1 only. Switch the orchestrator to
`emit_typed` after a minimal gate. Retire the legacy path as Stage 1 legacy.*

This means:
- Define a minimal switch gate (see §III).
- Switch `CompilerOrchestrator` to `emit_typed` after the gate passes.
- Update all Stage 2+ goldens and close-candidate fixtures to reflect the new
  output shape.
- Keep the parsed path accessible as a backward-compatibility option or
  internal detail but not as the production main path.

**Analysis:**

This aligns with the explicit goal stated in `META-EXPERT-011` and in the
S3-R1 card: "`emit_typed` path active in orchestrator" is one of the six Stage 3
close criteria. The typed path was designed to be the production direction; the
research work in R1–R3 has built sufficient evidence that it is ready.

The breaking behavioral change is real but scoped: sources using OLAP, stream,
History/BiHistory, or invariant syntax will produce valid SemanticIR instead of
OOF. This is the correct behavior for Stage 2+. The parity harness `FAIL` for
these cases reflects the legacy path being behind, not the typed path being wrong.

**Verdict: recommended.** See §III.

### Option C: Staged dual-path mode

*Keep both paths active. Route sources by a CLI flag or fragment-class heuristic.*

This means:
- CORE sources → parsed emission.
- Stage 2+ sources → typed emission.
- Introduce a routing mechanism in `CompilerOrchestrator`.

**Analysis:**

This option adds complexity without architectural benefit. The two paths would
need to remain in sync for CORE surfaces (risking drift). The routing logic
would require fragment-class detection before full compilation (requiring an
extra early-classifier pass). The dual-path state already exists in the current
codebase; the problem is that it has no explicit retirement plan.

If the goal is to reduce risk during the switch, Option C is a temporarily
acceptable workaround. But it is a governance band-aid, not a direction. Any
dual-path mode must have an explicit retirement timeline — otherwise the project
accumulates two emission paths indefinitely.

If used: Option C should require that the legacy path be deprecated with a
versioned notice in the next gem metadata cycle, and that Option B gate evidence
is the retirement condition.

**Verdict: acceptable only as a time-boxed transition, not as a final state.**

---

## III. Decision Matrix

```
Option     Architectural clarity  Cost   Risk on switch  Stage 3 goal alignment
──────────────────────────────────────────────────────────────────────────────
A          ❌ backward investment  HIGH   LOW             ❌ wrong direction
B          ✅ clean forward path   LOW    MEDIUM          ✅ direct
C          ⚠️  dual-path debt       MEDIUM LOW             ⚠️  deferred debt
──────────────────────────────────────────────────────────────────────────────
```

Additional gate conditions for Option B:

```
Condition                                      Status
──────────────────────────────────────────────────────────────────────────────
typed_source_blocked_items = 0                 ✅ PASS (S3-R3-C1-P)
package_facade_add (CORE baseline) parity      ✅ PASS (S3-R2-C1-P)
stage2_close_candidate PASS (via parsed path)  ✅ PASS (unchanged)
stage1_close_candidate PASS                    ⚠️ classifier golden mismatch
                                                  (separate issue, not emission)
SparkCRM BiHistory source fixture              ❌ no .ig source, proof-local only
Ledger descriptor not source-comparable        ✅ accepted (metadata, not emission)
```

SparkCRM BiHistory is the only remaining gate condition that directly affects
typed emission coverage. The stage1_close_candidate classifier mismatch
(`olap_points` field) is a separate golden-update issue unrelated to the
orchestrator switch.

---

## IV. Governance Decision

[D] **Path B is the correct architectural direction.**

Typed emission is the production path. Parsed emission is the Stage 1 legacy
path. The switch should proceed after the SparkCRM BiHistory source fixture is
added to the parity harness.

[D] **The switch gate has exactly two conditions:**

```
Gate 1: SparkCRM BiHistory .ig source fixture added to parity harness
        -> sparkcrm_bihistory must move from NOT_COMPARABLE to PASS or FAIL
           (FAIL is acceptable if the delta is documented and accepted)

Gate 2: stage2_close_candidate PASS through typed emission path
        -> run after orchestrator switch to confirm no regression
```

[D] **The switch must not be blocked on legacy parity.**

The 11 `legacy_parity_delta_items` are not a switch blocker. They represent
the legacy path being behind the typed path. The typed path produces the correct
Stage 2 outputs. This is not a risk — it is the intended improvement.

[D] **After the switch, update goldens and close-candidate fixtures to typed
emission shape.** The old parsed emission shape for Stage 2 surfaces becomes
historical.

[D] **The parsed path (`emit`) should remain in the codebase but be marked as
Stage 1 legacy.** It should not be called from the production orchestrator after
the switch. It may remain for internal testing and comparison utilities.

---

## V. Risks If Switching Too Early (before Gate 1)

Before SparkCRM BiHistory has a source fixture and parity check:

**Risk 1: Stage 2 close evidence becomes partially untestable through the new path.**

The stage2_close_candidate uses SparkCRM BiHistory as proof-local evidence.
If BiHistory lacks a source fixture, the typed emission path cannot be
verified end-to-end for BiHistory. The close candidate would silently rely on
proof-local Ruby fixture evidence for this surface — which is not source-path
parity evidence.

**Risk 2: BiHistory temporal access node lowering may have source-path gaps.**

The typed path proves BiHistory from proof-local TypedProgram fixtures. The
source-to-typed path for BiHistory (`.ig` → Parser → Classifier → TypeChecker →
`emit_typed`) has not been measured. If there are gaps in that path (analogous
to the OLAP `KeyError` seen in S3-R1-C3-P), the switch would produce a runtime
error for BiHistory sources.

**Risk 3: The parity harness would undercount coverage.**

If the parity harness keeps `sparkcrm_bihistory: NOT_COMPARABLE` after the
switch, it provides false confidence: the harness passes while an untested
surface remains. The harness becomes misleading documentation.

**Risk 4: OOF-to-OK behavioral transition is irreversible in golden files.**

Once goldens are updated to typed emission shape, the previous parsed-path
behavior is erased from the test suite. If a regression is later discovered in
the typed path for a Stage 2 surface, there is no fast comparison baseline.
Mitigation: archive the final parsed-path golden snapshot before switching.

---

## VI. Exact Next Implementation Card

```text
Card: S3-R4-C5-P (or equivalent)
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: bihistory-source-fixture-parity-gate-v0

Goal:
1. Add a .ig source fixture for SparkCRM BiHistory (or a minimal BiHistory
   contract exercising both valid_time and transaction_time reads).
2. Run that fixture through Parser → Classifier → TypeChecker → emit_typed.
3. Add it to the parity harness: sparkcrm_bihistory must move from
   NOT_COMPARABLE to PASS.
4. Run stage2_close_candidate PASS.

Acceptance: sparkcrm_bihistory PASS in parity harness, stage2_close_candidate PASS.

After acceptance: switch CompilerOrchestrator to emit_typed.
  Card: S3-R4-C6-P: orchestrator-emit-typed-switch-v0
```

The orchestrator switch should be a **separate one-line card** after gate
evidence is confirmed, not bundled into the parity gate card. This maintains
auditability: the parity gate and the switch have distinct proof artifacts.

---

## VII. Summary

```text
Where we are:
  typed_source_blocked_items: 0   → typed path is Stage 2 complete
  legacy_parity_delta_items: 11   → legacy path is Stage 1 only (by design)
  safe_to_switch: false           → behavioral delta exists; not a bug

Decision:
  Option B: typed emission becomes sole Stage 2+ lowering path
  Reject Option A: backward investment
  Reject Option C as permanent state (acceptable as time-boxed transition)

Switch gate (2 conditions):
  1. sparkcrm_bihistory: NOT_COMPARABLE → PASS in parity harness
  2. stage2_close_candidate PASS through typed path after switch

Next card:
  bihistory-source-fixture-parity-gate-v0 [Research Agent]
  -> PASS → orchestrator-emit-typed-switch-v0 [Research Agent]
```

---

## Handoff

```text
Card: S3-R4-C4-S
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: typed-emission-stage2-switch-decision-v0
Status: done

[D] Decisions
- Typed emission is the production path direction. Option B adopted.
- Option A (legacy parity) is rejected: backward investment with no value.
- Option C is acceptable only as a time-boxed transition, not permanent.
- Legacy parity deltas (11 items) are not switch blockers — they describe the
  legacy path being behind.
- Switch gate has exactly two conditions:
    1. sparkcrm_bihistory source fixture added, parity PASS
    2. stage2_close_candidate PASS through typed path post-switch
- The orchestrator switch must be a separate card from the parity gate.

[S] Signals
- Typed path is Stage 2 complete (typed_source_blocked_items: 0).
- 11 legacy deltas are a capability gap description, not defects in typed path.
- SparkCRM BiHistory is the only blocking parity gap.
- Stage 1 close candidate mismatch is a separate golden issue, not a switch blocker.

[R] Risks
- Switching before BiHistory source fixture: parity harness gives false confidence.
- Switching before BiHistory source path validation: possible runtime error on
  BiHistory .ig sources.
- Forgetting to archive parsed-path goldens before switch: loses regression baseline.

[Next] Suggested next slices
- S3-R4-C5-P: bihistory-source-fixture-parity-gate-v0 [Research Agent]
  Acceptance: sparkcrm_bihistory PASS, stage2_close_candidate PASS
- S3-R4-C6-P: orchestrator-emit-typed-switch-v0 [Research Agent]
  Depends on: S3-R4-C5-P gate PASS
  One change: compiler_orchestrator.rb emit → emit_typed
```
