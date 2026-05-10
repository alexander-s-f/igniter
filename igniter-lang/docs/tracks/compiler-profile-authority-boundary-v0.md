# Track: Compiler Profile Authority Boundary v0

Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-authority-boundary-v0`
Status: done
Date: 2026-05-10

---

## Goal

Separate compiler understanding authority from runtime execution authority before
`compiler_profile_id` enters real `.igapp` manifests.

This slice is proof-local. It does not implement runtime executor behavior, call
Ledger/TBackend, change `.igapp`, or change production compiler code.

---

## Implemented Proof Boundary

Added:

```text
igniter-lang/experiments/compiler_profile_authority_boundary/compiler_profile_authority_boundary.rb
igniter-lang/experiments/compiler_profile_authority_boundary/out/compiler_profile_authority_boundary_summary.json
```

The proof reads:

```text
igniter-lang/experiments/compiler_profile_spec_and_rule_unification/out/compiler_profile_spec_and_rule_unification_summary.json
igniter-lang/experiments/compiler_profile_id_manifest_boundary/out/compiler_profile_id_manifest_boundary_summary.json
```

and models a decision table for CORE and TEMPORAL artifacts.

---

## Authority Contract

`compiler_profile_id` proves:

- the artifact was assembled by a compiler profile with known slots and rule
  registries;
- the compiler profile was allowed to understand the language capabilities in
  the artifact;
- the compiler identity can be fingerprint-compared by loaders and
  CompatibilityReports.

`compiler_profile_id` does not prove:

- runtime executor approval;
- Gate 3 authorization;
- live TBackend binding;
- Ledger read/write/replay permission;
- cache key policy safety;
- artifact `guard_policy` permission.

Runtime authority remains controlled by:

```text
artifact guard_policy
runtime profile capabilities
live backend binding
executor approval token
Gate 3 state
cache key schema
```

---

## Decision Table

| Case | Compiler decision | Runtime decision |
|---|---|---|
| CORE artifact with matching profile | `accept_profile_match` | CORE runtime policy may evaluate; not authorized by profile id. |
| Legacy artifact with absent profile | `accept_absent_legacy` under `legacy_optional` | Runtime authority unchanged. |
| Artifact with mismatched profile | `refuse_profile_mismatch` | Runtime not reached. |
| TEMPORAL artifact with metadata-only profile | `accept_profile_match` | Refuse: `runtime.temporal_execution_unsupported`. |
| TEMPORAL artifact with Ledger-backed profile, no approval | `accept_profile_match` | Refuse: `runtime.executor_approval_missing`. |
| TEMPORAL artifact with Ledger-backed profile, approval, Gate 3 closed | `accept_profile_match` | Refuse: `runtime.temporal_gate3_closed`. |

The proof records:

```text
compiler_profile_loaded_runtime_executor: false
compiler_profile_called_tbackend: false
compiler_profile_called_ledger: false
```

---

## Proof Checks

| Check | Meaning |
|---|---|
| `compiler.profile_match_grants_understanding_only` | Matching profile grants compiler understanding authority, not runtime authority. |
| `compiler.absent_legacy_not_runtime_authority` | Legacy absent profile remains non-authoritative for runtime. |
| `compiler.mismatch_refuses_before_runtime` | Profile mismatch stops before runtime checks. |
| `temporal.metadata_only_refuses_execution` | Metadata-only temporal profile cannot execute TEMPORAL. |
| `temporal.ledger_backed_still_requires_approval` | Ledger-backed temporal profile still needs approval token. |
| `temporal.ledger_backed_gate3_closed_refuses` | Approval is still blocked while Gate 3 is closed. |
| `runtime.no_live_operations_attempted` | No case attempts live executor/backend/ledger operations. |
| `runtime.compiler_profile_never_authorizes_execution` | Compiler profile id never authorizes evaluation by itself. |
| `operation_check.no_backend_or_ledger_calls` | No proof path calls TBackend or Ledger. |

---

## Proof Result

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_authority_boundary/compiler_profile_authority_boundary.rb
```

Result:

```text
PASS compiler_profile_authority_boundary
compiler.profile_match_grants_understanding_only: ok
compiler.absent_legacy_not_runtime_authority: ok
compiler.mismatch_refuses_before_runtime: ok
temporal.metadata_only_refuses_execution: ok
temporal.ledger_backed_still_requires_approval: ok
temporal.ledger_backed_gate3_closed_refuses: ok
runtime.no_live_operations_attempted: ok
runtime.compiler_profile_never_authorizes_execution: ok
operation_check.no_backend_or_ledger_calls: ok
profile_id: compiler_profile_unified/sha256:2944e573270aa56fca51cea3
summary: igniter-lang/experiments/compiler_profile_authority_boundary/out/compiler_profile_authority_boundary_summary.json
```

---

## Decisions

[D] `compiler_profile_id` is an understanding authority, not an execution
authority.

[D] A matching compiler profile can prove that a TEMPORAL artifact was compiled
by a profile that understands temporal semantics, but it cannot prove that the
runtime may execute temporal reads.

[D] Even a Ledger-backed temporal compiler profile still requires runtime
executor approval, Gate 3 authorization, live TBackend binding, artifact
`guard_policy`, and cache key safety.

[D] Profile mismatch should refuse before runtime evaluation checks.

[D] `absent_legacy` compatibility should not grant additional runtime authority.

---

## Risks

[R] CompatibilityReport must keep compiler-profile status and runtime-readiness
status as separate fields. Combining them would blur the boundary.

[R] Future manifests may tempt loaders to treat `compiler_profile_id` as a
runtime trust token. This proof explicitly rejects that interpretation.

[R] Ledger-backed temporal compiler profile variants require security review
before they are allowed to pair with live runtime adapters.

---

## Next Recommended Slice

```text
Track: compiler-profile-compatibility-report-fields-v0
Goal:
- Add proof-local CompatibilityReport field model for compiler profile status.
Scope:
- Separate compiler_profile_status from runtime_evaluation_readiness.
- Include absent_legacy, present_verified, mismatch, malformed.
- Include temporal runtime refusal reasons unchanged.
- No .igapp changes.
- No runtime enforcement changes.
Acceptance:
- Decision table proving compiler profile status cannot bypass runtime readiness.
- Existing profile foundation proofs remain PASS.
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: compiler-profile-authority-boundary-v0
Status: done

[D] Decisions:
- compiler_profile_id proves compiler understanding only.
- runtime execution authority remains separate.
- TEMPORAL execution still requires approval/Gate/backend/cache/guard checks.
- Profile mismatch refuses before runtime.

[S] Signals:
- Metadata-only temporal profile refuses execution.
- Ledger-backed temporal profile still refuses without approval or with Gate 3 closed.
- No proof path attempts executor, TBackend, or Ledger operations.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/compiler_profile_authority_boundary/compiler_profile_authority_boundary.rb -> PASS

[R] Risks:
- CompatibilityReport must not collapse profile verification and runtime readiness.
- Future loader code must not treat profile ID as a runtime trust token.

[Next]
- Route compiler-profile-compatibility-report-fields-v0.
```
