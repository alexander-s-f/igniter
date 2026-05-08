# Runtime Machine Temporal Access Hook v0

Card: `S2-R6-C4-P`
Role: `[Igniter-Lang Research Agent]`
Track: `runtime-machine-temporal-access-hook-v0`
Status: done
Date: 2026-05-07
Depends on: `S2-R5-C3-P`

## Goal

Define and implement the bounded RuntimeMachine-facing hook for SemanticIR
`temporal_access_node` evaluation.

This slice stays independent from parser/classifier extraction. It does not
edit parser/typechecker behavior and does not wire the hook into the production
RuntimeMachine proof yet.

## Capability Naming Decision

[D] Canonical temporal access capabilities:

```text
valid_time  -> history_read
bitemporal  -> bihistory_read
```

[D] Chose `bihistory_read` over `bitemporal_read` because the language type is
`BiHistory[T]`, existing SparkCRM pressure already used `bihistory_read`, and
the operation family is named `bihistory_at`.

[D] `bitemporal_read` remains only as a Ruby constant alias for migration:

```ruby
IgniterLang::TemporalAccessRuntime::Capabilities::BITEMPORAL_READ
  == "bihistory_read"
```

Current helper behavior:

```text
Capabilities.for_axis("valid_time") -> ["history_read"]
Capabilities.for_axis("single")     -> ["history_read"]
Capabilities.for_axis("bitemporal") -> ["bihistory_read"]
```

## Implemented Hook

[D] Added `IgniterLang::TemporalAccessRuntime::RuntimeMachineHook` in:

```text
igniter-lang/lib/igniter_lang/temporal_access_runtime.rb
```

Constructor:

```ruby
RuntimeMachineHook.new(backend:, capabilities: nil)
```

If `capabilities:` is omitted, the hook infers capabilities from backend
methods:

```text
respond_to?(:read_as_of)    -> history_read
respond_to?(:bihistory_at)  -> bihistory_read
```

Public methods:

```ruby
load_check(contract:, requirements: {})
evaluate(access_node, temporal_inputs:, inputs:)
```

## Hook Contract

### Load Check

`load_check` accepts a ContractIR-like hash:

```text
contract.nodes:
  temporal_input_node*
  temporal_access_node*
```

For each `temporal_access_node`, it:

```text
1. Resolves source_ref against temporal_input_node.
2. Normalizes axis: single -> valid_time.
3. Computes required capability:
   valid_time  -> history_read
   bitemporal  -> bihistory_read
4. Checks required capability is available on the backend/capability descriptor.
5. Checks required backend methods exist:
   valid_time  -> read_as_of
   bitemporal  -> bihistory_at
6. If requirements.capabilities.required_caps is present, checks the program
   declared the required capability.
```

Result shape:

```json
{
  "kind": "temporal_access_hook_load_check",
  "status": "ok",
  "checks": [
    {
      "node": "current_count",
      "axis": "valid_time",
      "required_capabilities": ["history_read"],
      "declared_capabilities": ["history_read"],
      "missing_declared_capabilities": [],
      "missing_capabilities": [],
      "required_backend_methods": ["read_as_of"],
      "missing_backend_methods": [],
      "status": "ok"
    }
  ]
}
```

### Evaluate

`evaluate` maps directly to the existing SemanticIR evaluator:

```text
RuntimeMachineHook#evaluate(...)
  -> check capability availability
  -> check backend method contract
  -> SemanticIRTemporalAccessEvaluator#evaluate(...)
```

Supported SemanticIR route:

```text
temporal_access_node
  source_ref -> temporal_input_node
  axis       -> valid_time | bitemporal
  access     -> point
```

Valid-time backend call:

```ruby
backend.read_as_of(subject, as_of)
```

Bitemporal backend call:

```ruby
backend.bihistory_at(history_ref, vt:, tt:, node_name:)
```

Returned evaluation remains unchanged:

```json
{
  "kind": "temporal_access_evaluation",
  "node": "...",
  "axis": "valid_time | bitemporal",
  "result": { "kind": "some", "value": "..." },
  "observation": { "...": "..." },
  "evidence_links": []
}
```

## TBackend Checks

[D] Minimal TBackend adapter contract for this hook:

```text
supports_capability?("history_read")   -> true | false  (optional if capabilities: supplied)
supports_capability?("bihistory_read") -> true | false  (optional if capabilities: supplied)
read_as_of(subject, as_of)             -> [Option[T], history_access_observation]
bihistory_at(history_ref, vt:, tt:, node_name:)
                                      -> [Option[T], bihistory_access_observation]
```

[D] Hook errors:

```text
CapabilityError(capability, node)
BackendContractError(method_name, axis)
```

These are runtime hook errors for now. Parser/typechecker OOF ownership remains
separate.

## Smoke Checks

```text
ruby -c igniter-lang/lib/igniter_lang/temporal_access_runtime.rb -> Syntax OK
ruby -c igniter-lang/experiments/temporal_access_runtime/temporal_access_runtime.rb -> Syntax OK
runtime_hook_smoke: ok
runtime_hook_capability_block: ok
```

Smoke covered:

```text
valid_time capability: history_read
bitemporal capability: bihistory_read
load_check status: ok for valid_time
evaluate delegates to SemanticIRTemporalAccessEvaluator and returns Option.some(7)
load_check blocks bitemporal when bihistory_read is unavailable
evaluate raises CapabilityError("bihistory_read") when unavailable
```

## Proof Output

History proof:

```text
PASS history_type_proof
history.append_seed_observations: ok
parser.hand_authored_history_parsed_program: ok
classifier.history_read_escape: ok
typechecker.history_at_option_integer: ok
semanticir.temporal_input_node: ok
semanticir.temporal_access_node: ok
assembler.history_igapp: ok
runtime.load_history_igapp_trusted: ok
runtime.evaluate_as_of_2026_05_03: ok
runtime.evaluate_as_of_2026_05_06: ok
runtime.output_links_selected_append_observation: ok
runtime.temporal_access_node_loader_valid_time: ok
negative.missing_as_of_oof_h1: ok
compilation.positive_report_ok: ok
option.encoding: some={"kind":"some","value":value} none={"kind":"none"}
summary: igniter-lang/experiments/history_type_proof/history_type_proof_summary.json
```

SparkCRM BiHistory proof:

```text
PASS sparkcrm_bihistory_fixture
seed.synthetic_bihistory_events: ok
option.canonical_some: ok
option.canonical_none: ok
decision.snapshot_blocks_requested_window: ok
corrected.snapshot_frees_requested_window: ok
correction.report_links_prior_and_corrected_events: ok
dispatch.original_explanation_preserved: ok
runtime.temporal_access_node_loader_bitemporal: ok
negative.missing_vt_oof_bt2: ok
negative.missing_tt_oof_bt3: ok
negative.wrong_axis_type_oof_bt4: ok
safety.synthetic_only: ok
decision.requested_window: blocked/busy
corrected.requested_window: available/available
correction.changed_slots: 1
summary: igniter-lang/experiments/sparkcrm_bihistory_fixture/summary.json
```

Stage 1 regression:

```text
PASS stage1_close_candidate
classifier: PASS
typechecker: PASS
semanticir: PASS
stdlib_kernel: PASS
igapp_assembler: PASS
summary: igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.json
```

## Changed Files

```text
igniter-lang/docs/tracks/runtime-machine-temporal-access-hook-v0.md
igniter-lang/lib/igniter_lang/temporal_access_runtime.rb
```

## Handoff

```text
Card: S2-R6-C4-P
[Igniter-Lang Research Agent]
Track: runtime-machine-temporal-access-hook-v0
Status: done

[D] Decisions
- Canonical valid-time capability is history_read.
- Canonical bitemporal capability is bihistory_read.
- bitemporal_read remains only as a Ruby alias to bihistory_read during migration.
- Added RuntimeMachineHook as the bounded resolver hook surface.
- Hook maps SemanticIR temporal_access_node to TemporalAccessRuntime evaluator.
- Hook checks capability availability and backend method contract before evaluation.

[S] Shipped / Signals
- RuntimeMachineHook#load_check returns per-node ok/blocked compatibility data.
- RuntimeMachineHook#evaluate delegates to SemanticIRTemporalAccessEvaluator.
- Positive hook smoke evaluates valid_time access to Option.some(7).
- Negative hook smoke blocks bitemporal access without bihistory_read.

[T] Tests / Proofs
- ruby -c igniter-lang/lib/igniter_lang/temporal_access_runtime.rb -> Syntax OK
- ruby -c igniter-lang/experiments/temporal_access_runtime/temporal_access_runtime.rb -> Syntax OK
- runtime_hook_smoke -> ok
- runtime_hook_capability_block -> ok
- ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb -> PASS
- ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks / Recommendations
- Next implementation should wire RuntimeMachineHook into a proof RuntimeMachine
  load/evaluate path, producing CompatibilityReport.backend_check details.
- Compiler/Grammar should adopt bihistory_read in classifier/typechecker outputs.

[Next] Suggested next slice
- runtime-machine-temporal-access-hook-proof-v0:
  wire RuntimeMachineHook into the proof-local HistoryRuntimeMachine load/evaluate
  path and add explicit blocked capability fixture coverage.
```
