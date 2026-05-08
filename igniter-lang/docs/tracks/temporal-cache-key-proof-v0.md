# Track: Temporal Cache Key Proof v0

Card: S3-R2-C3-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/temporal-cache-key-proof-v0`
Status: done
Date: 2026-05-08

---

## Goal

Prove CORE vs TEMPORAL cache-key semantics before RuntimeMachine memoization is
implemented.

This is a proof-local cache-key model only. It does not add a RuntimeMachine
cache, does not change temporal access runtime behavior, and does not bind a
production TBackend adapter.

---

## Proof

Runner:

```text
ruby igniter-lang/experiments/temporal_cache_key_proof/temporal_cache_key_proof.rb
```

JSON summary:

```text
igniter-lang/experiments/temporal_cache_key_proof/temporal_cache_key_proof.json
```

Console result:

```text
PASS temporal_cache_key_proof
verdict: temporal_key_required
core.same_inputs_same_key: ok
core.different_inputs_different_key: ok
history.same_inputs_different_as_of_distinct_temporal_keys: ok
history.core_key_collides_across_as_of: ok
history.core_key_collision_would_be_stale: ok
bihistory.same_inputs_same_vt_different_tt_distinct_keys: ok
bihistory.core_key_collides_across_tt: ok
bihistory.core_key_collision_would_be_stale: ok
summary: igniter-lang/experiments/temporal_cache_key_proof/temporal_cache_key_proof.json
```

---

## Model

[D] CORE cache key:

```text
hash(contract_ref, canonical_inputs)
```

[D] TEMPORAL cache key:

```text
hash(contract_ref, canonical_inputs, canonical_temporal_coordinates)
```

[D] Single-axis History key:

```text
hash(contract_ref, canonical_inputs, as_of)
```

[D] BiHistory key:

```text
hash(contract_ref, canonical_inputs, valid_time, transaction_time)
```

The proof intentionally treats `inputs` as non-temporal business inputs. Temporal
coordinates are separate key material even if a current source fixture passes
`as_of`, `valid_time`, or `known_time` through an input-shaped surface.

---

## Evidence

### CORE

The Add example proves canonicalized input order does not change the key:

```text
{a: 20, b: 22}
{b: 22, a: 20}
```

Both produce the same CORE key. Changing a value produces a different key.

### History

The History example uses the Stage 2 History proof scenario:

```text
contract: TechnicianJobCountAt
inputs:   technician_id = tech-synthetic-1
as_of:    2026-05-03T10:00:00Z -> current_count = 7
as_of:    2026-05-06T10:00:00Z -> current_count = 9
```

Result:

- TEMPORAL keys are distinct.
- CORE-shaped keys collide because contract + business inputs are unchanged.
- Reusing the CORE key would return `7` for the later `as_of`, where expected
  output is `9`.

### BiHistory

The BiHistory example uses the SparkCRM correction scenario:

```text
contract: SparkCRMBiHistoryAvailabilityCorrection
inputs:   company-fixture-acme, tech-t-17, slot_local 10:00
vt:       2026-05-07T14:00:00Z
tt:       2026-05-07T13:30:00Z -> blocked / busy
tt:       2026-05-07T15:20:00Z -> available / available
```

Result:

- BiHistory keys are distinct when `tt` changes, even with the same `vt` and
  same business inputs.
- CORE-shaped keys collide across transaction time.
- Reusing the CORE key would return the decision-time blocked result for the
  corrected-time available result.

---

## Recommendation

[R] Future RuntimeMachine cache contract should require:

1. Every runtime cache key includes `fragment`.
2. CORE cache keys use `contract_ref + canonical non-temporal inputs`.
3. TEMPORAL cache keys use `contract_ref + canonical non-temporal inputs +
   canonical temporal_coordinates`.
4. History reads include `as_of` or the equivalent valid-time coordinate.
5. BiHistory reads include both `valid_time` and `transaction_time`.
6. Cache-hit observations record:
   - key material hash
   - fragment
   - temporal axis, if any
   - freshness status: `fresh | stale | unknown | provisional`

[D] Using a CORE-shaped key for TEMPORAL evaluation is a semantic bug, not a
performance tradeoff. It can silently return stale values.

---

## Non-Goals

[X] No RuntimeMachine memoization implementation.

[X] No cache invalidation policy.

[X] No TBackend read/write binding.

[X] No production persistence of cache entries.

---

## Handoff

```text
Card: S3-R2-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/temporal-cache-key-proof-v0
Status: done

[D] Decisions
- CORE cache key is contract_ref + canonical non-temporal inputs.
- TEMPORAL cache key must add canonical temporal coordinates.
- History requires as_of/valid-time in the key.
- BiHistory requires both valid_time and transaction_time in the key.
- CORE-shaped keys for TEMPORAL evaluations create stale collisions.

[S] Shipped / Signals
- Added proof-local cache-key model.
- Added JSON summary with CORE, History, and BiHistory examples.
- Demonstrated stale collision for History and BiHistory when a CORE key is
  incorrectly used.

[T] Tests / Proofs
- ruby igniter-lang/experiments/temporal_cache_key_proof/temporal_cache_key_proof.rb -> PASS
- ruby -c igniter-lang/experiments/temporal_cache_key_proof/temporal_cache_key_proof.rb -> Syntax OK

[R] Risks / Recommendations
- RuntimeMachine cache implementation should not begin until this key contract
  is promoted into the runtime memoization design.
- Cache observations should make temporal key material auditable without
  exposing full sensitive input payloads.

[Next] Suggested next slice
- RuntimeMachine memoization contract planning: cache entry envelope,
  freshness states, and cache-hit observation shape.
```
