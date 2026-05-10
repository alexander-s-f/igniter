# Track: Compilation Receipt Authority and Storage v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compilation-receipt-authority-and-storage-v0`
Status: done
Date: 2026-05-10

---

## Goal

Define where a future `CompilationReceipt` can live and what authority each
storage surface carries.

This slice does not implement production receipt storage, does not change
`.igapp`, does not implement signing, and does not grant runtime execution
authority.

---

## Added Proof

Added:

```text
igniter-lang/experiments/compilation_receipt_authority_and_storage/compilation_receipt_authority_and_storage.rb
igniter-lang/experiments/compilation_receipt_authority_and_storage/out/compilation_receipt_storage_policy.json
igniter-lang/experiments/compilation_receipt_authority_and_storage/out/compilation_receipt_authority_and_storage_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compilation_receipt_authority_and_storage/compilation_receipt_authority_and_storage.rb
```

Result:

```text
PASS compilation_receipt_authority_and_storage
```

The runner first refreshes:

```text
compiler_profile_auditable_build_receipt
```

then derives a proof-local storage and authority policy from the generated
receipt.

---

## Storage Surfaces

| Surface | Candidate Path | Authority | Stores | Runtime authority |
|---|---|---|---|---|
| embedded receipt | `.igapp/compilation_receipt.json` | co-located build explanation | public redacted receipt view | false |
| external signed bundle | `<artifact>.compilation_receipt.bundle.json` | signed build attestation candidate | digest/ref signature payload | false |
| `.ilk` metadata index | `.ilk/compilation_receipts/<receipt_digest>.json` | lineage/query index | receipt refs, digests, artifact refs, profile ids | false |

---

## Decisions

[D] There should not be one universal receipt storage authority.

Use three levels:

```text
embedded .igapp receipt     -> local explanation
external signed bundle      -> production audit candidate
.ilk metadata index         -> lineage/query/navigation
```

[D] Embedded `.igapp/compilation_receipt.json` should wait until artifact hash
ordering is formally specified. Otherwise the project risks ambiguity about
whether the receipt is inside or outside the signed artifact surface.

[D] The external signed bundle is the right home for production audit authority,
but only after key management, canonical JSON, timestamp, revocation, and
retention policy are specified.

[D] `.ilk` should index receipt digests and lineage. It should not replace the
signed receipt bundle.

[D] No storage surface grants runtime execution. Runtime authority remains with
CompatibilityReport and runtime guard policy.

---

## Redaction Policy

Public receipt views may expose:

```text
program_id
source_hash
compiler_profile_id
profile preflight refs
stage outcomes
pack/rule model
diagnostics and warnings
requirements
artifact refs and hashes
authority claims
```

Restricted fields:

```text
source.path
compile_command.cli
compile_command.direct_api
compatibility.runtime_smoke.outputs
```

Reason:

```text
Audit-friendly does not mean leaking local absolute paths, shell commands, or
runtime sample outputs into every public receipt surface.
```

---

## Signed Payload Candidate

The external signed bundle should sign digest/ref/policy fields, not every local
machine detail:

```text
receipt_digest
public_receipt_digest
artifact_hash
manifest_digest
source_hash
compiler_profile_id
program_id
authority
signature_policy
```

Required future policy:

```text
canonical_json
algorithm
key_management
timestamp_authority
revocation_policy
retention_policy
```

---

## CompatibilityReport Link

Future CompatibilityReport can consume receipt status as another evidence input:

```text
compilation_receipt_status
compilation_receipt_digest
signed_receipt_status
receipt_redaction_policy
```

But the report must preserve:

```text
receipt present/signed != runtime execution authorized
```

---

## Proof Checks

| Check | Meaning |
|---|---|
| `input.receipt_proof_passed` | Upstream receipt proof passed before storage modeling. |
| `policy.has_three_storage_surfaces` | Embedded, external signed, and `.ilk` surfaces are present. |
| `authority.no_surface_grants_runtime_execution` | No storage surface grants runtime execution. |
| `embedded.requires_hash_ordering_before_signed_surface` | Embedded receipt is blocked on artifact hash/signature semantics. |
| `signed_payload_uses_digests_not_local_paths` | Signed payload excludes local machine paths. |
| `public_view_redacts_local_paths_and_commands` | Public view excludes local paths and command strings. |
| `redaction.restricted_fields_named` | Sensitive fields are explicitly named. |
| `compatibility_report_link_present_without_authority_leak` | Report linkage is modeled without runtime authority leak. |
| `receipt_digest_preserved` | Storage policy preserves the upstream receipt digest. |
| `source_receipt_remains_non_production_audit` | Source receipt still does not overclaim production audit status. |

---

## Recommendation

[R] The next formal proposal should define `CompilationReceipt` as a sibling
evidence artifact to `.igapp` manifest and CompatibilityReport.

[R] Do not embed receipts into `.igapp` until the manifest proposal defines
whether receipt bytes participate in `artifact_hash`, signed surfaces, and
legacy compatibility.

[R] If production audit is required, start with external signed receipt bundle
semantics before changing runtime behavior.

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: compilation-receipt-authority-and-storage-v0
Status: done

[D] Decisions:
- Receipt storage has three authority levels: embedded explanation, external
  signed audit candidate, and .ilk lineage index.
- Embedded .igapp receipt is blocked on artifact hash/signature ordering.
- Public receipt views redact local paths, compile commands, and runtime outputs.
- Receipt presence/signature never grants runtime execution authority.

[S] Signals:
- Storage policy can derive from the proof-local CompilationReceipt.
- Signed payload can be digest/ref based and avoid local machine details.
- CompatibilityReport can consume receipt status without authority leakage.

[T] Tests:
- ruby igniter-lang/experiments/compilation_receipt_authority_and_storage/compilation_receipt_authority_and_storage.rb -> PASS

[R] Risks:
- Production signing still needs canonical JSON, key management, timestamp,
  revocation, and retention policy.
- `.igapp` embedding should wait for manifest/artifact hash semantics.

[Next]
- Draft `PROP-033-compilation-receipt-v0` or split into:
  1. `compiler_profile_id` manifest semantics
  2. `CompilationReceipt` storage/signature semantics
```
