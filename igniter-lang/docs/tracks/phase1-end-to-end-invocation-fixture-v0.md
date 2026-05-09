# Track: Phase 1 End-To-End Invocation Fixture v0

Card: S3-R22-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `phase1-end-to-end-invocation-fixture-v0`
Status: done
Date: 2026-05-09

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Compose the signed Phase 1 invocation path end-to-end:

```text
authority registry check
-> caller authorization
-> Phase1 executor
-> audit-ready envelope export
```

Starting evidence:

- S3-R20 signed Gate 3 addendum:
  `signed-approved-restricted-phase1-live-read`
- S3-R21 C1 audit-ready envelope proof
- S3-R21 C2 authority registry shape proof

---

## Decision

[D] The end-to-end path is still proof-local.

[D] Registry check gates caller policy before the caller passes
`gate3_authorized: true`.

[D] The executor still performs its own guard chain and backend identity check.

[D] Audit export is explicit and remains `audit_ready_not_persisted`.

---

## Fixture

Added:

```text
igniter-lang/experiments/phase1_end_to_end_invocation_fixture/
  phase1_end_to_end_invocation_fixture.rb
  out/phase1_end_to_end_invocation_fixture_summary.json
```

The positive path proves:

- active proof-local registry entry allows caller authorization;
- caller passes `gate3_authorized: true`;
- `IgniterLang::TemporalExecutor::Phase1` executes;
- MemoryBackend path reads `History[T] valid_time`;
- explicit non-Ledger Phase 1 backend path reads;
- `temporal_live_read_observation` is emitted;
- audit-ready envelope exports with:
  - registry check ref;
  - CompatibilityReport ref;
  - authority ref;
  - signed addendum ref;
  - backend identity;
  - allowed result reason.

Negative paths prove:

- revoked registry blocks before executor;
- missing signed addendum evidence blocks before executor;
- Ledger-like backend blocks at `backend_identity` before read;
- missing audit export is non-compliant and not persisted.

---

## Proof Output

Command:

```bash
ruby igniter-lang/experiments/phase1_end_to_end_invocation_fixture/phase1_end_to_end_invocation_fixture.rb
```

Observed output:

```text
PASS phase1_end_to_end_invocation_fixture
  addendum.signed_status_detected: ok
  memory_backend.end_to_end_allowed: ok
  non_ledger_backend.end_to_end_allowed: ok
  revoked_registry.blocks_before_executor: ok
  missing_signed_addendum.blocks_before_executor: ok
  ledger_like_backend.blocks_before_read: ok
  missing_audit_export.non_compliant_not_persisted: ok
  no_case_uses_production_signing: ok
  no_case_uses_production_storage_or_ledger: ok
summary: igniter-lang/experiments/phase1_end_to_end_invocation_fixture/out/phase1_end_to_end_invocation_fixture_summary.json
```

Related proof commands:

```text
ruby -c igniter-lang/experiments/phase1_end_to_end_invocation_fixture/phase1_end_to_end_invocation_fixture.rb
Syntax OK

ruby igniter-lang/experiments/gate3_authority_registry_shape/gate3_authority_registry_shape.rb
PASS gate3_authority_registry_shape

ruby igniter-lang/experiments/compatibility_report_persistence_audit/compatibility_report_persistence_audit.rb
PASS compatibility_report_persistence_audit

ruby igniter-lang/experiments/gate3_first_post_signature_fixture/gate3_first_post_signature_fixture.rb
PASS gate3_first_post_signature_fixture
```

---

## Non-Authorization

[X] No Ledger adapter or Ledger package binding.

[X] No production storage.

[X] No production signing or keys.

[X] No durable audit.

[X] No production cache.

[X] No Phase 2 expansion.

---

## Handoff

```text
Card: S3-R22-C1-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/phase1-end-to-end-invocation-fixture-v0
Status: done

[D] Decisions
- End-to-end Phase 1 invocation is composed proof-locally.
- Registry check gates caller authorization before executor.
- Executor still owns guard chain and backend identity check.
- Audit envelope export is explicit and not persisted.

[S] Shipped / Signals
- Added phase1_end_to_end_invocation_fixture proof and summary JSON.
- Proved MemoryBackend and explicit non-Ledger positive paths.
- Proved revoked registry and missing signed addendum block before executor.
- Proved Ledger-like backend blocks before read.
- Proved missing audit export is non-compliant, not persisted.

[T] Tests / Proofs
- ruby igniter-lang/experiments/phase1_end_to_end_invocation_fixture/phase1_end_to_end_invocation_fixture.rb -> PASS
- ruby -c igniter-lang/experiments/phase1_end_to_end_invocation_fixture/phase1_end_to_end_invocation_fixture.rb -> Syntax OK
- ruby igniter-lang/experiments/gate3_authority_registry_shape/gate3_authority_registry_shape.rb -> PASS
- ruby igniter-lang/experiments/compatibility_report_persistence_audit/compatibility_report_persistence_audit.rb -> PASS
- ruby igniter-lang/experiments/gate3_first_post_signature_fixture/gate3_first_post_signature_fixture.rb -> PASS

[R] Risks / Recommendations
- Production durable registry, production signing, and durable audit remain
  separate future tracks.
- Next code-touching runtime change should rerun this E2E fixture plus the
  R20/R21 component proofs.

[Next] Suggested next slice
- durable-observation-persistence-v0 or phase1-addendum-content-address-ref-v0.
```
