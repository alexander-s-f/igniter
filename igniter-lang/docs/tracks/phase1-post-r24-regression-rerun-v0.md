# Track: Phase 1 Post-R24 Regression Rerun v0

Card: S3-R25-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: `research-agent`
Track: `phase1-post-r24-regression-rerun-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Purpose

Expand the canonical Gate 3 Phase 1 regression matrix from the R24
post-R23 23-command chain to a 25-command chain by adding the R24 durability
fixtures:

- `phase1_durable_registry_storage_semantics`
- `phase1_observation_tamper_evidence_shape`

This is a regression record only. It does not authorize new behavior,
production signing, durable audit, production authority registry, Ledger
adapter/package binding, production cache, BiHistory, stream, OLAP, writes,
replay, compact, or subscribe.

---

## Result

Verdict: PASS

Summary:

- Commands run: 25
- Passed: 25
- Failed: 0
- Prior 23-command chain: still PASS
- Added R24 durability fixtures: PASS
- Architect production-durable-audit scope decision: ready for review
- Production durable-audit implementation authorization: not granted by this
  track

---

## Command Matrix

| # | Surface | Command | Result |
|---|---------|---------|--------|
| 1 | Temporal load/eval split | `ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb` | PASS |
| 2 | Executor cache-key contract | `ruby igniter-lang/experiments/executor_boundary_cache_key_contract/executor_boundary_cache_key_contract.rb` | PASS |
| 3 | Approval token report matrix | `ruby igniter-lang/experiments/executor_approval_token_report_proof/executor_approval_token_report_proof.rb` | PASS |
| 4 | Guarded runtime approval enforcement | `ruby igniter-lang/experiments/guarded_runtime_executor_approval_enforcement/guarded_runtime_executor_approval_enforcement.rb` | PASS |
| 5 | Descriptor report-only consumption | `ruby igniter-lang/experiments/compatibility_report_package_descriptor_consumption/compatibility_report_package_descriptor_consumption.rb` | PASS |
| 6 | Full runtime smoke | `ruby igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb` | PASS |
| 7 | CompatibilityReport composition | `ruby igniter-lang/experiments/compatibility_report_composition/compatibility_report_composition.rb` | PASS |
| 8 | Temporal read observation envelope | `ruby igniter-lang/experiments/temporal_read_observation_proof/temporal_read_observation_proof.rb` | PASS |
| 9 | Runtime report enforcement preflight | `ruby igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb` | PASS |
| 10 | Temporal scope exclusion fixture | `ruby igniter-lang/experiments/temporal_scope_exclusion_runtime_fixture/temporal_scope_exclusion_runtime_fixture.rb` | PASS |
| 11 | Authority ref exact-match proof | `ruby igniter-lang/experiments/executor_approval_authority_ref_proof/executor_approval_authority_ref_proof.rb` | PASS |
| 12 | Phase 1 TemporalExecutor lib prep | `ruby igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb` | PASS |
| 13 | Stage 1 regression | `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS |
| 14 | Stage 2 regression | `ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb` | PASS |
| 15 | Backend identity guard | `ruby igniter-lang/experiments/phase1_backend_identity_guard/phase1_backend_identity_guard.rb` | PASS |
| 16 | Signed addendum / post-signature fixture | `ruby igniter-lang/experiments/gate3_first_post_signature_fixture/gate3_first_post_signature_fixture.rb` | PASS |
| 17 | Compatibility audit envelope | `ruby igniter-lang/experiments/compatibility_report_persistence_audit/compatibility_report_persistence_audit.rb` | PASS |
| 18 | Authority registry shape | `ruby igniter-lang/experiments/gate3_authority_registry_shape/gate3_authority_registry_shape.rb` | PASS |
| 19 | End-to-end invocation fixture | `ruby igniter-lang/experiments/phase1_end_to_end_invocation_fixture/phase1_end_to_end_invocation_fixture.rb` | PASS |
| 20 | Content-addressed addendum ref | `ruby igniter-lang/experiments/phase1_addendum_content_address_ref/phase1_addendum_content_address_ref.rb` | PASS |
| 21 | Durable observation persistence shape | `ruby igniter-lang/experiments/phase1_durable_observation_persistence_shape/phase1_durable_observation_persistence_shape.rb` | PASS |
| 22 | Registry v1 receipts shape | `ruby igniter-lang/experiments/gate3_authority_registry_v1_receipts_shape/gate3_authority_registry_v1_receipts_shape.rb` | PASS |
| 23 | Reason-code legacy alias deprecation signal | `ruby igniter-lang/experiments/phase1_reason_code_legacy_aliases_deprecation_signal/phase1_reason_code_legacy_aliases_deprecation_signal.rb` | PASS |
| 24 | Durable registry storage semantics | `ruby igniter-lang/experiments/phase1_durable_registry_storage_semantics/phase1_durable_registry_storage_semantics.rb` | PASS |
| 25 | Observation tamper-evidence shape | `ruby igniter-lang/experiments/phase1_observation_tamper_evidence_shape/phase1_observation_tamper_evidence_shape.rb` | PASS |

---

## Added R24 Signals

- Durable registry storage semantics prove proof-local storage identity,
  `authority_ref` lookup, effective-time active/revoked/superseded status,
  receipt-chain verification, content-address mismatch blocking, and no
  executor/signing/Ledger path.
- Observation tamper-evidence shape proves a proof-local SHA256 chain with
  `sequence`, `previous_record_hash`, `record_hash`, `storage_identity`, and
  `created_at`, while preserving the no Ledger/write/replay/compact/subscribe
  exclusions.
- The tamper-evidence proof remains SHA256-only and file-backed/in-memory; it is
  not a production cryptographic commitment or compliance claim.

---

## Recommendation

Ready for Architect production-durable-audit scope decision.

This recommendation means the proof evidence is coherent enough for a scope
decision. It does not authorize production implementation. A future durable-audit
decision should explicitly decide ownership for production signing/key
management, durable registry storage, audit store/replay semantics, retention,
monitoring/alerting, and compliance language.

---

## Worktree Note

Running the suite regenerated two nondeterministic proof artifacts:

- `experiments/stage2_close_candidate/stage2_close_candidate.json`
- `experiments/phase1_observation_tamper_evidence_shape/out/phase1_tamper_evident_store.jsonl`

Both were restored to their checked-in contents with scoped patches. One
unrelated untracked gate document was present and left untouched:

- `igniter-lang/docs/gates/phase1-production-durable-audit-scope-decision-v0.md`

---

## Handoff

```text
Card: S3-R25-C1-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: phase1-post-r24-regression-rerun-v0
Status: done

[D] Decisions
- The canonical Gate 3 Phase 1 regression matrix is now 25 commands.
- R25 is a regression record only; no new behavior authorized.
- Recommendation is ready for Architect production-durable-audit scope decision,
  not production durable-audit implementation.

[S] Shipped / Signals
- Prior 23-command chain remains green.
- Durable registry storage semantics and observation tamper-evidence shape are
  green together with the existing Phase 1 chain.

[T] Tests / Proofs
- 25/25 commands PASS; see command matrix above.

[R] Risks / Recommendations
- Production signing/key management, durable registry service, audit store,
  retention/replay semantics, monitoring/alerting, compliance language,
  Ledger/TBackend Phase 2, and production cache remain outside this proof.

[Next] Suggested next slice
- Architect production-durable-audit scope decision, if the Supervisor accepts
  this 25-command record as current.
```
