# Track: Durable Audit Hash And Posture Design Amendment v0

Card: S3-R32-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: `research-agent`
Track: `durable-audit-hash-and-posture-design-amendment-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Purpose

Close P-37/P-38 before restart rebuild, audit traversal, audit reader, or role
boundary work continues.

This is design sync only. It does not implement code, does not authorize
production deployment, and does not widen Phase 1 durable audit scope.

---

## Inputs Read

- `phase1-production-durable-audit-bounded-implementation-v0.md`
- `phase1-production-durable-audit-v0.md`
- `r31-bounded-audit-and-governance-pressure-v0.md`

Onboarding reread for this slice:

- `AGENTS.md`
- `roles/README.md`
- `roles/research-agent.md`
- `docs/README.md`
- `docs/operating-model.md`
- `docs/current-status.md`

---

## Amendment Applied

Updated:

```text
igniter-lang/docs/tracks/phase1-production-durable-audit-v0.md
```

New section:

```text
R32 Hash/Posture Amendment
```

Also updated:

- production audit record schema notes;
- restart rebuild algorithm;
- audit traversal semantics;
- refusal/error code list.

---

## Decisions

### D1 — Canonical `record_hash` Excluded Fields

The canonical record hash excludes exactly five fields by setting them to JSON
`null` in a deep copy before canonicalization:

| Field | Exact reason excluded |
|-------|-----------------------|
| `chain.record_hash` | Self-referential field being computed. Including it would make the hash circular. |
| `signature.signature_value` | Produced after the hash is known and signed. Including it would require signing a value that does not exist yet. |
| `signature.signed_payload_hash` | Mirrors the canonical body hash / `record_hash`. Including it would create a derived-field loop and duplicate the value being proven. |
| `record_id` | Derived from `record_hash` / hash prefix. It is an address for the record, not an input to the hash. |
| `compliance_posture` | Derived from storage identity, signature/key trust, chain verification, and authorization context. It is stored as an auditor-visible snapshot but is never authoritative input to the hash. |

Canonical algorithm:

```text
record_for_hash = deep_copy(record)
record_for_hash.chain.record_hash = null
record_for_hash.signature.signature_value = null
record_for_hash.signature.signed_payload_hash = null
record_for_hash.record_id = null
record_for_hash.compliance_posture = null

canonical_json(record_for_hash)
  -> all Hash keys sorted recursively
  -> null values rendered as JSON null
  -> no whitespace

record_hash = "sha256:" + SHA256.hexdigest(canonical_json)
signature.signed_payload_hash = record_hash
record_id = "audit/phase1/" + record_hash prefix
```

Note: the R31 implementation track heading said "Four fields" but its D1 table
and handoff list five fields. This amendment treats the five-field table as the
actual implementation decision and removes the ambiguity for future work.

### D2 — `compliance_posture` Is Stored + Derived + Mismatch-Checked

Answer to the card's required question:

```text
compliance_posture is stored as an auditor-visible snapshot,
derived as the authoritative value,
and mismatch-checked by validators/readers/rebuild.
```

It is not:

- caller supplied;
- hash authoritative;
- trusted because it appears in persisted JSON;
- omitted from the record.

Rationale:

- Auditors need to see the posture asserted at append time.
- Hash/signature should not depend on a value whose truth depends on
  hash/signature/storage verification.
- Readers and rebuild must detect tampering or stale serialization by comparing
  stored posture to re-derived posture.

Production rules:

1. Appenders ignore caller-provided posture.
2. Appenders derive and store posture after enough validation evidence exists.
3. Readers/rebuild re-derive posture from record fields and verification context.
4. Stored and derived posture must match exactly.
5. Mismatch refuses validation/export with:

```text
audit.record.compliance_posture_mismatch
```

### D3 — Reader/Rebuild Implications

Restart rebuild must:

- verify chain and signature first;
- derive compliance posture using the same canonical derivation rules;
- compare derived posture to stored posture;
- refuse cursor rebuild on mismatch;
- never auto-repair or overwrite stored posture during rebuild.

Audit traversal / reader must:

- re-derive posture for every returned record;
- refuse compliant export on mismatch;
- surface mismatch as an audit validation failure, not as runtime evidence;
- never use stored posture as a shortcut for proof of production durable audit.

---

## What This Closes

| Item | Result |
|------|--------|
| P-37 | Closed: canonical hash excluded fields now documented in the design. |
| P-38 | Closed: compliance_posture model is stored + derived + mismatch-checked. |

This unblocks the next design/proof slices for:

- restart rebuild;
- audit traversal / reader;
- appender / reader role boundary.

---

## Non-Authorization

This amendment does not authorize:

- production deployment;
- production signing execution;
- production storage/provider selection;
- Ledger;
- Phase 2;
- BiHistory;
- stream/OLAP;
- production cache;
- write/replay/compact/subscribe;
- HSM/KMS onboarding;
- new RuntimeMachine binding.

---

## Handoff

```text
Card: S3-R32-C1-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: durable-audit-hash-and-posture-design-amendment-v0
Status: done

[D] Decisions
- Canonical record_hash excludes five fields: chain.record_hash,
  signature.signature_value, signature.signed_payload_hash, record_id,
  compliance_posture.
- compliance_posture is stored as an auditor-visible snapshot, derived as the
  authoritative value, and mismatch-checked by reader/rebuild.
- Mismatch emits audit.record.compliance_posture_mismatch and blocks compliant
  traversal/rebuild/export.

[S] Shipped / Signals
- Amended phase1-production-durable-audit-v0 with R32 Hash/Posture Amendment.
- Added this track doc.
- Documented reader/rebuild implications before B-A/B-B/B-C continue.

[T] Tests / Proofs
- Design-only card; no code or proof script run.

[R] Risks / Recommendations
- Implementation proof should add explicit mismatch cases for restart rebuild
  and audit traversal.
- Future production signer/store work must use the amended hash algorithm, not
  the older R26 two-field note.

[Next] Suggested next slice
- Restart rebuild proof can proceed using the amended hash/posture design.
```
