# Track: Phase 1 Durable Observation Persistence Shape v0

Card: S3-R23-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `phase1-durable-observation-persistence-shape-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Define and prove the minimal durable-observation persistence shape for signed
Gate 3 Phase 1 without turning it into Ledger or production audit.

Starting evidence:

- R21 audit-ready envelope: explicit export, not persisted.
- R22 end-to-end invocation: registry check -> caller authorization ->
  Phase1 executor -> audit-ready envelope.

---

## Decision

[D] Phase 1 may persist only a proof-local observation record derived from an
audit-ready envelope.

[D] The persistence mode proven here is file-backed proof-local JSONL:

```text
proof_local_file
```

[D] `audit_ready` still does not mean production durable audit.

[D] Ledger adapter, writes, replay, compact, and subscribe remain excluded.

---

## Persistable Shape

Allowed record kind:

```text
phase1_observation_persistence_record
```

Minimum persisted fields:

```text
temporal_live_read_observation
compatibility_report_ref
authority_ref
signed_addendum_ref
backend_identity
result
```

Required caveat:

```json
{
  "audit_ready": true,
  "production_durable_audit": false,
  "production_compliance_claim": false,
  "ledger": false
}
```

---

## Fixture

Added:

```text
igniter-lang/experiments/phase1_durable_observation_persistence_shape/
  phase1_durable_observation_persistence_shape.rb
  out/phase1_observation_store.jsonl
  out/phase1_durable_observation_persistence_shape_summary.json
```

The fixture:

- builds an audit-ready envelope from a signed Phase 1 MemoryBackend read;
- appends one `phase1_observation_persistence_record` to a proof-local JSONL
  store;
- records a receipt for the append;
- proves the stored record has the minimum shape;
- proves all excluded operations do not append to the store.

---

## PASS/FAIL Matrix

Command:

```bash
ruby igniter-lang/experiments/phase1_durable_observation_persistence_shape/phase1_durable_observation_persistence_shape.rb
```

Observed output:

```text
PASS phase1_durable_observation_persistence_shape
  allowed_observation.persisted_once: ok
  record.minimum_shape_present: ok
  record.audit_ready_not_production_audit: ok
  ledger_adapter.excluded: ok
  write.excluded: ok
  replay.excluded: ok
  compact.excluded: ok
  subscribe.excluded: ok
  negative_cases.did_not_append: ok
summary: igniter-lang/experiments/phase1_durable_observation_persistence_shape/out/phase1_durable_observation_persistence_shape_summary.json
```

Related checks:

```text
ruby -c igniter-lang/experiments/phase1_durable_observation_persistence_shape/phase1_durable_observation_persistence_shape.rb
Syntax OK

ruby igniter-lang/experiments/phase1_end_to_end_invocation_fixture/phase1_end_to_end_invocation_fixture.rb
PASS phase1_end_to_end_invocation_fixture

ruby igniter-lang/experiments/compatibility_report_persistence_audit/compatibility_report_persistence_audit.rb
PASS compatibility_report_persistence_audit
```

---

## Non-Authorization

[X] This is not production durable audit.

[X] This is not a production compliance claim.

[X] This is not Ledger or Ledger adapter binding.

[X] This does not authorize write, replay, compact, or subscribe.

[X] This does not add production storage.

---

## Signed Follow-Up Recommendation

[R] This shape can become a signed follow-up as a **Phase 1 proof-local/file-backed
observation persistence shape** if the signature text preserves these limits:

- `proof_local_file` only;
- no Ledger;
- no production compliance claim;
- no production durable audit;
- no write/replay/compact/subscribe;
- no Phase 2 inference.

[R] A production durable audit follow-up should be a separate track with storage
identity, retention, tamper evidence, replay semantics, and compliance language.

---

## Handoff

```text
Card: S3-R23-C1-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/phase1-durable-observation-persistence-shape-v0
Status: done

[D] Decisions
- Minimal persisted shape is phase1_observation_persistence_record.
- Persistence is proof-local file-backed JSONL only.
- audit_ready remains distinct from production durable audit.

[S] Shipped / Signals
- Added durable observation persistence shape proof and summary JSON.
- Persisted one allowed observation record.
- Proved Ledger/write/replay/compact/subscribe exclusions do not append.

[T] Tests / Proofs
- ruby igniter-lang/experiments/phase1_durable_observation_persistence_shape/phase1_durable_observation_persistence_shape.rb -> PASS
- ruby -c igniter-lang/experiments/phase1_durable_observation_persistence_shape/phase1_durable_observation_persistence_shape.rb -> Syntax OK
- ruby igniter-lang/experiments/phase1_end_to_end_invocation_fixture/phase1_end_to_end_invocation_fixture.rb -> PASS
- ruby igniter-lang/experiments/compatibility_report_persistence_audit/compatibility_report_persistence_audit.rb -> PASS

[R] Risks / Recommendations
- Can become a signed follow-up only as proof-local/file-backed persistence.
- Production durable audit remains a separate future track.

[Next] Suggested next slice
- phase1-post-r22-regression-rerun-v0 or production durable audit planning.
```
