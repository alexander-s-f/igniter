# Track: Compiler Profile Manifest PROP Draft v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-manifest-prop-draft-v0`
Status: done
Date: 2026-05-10

---

## Goal

Draft a PROP-ready model for adding `compiler_profile_id` to future
`.igapp/manifest.json` artifacts.

This is a track-level draft candidate. It does not claim an official PROP number,
does not implement assembler changes, does not update `.igapp` fixtures, and
does not authorize runtime execution.

---

## Added Proof

Added:

```text
igniter-lang/experiments/compiler_profile_manifest_prop_draft/compiler_profile_manifest_prop_draft.rb
igniter-lang/experiments/compiler_profile_manifest_prop_draft/out/compiler_profile_manifest_prop_draft.json
igniter-lang/experiments/compiler_profile_manifest_prop_draft/out/compiler_profile_manifest_prop_draft_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_manifest_prop_draft/compiler_profile_manifest_prop_draft.rb
```

Result:

```text
PASS compiler_profile_manifest_prop_draft
```

The runner refreshes:

```text
compiler_profile_id_manifest_boundary
compiler_profile_compatibility_report_fields
compilation_receipt_authority_and_storage
```

and combines their evidence into one PROP draft candidate.

---

## Proposed Manifest Field

```json
{
  "compiler_profile_id": "ordered_rule_profile/sha256:674d7b6d7512186d5031555d"
}
```

Field contract:

| Property | Value |
|---|---|
| name | `compiler_profile_id` |
| type | string |
| placement | top-level manifest field |
| initial policy | `legacy_optional` |
| future policy | `profile_required` |
| authority | compiler understanding only |
| runtime execution authority | false |

[D] Start with a small top-level id field, not an inline profile body.

---

## Hash And Signature Policy

[D] `compiler_profile_id` must participate in artifact hash material.

Required ordering:

```text
finalize compiler profile
assemble manifest with compiler_profile_id
compute artifact_hash
sign artifact_hash and compiler_profile_id together
```

Forbidden:

```text
post-signing compiler_profile_id annotation
```

Initial profile body policy:

```text
profile_body_inline_initially_allowed: false
expanded_profile_sidecar_future: true
```

---

## Loader Policy

| Policy | Absent | Match | Mismatch | Malformed |
|---|---|---|---|---|
| `legacy_optional` | `accept_absent_legacy` | `accept_profile_match` | `refuse_profile_mismatch` | `refuse_malformed_profile_id` |
| `profile_required` | `refuse_missing_compiler_profile_id` | `accept_profile_match` | `refuse_profile_mismatch` | `refuse_malformed_profile_id` |

[D] `absent_legacy` must remain distinct from `malformed` or `mismatch`.

---

## CompatibilityReport Fields

The draft carries forward the report split:

```text
compiler_profile_status:
  absent_legacy
  present_verified
  mismatch
  malformed
  missing_required

runtime_evaluation_readiness:
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

## Receipt Relationship

`CompilationReceipt` may reference:

```text
compiler_profile_id
manifest_digest
artifact_hash
receipt_digest
```

But:

```text
signed receipt != runtime execution authority
```

Receipt manifest links should wait until manifest hash/signature ordering is
stable.

---

## Migration Order

1. Finalize PROP for `compiler_profile_id` field and compatibility policies.
2. Add report-only loader support for `absent_legacy`, `mismatch`, `malformed`,
   and `missing_required`.
3. Add assembler support behind `legacy_optional` policy and update proof
   fixtures.
4. Regenerate artifact hashes and goldens intentionally.
5. Add `CompilationReceipt` references after manifest hash ordering is stable.
6. Consider `profile_required` only after profiled artifacts are normal.

---

## Implementation Cards

```text
assembler-compiler-profile-id-field-v0
loader-compiler-profile-status-report-v0
artifact-hash-profile-id-golden-migration-v0
compilation-receipt-manifest-link-v0
```

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.manifest_boundary_passed` | Manifest boundary proof passed. |
| `input.report_fields_passed` | CompatibilityReport field proof passed. |
| `input.receipt_storage_passed` | Receipt storage proof passed. |
| `field.compiler_profile_id_top_level` | Field is top-level `compiler_profile_id`. |
| `authority.no_runtime_execution_authority` | Field and receipt do not grant runtime execution. |
| `hash.before_hash_and_signing` | Field is before hash and signing. |
| `hash.no_post_signing_annotation` | Post-signing annotation is forbidden. |
| `policy.has_legacy_and_required_modes` | Both rollout policies are present. |
| `report.separates_profile_and_runtime_fields` | Profile status and runtime readiness stay separate. |
| `migration.has_ordered_implementation_cards` | Migration order and cards are explicit. |

---

## Numbering Note

This track does not claim `PROP-033` because `docs/proposals/README.md` already
queues `PROP-033` for `via profile binding`.

[R] Architect / Compiler-Expert should assign a fresh proposal number or
re-queue the Stage 3 proposal list before promoting this draft.

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: compiler-profile-manifest-prop-draft-v0
Status: done

[D] Decisions:
- Draft candidate uses top-level compiler_profile_id.
- Field participates in artifact hash and signing material.
- Initial loader policy is legacy_optional; future policy is profile_required.
- The field proves compiler understanding only, never runtime authority.

[S] Signals:
- Manifest boundary, report fields, and receipt storage proofs compose cleanly.
- Migration order and implementation card sequence are explicit.

[T] Tests:
- ruby igniter-lang/experiments/compiler_profile_manifest_prop_draft/compiler_profile_manifest_prop_draft.rb -> PASS

[R] Risks:
- Official PROP number is not claimed.
- Real assembler/golden changes remain blocked until proposal approval.

[Next]
- Update closure index and tracks index with this new draft candidate.
```
