# Track: Executor Boundary Cache Key Contract v0

Card: S3-R9-C3-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/executor-boundary-cache-key-contract-v0`
Status: done
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Prove that a future TEMPORAL executor boundary must construct
TEMPORAL-shaped cache keys and reject CORE-shaped keys before any executor,
TBackend, Ledger, or production cache work is allowed.

This addresses the PROP-028 silent-staleness risk:

```text
CORE      key = hash(contract, inputs)
TEMPORAL  key = hash(contract, inputs, as_of/Tt)
```

A CORE-shaped key for a TEMPORAL contract can reuse a value from the wrong time
coordinate. That is semantic corruption, not a cache optimization detail.

---

## Decision

[D] The executor boundary must read cache-key shape from:

```text
manifest.contract_index.<contract>.temporal.cache_key_schema_hint
```

[D] CORE contracts can use:

```json
{
  "fragment": "CORE",
  "contract_ref": "...",
  "inputs": {}
}
```

[D] TEMPORAL contracts must use:

```json
{
  "fragment": "TEMPORAL",
  "contract_ref": "...",
  "inputs": {},
  "axis": "valid_time | bitemporal",
  "temporal_coordinates": []
}
```

[D] A CORE-shaped key for TEMPORAL is refused at the executor boundary with an
`L-T5`-style fault:

```json
{
  "kind": "cache_key_fault",
  "status": "refused",
  "gate": "L-T5",
  "reason_code": "executor.cache_key_schema_mismatch"
}
```

[D] The proof remains proof-local. It does not authorize live executor,
TBackend, Ledger, or production cache behavior.

---

## Implemented Proof

Added:

```text
igniter-lang/experiments/executor_boundary_cache_key_contract/
  executor_boundary_cache_key_contract.rb
  out/executor_boundary_cache_key_contract_summary.json
  out/*.igapp/
```

The proof compiles three artifacts into its own `out/` directory:

| Artifact | Fragment | Source |
| --- | --- | --- |
| `core_add.igapp` | CORE | `source_to_semanticir_fixture/add.ig` |
| `history_single_axis.igapp` | TEMPORAL | `history_type_proof/history_integer_point_access.ig` |
| `bihistory_bitemporal.igapp` | TEMPORAL | `typed_emission_main_path_parity/sparkcrm_bihistory_source.ig` |

It then reads `manifest.contract_index` from each artifact and constructs cache
keys at a simulated executor boundary.

---

## Proof Cases

| Case | Expected result |
| --- | --- |
| CORE Add requested with CORE key | accepted |
| History requested with TEMPORAL key containing `valid_time` | accepted |
| History requested with CORE-shaped key | refused, `L-T5` |
| History same inputs, different `as_of` | CORE key collides; TEMPORAL key changes |
| BiHistory requested with TEMPORAL key containing `valid_time` + `transaction_time` | accepted |
| BiHistory requested with CORE-shaped key | refused, `L-T5` |
| BiHistory same inputs, different transaction-time | CORE key collides; TEMPORAL key changes |

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/executor_boundary_cache_key_contract/executor_boundary_cache_key_contract.rb
```

Observed output:

```text
PASS executor_boundary_cache_key_contract
core.key_shape_contract_plus_inputs: ok
core.requested_core_key_accepted: ok
history.temporal_key_uses_manifest_hint: ok
history.temporal_key_includes_valid_time: ok
history.core_shaped_key_refused_l_t5: ok
history.silent_staleness_prevented: ok
bihistory.temporal_key_uses_manifest_hint: ok
bihistory.temporal_key_includes_vt_and_tt: ok
bihistory.core_shaped_key_refused_l_t5: ok
bihistory.silent_staleness_prevented: ok
```

Summary:

```text
igniter-lang/experiments/executor_boundary_cache_key_contract/out/executor_boundary_cache_key_contract_summary.json
```

---

## PROP-028 Link

This proof concretizes PROP-028 §5.3:

```text
If a RuntimeMachine caches a TEMPORAL contract using the CORE key, it can return
a stale value for a different as_of without crashing.
```

The executor boundary now has a concrete proof-local contract:

```text
manifest says TEMPORAL
  -> executor cache key must be TEMPORAL
  -> CORE-shaped key is L-T5 refusal
```

---

## Non-Authorization

This track does not authorize:

- live TEMPORAL executor
- live TBackend binding
- Ledger read/write/replay
- production RuntimeMachine cache
- cache hit/miss persistence
- bypassing `CompatibilityReport.evaluation_readiness`

---

## Handoff

```text
Card: S3-R9-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/executor-boundary-cache-key-contract-v0
Status: done

[D] Decisions
- Executor-boundary cache key construction must consume
  manifest.contract_index.cache_key_schema_hint.
- CORE keys are contract + inputs.
- TEMPORAL keys are contract + non-temporal inputs + temporal coordinates.
- CORE-shaped keys for TEMPORAL are refused with L-T5-style fault.

[S] Shipped / Signals
- Added proof-local executor_boundary_cache_key_contract experiment.
- Proved Add CORE key acceptance.
- Proved History and BiHistory TEMPORAL key acceptance.
- Proved History and BiHistory CORE-shaped key rejection.
- Explicitly linked the refusal to PROP-028 silent staleness prevention.

[T] Tests / Proofs
- executor_boundary_cache_key_contract -> PASS
- ruby -c executor_boundary_cache_key_contract.rb -> Syntax OK

[R] Risks / Recommendations
- Future executor implementation must call this boundary before cache lookup or
  TBackend access.
- Gate 3 remains closed; this is a cache-key contract, not executor approval.

[Next] Suggested next slice
- Runtime executor approval token/field contract, or production RuntimeMachine
  check that evaluates CompatibilityReport readiness before executor/cache use.
```
