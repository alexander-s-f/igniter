# Track: Phase 1 Durable Audit Operational Rollout Readiness Plan v0

Card: S3-R39-C2-P1
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `phase1-durable-audit-operational-rollout-readiness-plan-v0`
Status: done
Date: 2026-05-12

---

## Goal

Draft the design-only operational rollout readiness plan authorized by
`S3-R38-C1-A`.

This plan is not an implementation card and not an operational rollout
authorization.

Read set:

```text
docs/gates/durable-audit-restricted-deployment-proof-review-v0.md
docs/tracks/durable-audit-restricted-deployment-implementation-v0.md
docs/gates/durable-audit-b-e-deployment-review-decision-v0.md
docs/tracks/stage3-round38-status-curation-v0.md
```

---

## Boundary

Allowed here:

```text
design-only readiness plan
operator-facing checklist
selection criteria
runbook outline
blocker list
smoke checklist
```

Not authorized here:

```text
code implementation
production deployment
real storage provisioning
concrete HSM/KMS onboarding
Ledger adapter
Phase 2
BiHistory
stream/OLAP production executor
production cache
broad RuntimeMachine binding
TBackend binding
.igapp / .ilk changes
```

Safe status phrase:

```text
Operational rollout remains closed. This plan identifies the evidence required
before a later Architect review can consider rollout authorization.
```

---

## Readiness Plan Matrix

| Area | Readiness requirement | Required evidence before rollout review | Refusal / hold condition |
| --- | --- | --- | --- |
| Storage identity | Dedicated Phase 1 audit storage identity; explicit, stable, non-Ledger, audit-specific | `storage_kind`, `storage_id`, owner, retention boundary, append-only posture, isolation from runtime/TBackend/Ledger stores | Missing `storage_id`; Ledger/local/stub/test identity; shared general-purpose store |
| Signer abstraction | Deployment contract for signer abstraction; rejects nil/noop/stub/local/test identities | `key_id`, `public_key_source`, `verification_metadata`, signer owner, rotation policy placeholder, refusal behavior | Concrete HSM/KMS onboarding attempted in this slice; nil/noop/stub/local/test signer accepted |
| Startup rebuild | Startup blocks append/traverse until rebuild or fresh verify passes | Ordered startup sequence, expected rebuild inputs, clean/fail criteria, first-failure cursor handling, no auto-repair rule | Append opens before clean rebuild; rebuild mutates/truncates/repairs records |
| Appender role | `phase1_audit_appender` may append canonical records only after clean startup | Role owner, operation list, refusal paths, append metadata allowed to caller | Appender can read broadly, mutate, overwrite, delete, replay, compact, subscribe |
| Reader role | `phase1_audit_reader` may traverse verified append-only chain and report failures | Role owner, allowed filters, verified export shape, posture re-derivation requirement | Reader can append, sign, authorize Gate 3, query Ledger/runtime stores, or become analytics engine |
| Observability | Stable refusal-code export and operational signals | Export sink, code list, retention, alert owner, dashboard/report location, evidence that existing codes are not collapsed | Missing code; collapsed generic errors; production flags inferred from proof-local artifact |
| Disable / rollback | Operator-run disable/enable procedure with captured metadata | Authorized operator list, required reason, timestamp, enable criteria, audit trail for disable/enable | Disable bypasses audit trail; enable happens without authority/reason; data repair attempted |
| Smoke checklist | Append/traverse/rebuild/refusal/disable/enable checks before rollout | Dry-run checklist results from target-like environment, with excluded-surface assertions | Any smoke path fails; excluded surface becomes reachable |
| Ownership | Named operational owners for storage, signer abstraction, appender, reader, observability, rollback | Ownership table and escalation path | Any owner missing or shared with unauthorized Ledger/Runtime role |
| Failure drills | Drill notes for rebuild fail, signer invalid, storage identity mismatch, disabled surface, posture mismatch | Operator drill log and expected refusal codes | Drill cannot reproduce reason-coded refusal or safe hold state |

---

## Storage Identity Selection Criteria

Production audit storage identity must be:

```text
explicit
stable
audit-specific
non-Ledger
not reused by runtime/TBackend/general persistence
append-only by operational policy
configured before surface construction
verifiable during startup rebuild and reader traversal
```

Minimum descriptor:

```text
storage_identity:
  kind: phase1_audit_storage
  storage_id: <stable audit-specific id>
  owner: <operations owner/team>
  environment: <target environment>
  ledger_binding: false
  runtime_store_binding: false
  append_only_policy_ref: <policy/reference>
  retention_policy_ref: <policy/reference>
```

Selection refusals:

```text
audit.deploy.storage_identity_missing
audit.deploy.storage_identity_kind_missing
audit.deploy.storage_identity_untrusted
audit.deploy.storage_identity_id_missing
audit.record.storage_identity_mismatch
```

Operational note:

```text
The storage identity may be production-shaped, but actual provisioning and
operational rollout need a later Architect decision.
```

---

## Signer Abstraction Deployment Contract

Signer abstraction must be configured as an abstract verification/signing
boundary, still without concrete HSM/KMS onboarding.

Minimum descriptor:

```text
signer_config:
  key_id: <non-empty non-test key reference>
  public_key_source: <non-local non-stub verification source>
  verification_metadata:
    algorithm: <algorithm id>
    key_version: <version/ref>
    owner: <signing owner/team>
    rotation_policy_ref: <policy/reference>
  concrete_provider: not_selected_in_this_plan
```

Required refusal behavior:

```text
audit.deploy.signer_config_missing
audit.deploy.signer_key_id_missing
audit.deploy.signer_key_id_blocked
audit.deploy.signer_verification_metadata_missing
audit.deploy.signer_public_key_source_missing
audit.deploy.signer_public_key_source_blocked
audit.signer.configuration_invalid
```

Contract rule:

```text
The rollout readiness package may specify the signer abstraction contract and
validation expectations. It must not select, onboard, configure, or test a
concrete HSM/KMS provider.
```

---

## Startup / Rebuild Operational Sequence

Required sequence:

1. Load deployment configuration.
2. Validate storage identity descriptor.
3. Validate signer abstraction descriptor.
4. Construct audit surface in locked state.
5. Run startup rebuild or verify a fresh rebuild result.
6. Full-scan records and collect errors.
7. Re-derive hash chain, signatures, storage identity, and compliance posture.
8. Set cursor to first failure point when any failure exists.
9. Keep append/traverse closed unless rebuild status is `clean`.
10. Export startup status and refusal codes.
11. Only after clean startup, enable appender and reader roles.

Required invariants:

```text
append before startup verify -> audit.surface.startup_not_verified
traverse before startup verify -> audit.surface.startup_not_verified
failed rebuild leaves surface locked
rebuild never auto-repairs, truncates, compacts, overwrites, or deletes records
append refuses when last rebuild status is not clean
```

Required refusal:

```text
audit.writer.rebuild_not_clean
```

---

## Appender / Reader Role Mapping

### Appender

Role:

```text
phase1_audit_appender
```

May:

```text
append canonical Phase 1 audit records
receive append result metadata
receive reason-coded refusal
```

Must not:

```text
read full chain
mutate existing records
overwrite
delete
replay
compact
subscribe
bypass signer/storage/rebuild gates
```

### Reader

Role:

```text
phase1_audit_reader
```

May:

```text
traverse append-only chain
filter verified records by approved dimensions
report integrity failures
re-derive compliance posture for returned records
exclude mismatched records from verified export
```

Must not:

```text
append
mutate
delete
sign
authorize Gate 3
query Ledger/runtime stores
act as broad OLAP/analytics/subscription surface
```

Role refusals:

```text
audit.writer.unauthorized
audit.reader.unauthorized
audit.writer.rebuild_not_clean
audit.surface.startup_not_verified
audit.surface.disabled
```

---

## Refusal-Code And Observability Export Plan

Export all required codes as stable machine-readable signals.

Required B-E codes:

```text
audit.record.format_version_missing
audit.record.format_version_unrecognized
audit.record.kind_unrecognized
audit.chain.sequence_gap
audit.record.storage_identity_mismatch
audit.chain.previous_hash_mismatch
audit.chain.record_hash_mismatch
audit.record.compliance_posture_mismatch
audit.writer.unauthorized
audit.reader.unauthorized
audit.writer.rebuild_not_clean
audit.signer.configuration_invalid
```

Required deployment-surface codes:

```text
audit.deploy.storage_identity_missing
audit.deploy.storage_identity_kind_missing
audit.deploy.storage_identity_untrusted
audit.deploy.storage_identity_id_missing
audit.deploy.signer_config_missing
audit.deploy.signer_key_id_missing
audit.deploy.signer_key_id_blocked
audit.deploy.signer_verification_metadata_missing
audit.deploy.signer_public_key_source_missing
audit.deploy.signer_public_key_source_blocked
audit.surface.startup_not_verified
audit.surface.disabled
```

Export requirements:

```text
stable code
severity
surface
role
storage_id when available
sequence/cursor when available
first_failure_cursor when rebuild fails
operator action required
timestamp
correlation_id
```

Retention plan must be named before rollout review. The plan may be a policy
reference; it must not create a new broad analytics/query surface.

---

## Disable / Rollback Runbook

Disable is the only approved rollback shape for this bounded surface.

Disable sequence:

1. Authorized operator invokes disable with reason.
2. Surface records `disabled: true`, `reason`, `authorized_by`, timestamp.
3. Append refuses with `audit.surface.disabled`.
4. Traverse refuses with `audit.surface.disabled`.
5. Observability export records disabled state.
6. No record repair, truncation, compaction, overwrite, or deletion is performed.

Enable sequence:

1. Authorized operator verifies disable reason is resolved.
2. Startup rebuild/verify is rerun or confirmed fresh.
3. Enable records `authorized_by`, timestamp, and reason/resolution.
4. Append/traverse resume only if rebuild status is clean.

Rollback rule:

```text
Rollback means disabling the audit surface and preserving records as-is. It does
not mean deleting, compacting, replaying, repairing, or migrating records.
```

---

## Smoke Checklist

Run before any rollout review in a target-like environment.

| Smoke path | Expected result |
| --- | --- |
| Config accepts valid non-Ledger storage identity | accepted |
| Config refuses Ledger storage identity | `audit.deploy.storage_identity_untrusted` |
| Config refuses missing storage id | `audit.deploy.storage_identity_id_missing` |
| Config accepts valid signer abstraction descriptor | accepted |
| Config refuses nil/noop/stub/local/test signer identity | relevant `audit.deploy.signer.*` refusal |
| Append before startup verify | `audit.surface.startup_not_verified` |
| Traverse before startup verify | `audit.surface.startup_not_verified` |
| Clean startup rebuild | appender/reader may open |
| Failed startup rebuild | surface remains locked |
| Append after clean rebuild | canonical record appended |
| Reader traverse after append | verified record visible |
| Storage identity mismatch | `audit.record.storage_identity_mismatch` |
| Hash mismatch | `audit.chain.record_hash_mismatch` or previous hash code |
| Compliance posture mismatch | `audit.record.compliance_posture_mismatch` |
| Append when rebuild not clean | `audit.writer.rebuild_not_clean` |
| Reader attempts append | `audit.writer.unauthorized` |
| Appender attempts traverse | `audit.reader.unauthorized` |
| Disable surface | append/traverse refuse with `audit.surface.disabled` |
| Enable after disable with clean rebuild | append/traverse restored |
| Excluded Ledger/Phase2/BiHistory/stream/OLAP/cache/RuntimeMachine paths | unreachable / refused |

---

## Operator Ownership

Minimum ownership table before rollout review:

| Surface | Required owner |
| --- | --- |
| Storage identity | Audit storage owner |
| Signer abstraction contract | Signing owner |
| Startup rebuild | Runtime operations owner for audit surface only |
| Appender role | Audit write owner |
| Reader role | Audit read owner |
| Observability/refusal export | Observability owner |
| Disable/enable authority | Incident commander or designated audit operator |
| Failure drills | Reliability/operations owner |
| Architect review packet | Supervisor / release owner |

No owner may use this plan to bind Ledger, broad RuntimeMachine, Phase 2,
BiHistory, stream/OLAP, production cache, concrete HSM/KMS onboarding, or
TBackend surfaces.

---

## Failure-Drill Notes

Required drills before rollout authorization:

| Drill | Expected safe state |
| --- | --- |
| Signer config invalid | surface not constructed or refuses with signer config code |
| Storage identity mismatch | rebuild/traverse reports mismatch; verified export excludes bad record |
| Rebuild failure | append/traverse remain locked; first failure cursor exported |
| Compliance posture mismatch | mismatch code exported; no auto-repair |
| Reader attempts write | writer unauthorized refusal |
| Appender attempts broad read | reader unauthorized refusal |
| Disable during normal operation | append/traverse refuse; records preserved |
| Enable after disable | clean rebuild/verify required before reopening |

Drills must record:

```text
operator
timestamp
environment
input condition
expected refusal code
observed refusal code
safe-state confirmation
excluded-surface confirmation
```

---

## Exact Blockers Before Implementation Or Rollout Authorization

### Blockers Before Any Operational Implementation Card

1. Architect must approve a bounded operational implementation card that cites
   this readiness plan.
2. Storage identity descriptor shape must be reviewed and confirmed non-Ledger.
3. Signer abstraction descriptor shape must be reviewed with no concrete HSM/KMS
   provider onboarding.
4. Appender/reader role owners must be named.
5. Observability export destination and retention policy reference must be named.
6. Disable/enable operator authority must be named.
7. Smoke checklist target environment must be named.
8. Excluded-surface assertion list must be included in the implementation card.

### Blockers Before Operational Rollout Authorization

1. Explicit, non-Ledger production audit storage identity selected and reviewed.
2. Signer abstraction deployment contract reviewed; nil/noop/stub/local/test
   identities refused.
3. Startup rebuild sequence dry-run completed with clean and failing cases.
4. Appender/reader role mapping tested with unauthorized role refusals.
5. All required refusal codes exported and retained in the named observability
   destination.
6. Disable/enable runbook drill completed; records preserved as-is.
7. Smoke checklist passed for append/traverse/rebuild/refusal/disable/enable.
8. Operator ownership table complete.
9. Failure drills complete with expected reason codes.
10. Independent pressure review confirms no hidden Ledger, Phase 2, BiHistory,
    stream/OLAP, cache, broad RuntimeMachine, concrete HSM/KMS, or TBackend
    widening.
11. Architect issues a separate rollout authorization decision.

---

## Handoff

```text
Card: S3-R39-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: phase1-durable-audit-operational-rollout-readiness-plan-v0
Status: done

[D] Decisions
- Drafted design-only operational rollout readiness plan.
- Operational rollout remains closed.
- Disable/enable is the only rollback shape; records must be preserved as-is.

[S] Signals
- R37 proof-local package provides the correct seven surface anchors.
- R38 confirms proof-local closure and authorizes this plan only.
- Next rollout consideration requires storage, signer abstraction, startup, role, observability, runbook, smoke, ownership, and drill evidence.

[T] Tests / Proofs
- No code or proof changes in this slice.
- Evidence read: R38 proof review, R37 implementation track, B-E deployment decision, R38 status curation.

[R] Risks / Recommendations
- Do not start operational implementation without a new Architect card.
- Do not treat signer abstraction as concrete HSM/KMS onboarding.
- Do not allow proof-local flags or artifacts to imply production deployment.

[Next]
- Architect review of this readiness plan before any operational implementation or rollout authorization.
```
