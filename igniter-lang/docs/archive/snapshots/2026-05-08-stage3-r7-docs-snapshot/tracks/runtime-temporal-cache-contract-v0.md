# Runtime Temporal Cache Contract v0

Card: S3-R3-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/runtime-temporal-cache-contract-v0
Status: done
Date: 2026-05-08

## Goal

Promote the temporal cache-key proof into a RuntimeMachine memoization contract
design without implementing production cache.

This track defines the runtime cache entry envelope, CORE vs TEMPORAL cache key
schema, freshness states, cache-hit observation shape, and the load/evaluate
phase split. It does not add production memoization.

## Evidence

Source proof:

```text
ruby igniter-lang/experiments/temporal_cache_key_proof/temporal_cache_key_proof.rb
```

Proof verdict:

```text
PASS temporal_cache_key_proof
verdict: temporal_key_required
```

Key evidence:

```text
CORE key:
  hash(contract_ref, canonical_non_temporal_inputs)

TEMPORAL History key:
  hash(contract_ref, canonical_non_temporal_inputs, as_of)

TEMPORAL BiHistory key:
  hash(contract_ref, canonical_non_temporal_inputs, valid_time, transaction_time)
```

[S] The proof demonstrates that a CORE-shaped key collides across History
`as_of` and BiHistory `transaction_time`, causing stale outputs. Therefore,
using CORE cache keys for TEMPORAL evaluation is a semantic bug.

Current RuntimeMachine memory proof still advertises:

```text
cache_policy: "none"
```

So this track is contract design, not implementation.

## Runtime Cache Key Schema

[D] Cache keys must carry a schema version:

```json
{
  "kind": "runtime_cache_key",
  "version": "runtime-cache-key-v1",
  "fragment": "CORE | TEMPORAL",
  "contract_ref": "contract/...",
  "input_hash": "sha256:<canonical non-temporal input hash>",
  "temporal_coordinates": null
}
```

### CORE

CORE cache keys use only contract identity and canonical non-temporal inputs:

```json
{
  "kind": "runtime_cache_key",
  "version": "runtime-cache-key-v1",
  "fragment": "CORE",
  "contract_ref": "contract/Add/...",
  "input_hash": "sha256:<inputs>",
  "temporal_coordinates": null
}
```

Formula:

```text
cache_key_hash = hash(version, fragment, contract_ref, input_hash)
```

### TEMPORAL / Valid Time

History-style temporal keys add the valid-time coordinate:

```json
{
  "kind": "runtime_cache_key",
  "version": "runtime-cache-key-v1",
  "fragment": "TEMPORAL",
  "axis": "valid_time",
  "contract_ref": "contract/TechnicianJobCountAt/...",
  "input_hash": "sha256:<non-temporal inputs>",
  "temporal_coordinates": {
    "as_of": "2026-05-06T10:00:00Z"
  }
}
```

Formula:

```text
cache_key_hash = hash(version, fragment, axis, contract_ref, input_hash, as_of)
```

### TEMPORAL / Bitemporal

BiHistory-style temporal keys add both valid and transaction time:

```json
{
  "kind": "runtime_cache_key",
  "version": "runtime-cache-key-v1",
  "fragment": "TEMPORAL",
  "axis": "bitemporal",
  "contract_ref": "contract/SparkCRMBiHistoryAvailabilityCorrection/...",
  "input_hash": "sha256:<non-temporal inputs>",
  "temporal_coordinates": {
    "valid_time": "2026-05-07T14:00:00Z",
    "transaction_time": "2026-05-07T15:20:00Z"
  }
}
```

Formula:

```text
cache_key_hash = hash(
  version,
  fragment,
  axis,
  contract_ref,
  input_hash,
  valid_time,
  transaction_time
)
```

[D] Temporal coordinates are separate key material even when a source fixture
currently passes `as_of`, `valid_time`, or `known_time` through an input-shaped
surface.

## Runtime Cache Entry Envelope

[D] Runtime cache entries should use an observation-friendly envelope:

```json
{
  "kind": "runtime_cache_entry",
  "version": "runtime-cache-entry-v1",
  "cache_key": {
    "key": "cache/<short-hash>",
    "hash": "sha256:<key-material>",
    "schema": "runtime-cache-key-v1"
  },
  "fragment": "CORE | TEMPORAL",
  "axis": "valid_time | bitemporal | null",
  "contract_ref": "contract/...",
  "program_id": "semanticir/...",
  "value_hash": "sha256:<canonical output>",
  "value_ref": "runtime-value/<hash-or-local-ref>",
  "freshness": "fresh | stale | unknown | provisional",
  "created_at": "2026-05-08T00:00:00Z",
  "validated_at": "2026-05-08T00:00:00Z",
  "expires_at": null,
  "dependency_refs": [],
  "temporal_coordinates": null,
  "evidence_links": []
}
```

[D] The entry stores hashes and refs by default. Full input/output payloads are
not required in the cache-hit observation and should be avoided for sensitive
payloads.

## Freshness States

| State | Meaning | Runtime may return cached value? |
|-------|---------|-----------------------------------|
| `fresh` | Key schema matches, dependencies/coordinates are verified current for the runtime contract. | yes |
| `stale` | Runtime has evidence that dependency state or temporal coordinate meaning has changed. | no |
| `unknown` | Runtime cannot verify freshness because evidence is missing. | no by default |
| `provisional` | Runtime can return the value only with downgraded trust and explicit observation. | yes, with marked result |

[D] `unknown` must not silently degrade into `fresh`.

[D] `provisional` is an explicit trust mark, not a convenience synonym for
`fresh`.

[R] `stale` and `unknown` should be cache-miss paths unless an approved runtime
policy says otherwise. `provisional` may be returned only when the evaluation
result carries the downgrade.

## Cache-Hit Observation Shape

[D] Cache hits should emit a platform/runtime observation:

```json
{
  "kind": "runtime_cache_hit_observation",
  "version": "runtime-cache-observation-v1",
  "runtime_session_ref": "runtime-session/...",
  "contract_ref": "contract/...",
  "program_id": "semanticir/...",
  "cache_key_hash": "sha256:<key-material>",
  "cache_entry_ref": "cache/<short-hash>",
  "fragment": "CORE | TEMPORAL",
  "axis": "valid_time | bitemporal | null",
  "freshness": "fresh | stale | unknown | provisional",
  "temporal_coordinates": null,
  "value_hash": "sha256:<canonical output>",
  "result_policy": "returned | bypassed | rejected | returned_provisional",
  "reason": "cache.fresh_hit",
  "evidence_links": [
    {
      "rel": "selected_cache_entry",
      "from": "obs/cache-hit/...",
      "to": "cache/<short-hash>"
    }
  ]
}
```

Recommended `reason` values:

```text
cache.fresh_hit
cache.stale_rejected
cache.unknown_rejected
cache.provisional_hit
cache.key_schema_mismatch
cache.temporal_coordinate_mismatch
cache.fragment_mismatch
```

[D] A cache observation should expose key material hashes and dimensions, not
raw sensitive inputs.

## Load-Time vs Evaluate-Time Split

### Load Time

RuntimeMachine load should verify cache capability only at the level of runtime
contract and loaded artifact metadata:

```text
load(.igapp/)
  -> read fragment_class / temporal axes from manifest or ContractIR
  -> verify backend/cache adapter supports required fragment/key schema
  -> verify temporal access capabilities separately:
       history_read | bihistory_read
  -> record CompatibilityReport backend/runtime/cache dimensions
```

[D] Load-time checks answer: "Can this runtime construct and verify the needed
cache key class if cache is enabled?"

### Evaluate Time

RuntimeMachine evaluate constructs the concrete key because only evaluation has
the actual non-temporal inputs and temporal coordinates:

```text
evaluate(inputs, temporal_context)
  -> split non-temporal inputs from temporal coordinates
  -> build CORE or TEMPORAL cache key
  -> inspect cache entry
  -> emit cache-hit / cache-reject observation
  -> return cached result only if freshness policy permits
```

[D] Evaluate-time key construction must use SemanticIR/runtime metadata to know
which coordinates are temporal. It must not rely only on field names like
`as_of` when `temporal_input_node` / temporal access metadata is available.

## Runtime Contract Shape

RuntimeContract should grow a cache section only when memoization is implemented:

```json
{
  "descriptor": "RuntimeContract",
  "version": "runtime-contract-vNext",
  "cache_policy": "none | memoized",
  "cache_contract": {
    "key_schema": "runtime-cache-key-v1",
    "entry_schema": "runtime-cache-entry-v1",
    "observation_schema": "runtime-cache-observation-v1",
    "freshness_states": ["fresh", "stale", "unknown", "provisional"],
    "supports_fragments": ["CORE", "TEMPORAL"],
    "temporal_axes": ["valid_time", "bitemporal"],
    "default_unknown_policy": "reject",
    "default_stale_policy": "reject",
    "provisional_policy": "return_with_downgrade"
  }
}
```

The current proof runtime remains:

```text
cache_policy: "none"
```

## Not Implemented Yet

[X] No production RuntimeMachine memoization implementation.

[X] No cache store, invalidation engine, TTL policy, or dependency watcher.

[X] No assembler manifest change in this slice.

[X] No production TBackend cache adapter binding.

[X] No raw input/output persistence policy.

[X] No change to temporal access runtime behavior.

## Verification

```text
ruby -c igniter-lang/experiments/temporal_cache_key_proof/temporal_cache_key_proof.rb
  -> Syntax OK

ruby igniter-lang/experiments/temporal_cache_key_proof/temporal_cache_key_proof.rb
  -> PASS temporal_cache_key_proof
```

## Changed Files

```text
igniter-lang/docs/tracks/runtime-temporal-cache-contract-v0.md
```

## Handoff

```text
Card: S3-R3-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/runtime-temporal-cache-contract-v0
Status: done

[D] Decisions
- Runtime cache keys have separate CORE and TEMPORAL schemas.
- TEMPORAL cache keys include canonical temporal coordinates outside ordinary input hash material.
- Runtime cache entries use an observation-friendly envelope with freshness state.
- Freshness states are fresh / stale / unknown / provisional.
- Load time verifies capability/schema support; evaluate time constructs concrete cache keys.

[S] Shipped / Signals
- Promoted temporal_cache_key_proof evidence into a RuntimeMachine memoization contract design.
- Defined cache-hit observation shape and reason codes.
- Preserved explicit no-production-cache boundary.

[T] Tests / Proofs
- ruby -c igniter-lang/experiments/temporal_cache_key_proof/temporal_cache_key_proof.rb -> Syntax OK
- ruby igniter-lang/experiments/temporal_cache_key_proof/temporal_cache_key_proof.rb -> PASS

[R] Risks / Recommendations
- Assembler/manifest propagation of TEMPORAL fragment and axes remains a separate prerequisite for production runtime cache correctness.
- Unknown freshness must reject by default; provisional hits must mark result trust.
- Future implementation should start with an in-memory proof cache before any durable cache adapter.

[Next] Suggested next slice
- runtime-cache-proof-local-memoization-v0: proof-only RuntimeMachine cache store using this contract, with negative stale/unknown/provisional cases.
```
