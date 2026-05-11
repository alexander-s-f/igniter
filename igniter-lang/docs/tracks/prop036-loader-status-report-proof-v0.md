# Track: PROP-036 Loader Status Report Proof v0

Card: S3-R36-C5-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop036-loader-status-report-proof-v0`
Status: done
Date: 2026-05-11

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Meta Expert]`,
`[Igniter-Lang Implementation Agent]`

---

## Goal

Create the first PROP-036 design/proof slice: a proof-local loader status report
model for `compiler_profile_id`.

This slice does not implement or wire a production loader. It does not edit real
`.igapp` manifests, `.ilk` files, assembler output, RuntimeMachine behavior,
compiler dispatch, CompatibilityReport production code, or goldens.

---

## Source Evidence

Read:

- `docs/gates/prop036-compiler-profile-id-acceptance-decision-v0.md`
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `docs/tracks/proposal-lifecycle-status-labels-sync-v0.md`

Current status confirms PROP-036 is accepted proposal-only and implementation is
still blocked.

---

## Decision

[D] The proof uses synthetic in-memory manifests only.

[D] Initial policy remains:

```text
legacy_optional
```

[D] `profile_required` appears only as a future-policy model case to cover
`missing_required`. Rollout is explicitly not authorized.

[D] The report keeps compiler profile status separate from runtime readiness:

```text
compiler_profile.status = present_verified
runtime_evaluation_readiness.ready = false
```

---

## Proof

Added:

```text
experiments/prop036_loader_status_report_proof/
  prop036_loader_status_report_proof.rb
  out/prop036_loader_status_report_matrix.json
  out/prop036_loader_status_report_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/prop036_loader_status_report_proof/prop036_loader_status_report_proof.rb
```

Observed result:

```text
PASS prop036_loader_status_report_proof
```

---

## Matrix

| Case | Policy | Status | Loader decision | Runtime readiness |
| --- | --- | --- | --- | --- |
| `legacy_absent` | `legacy_optional` | `absent_legacy` | `accept_for_inspection` | `not_reached`, not ready |
| `legacy_present_verified` | `legacy_optional` | `present_verified` | `accept_for_inspection` | `blocked`, not ready |
| `legacy_mismatch` | `legacy_optional` | `mismatch` | `refuse_profile_status` | `not_reached`, not ready |
| `legacy_malformed` | `legacy_optional` | `malformed` | `refuse_profile_status` | `not_reached`, not ready |
| `future_missing_required` | `profile_required` | `missing_required` | `refuse_profile_status` | `not_reached`, not ready |

`future_missing_required` is model-only:

```json
{
  "model_scope": "future_policy_model_only",
  "profile_required_rollout_authorized": false
}
```

---

## PASS Checks

[T] The proof checks:

```text
status.absent_legacy
status.present_verified
status.mismatch
status.malformed
status.missing_required
policy.initial_legacy_optional
policy.no_profile_required_rollout
runtime.present_verified_not_ready
loader.absent_legacy_accepts_inspection
loader.mismatch_refuses
loader.malformed_refuses
loader.missing_required_refuses_future_only
scope.no_real_manifest_mutation
scope.no_production_loader
scope.non_authorizations_preserved
```

All checks PASS.

---

## Non-Authorizations Preserved

[S] The proof output records:

```text
real_manifest_mutation: false
production_loader_implementation: false
profile_required_rollout_authorized: false
```

[S] Every report case carries non-authorizations for:

- `.igapp` manifest mutation
- `.ilk` format mutation
- assembler implementation
- production loader implementation
- CompatibilityReport production change
- artifact hash/golden migration
- CompilationReceipt manifest link
- compiler dispatch migration
- RuntimeMachine binding
- RuntimeMachine execution authority
- `profile_required` rollout

---

## Blockers Before Any Implementation Card

[R] Before implementation, a later card must:

1. cite PROP-036 and the S3-R35-C3-A acceptance decision;
2. receive separate Architect/supervisor implementation authorization;
3. name exactly one surface: loader-only, report-only, assembler-only,
   golden-migration-only, or receipt-link-only;
4. preserve `present_verified != runtime ready`;
5. preserve `legacy_optional` unless a later Architect decision changes rollout;
6. include tests for all five statuses;
7. avoid `.igapp`/`.ilk` mutation unless the card explicitly authorizes it;
8. keep compiler dispatch migration and RuntimeMachine binding out of scope
   unless separately authorized.

---

## Handoff

```text
Card: S3-R36-C5-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/prop036-loader-status-report-proof-v0
Status: done

[D] Decisions
- Modeled loader status reports proof-locally using synthetic manifests only.
- Kept legacy_optional as the initial policy.
- Modeled missing_required only as future profile_required policy, with rollout
  unauthorized.
- Preserved present_verified as not runtime-ready.

[S] Shipped / Signals
- Added prop036_loader_status_report_proof experiment.
- Wrote matrix and summary JSON under experiment out/.
- Track doc records PASS matrix and blockers.

[T] Tests / Proofs
- ruby igniter-lang/experiments/prop036_loader_status_report_proof/prop036_loader_status_report_proof.rb -> PASS

[R] Risks / Recommendations
- Do not wire production loader or CompatibilityReport from this proof.
- Open a separate implementation card only after explicit authorization.
- Keep artifact hash/golden migration separate from loader/report status.

[Next] Suggested next slice
- PROP-036 artifact-hash ordering proof using synthetic artifact material, or a
  loader/report implementation plan if Architect authorizes it.
```
