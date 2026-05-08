# BiHistory Source Fixture Parity Gate v0

Card: S3-R5-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/bihistory-source-fixture-parity-gate-v0
Status: done
Date: 2026-05-08

## Goal

Close the typed-emission switch gate by adding a source-level BiHistory fixture
to the parity harness.

This slice does not switch `CompilerOrchestrator`.

## Source Fixture

Added:

```text
igniter-lang/experiments/typed_emission_main_path_parity/sparkcrm_bihistory_source.ig
```

The fixture is intentionally minimal but SparkCRM-shaped:

```text
read availability_history: BiHistory[String]
  from "sparkcrm/{technician_id}/availability"
  lifecycle :durable

compute availability_at =
  bihistory_at(availability_history, valid_time, transaction_time)
```

It exercises both bitemporal coordinates:

```text
valid_time: DateTime
transaction_time: DateTime
```

and routes through:

```text
Parser -> Classifier -> TypeChecker -> SemanticIREmitter#emit_typed
```

## Harness Change

[D] `sparkcrm_bihistory` moved from `PROOF_LOCAL_CASES` to `SOURCE_CASES`.

Before:

```text
sparkcrm_bihistory: NOT_COMPARABLE
```

After:

```text
sparkcrm_bihistory: FAIL
```

This is an intentional measured result, not a missing fixture. The typed path
passes and emits the required temporal nodes; the current parsed legacy path
OOFs, so parity remains a legacy delta:

```text
parsed.pass_result: oof
typed.pass_result: ok
parsed.semantic_ir.present: false
typed.semantic_ir.present: true
typed.node_kinds:
  temporal_access_node
  temporal_input_node
```

Explicit status reason:

```text
report.pass_result: parsed="oof", typed="ok";
semantic_ir.present: parsed=false, typed=true;
CompilationReport differs after identity fields are normalized.
```

[D] `ledger_tbackend_descriptor` remains `NOT_COMPARABLE`, because it is
metadata-only descriptor evidence rather than a SemanticIR emission source.

## Proof Output

Command:

```text
ruby igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb
```

Result:

```text
PASS typed_emission_main_path_parity
verdict: blocked
safe_to_switch_production_path: false
cases_run: 6
package_facade_add: PASS
invariant_valid: FAIL
olap_point: FAIL
stream_fold: FAIL
history_access: FAIL
sparkcrm_bihistory: FAIL
ledger_tbackend_descriptor: NOT_COMPARABLE
blocked_items: 15
typed_source_blocked_items: 0
legacy_parity_delta_items: 14
```

Updated outputs:

```text
igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.json
igniter-lang/experiments/typed_emission_main_path_parity/golden/typed_emission_main_path_parity.golden.json
```

## Switch Gate Recommendation

[D] The BiHistory source fixture gate is closed: `sparkcrm_bihistory` is no
longer `NOT_COMPARABLE`.

[D] `typed_source_blocked_items` remains `0`, including the new BiHistory
source fixture.

[R] Proceed to a separate `CompilerOrchestrator` `emit_typed` switch card.
Do not switch inside this parity-gate slice.

Why `safe_to_switch_production_path` is still `false`:

```text
safe_to_switch_production_path is the strict legacy parity flag.
legacy_parity_delta_items are retained as evidence.
typed source blockers are the switch gate from the Stage 3 switch decision.
```

This means the harness still reports the conservative parity verdict
`blocked`, while the explicit orchestrator switch gate now recommends
`PROCEED` for the next, separate switch slice.

## Stage 2 Regression

Command:

```text
ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb
```

Result:

```text
PASS stage2_close_candidate
verdict: stage2_close_candidate
package_facade: PASS
invariant_runtime_observations: PASS
olap_point: PASS
stream_fold: PASS
history_bihistory_temporal_access: PASS
ledger_tbackend_descriptor: PASS
stage1_regression: PASS
```

## Changed Files

```text
igniter-lang/docs/tracks/bihistory-source-fixture-parity-gate-v0.md
igniter-lang/experiments/typed_emission_main_path_parity/sparkcrm_bihistory_source.ig
igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb
igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.json
igniter-lang/experiments/typed_emission_main_path_parity/golden/typed_emission_main_path_parity.golden.json
```

## Handoff

```text
Card: S3-R5-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/bihistory-source-fixture-parity-gate-v0
Status: done

[D] Decisions
- Added a source-level BiHistory fixture to the typed emission parity harness.
- Moved `sparkcrm_bihistory` from `NOT_COMPARABLE` proof-local evidence to a measured source case.
- Kept `CompilerOrchestrator` unchanged.
- Kept `ledger_tbackend_descriptor` as `NOT_COMPARABLE` because it is metadata evidence, not an emission source.

[S] Shipped / Signals
- `sparkcrm_bihistory` now routes through Parser -> Classifier -> TypeChecker -> emit_typed.
- Typed path emits `temporal_input_node` and `temporal_access_node`.
- The case status is `FAIL` only because legacy parsed emission OOFs while typed emission succeeds.
- Added `orchestrator_switch_gate.status = PROCEED` to the parity summary.

[T] Tests / Proofs
- `ruby -c igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb` -> Syntax OK
- `ruby igniter-lang/experiments/typed_emission_main_path_parity/typed_emission_main_path_parity.rb` -> PASS, verdict blocked, typed_source_blocked_items 0
- `ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb` -> PASS

[R] Risks / Recommendations
- Recommendation: proceed to a separate orchestrator switch card.
- Do not interpret strict `safe_to_switch_production_path=false` as a fresh source blocker; it is preserving legacy parsed-vs-typed parity deltas.
- Archive or retain the final parsed-path parity evidence before switching if governance wants a comparison baseline.

[Next]
- `orchestrator-emit-typed-switch-v0`: switch `CompilerOrchestrator` to `emit_typed`, then run Stage 2 close candidate through the new main path.
```
