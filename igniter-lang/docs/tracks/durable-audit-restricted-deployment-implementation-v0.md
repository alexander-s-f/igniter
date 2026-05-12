# Track: durable-audit-restricted-deployment-implementation-v0

Card: S3-R37-C2-I
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Mode: implementation
Stage: bounded-proof
Track: durable-audit-restricted-deployment-implementation-v0
Date: 2026-05-12
Authorization: architect-supervisor://igniter-lang/gates/phase1-production-durable-audit/restricted-deployment-scope/2026-05-11
B-E Decision: S3-R36-C1-A

---

## Goal

Implement the first bounded deployment slice authorized by S3-R36-C1-A for Phase 1 production durable audit. Provide all 7 required follow-ups from S3-R36-C1-A §7 before operational rollout, in proof-local form.

---

## Scope

### In scope
- `Phase1DeploymentConfig` — validates storage identity and signer config at configuration time; refuses ledger, local, stub, test, noop patterns
- `RefusalCodeManifest` — exports all 12 B-E §8 required codes plus 12 deployment-surface codes (24 total); manifest is always proof-local
- `Phase1DeploymentAuditSurface` — wires `RoleGatedStore` appender + reader roles; gates all operations on startup verification; provides `disable!`/`enable!` rollback procedure; carries `production_durable_audit: false`, `gate3_authorized: false`, `ledger: false` in all outputs
- `FailingRebuildStub` — test stub for startup failure path; responds to `rebuild(records)` returning failed result without internal state manipulation
- Proof script covering all 7 follow-up surfaces: 30 cases + 5 invariants
- Full regression matrix (9/9 B-D commands PASS)

### Explicitly out of scope (non-authorization)
- Concrete HSM / KMS onboarding or production signing execution
- Ledger adapter
- Phase 2 surfaces
- BiHistory integration
- Stream / OLAP executor
- Production cache
- Broad RuntimeMachine binding
- Gate 3 authorization widening
- Production deployment beyond this bounded scope
- `.igapp` manifest changes
- `lib/` changes

---

## Decisions

### [D1] Phase1DeploymentConfig refuses before any surface is constructed

Storage identity and signer config are validated at construction time in `Phase1DeploymentConfig`. Invalid configs are refused with a structured `{ valid: false, code: "audit.deploy.*" }` result before any store or surface is instantiated. `Phase1DeploymentAuditSurface` requires a valid config.

### [D2] Startup verify gates ALL surface operations

`Phase1DeploymentAuditSurface` initializes with `@startup_verified = false`. Both `append` and `traverse` return `{ allowed: false, code: "audit.surface.startup_not_verified" }` until `startup_verify!` succeeds. A failed rebuild leaves `@startup_verified = false` and the surface remains locked.

### [D3] Reader store shares the underlying store with the appender after startup verify

After `startup_verify!` succeeds, `@reader_store` is constructed as a `RoleGatedStore` with `READER_ROLE` and its internal `@store` reference is set to the same `Phase1ProductionAuditStore` instance as the appender. This mirrors the `reader_store_with_records` pattern from B-C and ensures reader sees all appended records.

### [D4] disable!/enable! provide rollback procedure shape

`disable!(reason:, authorized_by:)` sets `@disabled = true` and captures metadata. Both `append` and `traverse` return `{ allowed: false, code: "audit.surface.disabled" }` when disabled. `enable!(authorized_by:)` restores the surface. The `status` output always includes disable metadata when present.

### [D5] RefusalCodeManifest carries proof-local flags; never claims deployment status

`RefusalCodeManifest.export` always returns `production_durable_audit: false`, `gate3_authorized: false`, `ledger: false`. The manifest is a proof-local code inventory, not a deployment authorization artifact.

### [D6] FailingRebuildStub used for startup failure path; no internal store tampering

The startup failure test case uses `FailingRebuildStub` — an object responding to `rebuild(records)` and returning a failed result hash — rather than manipulating store internal state. This keeps the test approach consistent with the proof-local pattern.

---

## Follow-up Map (S3-R36-C1-A §7)

| # | Required Follow-up | Proof Surface | Cases |
|---|-------------------|---------------|-------|
| 1 | Production storage identity configuration | Surface 1 | 4 |
| 2 | Signer abstraction config: refuse nil/noop/stub/local-test | Surface 2 | 6 |
| 3 | Startup rebuild verification behavior | Surface 3 | 4 |
| 4 | Appender/reader role wiring | Surface 4 | 4 |
| 5 | Refusal code export | Surface 5 | 3 |
| 6 | Rollback/disable procedure shape | Surface 6 | 4 |
| 7 | Post-deployment smoke proof | Surface 7 | 5 |

---

## Proof Case Matrix

### Surface 1 — Storage identity config (4/4 PASS)

| Case | Description | Result |
|------|-------------|--------|
| C-S1-1 | Valid config accepted | PASS |
| C-S1-2 | Ledger kind refused with `audit.deploy.storage_identity_untrusted` | PASS |
| C-S1-3 | `ledger_binding: true` refused with `audit.deploy.storage_identity_untrusted` | PASS |
| C-S1-4 | Missing `storage_id` refused with `audit.deploy.storage_identity_id_missing` | PASS |

### Surface 2 — Signer abstraction config (6/6 PASS)

| Case | Description | Result |
|------|-------------|--------|
| C-S2-1 | Valid signer config accepted | PASS |
| C-S2-2 | `nil` key_id refused with `audit.deploy.signer_key_id_missing` | PASS |
| C-S2-3 | `noop` key_id refused with `audit.deploy.signer_key_id_blocked` | PASS |
| C-S2-4 | `stub` key_id refused with `audit.deploy.signer_key_id_blocked` | PASS |
| C-S2-5 | `local-test-key` key_id refused with `audit.deploy.signer_key_id_blocked` | PASS |
| C-S2-6 | `stub` public_key_source refused with `audit.deploy.signer_public_key_source_blocked` | PASS |

### Surface 3 — Startup rebuild verification (4/4 PASS)

| Case | Description | Result |
|------|-------------|--------|
| C-S3-1 | Append blocked before `startup_verify!` with `audit.surface.startup_not_verified` | PASS |
| C-S3-2 | Clean rebuild unblocks append | PASS |
| C-S3-3 | Failed rebuild leaves surface locked | PASS |
| C-S3-4 | `startup_verified` in status transitions false → true | PASS |

### Surface 4 — Appender/reader role wiring (4/4 PASS)

| Case | Description | Result |
|------|-------------|--------|
| C-S4-1 | Appender role can append | PASS |
| C-S4-2 | Reader role can traverse | PASS |
| C-S4-3 | Records appended by appender visible to reader | PASS |
| C-S4-4 | Config declares both `phase1_audit_appender` and `phase1_audit_reader` roles | PASS |

### Surface 5 — Refusal code export (3/3 PASS)

| Case | Description | Result |
|------|-------------|--------|
| C-S5-1 | All 12 B-E §8 required codes present in manifest | PASS |
| C-S5-2 | All 24 codes in manifest are strings | PASS |
| C-S5-3 | Manifest carries `production_durable_audit: false`, `gate3_authorized: false`, `ledger: false` | PASS |

### Surface 6 — Rollback/disable procedure (4/4 PASS)

| Case | Description | Result |
|------|-------------|--------|
| C-S6-1 | `disable!` blocks append with `audit.surface.disabled` | PASS |
| C-S6-2 | `disable!` blocks traverse with `audit.surface.disabled` | PASS |
| C-S6-3 | `enable!` after `disable!` restores append | PASS |
| C-S6-4 | `disable!` captures reason and authorized_by metadata | PASS |

### Surface 7 — Post-deployment smoke proof (5/5 PASS)

| Case | Description | Result |
|------|-------------|--------|
| C-S7-1 | Append flow: 3 records appended cleanly | PASS |
| C-S7-2 | Reader traversal: 2 signed records returned | PASS |
| C-S7-3 | Rebuild after appends returns clean status | PASS |
| C-S7-4 | Blocked signer config refused at config time | PASS |
| C-S7-5 | End-to-end flow: startup verify → append → traverse → rebuild → disable → enable → append | PASS |

### Invariants (5/5 PASS)

| Invariant | Check | Result |
|-----------|-------|--------|
| INV-1 | `production_durable_audit: false` in all surface outputs | PASS |
| INV-2 | `gate3_authorized: false` in all surface outputs | PASS |
| INV-3 | `ledger: false` in all surface outputs | PASS |
| INV-4 | All 12 B-E §8 required refusal codes present in manifest | PASS |
| INV-5 | Manifest is proof-local (no deployment authorization claim) | PASS |

**Total: 30/30 PASS, 5/5 invariants PASS**

---

## Regression Table

| Command | Cases | Status after S3-R37-C2-I |
|---------|-------|--------------------------|
| `volatile_fields_lint` | — | PASS |
| `startup_freshness_override_proof` | 28 | PASS |
| `contract_modifiers_proof` | — | PASS |
| `production_durable_audit_compliance_posture_proof` | 14 | PASS |
| `production_durable_audit_signer_validation_proof` | 18 | PASS |
| `production_durable_audit_bounded_implementation_proof` | 29 | PASS |
| `durable_audit_restart_rebuild_proof` | 21 | PASS |
| `durable_audit_reader_traversal_proof` | 26 | PASS |
| `durable_audit_append_reader_role_boundary_proof` | 21 | PASS |

**9/9 commands PASS**

---

## Refusal Codes

### B-E §8 Required Codes (12)

| Code | Meaning |
|------|---------|
| `audit.record.format_version_missing` | Record missing format_version field |
| `audit.record.format_version_unrecognized` | format_version not "1.0.0" |
| `audit.record.kind_unrecognized` | kind not "phase1_production_audit_record" |
| `audit.chain.sequence_gap` | Sequence number gap detected |
| `audit.record.storage_identity_mismatch` | storage_identity inconsistent across records |
| `audit.chain.previous_hash_mismatch` | prev_hash does not match prior record hash |
| `audit.chain.record_hash_mismatch` | Stored record_hash ≠ re-derived hash |
| `audit.record.compliance_posture_mismatch` | Stored posture ≠ re-derived posture |
| `audit.writer.unauthorized` | Mutating operation refused by reader role |
| `audit.reader.unauthorized` | Read operation refused by writer role |
| `audit.writer.rebuild_not_clean` | Append refused when rebuild_status ≠ "clean" |
| `audit.signer.configuration_invalid` | Signer config rejected at record sign time |

### Deployment Surface Codes (12)

| Code | Meaning |
|------|---------|
| `audit.deploy.storage_identity_missing` | storage_identity not provided |
| `audit.deploy.storage_identity_kind_missing` | storage_identity.kind absent |
| `audit.deploy.storage_identity_untrusted` | kind is ledger/local/stub/test or ledger_binding: true |
| `audit.deploy.storage_identity_id_missing` | storage_identity.storage_id absent or empty |
| `audit.deploy.signer_config_missing` | signer_config not provided |
| `audit.deploy.signer_key_id_missing` | key_id absent or nil |
| `audit.deploy.signer_key_id_blocked` | key_id contains noop/no-op/stub/local/test pattern |
| `audit.deploy.signer_verification_metadata_missing` | verification_metadata absent |
| `audit.deploy.signer_public_key_source_missing` | public_key_source absent |
| `audit.deploy.signer_public_key_source_blocked` | source contains stub/local/test/noop/no-op pattern |
| `audit.surface.startup_not_verified` | Operation refused because startup_verify! has not passed |
| `audit.surface.disabled` | Surface has been disabled via disable! |

---

## Non-Authorizations

The following surfaces remain closed and were not opened by this implementation:

- Concrete HSM / KMS onboarding or production signing execution
- Ledger adapter
- Phase 2
- BiHistory integration
- Stream / OLAP executor
- Production cache
- Broad RuntimeMachine binding
- Gate 3 authorization widening
- Production deployment beyond this bounded scope

---

## Artifacts

- `experiments/durable_audit_restricted_deployment_proof/durable_audit_restricted_deployment_proof.rb` — proof script
- `experiments/durable_audit_restricted_deployment_proof/out/durable_audit_restricted_deployment_proof_summary.json` — summary artifact
- `docs/tracks/durable-audit-restricted-deployment-implementation-v0.md` — this document

---

## Handoff

**[D]** Card S3-R37-C2-I is closed. All 7 required follow-ups from S3-R36-C1-A §7 are addressed in proof-local form. 30/30 cases PASS. 9/9 regression commands PASS. Proof-local flags (`production_durable_audit: false`, `gate3_authorized: false`, `ledger: false`) confirmed in all outputs and invariants.

**[S]** No blockers were introduced. The implementation is bounded to proof-local scope; no `lib/` or `.igapp` changes were made.

**[T]** The 7 follow-up surfaces are proof-complete but not operationally deployed. Moving from proof-local to operational deployment requires a separate Architect authorization (beyond the scope of this card).

**[R]** Regression table: 9/9 PASS (unchanged from B-D baseline).

**[Q]** None.

**[Next]** The next required step per S3-R36-C1-A is an Architect review of the 7 follow-up outputs before any operational rollout authorization is issued. Open items from prior rounds (P-43 production store rebuild gate, P-44 PROP-036+ → PROP-037+ updates) remain open and are not addressed by this card.
