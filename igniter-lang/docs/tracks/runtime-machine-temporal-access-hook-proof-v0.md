# Runtime Machine Temporal Access Hook Proof v0

Card: `S2-R7-C4-P`
Role: `[Igniter-Lang Research Agent]`
Track: `runtime-machine-temporal-access-hook-proof-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R6-C4-P`

## Goal

Prove the bounded RuntimeMachine wiring path for SemanticIR
`temporal_access_node` evaluation:

```text
RuntimeMachine-like load/evaluate
  -> RuntimeMachineHook#load_check
  -> RuntimeMachineHook#evaluate
  -> SemanticIRTemporalAccessEvaluator
  -> MemoryBackend
```

This slice avoids parser/typechecker edits and does not implement the broad
production RuntimeMachine integration.

## Source Horizon

- `docs/current-status.md`: RuntimeMachine temporal access hook proof is the
  open gap after RuntimeMachineHook smoke.
- `docs/tracks/runtime-machine-temporal-access-hook-v0.md`: canonical
  capabilities are `history_read` for valid-time and `bihistory_read` for
  bitemporal access.
- `lib/igniter_lang/temporal_access_runtime.rb`: shared `RuntimeMachineHook`,
  `MemoryBackend`, and evaluator are already extracted.

## Proof Changes

[D] `HistoryTypeProof::HistoryRuntimeMachine` now owns a
`TemporalAccessRuntime::RuntimeMachineHook` instead of calling
`SemanticIRTemporalAccessEvaluator` directly.

[D] `HistoryRuntimeMachine#load` calls:

```ruby
RuntimeMachineHook#load_check(contract:, requirements:)
```

and records the returned hook check inside the compatibility report. A loaded
history `.igapp/` is trusted only when the hook check is `ok`.

[D] `HistoryRuntimeMachine#evaluate` calls:

```ruby
RuntimeMachineHook#evaluate(access_node, temporal_inputs:, inputs:)
```

and returns `temporal_access_loader:
"TemporalAccessRuntime::RuntimeMachineHook"` in the runtime evaluation.

[D] `SparkCRMBiHistoryFixture::Proof` now uses `RuntimeMachineHook` for
bitemporal `schedule_at`, `off_schedule_at`, and `day_off_config_at`
evaluations.

## Coverage

### Valid-Time History Path

`history_type_proof` covers:

```text
temporal_input_node(axis: "single")
temporal_access_node(access: "point", time_ref: "as_of")
required_capabilities: ["history_read"]
backend method: read_as_of
```

Checks added:

```text
runtime.hook_load_check_valid_time
runtime.temporal_access_node_loader_valid_time
negative.missing_history_read_capability_blocked
negative.missing_history_read_evaluate_rejected
```

The existing selected-append evidence check remains:

```text
runtime.output_links_selected_append_observation
```

### Bitemporal BiHistory Path

`sparkcrm_bihistory_fixture` covers:

```text
temporal_input_node(axis: "bitemporal")
temporal_access_node(valid_time_ref:, transaction_time_ref:)
required_capabilities: ["bihistory_read"]
backend method: bihistory_at
```

Checks added:

```text
runtime.hook_load_check_bitemporal
runtime.output_links_selected_event_observation
negative.missing_bihistory_read_capability_blocked
```

[S] Bitemporal selected evidence is now preserved explicitly in each projected
slot under `temporal_evidence_links`; the requested 10:00 decision slot links
`schedule_at` to the selected planned event.

## Production Gap

[R] The final production runtime integration gap is no longer the hook API or
the backend/evaluator route. The remaining gap is wiring this proven hook shape
into the production RuntimeMachine load/evaluate boundary:

```text
production RuntimeMachine.load(.igapp/)
  -> build/select TBackend adapter descriptor
  -> run RuntimeMachineHook#load_check
  -> merge hook details into CompatibilityReport
  -> block load on missing capability/backend contract

production RuntimeMachine.evaluate(...)
  -> route temporal_access_node through RuntimeMachineHook
  -> preserve returned observations and evidence_links
  -> map hook errors to canonical RuntimeMachine diagnostics
```

[R] Parser/typechecker OOF ownership remains separate. This proof should not be
used as a reason to edit grammar or typechecker behavior inside the runtime
lane.

## Proof Output

```text
ruby -c igniter-lang/experiments/history_type_proof/history_type_proof.rb -> Syntax OK
ruby -c igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb -> Syntax OK
ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb -> PASS
ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb -> PASS
ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS
```

## Changed Files

```text
igniter-lang/docs/tracks/runtime-machine-temporal-access-hook-proof-v0.md
igniter-lang/experiments/history_type_proof/history_type_proof.rb
igniter-lang/experiments/history_type_proof/history_type_proof_summary.json
igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb
igniter-lang/experiments/sparkcrm_bihistory_fixture/summary.json
igniter-lang/experiments/sparkcrm_bihistory_fixture/golden/decision_snapshot.json
igniter-lang/experiments/sparkcrm_bihistory_fixture/golden/corrected_snapshot.json
```

## Handoff

```text
Card: S2-R7-C4-P
[Igniter-Lang Research Agent]
Track: runtime-machine-temporal-access-hook-proof-v0
Status: done

[D] Decisions
- HistoryRuntimeMachine now delegates temporal_access_node load/evaluate through RuntimeMachineHook.
- SparkCRM bitemporal fixture now delegates bihistory temporal access through RuntimeMachineHook.
- Hook load checks are compatibility evidence, not parser/typechecker OOF edits.

[S] Shipped / Signals
- Valid-time history_read hook path PASS.
- Bitemporal bihistory_read hook path PASS.
- Missing history_read and bihistory_read capabilities are rejected.
- selected_append and selected_event evidence links survive the hook path.

[T] Tests / Proofs
- ruby -c igniter-lang/experiments/history_type_proof/history_type_proof.rb -> Syntax OK
- ruby -c igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb -> Syntax OK
- ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb -> PASS
- ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations
- Production RuntimeMachine still needs a real integration slice to select TBackend adapters, merge hook checks into CompatibilityReport, and canonicalize hook errors.
- Keep parser/typechecker temporal OOF work in separate cards.

[Next] Suggested next slice
- production-runtime-machine-temporal-access-integration-v0: wire this proven RuntimeMachineHook path into the production RuntimeMachine boundary.
```
