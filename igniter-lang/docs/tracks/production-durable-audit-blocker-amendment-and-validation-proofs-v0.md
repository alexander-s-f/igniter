Card: S3-R28-C1-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/production-durable-audit-blocker-amendment-and-validation-proofs-v0
Status: done
Date: 2026-05-10

---

# Track: Production Durable Audit Blocker Amendment and Validation Proofs v0

## Purpose

Close C1-A Blockers 1, 2, and 3 from
`phase1-production-durable-audit-implementation-authorization-review-v0`
(S3-R27-C1-A) without implementing or authorizing production durable audit.

Blockers 4 and 5 were already closed by S3-R27-C2-P. This track closes
Blockers 1, 2, and 3, and closes Blocker 7 (design amendment recording these
requirements).

---

## Source Signals

- `docs/gates/phase1-production-durable-audit-implementation-authorization-review-v0.md`
  (S3-R27-C1-A) — Blockers 1-3 definitions
- `docs/tracks/phase1-production-durable-audit-v0.md` (S3-R26-C1-P) — base design
- `docs/discussions/durable-audit-authorization-and-prop031-pressure-v0.md`
  (S3-R27-X1-S) — Sharper Question answer: Blockers 1-2 require bounded proof
  fixtures; Blocker 3 closes by design amendment only
- `docs/tracks/stage3-round27-status-curation-v0.md` (S3-R27-C5-S) — R28 route

---

## Design Amendment: Blockers 1-3

This track formally amends `phase1-production-durable-audit-v0` with the
following implementation requirements. These are pre-authorization constraints —
they define what any future implementation track MUST satisfy before
`production_durable_audit: true` can be emitted or a production signer can be
instantiated.

---

### [D] Blocker 1 Amendment — compliance_posture.production_durable_audit is Store-Bound and Verification-Bound

**Requirement (closure signal from C1-A §1):**

```text
compliance_posture.production_durable_audit is store-bound and verification-bound.
Proof-local stores cannot emit or accept production_durable_audit: true.
Production stores cannot accept production_durable_audit: false for a successful
production append without an explicit refusal/error.
```

**Amendment — CompliancePostureEvaluator contract:**

`production_durable_audit: true` is emitted if and only if ALL of the following hold:

1. `storage_identity` is non-nil
2. `storage_identity["kind"]` ∈ `["phase1_production_audit_store"]`
3. `storage_identity["ledger_binding"] != true`
4. `chain_verified == true` (hash continuity and record_hash recomputation passed)
5. `signature_verified == true` (signature_value verified against trusted key)

`production_durable_audit: false` is the mandatory result for:

| Scenario | Reason |
|----------|--------|
| `storage_identity.kind` ∈ proof-local kinds | `proof_local_file`, `proof_local_jsonl`, `proof_local_memory` are not production stores |
| `storage_identity.kind` unknown/test | Not in accepted production set |
| `storage_identity.ledger_binding == true` | Ledger-bound stores are out of scope for Phase 1 audit |
| `storage_identity.nil?` | Missing identity cannot be verified |
| `chain_verified == false` | Chain integrity not established |
| `signature_verified == false` | Signature integrity not established |

**Caller cannot inject:** The evaluator is the sole source of the boolean.
Any caller-provided value is ignored. A record-building API MUST derive
`production_durable_audit` from the evaluator, not from caller input.

**Successful append constraint:** A successful production append (production
storage kind + chain verification passed + signature verification passed) MUST
evaluate to `production_durable_audit: true`. Emitting `false` for a successful
production append is a constraint violation.

---

### [D] Blocker 2 Amendment — Production Signer Injection Rejects Nil/No-Op/Stub Signers

**Requirement (closure signal from C1-A §2):**

```text
production signer configuration rejects nil/no-op/stub/local-test signers and
requires a trusted signing_key_id, signing_key_version, signing_authority_ref,
and verification metadata source.
```

**Amendment — ProductionSignerValidator contract:**

A production signer configuration is valid if and only if ALL of the following
fields are present, non-empty, and non-blocked:

| Field | Required | Rejection on nil | Blocked patterns |
|-------|----------|-----------------|-----------------|
| `signing_key_id` | ✅ | `audit.signer.missing_key_id` | See key_id blocked list |
| `signing_key_version` | ✅ | `audit.signer.missing_key_version` | nil or empty |
| `signing_authority_ref` | ✅ | `audit.signer.missing_authority_ref` | See authority blocked list |
| `verification_metadata` | ✅ | `audit.signer.missing_verification_metadata` | nil, empty, or stub source |

**Blocked `signing_key_id` patterns** (downcased comparison):

```text
Exact match: local, test, stub, noop, no-op, dev, development
Prefix match: local-test, stub-, test-, noop-, no-op-, dev-
```

**Blocked `signing_authority_ref` patterns** (downcased comparison):

```text
Exact match: test, stub, local
Prefix match: test-, stub-, local-
```

**Blocked `verification_metadata.public_key_source` patterns** (downcased, substring):

```text
Contains: stub, local, test
```

All rejections carry a machine-readable reason code beginning with `audit.signer.`.

A valid production signer must identify a real key management source (e.g., a
KMS ARN, HSM certificate identifier, or equivalent managed signing identity)
that is resolvable through a trusted verification metadata source.

---

### [D] Blocker 3 Amendment — startup_time Registry Freshness Maximum Staleness Bound

**Requirement (closure signal from C1-A §3):**

```text
startup_time registry index freshness has a maximum staleness bound and fails
closed when the bundled/generated index is older than that bound or lacks a
valid immutable anchor.
```

**Amendment — Maximum staleness bound and fail-closed rule:**

- **Maximum staleness bound:** 24 hours (86,400 seconds from index `generated_at`
  timestamp, measured at process startup).
- **Fail-closed rule:** If the bundled or generated registry index is older than
  24 hours at the time of the startup freshness check, the process MUST:
  1. Refuse to serve as a production gate authority
  2. Emit error code `audit.registry.startup_time_staleness_exceeded` with the
     measured age and the 24-hour bound
  3. Fail startup with a non-zero exit code or equivalent error

- **Missing or invalid immutable anchor:** If the index lacks a verifiable
  `generated_at` field, a content-addressed immutable anchor, or a valid
  `format_version`, the process MUST fail closed with
  `audit.registry.startup_time_anchor_invalid`.

- **This does NOT authorize per-invocation online lookup.** The startup freshness
  check is a one-time guard at process initialization, not a per-read freshness
  check. Per-invocation online lookup is separately gated and not authorized by
  this amendment.

**Closes Blocker 3 by design amendment alone.** No proof fixture is required
(this is a policy statement, not a validation interface contract).

---

## Shipped

- `experiments/production_durable_audit_compliance_posture_proof/production_durable_audit_compliance_posture_proof.rb`
  — CompliancePostureEvaluator + 14-check proof harness (Blocker 1)
- `experiments/production_durable_audit_compliance_posture_proof/out/production_durable_audit_compliance_posture_proof_summary.json`
  — Proof artifact
- `experiments/production_durable_audit_signer_validation_proof/production_durable_audit_signer_validation_proof.rb`
  — ProductionSignerValidator + 18-check proof harness (Blocker 2)
- `experiments/production_durable_audit_signer_validation_proof/out/production_durable_audit_signer_validation_proof_summary.json`
  — Proof artifact
- This track document (design amendment for Blockers 1-3)

---

## Proof Results

**Compliance posture store-binding (14/14 PASS):**

```bash
ruby igniter-lang/experiments/production_durable_audit_compliance_posture_proof/production_durable_audit_compliance_posture_proof.rb
# PASS production_durable_audit_compliance_posture_proof
#   posture.proof_local_file_kind_blocked: ok
#   posture.proof_local_jsonl_kind_blocked: ok
#   posture.proof_local_memory_kind_blocked: ok
#   posture.nil_storage_identity_blocked: ok
#   posture.unknown_kind_blocked: ok
#   posture.test_store_kind_blocked: ok
#   posture.ledger_binding_true_blocked: ok
#   posture.chain_unverified_blocked: ok
#   posture.signature_unverified_blocked: ok
#   posture.both_verifications_failed_blocked: ok
#   posture.production_kind_all_verified_emits_true: ok
#   posture.caller_true_claim_ignored_for_proof_local: ok
#   posture.caller_false_claim_ignored_for_verified_production: ok
#   posture.successful_production_append_cannot_emit_false: ok
# 14/14 PASS
```

**Signer validation (18/18 PASS):**

```bash
ruby igniter-lang/experiments/production_durable_audit_signer_validation_proof/production_durable_audit_signer_validation_proof.rb
# PASS production_durable_audit_signer_validation_proof
#   signer.nil_signer_rejected: ok
#   signer.nil_signing_key_id_rejected: ok
#   signer.empty_signing_key_id_rejected: ok
#   signer.local_test_key_id_rejected: ok
#   signer.stub_key_id_rejected: ok
#   signer.test_prefix_key_id_rejected: ok
#   signer.no_op_key_id_rejected: ok
#   signer.nil_signing_key_version_rejected: ok
#   signer.empty_signing_key_version_rejected: ok
#   signer.nil_signing_authority_ref_rejected: ok
#   signer.test_signing_authority_ref_rejected: ok
#   signer.local_signing_authority_ref_rejected: ok
#   signer.nil_verification_metadata_rejected: ok
#   signer.empty_verification_metadata_rejected: ok
#   signer.stub_public_key_source_rejected: ok
#   signer.local_public_key_source_rejected: ok
#   signer.valid_production_signer_accepted: ok
#   signer.rejection_carries_reason_code: ok
# 18/18 PASS
```

**Volatile fields lint (still passing after new artifacts):**

```bash
ruby igniter-lang/experiments/volatile_fields_lint/volatile_fields_lint.rb
# volatile_fields_lint: PASS (4 artifact(s) with _volatile_fields — no violations)
```

---

## Blocker Closure Status (cumulative through S3-R28-C1-P)

| C1-A Blocker | Description | Status |
|--------------|-------------|--------|
| Blocker 1 | `compliance_posture.production_durable_audit` store-bound and verification-bound | ✅ CLOSED — design amendment + `production_durable_audit_compliance_posture_proof` 14/14 PASS |
| Blocker 2 | Production signer injection rejects nil/no-op/stub signers | ✅ CLOSED — design amendment + `production_durable_audit_signer_validation_proof` 18/18 PASS |
| Blocker 3 | `startup_time` registry freshness max staleness bound + fail-closed | ✅ CLOSED — design amendment (24h bound, `audit.registry.startup_time_staleness_exceeded`, fail-closed rule) |
| Blocker 4 | `_volatile_fields` lint rejects status/checks/verdict | ✅ CLOSED — S3-R27-C2-P |
| Blocker 5 | Full artifact stability survey | ✅ CLOSED — S3-R27-C2-P |
| Blocker 6 | Post-R27 full regression matrix rerun | ⏳ open — separate track |
| Blocker 7 | Design amendment recording Blockers 1-3 requirements | ✅ CLOSED — this track |
| Blocker 8 | Updated pressure review confirming blocker package closed | ⏳ open — requires subsequent pressure review after R28 lands |

**After this track: Blockers 1, 2, 3, 4, 5, 7 are closed. Blockers 6 and 8 remain open.**

---

## What This Proves / What It Does Not Prove

### Proved

- `compliance_posture.production_durable_audit: true` requires production-kind
  storage identity + non-ledger binding + chain verification + signature
  verification. All blocking combinations correctly evaluate to `false`.
- Proof-local store kinds cannot emit `production_durable_audit: true` even with
  `chain_verified: true` and `signature_verified: true`.
- A caller-supplied `production_durable_audit` value is ignored; the evaluator
  is the sole source.
- A successful production append cannot evaluate to `false`.
- A production signer configuration with nil, empty, stub, local-test, or no-op
  key identity fields is rejected with a machine-readable reason code.
- A validly configured production signer (KMS ARN key_id, non-stub authority_ref,
  trusted verification_metadata) is accepted.
- The `startup_time` freshness policy is defined: 24h max staleness, fail-closed,
  error code defined.

### Not Proved / Not Claimed

- No production durable audit storage is implemented.
- No production signing key is issued or used.
- No HSM/KMS provider is selected or configured.
- No production deployment is authorized.
- The evaluator and validator are proof-local implementations only — they define
  the required interface contract for any future implementation.

---

## Non-Authorization

This track does not authorize:

- Production durable audit implementation
- Production deployment
- Production signing execution or key management
- Selecting or onboarding a concrete HSM/KMS provider
- Registry implementation or RuntimeMachine binding
- Ledger adapter or package binding
- Phase 2
- BiHistory, stream, OLAP, production cache
- Write, Ledger replay, compact, subscribe
- Broadening `gate3_authorized: true`

---

## Handoff

```text
Card: S3-R28-C1-P
Agent: [Igniter-Lang Implementation Agent]
Role: implementation-agent
Track: igniter-lang/production-durable-audit-blocker-amendment-and-validation-proofs-v0
Status: done

[D] Decisions
- Blocker 1 (compliance_posture store-binding): evaluator contract defined;
  proof-local kinds → false; unknown kinds → false; ledger_binding: true → false;
  chain/sig unverified → false; production kind + all verified → true;
  caller cannot inject; successful production append cannot emit false
- Blocker 2 (signer no-op rejection): validator contract defined; blocked key_id
  patterns (local/test/stub/noop/no-op/dev exact + prefix); blocked authority_ref
  patterns; blocked public_key_source substrings (stub/local/test); valid KMS ARN
  signer accepted; all rejections carry reason code
- Blocker 3 (startup_time freshness): 24h max staleness bound; fail-closed;
  error code audit.registry.startup_time_staleness_exceeded; design amendment only

[S] Shipped
- experiments/production_durable_audit_compliance_posture_proof/
  production_durable_audit_compliance_posture_proof.rb (14 checks)
- experiments/production_durable_audit_signer_validation_proof/
  production_durable_audit_signer_validation_proof.rb (18 checks)
- docs/tracks/production-durable-audit-blocker-amendment-and-validation-proofs-v0.md (this doc)

[T] Tests / Proofs
- command: ruby igniter-lang/experiments/production_durable_audit_compliance_posture_proof/production_durable_audit_compliance_posture_proof.rb
- result: PASS (14/14)
- command: ruby igniter-lang/experiments/production_durable_audit_signer_validation_proof/production_durable_audit_signer_validation_proof.rb
- result: PASS (18/18)
- command: ruby igniter-lang/experiments/volatile_fields_lint/volatile_fields_lint.rb
- result: PASS (4 artifacts, 0 violations)

[R] Risks
- Evaluator and validator are proof-local interface contracts only; a future
  implementation must match these contracts or re-prove them with a conformance test
- Blocked patterns for key_id/authority_ref/public_key_source are defined by
  this track; any production implementation must either import or satisfy them
- 24h freshness bound for startup_time is a design choice; operator requirements
  may require adjustment in the implementation track (update design amendment)

[Blockers closed by this track]
- C1-A Blocker 1: CLOSED
- C1-A Blocker 2: CLOSED
- C1-A Blocker 3: CLOSED
- C1-A Blocker 7: CLOSED (this amendment)

[Still open]
- C1-A Blocker 6: post-R28 full regression matrix rerun
- C1-A Blocker 8: updated pressure review confirming all 7 design blockers closed
  (requires subsequent pressure review after R28 lands)

[Next] Suggested next slice
- Post-R28 full regression matrix rerun (closes Blocker 6; add both new proofs
  to matrix; volatile_fields_lint as first step)
- Updated pressure review (closes Blocker 8; routes implementation authorization
  request to Architect if no new scope widening found)
- PROP-031 implementation card (parser/classifier/typechecker/SemanticIR emitter;
  resolve OOF-M1 stage ambiguity and contract_name field name before goldens lock)
```
