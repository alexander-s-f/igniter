# Track: Compiler Profile CompatibilityReport Fields v0

Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-compatibility-report-fields-v0`
Status: done
Date: 2026-05-10

---

## Goal

Define and prove a proof-local CompatibilityReport field shape that keeps
compiler profile verification separate from runtime evaluation readiness.

This slice does not edit production CompatibilityReport code, RuntimeMachine,
Assembler, or `.igapp` artifacts.

---

## Implemented Proof Boundary

Added:

```text
igniter-lang/experiments/compiler_profile_compatibility_report_fields/compiler_profile_compatibility_report_fields.rb
igniter-lang/experiments/compiler_profile_compatibility_report_fields/out/compiler_profile_compatibility_report_fields_summary.json
```

The proof reads:

```text
igniter-lang/experiments/compiler_profile_authority_boundary/out/compiler_profile_authority_boundary_summary.json
```

and emits proof-local report entries with two separate fields:

```text
compiler_profile_status
runtime_evaluation_readiness
```

---

## Proposed Report Shape

```json
{
  "kind": "proof_local_compatibility_report",
  "artifact": {
    "artifact_id": "history_valid",
    "fragment_class": "temporal",
    "guard_policy": "load_accept_evaluate_refuse"
  },
  "compiler_profile_status": {
    "status": "present_verified",
    "policy": "legacy_optional",
    "manifest_compiler_profile_id": "compiler_profile_unified/sha256:...",
    "expected_compiler_profile_id": "compiler_profile_unified/sha256:...",
    "decision": "accept_profile_match",
    "understanding_authority": true,
    "runtime_authority": false
  },
  "runtime_evaluation_readiness": {
    "status": "blocked",
    "decision": "refuse",
    "reason_code": "runtime.executor_approval_missing",
    "authorized_by_compiler_profile_id": false,
    "live_operation_attempted": false
  }
}
```

`compiler_profile_status.status` values:

```text
absent_legacy
present_verified
mismatch
malformed
missing_required
```

`runtime_evaluation_readiness.status` values:

```text
ready
blocked
not_reached
```

Invariant:

```text
compiler_profile_status.present_verified
  does not imply
runtime_evaluation_readiness.ready
```

---

## Proof Cases

| Case | Compiler profile status | Runtime readiness |
|---|---|---|
| `core_profile_match` | `present_verified` | `ready` for CORE policy path |
| `legacy_absent_profile` | `absent_legacy` | CORE policy path; no profile runtime authority |
| `mismatched_profile` | `mismatch` | `not_reached` |
| `temporal_metadata_only_profile` | `present_verified` | `blocked: runtime.temporal_execution_unsupported` |
| `temporal_ledger_backed_no_approval` | `present_verified` | `blocked: runtime.executor_approval_missing` |
| `temporal_ledger_backed_gate3_closed` | `present_verified` | `blocked: runtime.temporal_gate3_closed` |

---

## Proof Checks

| Check | Meaning |
|---|---|
| `schema.has_separate_compiler_profile_status` | Reports contain profile status field. |
| `schema.has_separate_runtime_readiness` | Reports contain runtime readiness field. |
| `compiler.present_verified_not_runtime_authority` | Verified compiler profile never grants runtime authority. |
| `runtime.verified_temporal_metadata_only_still_blocked` | Verified metadata-only temporal profile remains blocked. |
| `runtime.ledger_backed_no_approval_still_blocked` | Ledger-backed temporal profile still needs approval. |
| `runtime.ledger_backed_gate3_closed_still_blocked` | Ledger-backed + approval still blocks while Gate 3 is closed. |
| `compiler.mismatch_runtime_not_reached` | Profile mismatch blocks before runtime readiness. |
| `legacy.absent_profile_status_not_runtime_authority` | Legacy absent profile grants no runtime authority. |
| `authority.no_report_claims_profile_runtime_authority` | No report claims profile id authorizes runtime. |
| `operation.no_live_operations_attempted` | No report case attempts live operations. |

---

## Proof Result

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_compatibility_report_fields/compiler_profile_compatibility_report_fields.rb
```

Result:

```text
PASS compiler_profile_compatibility_report_fields
schema.has_separate_compiler_profile_status: ok
schema.has_separate_runtime_readiness: ok
compiler.present_verified_not_runtime_authority: ok
runtime.verified_temporal_metadata_only_still_blocked: ok
runtime.ledger_backed_no_approval_still_blocked: ok
runtime.ledger_backed_gate3_closed_still_blocked: ok
compiler.mismatch_runtime_not_reached: ok
legacy.absent_profile_status_not_runtime_authority: ok
authority.no_report_claims_profile_runtime_authority: ok
operation.no_live_operations_attempted: ok
summary: igniter-lang/experiments/compiler_profile_compatibility_report_fields/out/compiler_profile_compatibility_report_fields_summary.json
```

---

## Decisions

[D] CompatibilityReport should expose compiler profile verification and runtime
readiness as separate machine-readable fields.

[D] `present_verified` means the compiler identity is understood and matched. It
does not mean runtime evaluation is allowed.

[D] `mismatch`, `malformed`, and future `missing_required` should stop before
runtime readiness checks.

[D] `absent_legacy` is a compatibility state, not a trust upgrade.

[D] TEMPORAL runtime refusal reasons remain unchanged by compiler profile
verification.

---

## Risks

[R] Production reports must not collapse these fields into one `trusted` boolean.
That would erase the authority boundary.

[R] Once real `.igapp` manifests gain `compiler_profile_id`, report writers must
preserve old `absent_legacy` behavior until a planned migration removes it.

[R] Runtime enforcement remains out of scope. This is a report field model only.

---

## Next Recommended Slice

```text
Track: compiler-profile-preflight-chain-index-v0
Goal:
- Index the background compiler profile architecture proof chain.
Scope:
- List all profile/pack/kernel/manifest/authority proof commands.
- Record current PASS matrix.
- Mark which proofs are shadow-only, descriptor-only, or manifest-plan-only.
- No implementation changes.
Acceptance:
- Track doc with proof matrix and next migration blockers.
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: compiler-profile-compatibility-report-fields-v0
Status: done

[D] Decisions:
- CompatibilityReport needs separate compiler_profile_status and runtime_evaluation_readiness.
- present_verified never implies runtime ready.
- absent_legacy is compatibility state only.
- TEMPORAL runtime refusal reasons stay separate.

[S] Signals:
- Verified metadata-only temporal profile remains blocked.
- Verified Ledger-backed temporal profile remains blocked without approval or with Gate 3 closed.
- Profile mismatch stops before runtime readiness.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/compiler_profile_compatibility_report_fields/compiler_profile_compatibility_report_fields.rb -> PASS

[R] Risks:
- Do not collapse report status to a single trusted boolean.
- Runtime enforcement remains separate from report shape.

[Next]
- Route compiler-profile-preflight-chain-index-v0.
```
