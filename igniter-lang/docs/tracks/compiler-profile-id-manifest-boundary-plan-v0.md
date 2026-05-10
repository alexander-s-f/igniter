# Track: Compiler Profile ID Manifest Boundary Plan v0

Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-id-manifest-boundary-plan-v0`
Status: done
Date: 2026-05-10

---

## Goal

Plan and prove a proof-local compatibility model for adding
`compiler_profile_id` to future `.igapp/manifest.json` artifacts without
changing current assembler output.

This slice does not edit `Assembler`, `RuntimeMachine`, existing `.igapp`
fixtures, signed artifact formats, or `.ilk` metadata.

---

## Current Manifest Reality

Current `.igapp/manifest.json` artifacts include fields such as:

```text
kind
format_version
format
program_id
artifact_hash
language_version
grammar_version
schema_version
assembler
semantic_ir_ref
compilation_report_ref
source_hash
source_path
contracts
contract_refs
fragment_class
fragment_summary
contract_index
schema_descriptor
warnings
diagnostics
```

They do not include `compiler_profile_id`.

---

## Implemented Proof Boundary

Added:

```text
igniter-lang/experiments/compiler_profile_id_manifest_boundary/compiler_profile_id_manifest_boundary.rb
igniter-lang/experiments/compiler_profile_id_manifest_boundary/out/compiler_profile_id_manifest_boundary_summary.json
```

The proof reads existing manifests but does not mutate them:

```text
igniter-lang/experiments/igapp_assembler_proof/out/add.igapp/manifest.json
igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/out/assembled/history_valid.igapp/manifest.json
```

It also reads the proof-local ordered compiler profile:

```text
igniter-lang/experiments/compiler_kernel_ordered_rule_precedence/out/compiler_kernel_ordered_rule_precedence_summary.json
```

It then models profiled manifest variants in memory and writes only a summary.

---

## Proposed Field Shape

Minimal first field:

```json
{
  "compiler_profile_id": "ordered_rule_profile/sha256:674d7b6d7512186d5031555d"
}
```

Recommended semantics:

- Identifies the frozen compiler profile that assembled the artifact.
- Includes pack implementation identities through the profile fingerprint.
- Does not grant runtime execution authority.
- Does not replace `artifact_hash`.
- Should be included before computing `artifact_hash` and before signing.

Deferred optional sidecar:

```json
{
  "compiler_profile": {
    "profile_id": "...",
    "packs": [],
    "fragment_registry": {},
    "oof_registry": {}
  }
}
```

Recommendation: do not add the full profile object to `manifest.json` first.
Start with stable `compiler_profile_id`; put expanded profile material in a
sidecar only after a manifest PROP decides whether the profile body belongs in
`.igapp/`.

---

## Compatibility Policies

| Policy | Absent field | Matching field | Mismatched field | Malformed field |
|---|---|---|---|---|
| `legacy_optional` | Accept with `profile_status: absent_legacy` | Accept | Refuse | Refuse |
| `profile_required` | Refuse | Accept | Refuse | Refuse |

Recommended rollout:

1. Begin with `legacy_optional`.
2. Add assembler support behind an explicit manifest/profile PROP.
3. Teach loaders and compatibility reports to surface `absent_legacy`.
4. Move to `profile_required` only after profiled assembler output is the normal
   path and old fixtures are intentionally migrated or grandfathered.

---

## Signed Artifact / `.ilk` Implications

The proof confirms that adding `compiler_profile_id` changes the modeled manifest
hash. Therefore profile identity must be added before artifact hashing and
signing:

```text
finalize compiler profile
assemble manifest with compiler_profile_id
compute artifact_hash over profiled artifact material
sign artifact_hash and compiler_profile_id together
```

Approval tokens and signed `.ilk` metadata should eventually include:

```text
artifact_ref
compiler_profile_id
```

This prevents reusing approval for an artifact under a different compiler profile
once profile IDs become required. It still does not authorize execution; runtime
approval and guard policy remain separate.

---

## Proof Checks

| Check | Meaning |
|---|---|
| `legacy.current_policy_accepts_absent` | Current policy can accept existing artifacts without profile IDs. |
| `legacy.future_policy_refuses_absent` | Future required policy can refuse missing profile IDs. |
| `profiled.core_accepts_match` | A profiled CORE manifest with matching id is accepted. |
| `profiled.temporal_accepts_match` | A profiled TEMPORAL manifest with matching id is accepted. |
| `negative.mismatch_refused` | A present but mismatched profile id is refused. |
| `negative.malformed_refused` | A malformed profile id is refused. |
| `field.profile_id_present_in_profiled_variants` | Modeled variants carry `compiler_profile_id`. |
| `artifact_hash.profile_field_changes_manifest_hash` | Adding the field changes manifest hash material. |
| `recommendation.reassembly_before_signing` | Profile id must be present before artifact signing. |
| `runtime.profile_id_grants_no_authority` | The field grants no runtime execution authority. |

---

## Proof Result

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_id_manifest_boundary/compiler_profile_id_manifest_boundary.rb
```

Result:

```text
PASS compiler_profile_id_manifest_boundary
legacy.current_policy_accepts_absent: ok
legacy.future_policy_refuses_absent: ok
profiled.core_accepts_match: ok
profiled.temporal_accepts_match: ok
negative.mismatch_refused: ok
negative.malformed_refused: ok
field.profile_id_present_in_profiled_variants: ok
artifact_hash.profile_field_changes_manifest_hash: ok
recommendation.reassembly_before_signing: ok
runtime.profile_id_grants_no_authority: ok
profile_id: ordered_rule_profile/sha256:674d7b6d7512186d5031555d
summary: igniter-lang/experiments/compiler_profile_id_manifest_boundary/out/compiler_profile_id_manifest_boundary_summary.json
```

---

## Decisions

[D] The first manifest field should be `compiler_profile_id`, not a large inline
profile object.

[D] Initial compatibility policy should be `legacy_optional`.

[D] Future stricter policy should be `profile_required`, but only after an
explicit manifest/profile PROP and fixture migration plan.

[D] `compiler_profile_id` must be part of artifact hash material. It is not safe
as a post-signing annotation.

[D] `compiler_profile_id` does not grant runtime executor authority. It identifies
what the compiler was allowed to understand, not what the runtime is allowed to do.

---

## Risks

[R] Adding `compiler_profile_id` to real assembler output will change artifact
hashes and goldens. It needs a dedicated manifest PROP and migration card.

[R] Loader behavior must distinguish `absent_legacy` from invalid/mismatched
profile IDs, otherwise old artifacts and corrupt artifacts become indistinguishable.

[R] The proof models manifest hash impact, but does not update the real
`artifact_hash` computation in `Assembler`.

[R] `.ilk` and approval token integration need a security review before profile
IDs become required.

---

## Next Recommended Slice

```text
Track: compiler-profile-id-manifest-prop-draft-v0
Goal:
- Draft the explicit manifest/profile PROP for compiler_profile_id.
Scope:
- Define manifest field shape.
- Define legacy_optional and profile_required policies.
- Define loader CompatibilityReport fields.
- Define artifact_hash/signing implications.
- Define fixture migration order.
- No code changes.
Acceptance:
- PROP draft.
- Implementation card recommendations for assembler and loader.
```

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: compiler-profile-id-manifest-boundary-plan-v0
Status: done

[D] Decisions:
- Use `compiler_profile_id` as the first manifest field.
- Start with `legacy_optional`; move to `profile_required` only after explicit PROP.
- Include compiler_profile_id before artifact_hash/signing.
- Treat compiler_profile_id as compiler identity, not runtime authority.

[S] Signals:
- Existing CORE and TEMPORAL manifests lack profile IDs and can be modeled as absent_legacy.
- Matching profiled variants accept under current compatibility policy.
- Mismatched and malformed profile IDs refuse.
- Adding profile ID changes manifest hash material.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/compiler_profile_id_manifest_boundary/compiler_profile_id_manifest_boundary.rb -> PASS

[R] Risks:
- Real assembler adoption will churn artifact hashes/goldens.
- Loader CompatibilityReport must preserve absent_legacy vs invalid distinction.
- Signed artifact and .ilk integration require a separate security/manifest review.

[Next]
- Draft compiler-profile-id-manifest-prop-v0 before any `.igapp` implementation.
```
