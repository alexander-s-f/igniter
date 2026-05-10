# Track: Gate 3 Authority Registry v1 Receipts Shape v0

Card: S3-R23-C2-P
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `gate3-authority-registry-v1-receipts-shape-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Purpose

Strengthen the proof-local Gate 3 authority registry into a v1 registry shape
with explicit transition receipts for issuance, revocation, and supersession.

This starts from:

- `gate3-authority-registry-shape-v0`
- `phase1-addendum-content-address-ref-v0`

No production signing, key management, production registry service, package
binding, Ledger adapter, or TemporalExecutor call is introduced here.

---

## Registry v1 Entry

[D] Registry v1 records both current state and receipt refs:

```json
{
  "authority_ref": "architect-supervisor://igniter-lang/gates/gate3/runtime-temporal-executor/restricted-history-valid-time-v0/2026-05-09",
  "registry_version": "gate3_authority_registry.v1",
  "status": "draft|active|revoked|superseded",
  "issued_on": "YYYY-MM-DD|null",
  "revoked_on": "YYYY-MM-DD|null",
  "superseded_on": "YYYY-MM-DD|null",
  "superseded_by": "authority_ref|null",
  "allowed_scope": {
    "gate": "gate3",
    "phase": "phase1",
    "executor": "IgniterLang::TemporalExecutor::Phase1",
    "operation": "history_valid_time_read",
    "history_axis": "valid_time",
    "backend_family": "memory_or_explicit_non_ledger"
  },
  "required_capability": "history_read",
  "decision_ref": {
    "document_path": "igniter-lang/docs/gates/gate3-live-read-decision-addendum-v0.md",
    "git_commit": "workspace-current|<commit-sha>",
    "content_sha256": "sha256:<document-bytes>",
    "status": "signed-approved-restricted-phase1-live-read",
    "signed_on": "2026-05-09",
    "authority_ref": "<authority_ref>"
  },
  "receipt_refs": {
    "issuance": "receipt id|null",
    "revocation": "receipt id|null",
    "supersession": "receipt id|null"
  }
}
```

`decision_ref` must be content-addressed when it refers to a signed addendum or
transition decision. Path-only evidence is not sufficient.

---

## Receipt Schema

[D] Registry v1 receipts are proof-local transition receipts:

```json
{
  "kind": "gate3_authority_registry_transition_receipt",
  "receipt_version": "0.1.0",
  "transition": "issuance|revocation|supersession",
  "authority_ref": "<authority_ref>",
  "from_status": "status|null",
  "to_status": "status",
  "occurred_on": "YYYY-MM-DD",
  "decision_ref": {
    "document_path": "human path or proof-local transition ref",
    "git_commit": "workspace-current|<commit-sha>",
    "content_sha256": "sha256:<decision bytes>",
    "status": "signed-approved-restricted-phase1-live-read|proof-local",
    "signed_on": "YYYY-MM-DD|null",
    "authority_ref": "<authority_ref>"
  },
  "caused_by_ref": "prior receipt id|null",
  "superseded_by": "authority_ref|null",
  "receipt_id": "receipt/gate3-authority/<content-derived-short-hash>",
  "production_signing": false,
  "production_key_management": false
}
```

Receipt chain:

```text
issuance:    nil     -> active
revocation:  active  -> revoked, caused_by issuance receipt
supersession: revoked -> superseded, caused_by revocation receipt
```

The supersession transition in this proof deliberately follows revocation to
model the requested `active -> revoked -> superseded` path.

---

## Proof Fixture

Added:

```text
igniter-lang/experiments/gate3_authority_registry_v1_receipts_shape/
  gate3_authority_registry_v1_receipts_shape.rb
  out/gate3_authority_registry_v1_receipts_shape_summary.json
```

The fixture:

- issues an active registry entry with a content-addressed signed addendum ref;
- revokes it with a revocation receipt linked to the issuance receipt;
- supersedes it with a supersession receipt linked to the revocation receipt;
- blocks issuance without a content-addressed decision ref;
- blocks revocation for a missing entry;
- blocks supersession without a decision ref;
- never calls `TemporalExecutor`;
- never uses signing keys or production key management.

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/gate3_authority_registry_v1_receipts_shape/gate3_authority_registry_v1_receipts_shape.rb
```

Observed output:

```text
PASS gate3_authority_registry_v1_receipts_shape
  issuance.active: ok
  issuance.has_content_addressed_decision_ref: ok
  revocation.revoked: ok
  revocation.receipt_links_issuance: ok
  supersession.superseded: ok
  supersession.receipt_links_revocation: ok
  issuance_without_content_ref.blocks: ok
  revocation_from_missing_entry.blocks: ok
  supersession_without_decision_ref.blocks: ok
  no_case_uses_production_signing_or_keys: ok
  no_case_calls_executor: ok
summary: igniter-lang/experiments/gate3_authority_registry_v1_receipts_shape/out/gate3_authority_registry_v1_receipts_shape_summary.json
```

---

## Outside Phase 1

[X] Still outside Phase 1:

- production signing;
- production key management;
- production trust store;
- durable registry service;
- distributed revocation lookup;
- package implementation;
- Ledger package binding;
- Phase 2 Ledger-backed adapter;
- BiHistory, transaction-time, stream, OLAP;
- writes, replay, compact, subscribe;
- production cache;
- durable audit/observation persistence.

This proof only strengthens proof-local registry shape and transition evidence.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/gate3-authority-registry-v1-receipts-shape-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert

[D] Decisions:
- Registry v1 carries state plus receipt refs.
- Issuance, revocation, and supersession each produce transition receipts.
- Decision/addendum refs must be content-addressed where applicable.

[R] Recommendations:
- A future production registry can reuse this receipt vocabulary, but must add durable storage and separate signing/key-management tracks.
- Keep Phase 2 Ledger adapter work behind its own Architect addendum.

[S] Signals:
- Fixture proves active -> revoked -> superseded transition chain.
- Receipts link issuance -> revocation -> supersession.
- No TemporalExecutor call, signing key, or production registry is used.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/gate3_authority_registry_v1_receipts_shape/gate3_authority_registry_v1_receipts_shape.rb
- ruby -c igniter-lang/experiments/gate3_authority_registry_v1_receipts_shape/gate3_authority_registry_v1_receipts_shape.rb

[Files] Changed:
- igniter-lang/docs/tracks/gate3-authority-registry-v1-receipts-shape-v0.md
- igniter-lang/experiments/gate3_authority_registry_v1_receipts_shape/gate3_authority_registry_v1_receipts_shape.rb
- igniter-lang/experiments/gate3_authority_registry_v1_receipts_shape/out/gate3_authority_registry_v1_receipts_shape_summary.json

[Q] Open Questions:
- Should production registry durability live in a package, a gate document store, or an external authority service?
- Should production supersession allow active -> superseded directly, or preserve this proof's revoked -> superseded chain?

[X] Rejected:
- No production signing, key management, package edits, TemporalExecutor calls, Phase 2 Ledger adapter, or Ledger package binding.

[Next] Proposed next slice:
- Durable registry storage semantics, or production signing/key-management split, only after Architect asks for that boundary.
```
