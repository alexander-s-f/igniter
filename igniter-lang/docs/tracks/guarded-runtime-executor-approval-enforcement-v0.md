# Track: Guarded Runtime Executor Approval Enforcement v0

Card: S3-R10-C2-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/guarded-runtime-executor-approval-enforcement-v0`
Status: done
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Runtime Agent]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Upgrade proof-local `GuardedRuntimeMachine` behavior from generic TEMPORAL
refusal to PROP-030 approval/Gate3-aware refusal, without adding live executor,
TBackend, Ledger, or production cache behavior.

---

## Inputs

- `docs/proposals/PROP-030-executor-approval-token-contract-v0.md`
- `docs/tracks/prop-030-executor-approval-token-contract-v0.md`
- `docs/tracks/guarded-runtime-c2-profile-consistency-v0.md`
- `docs/tracks/executor-boundary-cache-key-contract-v0.md`
- `experiments/temporal_runtime_load_guard/temporal_runtime_load_guard.rb`

---

## Decision

[D] `GuardedRuntimeMachine` now has an approval-aware proof mode.

[D] Load behavior is unchanged:

```text
valid TEMPORAL .igapp -> loaded for inspection
```

[D] Evaluation in approval-aware mode refuses before any executor/cache/backend
path:

| Case | Reason |
| --- | --- |
| missing token | `runtime.executor_approval_missing` |
| valid token + Gate 3 closed | `runtime.temporal_gate3_closed` |
| valid token + Gate 3 open placeholder + CORE-shaped cache key | `runtime.temporal_cache_schema_mismatch` |

[D] The CORE-shaped cache key refusal carries `gate: L-T5`, preserving the
PROP-028 silent-staleness guard at the executor boundary.

---

## CompatibilityReport Mapping

| CompatibilityReport reason | GuardedRuntimeMachine reason | Alignment |
| --- | --- | --- |
| `runtime.temporal_executor_approval_missing` | `runtime.executor_approval_missing` | PROP-030 refines C2's report reason into canonical runtime approval refusal |
| `runtime.temporal_gate3_closed` | `runtime.temporal_gate3_closed` | identical |
| `runtime.temporal_cache_schema_mismatch` | `runtime.temporal_cache_schema_mismatch` | future CompatibilityReport cache dimension should use the same runtime refusal |

---

## Implemented Proof

Updated:

```text
igniter-lang/experiments/temporal_runtime_load_guard/temporal_runtime_load_guard.rb
```

Added:

```text
igniter-lang/experiments/guarded_runtime_executor_approval_enforcement/
  guarded_runtime_executor_approval_enforcement.rb
  out/guarded_runtime_executor_approval_enforcement_summary.json
```

The proof runs History and BiHistory TEMPORAL artifacts through approval-aware
`GuardedRuntimeMachine` cases:

1. load-for-inspection is preserved;
2. no approval token refuses with `runtime.executor_approval_missing`;
3. valid proof-local token while Gate 3 is closed refuses with
   `runtime.temporal_gate3_closed`;
4. valid proof-local token with Gate 3-open placeholder but CORE-shaped cache
   key refuses with `runtime.temporal_cache_schema_mismatch`;
5. no executor, TBackend, Ledger, or production cache call is attempted.

Proof-local token shape follows PROP-030 fields:

- `kind: executor_approval_token`
- `version: executor-approval-token-v1`
- `gate: tbackend_gate3`
- `scope.operation: temporal_evaluate`
- artifact/contract/capability refs
- `evidence_ref`
- deterministic proof-local token hash and recorded-decision-hash signature

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/guarded_runtime_executor_approval_enforcement/guarded_runtime_executor_approval_enforcement.rb
```

Observed output:

```text
PASS guarded_runtime_executor_approval_enforcement
history_valid.load_for_inspection_preserved: ok
history_valid.missing_approval_refused: ok
history_valid.valid_token_gate3_closed_refused: ok
history_valid.core_cache_key_refused: ok
history_valid.no_live_operations_attempted: ok
bihistory_valid.load_for_inspection_preserved: ok
bihistory_valid.missing_approval_refused: ok
bihistory_valid.valid_token_gate3_closed_refused: ok
bihistory_valid.core_cache_key_refused: ok
bihistory_valid.no_live_operations_attempted: ok
```

Summary:

```text
igniter-lang/experiments/guarded_runtime_executor_approval_enforcement/out/guarded_runtime_executor_approval_enforcement_summary.json
```

---

## Regression / Neighbor Checks

```text
ruby igniter-lang/experiments/temporal_runtime_load_guard/temporal_runtime_load_guard.rb -> PASS
ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb -> PASS
ruby igniter-lang/experiments/guarded_runtime_c2_profile_consistency/guarded_runtime_c2_profile_consistency.rb -> PASS when run sequentially
```

Note: `runtime_compatibility_report_temporal_load_check` and
`guarded_runtime_c2_profile_consistency` both write the C2 report summary; do
not run those two writers concurrently in the same out directory.

---

## Recommendation

[R] `GuardedRuntimeMachine` should remain proof-local for now.

It is now a strong reference for the order and shape of RuntimeMachine checks:

```text
capabilities -> approval token -> Gate 3 -> cache key schema -> artifact guard
```

It should become a trusted production reference only after:

1. approval-token validation is owned by production RuntimeMachine code;
2. Gate 3 state has an approved authority source;
3. CompatibilityReport uses the same approval/cache reason dimensions;
4. live executor/TBackend/Ledger paths are still proven unreachable on refusal.

---

## Non-Authorization

This slice does not authorize:

- live TEMPORAL executor
- live TBackend binding
- Ledger read/write/replay
- production cache
- Gate 3 opening
- using a proof-local token as production authority

---

## Handoff

```text
Card: S3-R10-C2-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/guarded-runtime-executor-approval-enforcement-v0
Status: done

[D] Decisions
- GuardedRuntimeMachine now has approval-aware proof behavior.
- Missing approval, Gate 3 closed, and CORE-shaped TEMPORAL cache key each get
  explicit runtime refusal reasons.
- Load-for-inspection remains unchanged.

[S] Shipped / Signals
- Added guarded_runtime_executor_approval_enforcement proof and summary JSON.
- Updated proof-local GuardedRuntimeMachine with PROP-030 token checks, Gate 3
  checks, and TEMPORAL cache schema checks.
- Recorded CompatibilityReport-to-runtime reason mapping.

[T] Tests / Proofs
- ruby -c guarded_runtime_executor_approval_enforcement.rb -> PASS
- ruby guarded_runtime_executor_approval_enforcement.rb -> PASS
- ruby temporal_runtime_load_guard.rb -> PASS
- ruby runtime_compatibility_report_temporal_load_check.rb -> PASS
- ruby guarded_runtime_c2_profile_consistency.rb -> PASS when run sequentially

[R] Risks / Recommendations
- Keep GuardedRuntimeMachine proof-local until production RuntimeMachine owns
  the same approval/Gate3/cache checks.
- Next CompatibilityReport slice should add first-class approval/cache
  dimensions using the same reason codes.

[Next] Suggested next slice
- executor-approval-token-report-proof-v0: make CompatibilityReport validate
  PROP-030 token state with the same runtime refusal dimensions.
```
