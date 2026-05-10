# Track: Post-R27 Regression Matrix With Volatile Lint v0

Card: S3-R28-C3-P
Agent: `[Igniter-Lang Research Agent]`
Role: `research-agent`
Track: `post-r27-regression-matrix-with-volatile-lint-v0`
Status: done
Date: 2026-05-10

Affected neighbor roles: `[Igniter-Lang Compiler/Grammar Expert]`,
`[Igniter-Lang Bridge Agent]`

---

## Purpose

Run the full post-R27/R28 regression matrix against current HEAD with
`volatile_fields_lint` as the first mandatory step.

This track does not edit compiler/runtime semantics and does not authorize new
Gate 3 behavior.

---

## Inputs Read

- `volatile-fields-lint-and-artifact-stability-survey-v0.md`
- `stage3-round27-status-curation-v0.md`
- Current track/proof discovery for C1/C2:
  - `production-durable-audit-blocker-amendment-and-validation-proofs-v0.md`
    landed with two bounded proof scripts and both were run;
  - `experiments/contract_modifiers_proof/contract_modifiers_proof.rb` exists
    and was run.

---

## Result

Verdict: READY for next Architect review of the currently landed R28 surface
after a fully sequential rerun on the updated Compiler/Grammar worktree.

Summary:

- Unique command surfaces run: 29
- Passed: 29
- Failed: 0
- C1 production-durable-audit bounded proofs: 2/2 PASS
- C2 contract modifiers proof: runner present, 19/19 PASS
- Stage 1 close candidate: PASS
- Stage 2 close candidate: PASS
- Generated diff: Stage 2 close candidate `timestamp` only; classified as
  expected volatile field and restored to checked-in value.

Recommendation: ready for next Architect review. The previous transient
runtime/executor failures are no longer present after Compiler/Grammar updates
and sequential rerun.

---

## Command Matrix

| # | Surface | Command | Result | Classification |
|---|---------|---------|--------|----------------|
| 1 | Volatile fields lint | `ruby igniter-lang/experiments/volatile_fields_lint/volatile_fields_lint.rb` | PASS | ok |
| 2 | Temporal load/eval split | `ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb` | PASS | ok |
| 3 | Executor cache-key contract | `ruby igniter-lang/experiments/executor_boundary_cache_key_contract/executor_boundary_cache_key_contract.rb` | PASS | ok |
| 4 | Approval token report matrix | `ruby igniter-lang/experiments/executor_approval_token_report_proof/executor_approval_token_report_proof.rb` | PASS | ok |
| 5 | Guarded runtime approval enforcement | `ruby igniter-lang/experiments/guarded_runtime_executor_approval_enforcement/guarded_runtime_executor_approval_enforcement.rb` | PASS | ok |
| 6 | Descriptor report-only consumption | `ruby igniter-lang/experiments/compatibility_report_package_descriptor_consumption/compatibility_report_package_descriptor_consumption.rb` | PASS | ok |
| 7 | Full runtime smoke | `ruby igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb` | PASS | ok |
| 8 | CompatibilityReport composition | `ruby igniter-lang/experiments/compatibility_report_composition/compatibility_report_composition.rb` | PASS | ok |
| 9 | Temporal read observation envelope | `ruby igniter-lang/experiments/temporal_read_observation_proof/temporal_read_observation_proof.rb` | PASS | ok |
| 10 | Runtime report enforcement preflight | `ruby igniter-lang/experiments/runtime_report_enforcement_preflight/runtime_report_enforcement_preflight.rb` | PASS | ok |
| 11 | Temporal scope exclusion fixture | `ruby igniter-lang/experiments/temporal_scope_exclusion_runtime_fixture/temporal_scope_exclusion_runtime_fixture.rb` | PASS | ok |
| 12 | Authority ref exact-match proof | `ruby igniter-lang/experiments/executor_approval_authority_ref_proof/executor_approval_authority_ref_proof.rb` | PASS | ok |
| 13 | Phase 1 TemporalExecutor lib prep | `ruby igniter-lang/experiments/temporal_executor_lib_prep/temporal_executor_lib_prep.rb` | PASS | ok |
| 14 | Stage 1 regression | `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS | ok |
| 15 | Stage 2 regression | `ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb` | PASS | ok; timestamp volatile |
| 16 | Backend identity guard | `ruby igniter-lang/experiments/phase1_backend_identity_guard/phase1_backend_identity_guard.rb` | PASS | ok |
| 17 | Signed addendum / post-signature fixture | `ruby igniter-lang/experiments/gate3_first_post_signature_fixture/gate3_first_post_signature_fixture.rb` | PASS | ok |
| 18 | Compatibility audit envelope | `ruby igniter-lang/experiments/compatibility_report_persistence_audit/compatibility_report_persistence_audit.rb` | PASS | ok |
| 19 | Authority registry shape | `ruby igniter-lang/experiments/gate3_authority_registry_shape/gate3_authority_registry_shape.rb` | PASS | ok |
| 20 | End-to-end invocation fixture | `ruby igniter-lang/experiments/phase1_end_to_end_invocation_fixture/phase1_end_to_end_invocation_fixture.rb` | PASS | ok |
| 21 | Content-addressed addendum ref | `ruby igniter-lang/experiments/phase1_addendum_content_address_ref/phase1_addendum_content_address_ref.rb` | PASS | ok |
| 22 | Durable observation persistence shape | `ruby igniter-lang/experiments/phase1_durable_observation_persistence_shape/phase1_durable_observation_persistence_shape.rb` | PASS | ok |
| 23 | Registry v1 receipts shape | `ruby igniter-lang/experiments/gate3_authority_registry_v1_receipts_shape/gate3_authority_registry_v1_receipts_shape.rb` | PASS | ok |
| 24 | Reason-code legacy alias deprecation signal | `ruby igniter-lang/experiments/phase1_reason_code_legacy_aliases_deprecation_signal/phase1_reason_code_legacy_aliases_deprecation_signal.rb` | PASS | ok |
| 25 | Durable registry storage semantics | `ruby igniter-lang/experiments/phase1_durable_registry_storage_semantics/phase1_durable_registry_storage_semantics.rb` | PASS | ok |
| 26 | Observation tamper-evidence shape | `ruby igniter-lang/experiments/phase1_observation_tamper_evidence_shape/phase1_observation_tamper_evidence_shape.rb` | PASS | ok |
| 27 | Production durable audit compliance posture proof | `ruby igniter-lang/experiments/production_durable_audit_compliance_posture_proof/production_durable_audit_compliance_posture_proof.rb` | PASS | ok |
| 28 | Production durable audit signer validation proof | `ruby igniter-lang/experiments/production_durable_audit_signer_validation_proof/production_durable_audit_signer_validation_proof.rb` | PASS | ok |
| 29 | Contract modifiers proof | `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb` | PASS | ok |

---

## C1/C2 Discovery

| Requested Family | Discovery | Classification |
|------------------|-----------|----------------|
| Production durable audit bounded proofs | `production_durable_audit_compliance_posture_proof.rb` and `production_durable_audit_signer_validation_proof.rb` landed and were run. Startup freshness is a design amendment in C1, not a separate proof script. | C1 bounded proofs PASS |
| Contract modifiers proof | `igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb` exists and was run after Compiler/Grammar updates. Parser/classifier/typechecker/SemanticIR checks pass. | C2 proof PASS |

Rerun note:

```text
executor_boundary_cache_key_contract: PASS
executor_approval_token_report_proof: PASS
runtime_smoke_post_switch_full_coverage: PASS
contract_modifiers_proof: PASS
```

Earlier intermediate failures were caused by running during active
Compiler/Grammar edits and by a parallel shared-output run. The final recorded
matrix is the fully sequential rerun after those updates landed.

---

## Volatile Artifact Note

Running `stage2_close_candidate` changed:

```text
experiments/stage2_close_candidate/stage2_close_candidate.json
```

Changed field:

```text
timestamp
```

Classification: expected volatile field. The artifact declares
`"_volatile_fields": ["timestamp"]`. The checked-in timestamp was restored after
the run to keep this regression record doc-only.

No additional generated artifact diff remains after restoring the volatile
timestamp.

---

## Worktree Caveat

Before the first rerun, the shared worktree had been changing while
Compiler/Grammar Expert landed PROP-031 support. After the final sequential
rerun and cleanup, the remaining changed file for this card is:

```text
igniter-lang/docs/tracks/post-r27-regression-matrix-with-volatile-lint-v0.md
```

No compiler/runtime semantics were edited by this card.

---

## Final Classification

| Category | Count | Items |
|----------|-------|-------|
| regression | 0 | none |
| expected golden/volatile migration | 1 | Stage 2 timestamp changed and was restored |
| environment/setup | 0 | none in final sequential run |
| upstream dependency not landed/incomplete | 0 | none |

---

## Recommendation

Ready for next Architect review of the currently landed R28 surface.

Architect can review the C1 production-durable-audit blocker amendments
separately:

- compliance posture proof: PASS;
- signer validation proof: PASS;
- startup freshness: design amendment only, no separate proof expected in C1.

Contract modifiers themselves are green:

- `contract_modifiers_proof`: PASS.

---

## Handoff

```text
Card: S3-R28-C3-P
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: post-r27-regression-matrix-with-volatile-lint-v0
Status: done

[D] Decisions
- Current post-R27/R28 matrix is 29 command surfaces: volatile lint + prior 25-command Phase 1 chain + Stage 1/2 regressions + C1 compliance/signer proofs + C2 contract-modifier proof.
- C1 bounded durable-audit proofs pass.
- C2 contract-modifier proof now passes after Compiler/Grammar updates.
- Stage 3 runtime smoke and dependent executor proofs pass in the final sequential rerun.
- Stage 2 timestamp churn is expected volatile-field behavior, not a regression.

[S] Shipped / Signals
- Added exact PASS/FAIL command matrix.
- Reran matrix after Compiler/Grammar changes, sequentially to avoid shared `out/` races.
- 29/29 command surfaces PASS.

[T] Tests / Proofs
- 29/29 command surfaces PASS.

[R] Risks / Recommendations
- Ready for next Architect review of the currently landed R28 surface.
- C1 durable-audit bounded proof surface is reviewable separately.
- Changed-file list for this card is the track doc only.

[Next] Suggested next slice
- Architect review / pressure review can proceed with this 29/29 sequential PASS record.
```
