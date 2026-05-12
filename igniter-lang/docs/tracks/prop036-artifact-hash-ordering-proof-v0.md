# Track: PROP-036 Artifact Hash Ordering Proof v0

Card: S3-R37-C5-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop036-artifact-hash-ordering-proof-v0`
Status: done
Date: 2026-05-12

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`, `[Igniter-Lang Meta Expert]`,
`[Igniter-Lang Implementation Agent]`

---

## Goal

Continue PROP-036 with a proof-local artifact-hash ordering proof.

This slice proves that `compiler_profile_id` must participate in artifact hash
material before signing. It does not mutate real `.igapp` manifests, update real
goldens, implement loader or assembler behavior, migrate compiler dispatch, bind
RuntimeMachine, or change production behavior.

---

## Source Evidence

Read:

- `docs/gates/prop036-compiler-profile-id-acceptance-decision-v0.md`
- `docs/tracks/prop036-loader-status-report-proof-v0.md`
- `docs/proposals/PROP-036-compiler-profile-manifest-identity-v0.md`
- `docs/discussions/r36-deployment-prop032-prop036-prop037-mundane-pressure-v0.md`

[D] This track cites both blocker authorities:

- C3-A: `docs/gates/prop036-compiler-profile-id-acceptance-decision-v0.md`
- C5-P: `docs/tracks/prop036-loader-status-report-proof-v0.md`

---

## Decision

[D] Use synthetic artifact material only.

[D] The permitted ordering is:

```text
assemble synthetic material
add compiler_profile_id to synthetic manifest material
compute artifact_hash over that material
sign artifact_hash and compiler_profile_id together
```

[D] The forbidden ordering remains:

```text
hash/sign artifact material
add compiler_profile_id after signing
```

[D] Signing in this proof is synthetic and proof-local. It models payload
coverage only; it is not production cryptographic signing policy.

---

## Proof

Added:

```text
experiments/prop036_artifact_hash_ordering_proof/
  prop036_artifact_hash_ordering_proof.rb
  out/prop036_artifact_hash_ordering_matrix.json
  out/prop036_artifact_hash_ordering_summary.json
```

The proof builds deterministic canonical JSON material, computes
`sha256:<digest>` over that material, and signs a synthetic payload containing:

```json
{
  "artifact_hash": "sha256:...",
  "compiler_profile_id": "compiler_profile_unified/sha256:...",
  "signing_context": "synthetic-proof-local-prop036-signing-v0",
  "synthetic_signature_only": true
}
```

---

## Matrix

| Case | Decision | Expected result |
| --- | --- | --- |
| `profiled_before_hash_and_sign` | `accept_profiled_hash_material` | Profiled material validates because hash and signature payload cover `compiler_profile_id`. |
| `legacy_without_profile` | `legacy_optional_hash_material` | Legacy material remains valid only for legacy material under the current optional policy. |
| `post_sign_annotation_forbidden` | `refuse_post_sign_profile_annotation` | Adding `compiler_profile_id` after signing changes the recomputed hash and is not signature-covered. |
| `profile_id_change_changes_hash` | `require_rehash_and_resign` | Changing the profile id changes artifact hash and synthetic signature. |
| `signature_profile_mismatch_refused` | `refuse_signature_profile_mismatch` | A signed profile id mismatch is rejected by the profile-aware policy. |

---

## Command Matrix

```text
ruby igniter-lang/experiments/prop036_artifact_hash_ordering_proof/prop036_artifact_hash_ordering_proof.rb -> PASS
ruby -c igniter-lang/experiments/prop036_artifact_hash_ordering_proof/prop036_artifact_hash_ordering_proof.rb -> PASS
git diff --check -- igniter-lang/docs/tracks/prop036-artifact-hash-ordering-proof-v0.md igniter-lang/experiments/prop036_artifact_hash_ordering_proof -> PASS
```

Observed proof checks:

```text
authority.cites_c3a
authority.cites_c5p
scope.synthetic_material_only
scope.no_real_igapp_mutation
scope.no_real_loader_implementation
scope.no_real_assembler_implementation
scope.no_compiler_dispatch_migration
scope.no_runtime_machine_binding
scope.no_production_behavior_change
scope.no_production_signing
ordering.profiled_before_hash_accepts
ordering.signature_payload_covers_profile_id
ordering.legacy_optional_hash_still_valid_for_legacy_material
negative.post_sign_annotation_refused
negative.post_sign_annotation_not_signature_covered
hash.profile_id_changes_artifact_hash
hash.profile_id_changes_signature_payload
negative.signature_profile_mismatch_refused
blockers.expanded_list_preserved
```

All checks PASS.

---

## Non-Authorizations Preserved

[S] This proof records:

```text
synthetic_material_only: true
real_igapp_mutation: false
real_loader_implementation: false
real_assembler_implementation: false
compiler_dispatch_migration: false
runtime_machine_binding: false
production_behavior_change: false
production_signing: false
```

[S] It does not change real `.igapp` manifests, `.ilk` files, real assembler
output, loader behavior, CompatibilityReport production code, artifact goldens,
CompilationReceipt links, compiler dispatch, RuntimeMachine binding, or runtime
execution authority.

---

## Updated Blockers Before Any PROP-036 Implementation Card

[R] Before implementation, a later card must:

1. cite PROP-036, the S3-R35-C3-A acceptance decision, and the S3-R36-C5-P
   loader proof as blocker authority;
2. receive separate Architect/supervisor implementation authorization;
3. name exactly one implementation surface for the card;
4. preserve `compiler_profile.present_verified != runtime ready`;
5. preserve `legacy_optional` unless a later Architect decision changes rollout;
6. avoid `profile_required` rollout without migration evidence;
7. avoid real `.igapp` manifest or `.ilk` artifact mutation unless explicitly
   authorized;
8. avoid real loader, assembler, CompatibilityReport, or artifact golden
   migration implementation from this proof;
9. keep compiler dispatch migration out of scope unless separately authorized;
10. keep RuntimeMachine binding and runtime execution authority out of scope
    unless separately authorized;
11. carry this hash-ordering proof into assembler field design before any
    artifact hash migration;
12. keep proof-local fixture output separate from real goldens.

---

## Handoff

```text
Card: S3-R37-C5-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: igniter-lang/prop036-artifact-hash-ordering-proof-v0
Status: done

[D] Decisions
- Proved hash ordering with synthetic artifact material only.
- Required compiler_profile_id to be present in artifact material before hash.
- Required synthetic signature payload to cover both artifact_hash and
  compiler_profile_id.
- Kept legacy material valid only as legacy_optional material.
- Cited both C3-A and C5-P blocker authorities.

[S] Shipped / Signals
- Added prop036_artifact_hash_ordering_proof experiment.
- Wrote matrix and summary JSON under experiment out/.
- Track doc records PASS matrix and expanded blockers.

[T] Tests / Proofs
- ruby igniter-lang/experiments/prop036_artifact_hash_ordering_proof/prop036_artifact_hash_ordering_proof.rb -> PASS

[R] Risks / Recommendations
- Do not derive production signing, loader, assembler, dispatch, or runtime
  behavior from this proof.
- Treat artifact_hash migration as a separate implementation card requiring
  explicit authorization.

[Next] Suggested next slice
- PROP-036 assembler field design plan, still proof/design-only, carrying the
  hash ordering invariant into the future artifact_hash migration.
```
