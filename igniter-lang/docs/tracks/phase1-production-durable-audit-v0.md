# Track: Phase 1 Production Durable Audit v0

Card: S3-R26-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: `research-agent`
Track: `phase1-production-durable-audit-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Purpose

Design the production durable audit surface for the already-signed restricted
Gate 3 Phase 1 live-read path under
`phase1-production-durable-audit-scope-decision-v0`.

This track is design only. It does not implement or authorize production
deployment, production signing execution, Ledger adapter binding, Phase 2,
BiHistory, stream/OLAP, production cache, writes, Ledger replay, compact, or
subscribe.

Approved live-read scope remains unchanged:

```text
History[T] valid_time read
explicit as_of
signed Gate 3 Phase 1 addendum evidence
active authority_ref evidence
MemoryBackend or explicit non-Ledger Phase 1 backend identity
audit-ready observation envelope
```

---

## Source Inputs

- `docs/gates/phase1-production-durable-audit-scope-decision-v0.md`
- `docs/tracks/phase1-observation-tamper-evidence-shape-v0.md`
- `docs/tracks/phase1-durable-observation-persistence-shape-v0.md`
- `docs/tracks/phase1-post-r24-regression-rerun-v0.md`

The R25 regression record is green: 25/25 PASS.

---

## Design Summary

[D] Production durable audit should be a signed, append-only, off-process audit
log for Phase 1 temporal live-read observations.

[D] The audit store is not a Ledger and does not expose runtime replay. Its
read path is **audit traversal**: ordered verification and export of persisted
audit records.

[D] Production registry ownership is decoupled from audit persistence in v0.
The audit record copies `authority_ref`, `signed_addendum_ref`, and
content-addressed decision evidence; it does not perform registry authority
decisions. Caller policy and executor guard remain upstream.

[D] Recommended signing model: HSM/KMS-backed signing abstraction with per-record
signatures. The implementation may start with an injectable signer interface,
but production readiness requires a real HSM/KMS or equivalent managed signing
system.

[D] Production `format_version` starts at `1.0.0`. Proof-local `0.1.0` and
`0.2.0` records are not accepted as production audit records.

---

## Production Audit Record Schema

Record kind:

```text
phase1_production_audit_record
```

Format version:

```text
1.0.0
```

Required top-level shape:

```json
{
  "kind": "phase1_production_audit_record",
  "format_version": "1.0.0",
  "record_id": "audit/phase1/<record_hash_prefix>",
  "record_scope": {
    "gate": "gate3",
    "phase": "phase1",
    "operation": "history_valid_time_read",
    "fragment_class": "TEMPORAL",
    "excluded_surfaces": [
      "Ledger",
      "BiHistory",
      "stream",
      "OLAP",
      "write",
      "ledger_replay",
      "compact",
      "subscribe",
      "production_cache"
    ]
  },
  "storage_identity": {
    "kind": "phase1_production_audit_store",
    "storage_id": "audit/gate3/phase1/<environment>/<region>/<shard>",
    "provider": "managed_append_only_store",
    "environment": "production|staging",
    "region": "region-id",
    "shard": "shard-id",
    "durability_model": "off_process_append_only",
    "ledger_binding": false
  },
  "append_identity": {
    "writer_id": "service-or-principal-id",
    "writer_role": "phase1_audit_appender",
    "append_attempt_id": "uuid",
    "appended_at": "ISO8601"
  },
  "source_envelope": {
    "kind": "audit_ready_temporal_read_envelope",
    "envelope_id": "sha256:<canonical-envelope-hash>",
    "compatibility_report_ref": "compat/phase1/<hash>",
    "authority_ref": "architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09",
    "signed_addendum_ref": {
      "document_path": "igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md",
      "git_commit": "release-or-commit-sha",
      "content_sha256": "sha256:<document-bytes>",
      "status": "signed-approved-restricted-phase1-live-read",
      "signed_on": "2026-05-09"
    }
  },
  "temporal_live_read_observation": {
    "kind": "temporal_live_read_observation",
    "contract_id": "contract-id",
    "node": "node-id",
    "axis": "valid_time",
    "subject": "subject-ref",
    "as_of": "ISO8601",
    "backend_identity": {
      "kind": "phase1_non_ledger_backend",
      "class_name": "backend-class",
      "ledger_binding": false
    },
    "result": {
      "status": "allowed|refused",
      "reason_code": "runtime.temporal_evaluation_ready|...",
      "result_present": true
    }
  },
  "chain": {
    "sequence": 0,
    "previous_record_hash": "genesis|sha256:<previous-record-body>",
    "record_hash": "sha256:<record-body>",
    "chain_id": "audit-chain/gate3/phase1/<storage-id>",
    "hash_algorithm": "sha256",
    "canonicalization": "json-canonical-sorted-keys-v1"
  },
  "signature": {
    "signature_version": "1.0.0",
    "signing_model": "hsm_or_kms",
    "signing_key_id": "kms-or-hsm-key-id",
    "signing_key_version": "key-version",
    "signing_authority_ref": "authority/signing/gate3/phase1/audit",
    "signed_payload_hash": "sha256:<canonical-record-with-signature-null>",
    "signature_algorithm": "provider-selected-asymmetric-algorithm",
    "signature_value": "base64-signature",
    "signed_at": "ISO8601"
  },
  "retention": {
    "retention_policy_id": "retention/gate3/phase1/v1",
    "retain_until": "ISO8601",
    "archive_after": "ISO8601|null",
    "legal_hold": false,
    "deletion_policy": "explicit-policy-only"
  },
  "compliance_posture": {
    "audit_ready": true,
    "production_durable_audit": true,
    "production_compliance_claim": false,
    "compliance_regimes": []
  }
}
```

Notes:

- `record_hash` is computed over canonical JSON with `chain.record_hash = null`
  and `signature.signature_value = null`.
- `signed_payload_hash` must equal the same canonical body hash used for
  signing.
- `record_id` is derived from `record_hash`, not from a mutable storage cursor.
- `ledger_binding` must remain `false`.

---

## Signing And Verification Model

Recommended model: HSM/KMS-backed signing abstraction.

Writer flow:

1. Build the production audit record with `record_hash = null` and
   `signature_value = null`.
2. Canonicalize using `json-canonical-sorted-keys-v1`.
3. Compute `record_hash = sha256(canonical_record_body)`.
4. Set `record_id` from the hash.
5. Sign the canonical body hash through the signer abstraction.
6. Append the completed record to the off-process append-only store.

Verification flow:

1. Recompute canonical body hash with `record_hash` and `signature_value` nulled.
2. Verify it matches `chain.record_hash` and `signature.signed_payload_hash`.
3. Resolve `signing_key_id` and `signing_key_version` from a trusted key
   metadata source.
4. Verify `signature_value`.
5. Verify signing authority is allowed for Gate 3 Phase 1 audit only.

[R] Key recommendation: use asymmetric signing with externally managed private
keys. The audit system should never persist private keys. Rotated key versions
remain verifiable through retained public verification metadata.

---

## Restart Rebuild Algorithm

On startup, the audit appender must not trust in-memory cursor state. It rebuilds
from persisted records:

1. Open the off-process audit store in read-only traversal mode.
2. Read records in storage order for the configured `storage_id` and `chain_id`.
3. Reject any record with unsupported `kind` or `format_version`.
4. Verify `storage_identity` is constant across the chain.
5. For sequence `0`, require `previous_record_hash = "genesis"`.
6. For sequence `n > 0`, require sequence continuity and
   `previous_record_hash == prior.chain.record_hash`.
7. Recompute each `record_hash`.
8. Verify each signature.
9. Verify retention metadata is present and internally consistent.
10. Verify each record remains within restricted Phase 1 scope.
11. Set next append cursor to `last.sequence + 1` only after full verification.

Failure posture:

- fail closed;
- do not append new records;
- emit a rebuild failure report;
- require operator or automated recovery workflow outside the executor path;
- never auto-truncate, auto-compact, or auto-repair the production audit log.

---

## Format Version Enforcement

Accepted production versions in v0:

```text
1.0.0
```

Rejected versions:

- missing `format_version`;
- proof-local `0.1.0`;
- proof-local `0.2.0`;
- unknown future versions;
- mixed-version chain without an explicit migration receipt.

Migration rule:

```text
No implicit migration.
```

A future format migration requires a separate design/implementation track with:

- migration descriptor;
- old/new schema refs;
- migration receipt;
- chain continuity proof;
- auditor-visible compatibility report.

---

## Retention And Audit Traversal Semantics

Use **audit traversal** for the read-only audit verification path.

Audit traversal means:

- read records in chain order;
- verify hash and signature continuity;
- filter by allowed audit query fields;
- export an auditor-visible report;
- refuse traversal if gaps, reorder, hash mismatch, signature mismatch, or
  retention violations are detected.

Allowed audit queries:

- by `record_id`;
- by `contract_id`;
- by `authority_ref`;
- by `signed_addendum_ref.content_sha256`;
- by `backend_identity`;
- by time interval over `appended_at`;
- by `result.status` and `reason_code`.

Retention fields:

- `retention_policy_id`;
- `retain_until`;
- `archive_after`;
- `legal_hold`;
- `deletion_policy`.

What this is not:

- not Ledger replay;
- not runtime replay;
- not re-execution of a temporal read;
- not a write path;
- not compact;
- not subscribe;
- not cache warming.

---

## Off-Process Persistence Identity

Production durable audit requires off-process storage identity, not an in-memory
UUID or proof-local JSONL path.

Minimum identity:

- `storage_id`;
- provider kind;
- environment;
- region;
- shard;
- chain id;
- append-only guarantee;
- writer identity;
- auditor-readable public identity;
- `ledger_binding: false`.

[R] The storage provider can be selected later, but the interface must preserve
append-only semantics and ordered traversal. A generic database table is not
sufficient unless it can prove append-only behavior, sequence uniqueness, and
tamper-evident traversal.

---

## Audit Reader Role

Role:

```text
phase1_audit_reader
```

Allowed:

- read audit records;
- run chain verification;
- run signature verification;
- run scoped audit traversal;
- export audit reports;
- inspect retention metadata.

Denied:

- append records;
- authorize `gate3_authorized: true`;
- execute TemporalExecutor reads;
- call TBackend or Ledger;
- write, Ledger replay, compact, subscribe;
- mutate retention policies;
- repair chains;
- use audit records as runtime cache input.

The audit reader is separated from:

- caller policy authority;
- Phase1TemporalExecutor;
- audit appender;
- registry authority owner;
- signing key administrator.

---

## Compliance Language Boundaries

Allowed after implementation proof:

- `audit_ready`: record can be exported for audit review.
- `production_durable_audit`: record was durably appended to the approved
  production audit store and passed chain/signature verification.

Not allowed in this design:

- SOC2, GDPR, PCI, HIPAA, or other regime-specific compliance claims;
- legal retention sufficiency claims;
- non-repudiation claims beyond the selected signing provider guarantee;
- Ledger-backed audit claims;
- Phase 2 coverage claims;
- BiHistory/stream/OLAP coverage claims.

Compliance posture should remain explicit:

```json
{
  "audit_ready": true,
  "production_durable_audit": true,
  "production_compliance_claim": false,
  "compliance_regimes": []
}
```

---

## Refusal And Error Codes

Proposed code list:

| Code | Meaning |
|------|---------|
| `audit.scope.non_phase1_surface` | Record or append attempt is outside restricted Gate 3 Phase 1. |
| `audit.scope.ledger_forbidden` | Ledger-backed or Ledger-like backend reached audit append/traversal path. |
| `audit.scope.phase2_forbidden` | Phase 2 surface attempted to use Phase 1 audit store. |
| `audit.format.missing_version` | `format_version` missing. |
| `audit.format.unsupported_version` | Version is not accepted for production v0. |
| `audit.format.missing_required_field` | Required record field missing. |
| `audit.format.migration_required` | Mixed or old version requires explicit migration receipt. |
| `audit.storage.identity_mismatch` | Record storage identity does not match chain identity. |
| `audit.storage.append_order_unknown` | Store cannot provide ordered append traversal. |
| `audit.chain.sequence_gap` | Sequence is not contiguous. |
| `audit.chain.previous_hash_mismatch` | Previous hash does not match prior record hash. |
| `audit.chain.record_hash_mismatch` | Recomputed hash differs from stored hash. |
| `audit.chain.truncation_detected` | Expected chain tail is missing. |
| `audit.signature.missing` | Signature block or value missing. |
| `audit.signature.invalid` | Signature verification failed. |
| `audit.signature.untrusted_key` | Key id/version is not trusted for Phase 1 audit. |
| `audit.signature.expired_or_revoked_key` | Key status invalid for verification policy. |
| `audit.retention.missing_policy` | Retention policy missing. |
| `audit.retention.expired` | Traversal/export violates retention state. |
| `audit.retention.legal_hold_violation` | Operation conflicts with legal hold. |
| `audit.traversal.closed_interval_required` | Query interval is open/unbounded. |
| `audit.reader.unauthorized` | Caller lacks audit reader role. |
| `audit.writer.unauthorized` | Caller lacks audit appender role. |
| `audit.export.non_compliant` | Export lacks required verification or caveat fields. |

---

## Implementation Blockers

Implementation remains blocked until a later Architect decision. Required before
implementation authorization:

1. External or cross-role pressure review of this design.
2. Architect confirmation that audit persistence may proceed decoupled from
   production registry ownership, or a registry ownership decision.
3. Concrete signing provider choice or approved signer abstraction contract.
4. Verification key metadata source and key-rotation policy.
5. Off-process append-only storage provider/interface decision.
6. Retention policy owner and minimum retention values.
7. Audit reader/appender credential model.
8. Canonical JSON test vector acceptance.
9. Restart rebuild failure posture accepted by Supervisor/Bridge.
10. Explicit non-Ledger / non-Phase-2 statement preserved in the implementation
    card.

---

## Required Proofs For Implementation Track

Minimum proof plan:

1. `production_audit_record_schema_proof`: accepted record has all required
   fields and rejects missing/malformed fields.
2. `production_audit_signature_proof`: signs canonical record hash and rejects
   missing, malformed, untrusted, expired, revoked, and invalid signatures.
3. `production_audit_format_version_proof`: accepts `1.0.0`, rejects `0.1.0`,
   `0.2.0`, missing, unknown, and mixed-version chains.
4. `production_audit_restart_rebuild_proof`: rebuilds append cursor after clean
   restart and refuses gap/reorder/hash/signature/storage mismatch.
5. `production_audit_traversal_proof`: verifies ordered chain and exports
   auditor-visible report without executing runtime reads.
6. `production_audit_retention_proof`: enforces `retain_until`, `archive_after`,
   and `legal_hold` metadata without compact/delete behavior.
7. `production_audit_role_boundary_proof`: audit reader cannot append, appender
   cannot authorize runtime reads, neither can call Ledger/TBackend.
8. `phase1_executor_audit_append_integration_proof`: restricted Phase 1 allowed
   read can append an audit record after executor success; refused reads emit
   refusal evidence as specified.
9. `excluded_surface_regression_proof`: Ledger, BiHistory, stream, OLAP,
   writes, Ledger replay, compact, subscribe, and production cache remain
   blocked.
10. `phase1_regression_25_command_proof`: existing 25-command matrix remains
    PASS after implementation.

---

## Recommendation

Ready for implementation authorization review.

This means the design surface is specific enough for Architect/Meta/pressure
review to decide whether to authorize a bounded implementation track. It does
not authorize implementation by itself.

---

## Handoff

```text
Card: S3-R26-C1-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: phase1-production-durable-audit-v0
Status: done

[D] Decisions
- Production durable audit should be a signed append-only off-process audit log.
- Audit read path is audit traversal / chain verification, not Ledger replay.
- Registry ownership is decoupled in v0; audit copies authority/addendum evidence
  and does not make authority decisions.
- Production format_version starts at 1.0.0; proof-local 0.x records are rejected.

[S] Shipped / Signals
- Defined production audit record schema, signing model, rebuild algorithm,
  version rules, retention/traversal semantics, storage identity, reader role,
  compliance boundaries, refusal codes, blockers, and implementation proof plan.

[T] Tests / Proofs
- Design-only track; no executable proof added.
- Source evidence: R25 regression 25/25 PASS.

[R] Risks / Recommendations
- Implementation requires later Architect authorization, signing/provider choice,
  storage/interface choice, key metadata policy, retention policy, and pressure review.
- Keep Ledger/Phase 2/BiHistory/stream/OLAP/cache/write/Ledger replay/compact/
  subscribe exclusions explicit in any implementation card.

[Next] Suggested next slice
- External/Meta pressure review of this production durable audit design, then
  a bounded implementation authorization decision if accepted.
```
