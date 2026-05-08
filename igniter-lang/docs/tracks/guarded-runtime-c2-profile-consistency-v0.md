# Track: Guarded Runtime C2 Profile Consistency v0

Card: S3-R9-C4-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `igniter-lang/guarded-runtime-c2-profile-consistency-v0`
Status: done
Date: 2026-05-08

Affected neighbor roles: `[Igniter-Lang Runtime Agent]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Cross-check the S3-R8 C2 positive executor-boundary profiles against the
proof-local `GuardedRuntimeMachine` behavior, without authorizing live
execution, TBackend calls, Ledger calls, or production runtime enforcement.

---

## Context

S3-R8 C2 added two positive-looking CompatibilityReport profiles:

- `claimed_executor_live_binding`
- `approved_executor_placeholder`

Both profiles claim:

```json
{
  "temporal_executor": true,
  "live_tbackend_binding": true
}
```

The CompatibilityReport still blocks both profiles. This slice verifies that
the same artifacts also refuse evaluation through the proof-local
`GuardedRuntimeMachine`.

---

## Decision

[D] CompatibilityReport and GuardedRuntimeMachine agree on the behavior:

```text
load: accepted for inspection
evaluate: blocked/refused
```

[D] Reason codes are not identical, because the two proof layers model
different detail:

- CompatibilityReport models approval/Gate 3 policy explicitly.
- GuardedRuntimeMachine is older and only has a generic proof-local temporal
  execution refusal after required capabilities are present.

[D] The mismatch is accepted as an explicit mapping, not silent equivalence.

---

## Mapping Table

| CompatibilityReport reason | GuardedRuntimeMachine refusal reason | Alignment |
| --- | --- | --- |
| `runtime.temporal_executor_approval_missing` | `runtime.temporal_execution_not_implemented` | mapped to existing guard refusal |
| `runtime.temporal_gate3_closed` | `runtime.temporal_execution_not_implemented` | mapped to existing guard refusal |

Interpretation:

- `runtime.temporal_executor_approval_missing` maps to the existing guard
  refusal because GuardedRuntimeMachine has no approval-token layer.
- `runtime.temporal_gate3_closed` maps to the existing guard refusal because
  GuardedRuntimeMachine has no Gate 3 execution path.

---

## Implemented Proof

Added:

```text
igniter-lang/experiments/guarded_runtime_c2_profile_consistency/
  guarded_runtime_c2_profile_consistency.rb
  out/guarded_runtime_c2_profile_consistency_summary.json
```

Small support edits:

- Added `if $PROGRAM_NAME == __FILE__` guards to the existing C2 report proof
  and temporal load-guard proof so the new proof can require their modules
  without accidental side-effect execution.

The proof:

1. regenerates the C2 CompatibilityReport summary;
2. selects only `claimed_executor_live_binding` and
   `approved_executor_placeholder`;
3. loads the same History/BiHistory artifacts through `GuardedRuntimeMachine`;
4. evaluates the matching temporal contract;
5. asserts CompatibilityReport is blocked;
6. asserts GuardedRuntimeMachine refuses evaluation;
7. asserts the reason mapping above;
8. records no executor, TBackend, or Ledger operation attempted.

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/guarded_runtime_c2_profile_consistency/guarded_runtime_c2_profile_consistency.rb
```

Observed output:

```text
PASS guarded_runtime_c2_profile_consistency
history_valid.claimed_executor_live_binding.compatibility_report_blocked: ok
history_valid.claimed_executor_live_binding.guarded_runtime_evaluate_refuses: ok
history_valid.claimed_executor_live_binding.reason_code_mapped: ok
history_valid.approved_executor_placeholder.compatibility_report_blocked: ok
history_valid.approved_executor_placeholder.guarded_runtime_evaluate_refuses: ok
history_valid.approved_executor_placeholder.reason_code_mapped: ok
bihistory_valid.claimed_executor_live_binding.compatibility_report_blocked: ok
bihistory_valid.claimed_executor_live_binding.guarded_runtime_evaluate_refuses: ok
bihistory_valid.claimed_executor_live_binding.reason_code_mapped: ok
bihistory_valid.approved_executor_placeholder.compatibility_report_blocked: ok
bihistory_valid.approved_executor_placeholder.guarded_runtime_evaluate_refuses: ok
bihistory_valid.approved_executor_placeholder.reason_code_mapped: ok
```

Summary:

```text
igniter-lang/experiments/guarded_runtime_c2_profile_consistency/out/guarded_runtime_c2_profile_consistency_summary.json
```

---

## Non-Authorization

This proof does not add or authorize:

- live temporal executor
- real TBackend adapter binding
- Ledger read/write/replay
- production runtime enforcement
- runtime cache
- bypassing `compatibility_metadata.runtime_execution.guard_policy`

---

## Handoff

```text
Card: S3-R9-C4-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/guarded-runtime-c2-profile-consistency-v0
Status: done

[D] Decisions
- C2 positive executor profiles are consistent with GuardedRuntimeMachine:
  both report blocked and runtime refuses evaluation.
- Reason codes are explicitly mapped rather than treated as identical.
- Gate 3 remains closed; no live operation path is introduced.

[S] Shipped / Signals
- Added guarded_runtime_c2_profile_consistency proof and summary JSON.
- Reused C2 CompatibilityReport output and temporal load-guard runtime fixture.
- Added machine-readable mapping table for approval-missing and gate-closed
  CompatibilityReport reasons.

[T] Tests / Proofs
- ruby -c guarded_runtime_c2_profile_consistency.rb -> PASS
- ruby guarded_runtime_c2_profile_consistency.rb -> PASS
- ruby temporal_runtime_load_guard.rb -> PASS
- ruby runtime_compatibility_report_temporal_load_check.rb -> PASS

[R] Risks / Recommendations
- The mapping is intentionally lossy because GuardedRuntimeMachine predates
  the approval-token/Gate 3 policy layer.
- A future RuntimeMachine executor slice should either preserve this mapping or
  add first-class approval/Gate 3 refusal codes to the guarded runtime layer.

[Next] Suggested next slice
- Define `runtime-executor-approval-token-contract-v0`, then decide whether
  GuardedRuntimeMachine should gain first-class approval/Gate 3 refusal fields.
```
