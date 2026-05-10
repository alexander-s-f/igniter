# Track: Phase 1 Durable Registry Storage Semantics v0

Card: S3-R24-C2-P
Agent: `[Igniter-Lang Bridge Agent]`
Role: `bridge-agent`
Track: `phase1-durable-registry-storage-semantics-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Compiler/Grammar Expert]`

---

## Purpose

Define the durable/queryable registry storage semantics needed after
`gate3-authority-registry-v1-receipts-shape-v0`, without implementing
production signing, key management, package binding, or Ledger binding.

This is design/proof-local only.

---

## Durable Registry Meaning

[D] A durable registry service must mean more than a document path or a status
constant. At minimum it must provide:

- **storage identity**: stable `storage_id`, schema version, durability model,
  and explicit non-Ledger/non-signing flags;
- **query by `authority_ref`**: the primary lookup key for caller policy;
- **effective-time status lookup**: active, revoked, or superseded as of a
  supplied timestamp;
- **receipt chain verification**: issuance, revocation, and supersession
  receipts must be present and linked;
- **content-addressed decision ref verification**: signed addendum and
  transition decision refs must include document path, commit/release ref,
  `content_sha256`, status/date where applicable, and `authority_ref`;
- **revocation/supersession effective time**: `revoked_at` and `superseded_at`
  must control query results.

Proof-local storage identity:

```json
{
  "kind": "proof_local_gate3_authority_registry_store",
  "storage_id": "registry/gate3/phase1/proof-local",
  "schema_version": "gate3_authority_registry_storage.v0",
  "durability_model": "proof_local_file_backed_fixture",
  "production_signing": false,
  "ledger_binding": false
}
```

---

## State Machine

[D] For this v0, direct `active -> superseded` is **not allowed**.

State machine:

```text
draft -> active -> revoked -> superseded
```

Rationale:

- revocation has a distinct effective time and refusal reason;
- supersession should point to a prior revocation receipt;
- callers can distinguish "this authority is revoked" from "this authority has
  been replaced";
- a future production registry may add an atomic `active -> superseded`
  operation only if it emits a paired revocation receipt and supersession
  receipt in one transaction.

---

## Minimal Schema

Store:

```json
{
  "storage_identity": {
    "kind": "proof_local_gate3_authority_registry_store",
    "storage_id": "registry/gate3/phase1/proof-local",
    "schema_version": "gate3_authority_registry_storage.v0",
    "durability_model": "proof_local|production_later"
  },
  "entries": {
    "<authority_ref>": "registry v1 entry"
  },
  "receipts": {
    "<receipt_id>": "transition receipt"
  }
}
```

Entry delta over R23:

```json
{
  "status": "draft|active|revoked|superseded",
  "issued_at": "timestamp|null",
  "revoked_at": "timestamp|null",
  "superseded_at": "timestamp|null",
  "superseded_by": "authority_ref|null",
  "receipt_refs": {
    "issuance": "receipt id|null",
    "revocation": "receipt id|null",
    "supersession": "receipt id|null"
  }
}
```

Receipt delta over R23:

```json
{
  "kind": "gate3_authority_registry_storage_transition_receipt",
  "transition": "issuance|revocation|supersession",
  "effective_at": "timestamp",
  "decision_ref": "content-addressed decision ref",
  "caused_by_ref": "prior receipt id|null",
  "production_signing": false,
  "production_key_management": false,
  "ledger_binding": false
}
```

---

## Proof Fixture

Added:

```text
igniter-lang/experiments/phase1_durable_registry_storage_semantics/
  phase1_durable_registry_storage_semantics.rb
  out/phase1_durable_registry_storage_semantics_summary.json
```

The fixture proves:

| Case | Signal |
|---|---|
| `storage_identity` | stable proof-local storage identity exists |
| `query_active_by_authority_ref` | active lookup permits caller policy |
| `query_revoked_after_effective_time` | revoked lookup blocks caller policy |
| `query_superseded_after_effective_time` | superseded lookup blocks caller policy |
| `receipt_chain_verified` | issuance -> revocation -> supersession receipts verify |
| `content_address_mismatch_blocks_verification` | bad signed addendum hash blocks chain verification |
| `direct_active_to_superseded_blocked` | direct active -> superseded is rejected |
| `missing_authority_ref_query_blocks` | missing authority lookup blocks |

The proof never calls `TemporalExecutor`.

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/phase1_durable_registry_storage_semantics/phase1_durable_registry_storage_semantics.rb
```

Observed output:

```text
PASS phase1_durable_registry_storage_semantics
  storage_identity.present: ok
  query.active_by_authority_ref: ok
  query.revoked_after_effective_time: ok
  query.superseded_after_effective_time: ok
  receipt_chain.verified: ok
  content_address_mismatch.blocks: ok
  direct_active_to_superseded.blocked: ok
  missing_authority_ref.blocks: ok
  no_case_uses_signing_or_ledger: ok
  no_case_calls_executor: ok
summary: igniter-lang/experiments/phase1_durable_registry_storage_semantics/out/phase1_durable_registry_storage_semantics_summary.json
```

---

## Production Blockers

[X] Still outside this Phase 1 proof:

- production signing;
- production key management;
- production trust store;
- production registry service implementation;
- distributed revocation lookup;
- package implementation;
- Ledger package binding;
- Phase 2 Ledger-backed adapter;
- TemporalExecutor policy integration;
- durable audit/observation persistence;
- production cache;
- BiHistory, transaction-time, stream, OLAP;
- writes, replay, compact, subscribe.

This track defines storage semantics only; it does not authorize any production
runtime or package binding.

---

## Handoff

```text
[Igniter-Lang Bridge Agent]
Track: igniter-lang/phase1-durable-registry-storage-semantics-v0
Status: done
Neighbors: Research Agent | Compiler/Grammar Expert

[D] Decisions:
- Durable registry service means stable storage identity, query by authority_ref, effective-time status lookup, receipt chain verification, and content-addressed decision ref verification.
- Direct active -> superseded is blocked in v0; supersession requires revocation first.
- This remains proof-local and does not implement production signing/key management.

[R] Recommendations:
- Future production registry may add atomic active -> superseded only if it emits paired revocation and supersession receipts transactionally.
- Keep production signing/key management separate from registry storage semantics.

[S] Signals:
- Fixture proves active/revoked/superseded lookup by authority_ref and effective time.
- Fixture verifies receipt chain and blocks content hash mismatch.
- No TemporalExecutor call, signing, key management, package edit, or Ledger binding.

[T] Tests / Proofs:
- ruby igniter-lang/experiments/phase1_durable_registry_storage_semantics/phase1_durable_registry_storage_semantics.rb
- ruby -c igniter-lang/experiments/phase1_durable_registry_storage_semantics/phase1_durable_registry_storage_semantics.rb

[Files] Changed:
- igniter-lang/docs/tracks/phase1-durable-registry-storage-semantics-v0.md
- igniter-lang/experiments/phase1_durable_registry_storage_semantics/phase1_durable_registry_storage_semantics.rb
- igniter-lang/experiments/phase1_durable_registry_storage_semantics/out/phase1_durable_registry_storage_semantics_summary.json

[Q] Open Questions:
- Which future component owns production registry storage: package, gate document store, or external authority service?
- Should production require transaction receipts for any future atomic active -> superseded operation?

[X] Rejected:
- No production signing, key management, Ledger binding, package implementation, TemporalExecutor integration, production cache, or durable audit.

[Next] Proposed next slice:
- Production registry ownership decision, or production signing/key-management split, only with explicit Architect scope.
```
