# Track: Spec Ch7 Runtime Temporal Cache Sync v0

Card: S3-R6-C5-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `igniter-lang/spec-ch7-runtime-temporal-cache-sync-v0`
Status: done
Date: 2026-05-08

---

## Goal

Sync the runtime spec with the landed temporal cache contract and TEMPORAL
load guard.

---

## Updated File

```text
igniter-lang/docs/spec/ch7-runtime.md
```

---

## Decisions

[D] Replaced stale stdlib/operator gap language with PASS evidence:

```text
stdlib execution kernel and operator lookup PASS
```

[D] Added CORE and TEMPORAL cache key schemas:

- CORE: `hash(version, fragment, contract_ref, input_hash)`
- History TEMPORAL: adds `as_of`
- BiHistory TEMPORAL: adds `valid_time` and `transaction_time`

[D] Added freshness states:

```text
fresh
stale
unknown
provisional
```

with `stale` / `unknown` rejecting by default and `provisional` returning only
with explicit downgrade observation.

[D] Added current TEMPORAL runtime policy:

```text
load_accept_evaluate_refuse
```

Load may accept well-formed TEMPORAL artifacts for inspection and
CompatibilityReport work. Evaluate refuses TEMPORAL contracts unless a future
runtime temporal executor and required capabilities are explicitly approved.

[D] Kept production temporal executor, production cache, Ledger binding, and
live TBackend reads/writes/replay out of scope.

---

## Evidence References

- `tracks/runtime-temporal-cache-contract-v0.md`
  - S3-R3-C3: cache key schema, freshness states, no production memoization
- `tracks/runtime-cache-proof-local-memoization-v0.md`
  - S3-R4-C5: proof-local CORE/TEMPORAL cache behavior
- `tracks/temporal-assembler-manifest-contract-index-v0.md`
  - S3-R5-C1: manifest contract index and cache schema hint
- `tracks/temporal-runtime-load-guard-v0.md`
  - S3-R5-C2: load accepts for inspection; evaluate refuses unsupported TEMPORAL
- `experiments/stdlib_execution_kernel_stage1/`
  - stdlib/operator execution PASS

---

## Non-Goals

[X] No runtime code changed.

[X] No proof fixtures changed.

[X] No production RuntimeMachine memoization enabled.

[X] No temporal RuntimeMachine executor added.

[X] No Ledger/TBackend production binding authorized.

[X] No current-status or round-close map edited.

---

## Verification

Docs-only sync. Sanity checks:

```text
rg runtime-cache-key-v1 docs/spec/ch7-runtime.md
rg load_accept_evaluate_refuse docs/spec/ch7-runtime.md
rg freshness docs/spec/ch7-runtime.md
git diff --check -- docs/spec/ch7-runtime.md docs/tracks/spec-ch7-runtime-temporal-cache-sync-v0.md
```

---

## Handoff

```text
Card: S3-R6-C5-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/spec-ch7-runtime-temporal-cache-sync-v0
Status: done

[D] Decisions:
- Synced runtime spec with temporal cache contract and load guard.
- Replaced stale stdlib/operator gap with PASS evidence.
- Added CORE/TEMPORAL cache key schemas and freshness states.
- Added load_accept_evaluate_refuse policy.
- Preserved no-production-executor/no-cache/no-Ledger boundaries.

[S] Shipped / Signals:
- docs/spec/ch7-runtime.md now documents runtime cache key contract,
  proof-local cache semantics, TEMPORAL load for inspection, and evaluate
  refusal.
- Evidence references connect Ch7 to S3-R3/R4/R5 tracks.

[T] Tests / Proofs:
- Docs-only; no code proof required.

[R] Risks / Recommendations:
- Future spec sync should update TBackend/runtime executor chapters when a
  production temporal executor is actually approved.
- Runtime cache implementation remains a separate future slice.

[Next] Suggested next slice:
- spec-tbackend-temporal-descriptor-sync-v0, if the TBackend chapter still
  blurs descriptor/report-only metadata with live adapter binding.
```

## Files Changed

```text
igniter-lang/docs/spec/ch7-runtime.md
igniter-lang/docs/tracks/spec-ch7-runtime-temporal-cache-sync-v0.md
```
