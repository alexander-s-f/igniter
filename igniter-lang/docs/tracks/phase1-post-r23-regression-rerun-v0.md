# Track: Phase 1 Post-R23 Regression Rerun v0

Card: S3-R24-C1-P
Agent: `[Igniter-Lang Research Agent]`
Role: `research-agent`
Track: `phase1-post-r23-regression-rerun-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Purpose

Consolidate the current Gate 3 Phase 1 proof chain after R19/R20/R21/R22/R23
without widening behavior.

This is a regression record only. It does not authorize new live behavior,
production signing, Ledger adapters, durable audit, production cache, BiHistory,
stream, OLAP, writes, replay, compact, or subscribe.

Current approved live-read scope remains the signed restricted Phase 1 path:
History valid_time read, explicit `as_of`, approved authority/addendum evidence,
safe backend identity, and audit-ready observation envelope.

---

## Result

Verdict: PASS

Summary:

- Commands run: 23
- Passed: 23
- Failed: 0
- Production-facing design tracks: ready to proceed
- Production implementation authorization: not granted by this track

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

---

## Notable Signals

- The R19 baseline remains green with Stage 1 and Stage 2 regressions included.
- Post-signature behavior remains policy/status-only: guard order is unchanged.
- Audit output remains explicit export / audit-ready evidence, not automatic
  production persistence.
- Registry v1 receipts prove issuance, revocation, and supersession shape without
  production signing or key management.
- Durable observation persistence shape remains proof-local/file-backed and keeps
  Ledger/write/replay/compact/subscribe excluded.
- Reason-code checks confirm the lib executor emits canonical
  `runtime.temporal_scope_exclusion`; legacy aliases are compatibility/deprecation
  surface only.

---

## Recommendation

Ready for production-facing design tracks.

Do not treat this as authorization for production runtime expansion. The next
design work can safely discuss production-facing boundaries, but implementation
still needs separate tracks for production signing/key management, authority
registry durability, report persistence/audit, and any Ledger/TBackend Phase 2
adapter.

---

## Handoff

```text
Card: S3-R24-C1-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: phase1-post-r23-regression-rerun-v0
Status: done

[D] Decisions
- R24 is a regression record only; no new behavior authorized.
- The current post-R23 Phase 1 proof chain is 23 commands.
- Recommendation is ready for production-facing design tracks, not production implementation.

[S] Shipped / Signals
- All R19 baseline checks plus R20-R23 additions passed.
- Signed addendum, audit envelope, registry shape, content-addressed addendum ref,
  durable observation persistence shape, registry v1 receipts, and reason-code
  deprecation signal are green together.

[T] Tests / Proofs
- 23/23 commands PASS; see command matrix above.

[R] Risks / Recommendations
- Production signing/key management, durable authority registry, durable audit,
  Ledger/TBackend Phase 2, production cache, and unified production report
  persistence remain outside this proof.

[Next] Suggested next slice
- Open production-facing design tracks only after Meta/Supervisor accepts this
  regression record as current.
```
