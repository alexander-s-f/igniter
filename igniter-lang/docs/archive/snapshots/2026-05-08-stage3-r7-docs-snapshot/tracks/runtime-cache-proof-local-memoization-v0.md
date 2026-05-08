# Track: Runtime Cache Proof-Local Memoization v0

Card: S3-R4-C5-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/runtime-cache-proof-local-memoization-v0`
Status: done
Date: 2026-05-08

---

## Goal

Implement a proof-only RuntimeMachine memoization fixture from the S3-R3 runtime
temporal cache contract.

This is not production RuntimeMachine caching.

Affected neighbor roles:

- Compiler/Grammar Expert
- Bridge Agent

---

## Current Horizon

The prerequisite direction is clear enough for a proof:

- `temporal_input_node` / `temporal_access_node` now survive assembler output as
  `contracts/*.json.temporal_nodes`.
- temporal axes and coordinate refs are also copied into `requirements.json`.
- runtime temporal execution remains explicitly unsupported for assembled
  temporal artifacts.

This card tests cache semantics against that metadata shape only.

---

## Decisions

[D] The proof uses a local in-memory cache store only.

[D] CORE keys use:

```text
contract_ref + canonical non-temporal input hash
```

[D] TEMPORAL keys use:

```text
contract_ref + canonical non-temporal input hash + temporal coordinates
```

[D] Temporal coordinate names are derived from assembled temporal metadata, not
from name guessing alone:

```text
contracts/*.json.temporal_nodes[].coordinate_refs
requirements.temporal.coordinate_refs
```

[D] `stale` and `unknown` are rejected.

[D] `provisional` may return only with an explicit downgrade observation.

[D] A CORE-shaped key for TEMPORAL metadata is rejected as a cache schema
mismatch. It is not a fallback path.

---

## Implementation

Added:

```text
igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization.rb
```

The proof:

1. Assembles the temporal History and BiHistory SemanticIR fixtures using
   `IgniterLang::Assembler`.
2. Reads `manifest.json`, `contracts/*.json`, and `requirements.json`.
3. Constructs proof-local CORE and TEMPORAL cache keys.
4. Inserts `fresh`, `stale`, `unknown`, and `provisional` cache entries.
5. Emits `runtime_cache_hit_observation` and
   `runtime_cache_reject_observation`.
6. Emits `runtime_cache_downgrade_observation` for provisional returns.

Summary:

```text
igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization_summary.json
```

---

## Proof Output

Command:

```text
ruby igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization.rb
```

Output:

```text
PASS runtime_cache_proof_local_memoization
core.fresh_hit_returned: ok
temporal.history_fresh_hit_returned: ok
temporal.bihistory_key_uses_both_coordinates: ok
negative.core_shaped_key_for_temporal_rejected: ok
negative.stale_rejected: ok
negative.unknown_rejected: ok
provisional.returned_with_downgrade_observation: ok
observations.hit_and_reject_emitted: ok
observations.no_raw_input_payloads: ok
summary: igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization_summary.json
```

---

## Metadata Required

Current assembler metadata used by the proof:

```text
manifest.program_id
manifest.fragment_class
contract.source_contract_ref
contract.fragment_class
contract.temporal_nodes[].kind
contract.temporal_nodes[].axis
contract.temporal_nodes[].coordinate_refs
contract.temporal_nodes[].required_caps
requirements.temporal.axes
requirements.temporal.coordinate_refs
requirements.capabilities.required_caps
```

Needed before production RuntimeMachine cache enablement:

```text
manifest.contract_index[].fragment_class
manifest.contract_index[].contract_path
manifest.contract_index[].temporal.axes
manifest.contract_index[].temporal.required_capabilities
manifest.contract_index[].temporal.cache_key_schema_hint.schema
manifest.contract_index[].temporal.cache_key_schema_hint.fragment
manifest.contract_index[].temporal.cache_key_schema_hint.coordinate_names
```

Runtime cache policy required before enablement:

```text
cache_policy: memoized
key_schema: runtime-cache-key-v1
entry_schema: runtime-cache-entry-v1
observation_schema: runtime-cache-observation-v1
default_unknown_policy: reject
default_stale_policy: reject
provisional_policy: return_with_downgrade
```

---

## Non-Goals Preserved

[X] No production RuntimeMachine cache.

[X] No durable cache adapter.

[X] No Ledger binding.

[X] No temporal RuntimeMachine execution path.

[X] No cache invalidation engine.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/runtime-cache-proof-local-memoization-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Implemented cache as proof-local MemoryCacheStore only.
- CORE and TEMPORAL keys use runtime-cache-key-v1.
- TEMPORAL key construction uses assembled temporal coordinate metadata.
- CORE-shaped keys for TEMPORAL metadata reject with cache.key_schema_mismatch.
- stale and unknown reject; provisional returns only with downgrade observation.

[S] Signals:
- Cache hit/reject observations are emitted without raw input payloads.
- BiHistory cache keys include both valid_time and transaction_time.
- The proof identifies current assembler metadata and missing manifest/index
  fields needed before production enablement.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization.rb -> PASS
- ruby -c igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization.rb -> Syntax OK

[Files] Changed:
- igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization.rb
- igniter-lang/experiments/runtime_cache_proof_local_memoization/runtime_cache_proof_local_memoization_summary.json
- igniter-lang/experiments/runtime_cache_proof_local_memoization/assembled/
- igniter-lang/docs/tracks/runtime-cache-proof-local-memoization-v0.md

[Q] Open Questions:
- Should production load require manifest.contract_index cache_key_schema_hint
  before accepting memoized temporal artifacts?
- Should cache-hit observations include only value_hash/value_ref, or can
  selected non-sensitive result summaries appear under a separate debug mode?

[X] Rejected:
- Production RuntimeMachine memoization.
- Durable cache adapter.
- Ledger/TBackend cache binding.

[Next] Proposed next slice:
- runtime-cache-manifest-contract-index-v0: add/prove the manifest contract
  index and cache_key_schema_hint needed before runtime cache enablement.
```
