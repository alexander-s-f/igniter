# Track: Production RuntimeMachine Temporal Access Integration v0

Role: `[Igniter-Lang Research Agent]`
Track: `igniter-lang/production-runtime-machine-temporal-access-integration-v0`
Card: S2-R8-C4-P
Status: done
Date: 2026-05-07
Depends on: S2-R7-C4-P
Parallel note: Runtime integration lane. No parser/typechecker edits.

---

## Context

`runtime-machine-temporal-access-hook-proof-v0` proved the shared
`TemporalAccessRuntime::RuntimeMachineHook` for both:

- `history_read` valid-time access
- `bihistory_read` bitemporal access

That proof still lived mostly in History/BiHistory fixtures. This slice moves the hook
shape into the Stage 1 RuntimeMachine memory harness so the production integration point
is concrete without introducing real production TBackend adapters.

---

## RuntimeMachine Integration Point

The bounded production shape is:

```text
RuntimeMachine#load(contract, temporal_backend:)
  -> if contract exposes semantic_contract nodes
  -> build RuntimeMachineHook with TBackend adapter
  -> RuntimeMachineHook#load_check(contract:, requirements:)
  -> merge check into loaded_unit[:temporal_access_hook]
  -> block load on missing capability/backend method

RuntimeMachine#evaluate_temporal_access(node_name:, inputs:, as_of:, rule_version:)
  -> resolve temporal_access_node by name
  -> collect temporal_input_node table
  -> RuntimeMachineHook#evaluate(...)
  -> emit value_observation + receipt_observation
  -> preserve selected evidence links
```

This is proof code, but the method boundary maps directly to the production RuntimeMachine
load/evaluate phases.

---

## Capability Check

The proof uses the canonical capability names already decided in the hook track:

```text
valid-time History[T] -> history_read
bitemporal BiHistory[T] -> bihistory_read
```

`TemporalDispatchContract#runtime_requirements` declares:

```json
{ "capabilities": { "required_caps": ["history_read"] } }
```

At load, `RuntimeMachineHook#load_check` verifies:

- the contract declares the capability
- the adapter exposes the capability
- the adapter has the required backend method

The loaded unit records the hook check under `temporal_access_hook`.

---

## TBackend Adapter Expectation

The production adapter contract is now explicit:

```ruby
adapter.capabilities -> Array<String>
adapter.supports_capability?(capability) -> true/false
adapter.read_as_of(subject, as_of) -> [result, observation]          # history_read
adapter.bihistory_at(history_ref, vt:, tt:, node_name:) -> [...]     # bihistory_read
```

This slice adds a proof-local `MemoryTemporalAccessAdapter` that adapts the
Stage 1 `MemoryTBackend#read(subject:, as_of:)` method to the hook's `read_as_of`
expectation. Real production adapters remain out of scope.

---

## Error Shape

Load-time hook failures map to canonical RuntimeMachine failure packets with a compact
runtime diagnostic shape:

```json
{
  "reason_code": "temporal_access.missing_capability",
  "message": "temporal access capability is unavailable",
  "capability": "history_read",
  "node": "schedule_slot_at",
  "axis": "valid_time"
}
```

Backend contract failures use:

```json
{
  "reason_code": "temporal_access.backend_contract_missing",
  "message": "temporal backend adapter is missing required method",
  "backend_method": "read_as_of",
  "node": "schedule_slot_at",
  "axis": "valid_time"
}
```

Evaluate-time `CapabilityError` and `BackendContractError` are mapped to the same
reason-code family.

---

## Proof Update

`runtime_machine_memory_proof.rb` now includes a bounded temporal access case:

- boots a RuntimeMachine
- seeds ordinary memory facts
- loads `TemporalDispatchContract`
- runs hook load check through `RuntimeMachine#load`
- evaluates `schedule_slot_at` through `RuntimeMachine#evaluate_temporal_access`
- preserves the selected append evidence link
- rejects missing `history_read`
- rejects an adapter missing `read_as_of`

The existing Stage 1 golden path and resume/migration checks remain unchanged.

---

## Final Adapter Gap

The final production gap is adapter selection and compatibility persistence:

1. Select a production TBackend adapter from `.igapp/` runtime metadata.
2. Bind adapter capability declarations to `CompatibilityReport`.
3. Persist hook load checks as first-class compatibility dimensions.
4. Route emitted SemanticIR `temporal_access_node` through the hook from the real resolver.
5. Preserve access observations and evidence links in production RuntimeMachine output.
6. Add the bitemporal production adapter method (`bihistory_at`) next to `read_as_of`.

Parser and TypeChecker temporal ownership stays outside this lane.

---

## Acceptance Status

| Check | Status |
|-------|--------|
| `ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb` | PASS |
| `ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb` | PASS |
| `ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb` | PASS |
| `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS |

---

## Handoff

```text
[Igniter-Lang Research Agent]
Card: S2-R8-C4-P
Track: production-runtime-machine-temporal-access-integration-v0
Status: done

[D] Decisions:
- RuntimeMachine#load is the production integration point for temporal hook compatibility checks.
- RuntimeMachine#evaluate_temporal_access is the resolver hook boundary for temporal_access_node.
- TBackend adapters must expose capabilities plus read_as_of / bihistory_at methods expected by RuntimeMachineHook.
- Missing capability/backend contract errors map to temporal_access.* RuntimeMachine failure packets.

[S] Signals:
- runtime_machine_memory_proof now proves hook load/evaluate inside RuntimeMachine.
- selected_append evidence survives the RuntimeMachine hook route.
- Missing history_read and missing read_as_of are blocked at load.
- History/BiHistory proof stack remains green.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/runtime_machine_memory_proof/runtime_machine_memory_proof.rb -> PASS
- ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb -> PASS
- ruby igniter-lang/experiments/sparkcrm_bihistory_fixture/sparkcrm_bihistory_fixture.rb -> PASS
- ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb -> PASS

[R] Risks:
- This is still a proof-local RuntimeMachine contract, not the production adapter registry.
- bitemporal production adapter selection is specified but not added to runtime_machine_memory_proof.
- CompatibilityReport persistence of hook checks remains the final production gap.

[Next] Production RuntimeMachine adapter binding:
- Add adapter selection from .igapp runtime metadata, persist temporal hook checks in CompatibilityReport,
  and route real SemanticIR temporal_access_node evaluation through RuntimeMachineHook.
```
