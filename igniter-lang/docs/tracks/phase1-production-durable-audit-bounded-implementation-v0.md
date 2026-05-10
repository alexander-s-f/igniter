# Track: Phase 1 Production Durable Audit — Bounded Implementation

Card: S3-R31-C1-P
Agent: `[Igniter-Lang Implementation Agent]`
Role: `implementation-agent`
Track: `phase1-production-durable-audit-bounded-implementation-v0`
Status: done
Date: 2026-05-10

---

## Purpose

Implement the bounded Phase 1 production durable audit proof authorized by
S3-R30-C1-A (`phase1-production-durable-audit-implementation-authorization-decision-v0`).

This is the first implementation card in the bounded implementation track. It
covers surfaces 1–4 of the 9-surface authorization scope: audit record schema
validation, signer abstraction contract proof, append-only store interface proof,
and excluded-surface regression guards.

Does **not** authorize production deployment, Ledger binding, HSM/KMS onboarding,
Phase 2, BiHistory, stream/OLAP, or any excluded surface listed in S3-R30-C1-A.

---

## Authorization

```text
architect-supervisor://igniter-lang/gates/phase1-production-durable-audit/bounded-implementation-v0/2026-05-10
```

Source: `igniter-lang/docs/gates/phase1-production-durable-audit-implementation-authorization-decision-v0.md`

---

## Source Design

- `igniter-lang/docs/tracks/phase1-production-durable-audit-v0.md`
  (R26 audit record schema, record_hash algorithm, compliance_posture model)
- `igniter-lang/docs/tracks/production-durable-audit-blocker-amendment-and-validation-proofs-v0.md`
  (R28 compliance posture + signer validation proofs)

---

## Scope

Proof-local only. No production audit writer, no real signing execution, no
production registry, no Ledger, no Phase 2, no online lookup, no HSM/KMS.

All classes (`Phase1ProductionAuditRecordSchema`, `SignerInterface`,
`ProofLocalSigner`, `Phase1ProductionAuditStore`) live entirely inside the
proof script. No `lib/` changes. `compliance_posture.production_durable_audit`
is `false` in all proof-local outputs.

---

## Implementation Decisions

### [D1] Four fields excluded from canonical record_hash

**Decision:** `compute_record_hash` sets the following fields to `null` in the
deep-copied record before computing the canonical SHA-256:

| Field | Reason |
|-------|--------|
| `chain.record_hash` | The field being computed; self-referential |
| `signature.signature_value` | Set after hash is known |
| `signature.signed_payload_hash` | Mirrors `record_hash`; also derived |
| `record_id` | Derived from `record_hash`; not an input |
| `compliance_posture` | Always re-derived; not an input to hash |

**Rationale:** `signed_payload_hash` and `compliance_posture` are both computed
after the record_hash is known and must be excluded from the canonical form.
`record_id` is derived from a slice of `record_hash`. `compliance_posture` is
always re-derived at validate time and must not participate in the hash to avoid
a chicken-and-egg circular dependency (compliance_posture depends on the fields
that determine the hash).

**Proof coverage:** `schema.valid_record_accepted` → accepted;
`store.chain_verification_valid` → verified; `schema.caller_compliance_posture_ignored`
→ injected posture value overwritten by derived value.

### [D2] `compliance_posture` is always derived; caller value is ignored

The `validate` method derives `compliance_posture` entirely from:
- `storage_identity` (not Ledger/local/stub, `ledger_binding: false`)
- `signature` (key_id and authority_ref not blocked)
- `chain.sequence` (>= 1)
- `authorization_ref` (from the module constant)

Any `compliance_posture` key present in the input record is silently replaced
by the derived value. The proof case `schema.caller_compliance_posture_ignored`
injects `production_durable_audit: true` and verifies the output is `false`
(because proof-local storage never qualifies).

### [D3] Proof-local storage identity never claims `production_durable_audit: true`

`derive_compliance_posture` checks whether `storage_identity.kind` starts with
`"proof_local_"`. If so, `production_durable_audit` is forced to `false`
regardless of other fields.

**Proof coverage:** `excluded.proof_local_audit_never_claims_production` →
`production_durable_audit: false` in all proof outputs.

### [D4] `format_version: "0.1.0"` is explicitly refused

The startup freshness policy format (`0.1.0`) is a different document kind.
Production audit records require `format_version: "1.0.0"`. The proof case
`schema.format_version_unrecognized_refused` verifies `0.1.0` → refused with
`audit.record.format_version_unrecognized`.

---

## Proof Matrix (29/29 PASS)

```
ruby igniter-lang/experiments/production_durable_audit_bounded_implementation_proof/production_durable_audit_bounded_implementation_proof.rb
```

### Surface 1: Schema validation + format_version enforcement (12 cases)

| # | Case | Decision | Code |
|---|------|----------|------|
| 1 | `schema.valid_record_accepted` | accepted | — |
| 2 | `schema.format_version_missing_refused` | refused | `audit.record.format_version_missing` |
| 3 | `schema.format_version_unrecognized_refused` | refused | `audit.record.format_version_unrecognized` |
| 4 | `schema.kind_wrong_refused` | refused | `audit.record.kind_unrecognized` |
| 5 | `schema.sequence_zero_refused` | refused | `audit.record.sequence_invalid` |
| 6 | `schema.sequence_not_integer_refused` | refused | `audit.record.sequence_invalid` |
| 7 | `schema.previous_hash_invalid_refused` | refused | `audit.record.previous_hash_invalid` |
| 8 | `schema.record_hash_mismatch_refused` | refused | `audit.record.record_hash_mismatch` |
| 9 | `schema.ledger_storage_refused` | refused | `audit.record.storage_identity_untrusted` |
| 10 | `schema.ledger_binding_true_refused` | refused | `audit.record.storage_identity_untrusted` |
| 11 | `schema.stub_signature_signer_refused_at_store` | refused at store | `audit.store.signer_invalid` |
| 12 | `schema.caller_compliance_posture_ignored` | injected value overwritten **[D2]** | `production_durable_audit: false` |

### Surface 2: Signer abstraction contract (4 cases)

| # | Case | Decision | Code |
|---|------|----------|------|
| 13 | `signer.interface_conformance` | all required methods present | — |
| 14 | `signer.valid_config_accepted` | valid proof-local signer accepted | — |
| 15 | `signer.nil_key_id_refused` | nil key_id refused | `audit.signer.configuration_invalid` |
| 16 | `signer.stub_public_key_source_refused` | stub public_key_source refused | `audit.signer.configuration_invalid` |

### Surface 3: Append-only store interface (8 cases)

| # | Case | Decision | Code |
|---|------|----------|------|
| 17 | `store.first_record_genesis_prev_hash` | genesis previous_hash on first append | — |
| 18 | `store.second_record_chains_from_first` | second record chains from first | — |
| 19 | `store.chain_verification_valid` | full chain verified after 2 appends | — |
| 20 | `store.update_refused` | update refused | `audit.store.mutation_not_authorized` |
| 21 | `store.delete_refused` | delete refused | `audit.store.mutation_not_authorized` |
| 22 | `store.overwrite_refused` | overwrite refused | `audit.store.mutation_not_authorized` |
| 23 | `store.out_of_sequence_refused` | forced sequence refused | `audit.store.sequence_invalid` |
| 24 | `store.ledger_storage_identity_refused` | Ledger storage_identity refused at init | `audit.store.storage_identity_untrusted` |

### Surface 4: Excluded-surface regression (5 cases)

| # | Case | Result |
|---|------|--------|
| 25 | `excluded.no_ledger_adapter` | No Ledger constant or adapter in proof scope |
| 26 | `excluded.ledger_binding_false_in_all_records` | `ledger_binding: false` in all records |
| 27 | `excluded.no_phase2_surfaces` | No Phase 2 reference |
| 28 | `excluded.proof_local_audit_never_claims_production` | `production_durable_audit: false` in all outputs **[D3]** |
| 29 | `excluded.gate3_authorized_not_widened` | `gate3_authorized: false` everywhere |

### Cross-cutting invariant checks (5)

| Check | Result |
|-------|--------|
| `invariant.no_production_durable_audit_in_proof_local` | ok — all `false` |
| `invariant.no_ledger_access` | ok — no Ledger constant |
| `invariant.no_phase2_access` | ok — no Phase 2 reference |
| `invariant.no_hsm_kms_onboarding` | ok — proof-local signer only |
| `invariant.format_version_1_0_0_required` | ok — `0.1.0` refused |

**Total: 29/29 PASS, 5/5 invariant checks PASS.**

---

## Failure Codes Implemented

### Schema validation (`audit.record.*`)

| Code | Condition |
|------|-----------|
| `audit.record.format_version_missing` | `format_version` absent or nil |
| `audit.record.format_version_unrecognized` | `format_version` not in `["1.0.0"]` |
| `audit.record.kind_missing` | `kind` absent |
| `audit.record.kind_unrecognized` | `kind` ≠ `"phase1_production_audit_record"` |
| `audit.record.excluded_surfaces_incomplete` | `record_scope.excluded_surfaces` missing surfaces |
| `audit.record.storage_identity_untrusted` | `kind` is Ledger/local/stub or `ledger_binding: true` |
| `audit.record.sequence_invalid` | `chain.sequence` not Integer ≥ 1 |
| `audit.record.previous_hash_invalid` | `chain.previous_record_hash` not `"genesis"` or `"sha256:..."` |
| `audit.record.chain_inconsistency` | `previous_record_hash` ≠ expected from caller |
| `audit.record.record_hash_mismatch` | recomputed `record_hash` ≠ stored |
| `audit.record.signature_missing` | `signature` absent |
| `audit.record.signature_key_id_missing` | `signing_key_id` absent |
| `audit.record.signature_invalid` | `signing_key_id` matches blocked pattern |
| `audit.record.signature_authority_ref_missing` | `signing_authority_ref` absent |
| `audit.record.signature_authority_ref_untrusted` | `signing_authority_ref` blocked |

### Store (`audit.store.*`)

| Code | Condition |
|------|-----------|
| `audit.store.signer_interface_invalid` | Signer does not implement duck-type |
| `audit.store.signer_invalid` | `signer.valid?` returns false |
| `audit.store.audit_subject_invalid` | `audit_subject` not a non-empty Hash |
| `audit.store.record_validation_failed` | Schema validation refused |
| `audit.store.mutation_not_authorized` | `update`, `delete`, or `overwrite` called |
| `audit.store.sequence_invalid` | Forced sequence ≠ expected next |
| `audit.store.storage_identity_untrusted` | Ledger or local storage_identity at init |

### Signer (`audit.signer.*`)

| Code | Condition |
|------|-----------|
| `audit.signer.configuration_invalid` | Key_id nil/blocked or public_key_source blocked |

---

## Canonical Hash Algorithm

```
excluded fields (set to null before SHA-256):
  chain.record_hash
  signature.signature_value
  signature.signed_payload_hash
  record_id
  compliance_posture

canonical_json(record_with_nulled_fields)
  → all Hash keys sorted recursively
  → null values rendered as JSON null
  → no whitespace

record_hash = "sha256:" + SHA256.hexdigest(canonical_json)
```

---

## Validation Step Order (Schema)

```
1. format_version present and in ["1.0.0"]
2. kind present and == "phase1_production_audit_record"
3. record_scope.excluded_surfaces complete
4. storage_identity.kind not Ledger/local/stub; ledger_binding: false
5. chain.sequence: Integer >= 1
6. chain.previous_record_hash: "genesis" or "sha256:..."
7. chain consistency: previous_record_hash == caller's previous_record_hash (if provided)
8. chain.record_hash: recomputed == stored  [D1]
9. signature.signing_key_id: present, not blocked
10. signature.signing_authority_ref: present, not blocked
11. Derive compliance_posture from storage + signature + chain_seq  [D2][D3]
```

---

## Regression

| Proof | Result |
|-------|--------|
| `production_durable_audit_bounded_implementation_proof` | **29/29 PASS** (new) |
| `volatile_fields_lint` | PASS — 6 artifacts (was 5; new summary adds 1 valid `_volatile_fields`) |
| `startup_freshness_override_proof` | 28/28 PASS (unchanged) |
| `contract_modifiers_proof` | PASS (unchanged) |
| `production_durable_audit_compliance_posture_proof` | 14/14 PASS (unchanged) |
| `production_durable_audit_signer_validation_proof` | 18/18 PASS (unchanged) |

---

## Scope Boundaries

- No production durable audit writer created or modified in `lib/`.
- No production signing execution.
- No production registry implementation.
- No Ledger or Phase 2 access.
- No online lookup or per-invocation fetch.
- No HSM/KMS onboarding or real key issuance.
- All proof classes live entirely inside the proof script.
- `gate3_authorized: false` in all outputs.
- `production_durable_audit: false` in all proof-local outputs.

---

## Remaining Blockers Before Deployment Authorization

| Blocker | Surface | Required Before |
|---------|---------|----------------|
| B-A | Restart rebuild proof (S3-R30-C1-A surface 4) | Deployment authorization |
| B-B | Audit traversal / reader proof (S3-R30-C1-A surface 6) | Deployment authorization |
| B-C | Appender / reader role boundary proof (S3-R30-C1-A surface 7) | Deployment authorization |
| B-D | Post-implementation full regression matrix (all new proofs + existing 29 commands PASS) | Deployment authorization |
| B-E | Production deployment, HSM/KMS onboarding, production signing remain closed until S3-R30-C1-A follow-up Architect review | Any production deployment |

---

## Pre-Production Checklist

| Item | Status |
|------|--------|
| P-28: Architect production durable audit implementation authorization | ✅ **closed** — S3-R30-C1-A approved-bounded-implementation |
| P-29: startup_time override proof-local validator | ✅ **closed** — S3-R30-C2-P 28/28 PASS |
| P-31: Bounded implementation — schema + signer + store + excluded-surface proofs | ✅ **closed** — 29/29 PASS |

---

## Handoff

```text
Card: S3-R31-C1-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: phase1-production-durable-audit-bounded-implementation-v0
Status: done

[D] Decisions
- D1: Five fields excluded from canonical record_hash:
  chain.record_hash, signature.signature_value, signature.signed_payload_hash,
  record_id, compliance_posture. All are derived fields with circular dependency
  on the hash itself.
- D2: compliance_posture always derived at validate time; caller value silently
  overwritten. Proof-local storage forces production_durable_audit: false.
- D3: storage_identity.kind starts with "proof_local_" → production_durable_audit forced false.
- D4: format_version "0.1.0" (startup freshness policy format) explicitly refused;
  production audit records require "1.0.0".

[S] Shipped / Signals
- igniter-lang/experiments/production_durable_audit_bounded_implementation_proof/
    production_durable_audit_bounded_implementation_proof.rb
- igniter-lang/experiments/production_durable_audit_bounded_implementation_proof/
    out/production_durable_audit_bounded_implementation_proof_summary.json
- igniter-lang/docs/tracks/phase1-production-durable-audit-bounded-implementation-v0.md

[T] Tests / Proofs
- ruby igniter-lang/experiments/production_durable_audit_bounded_implementation_proof/
    production_durable_audit_bounded_implementation_proof.rb
  → PASS 29/29 cases, 5/5 invariant checks
- volatile_fields_lint → PASS 6 artifacts (was 5)
- startup_freshness_override_proof → 28/28 PASS (no regression)
- contract_modifiers_proof → PASS (no regression)
- compliance_posture_proof → 14/14 PASS (no regression)
- signer_validation_proof → 18/18 PASS (no regression)

[R] Risks / Recommendations
- D1 (canonical hash excluded fields): the set of excluded fields (especially
  compliance_posture and signed_payload_hash) was discovered during implementation,
  not specified in the R26 design. The Architect should review whether the canonical
  hash algorithm needs to be more explicitly specified in the design doc, or whether
  the current approach (null all derived fields) is the intended model.
- Proof-local signer (ProofLocalSigner) accepts any non-blocked signing_key_id and
  non-stub verification_metadata. In production this MUST verify against a real KMS
  or equivalent key management system.
- Proof-local store (Phase1ProductionAuditStore) uses in-memory storage. No durability.
  Production requires real append-only persistent storage.

[R Remaining blockers]
- B-A: Restart rebuild proof not yet implemented
- B-B: Audit traversal / reader proof not yet implemented
- B-C: Appender / reader role boundary proof not yet implemented
- B-D: Post-implementation full regression matrix not yet run
- B-E: Production deployment, HSM/KMS, and production signing remain closed

[Q] Open questions
- Q1: Should the R26 design spec be amended to document the canonical hash
  algorithm's excluded fields (D1)? Currently implicit.
- Q2: Is compliance_posture intended to be stored with the record (as in this
  implementation) or always re-derived at read time only? The current approach
  stores it but excludes it from the hash — consistent, but worth confirming.

[Next] Suggested next slice
- R31: Restart rebuild proof (B-A) — surface 4 of S3-R30-C1-A
- R31: Audit traversal / reader proof (B-B) — surface 6
- R31: Appender / reader role boundary proof (B-C) — surface 7
- R31: Post-implementation regression matrix (B-D) — surface 9
- R31: External Pressure Reviewer discussion (S3-R30-C1-A requirement before
  follow-up Architect review)
```
