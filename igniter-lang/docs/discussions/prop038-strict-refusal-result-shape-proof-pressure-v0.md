# PROP-038 Strict Refusal Result Shape Proof Pressure v0

Card: S3-R81-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: proof-pressure
Track: prop038-strict-refusal-result-shape-proof-pressure-v0
Route: UPDATE
Status: complete
Date: 2026-05-19

Authority ref:

- `docs/gates/prop038-strict-refusal-result-shape-decision-v0.md`

Inputs reviewed:

- `docs/tracks/prop038-strict-refusal-result-shape-proof-local-v0.md` (S3-R81-C1-P1)
- `docs/gates/prop038-strict-refusal-result-shape-decision-v0.md` (S3-R80-C4-A)
- `docs/tracks/stage3-round80-status-curation-v0.md` (S3-R80-C5-S)
- `experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb`
- `experiments/prop038_strict_refusal_result_shape_proof/out/prop038_strict_refusal_result_shape_proof_summary.json`

---

## Question

Does the proof-local strict-refusal result-shape experiment (C1-P1) stay inside
authorized write scope, correctly model both target result shapes, satisfy all
R80-C4-A required assertions, and preserve all closed surfaces without authorizing
live compile refusal or live implementation?

---

## Scope Checks

[1] Proof is proof-local only; no live compiler/orchestrator files changed.

Git commit `345c1b79` (`S3-R81-C1-P1`) changed exactly 5 files:
- `docs/org/current-map.md` (index update)
- `docs/org/indexes/prop038-strict-refusal-result-shape-proof-orientation-map-v0.md` (new)
- `docs/tracks/prop038-strict-refusal-result-shape-proof-local-v0.md` (new track)
- `experiments/prop038_strict_refusal_result_shape_proof/out/prop038_strict_refusal_result_shape_proof_summary.json` (new)
- `experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb` (new)

Physical scan confirms zero `lib/` or `bin/` files in the commit. Check: PASS.

[2] No `CompilerResult` code changed.

Confirmed by C1-P1 [X] Rejected section and git diff. `lib/igniter_lang/compiler_result.rb`
and all other `lib/` files are untouched. Check: PASS.

[3] Strict-refusal target shape matches R80 accepted key-set exactly.

R80-C4-A accepted the following 13-key public allowlist:
```text
kind, format_version, status, program_id, source_path, source_hash,
grammar_version, stages, igapp_path, contracts, compilation_report_path,
diagnostics, warnings
```

Proof `PUBLIC_KEY_ALLOWLIST` contains exactly these 13 keys in the same order.
Check `strict_refusal.public_key_allowlist_exact` PASS (verified by running
proof: 44/44 checks pass, 0 failed). Check: PASS.

[4] `compilation_report_path` is present and null.

Checks `strict_refusal.compilation_report_path_present_null` and
`configuration_error.compilation_report_path_present_null` both PASS.
The summary JSON confirms the field appears in the public result with value
`null`, not absent. R80-C4-A NB-2 convention (null-present) is machine-asserted.
Check: PASS.

[5] Malformed configuration-error target shape is as concrete as the refused
target shape.

Both `strict_refusal_case` and `malformed_strict_requirement_case` are built
with the same `result_shape(...)` helper function. The malformed case carries 10
named checks in the check matrix (status, public_key_allowlist_exact,
reason_distinct, not_digest_mismatch, compilation_report_path_present_null,
igapp_path_null, assemble_skipped, report_pass_result_ok, no_produced_paths,
top_level_report_diagnostics_unchanged), matching the precision level of the
refused case. R80-C4-A carry-forward pressure requirement is satisfied.
Check: PASS.

[6] Nested diagnostics isolation is proven.

Check `diagnostics.nested_isolated` PASS: asserts both
`internal_result["report"]["diagnostics"] == []` (top-level unchanged) and
`internal_result["report"]["compiler_profile_contract_validation"]["diagnostic_codes"]
== ["compiler_profile_contract.contract_digest_mismatch"]` (raw code stays
nested). Supported by `strict_refusal.nested_raw_validator_present` (PASS) and
`strict_refusal.top_level_report_diagnostics_unchanged` (PASS). Check: PASS.

[7] Public wrapper diagnostic shape is proven.

Check `strict_refusal.public_wrapper_only` PASS: confirms that
`public_diagnostic_codes == ["compiler_profile_contract_refusal.contract_digest_mismatch"]`.
Check `strict_refusal.raw_validator_not_public` PASS: confirms that raw code
`compiler_profile_contract.contract_digest_mismatch` is absent from the public
`diagnostics` field.
The wrapper diagnostic object carries `code`, `message`, `path`, and
`evidence_code` fields in the proof. `evidence_code` correctly back-links to the
nested raw validator code. Check: PASS.

[8] No sidecar/report/artifact path is produced by the proof target.

Checks `nonpersisting.no_sidecar_paths_modeled` and
`nonpersisting.no_igapp_paths_modeled` both PASS. Both modeled cases carry
`produced_paths: []`. No `.compilation_report.json` suffix and no `.igapp`
substring appear in any modeled path. Check: PASS.

[9] No `.igapp` artifact is produced by the proof target.

Confirmed by `nonpersisting.no_igapp_paths_modeled` PASS and by the internal
result shape having `igapp_path: null` for both modeled cases. Check: PASS.

[10] Command matrix and syntax checks are sufficient.

Two commands are listed:
- `ruby -c ... .rb` → PASS (syntax check, independently re-verified)
- `ruby ... .rb` → PASS (full run, independently re-verified: 3 cases, 44
  checks, 0 failed checks)

Both commands were re-run during this review and match C1-P1 claimed results
exactly. Check: PASS.

[11] Public API/CLI, loader/report, CompatibilityReport, runtime, and production
surfaces remain closed.

All 12 `non_authorizations_preserved` flags are `false`. The 10
`closed_surface_assertions` checks all PASS. Closed surfaces covered:
`live_compiler_orchestrator_changed`, `live_compile_refusal_enabled`,
`compiler_result_code_changed`, `public_api_cli_widened`,
`persisted_report_or_sidecar_written`, `parser_typechecker_semanticir_changed`,
`assembler_or_igapp_changed`, `loader_report_or_compatibility_report_changed`,
`diagnostics_centralization_changed`, `runtime_or_production_behavior_changed`,
`gate3_or_tbackend_behavior_changed`, `bihistory_stream_olap_cache_behavior_changed`.
Check: PASS.

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 1
```

All eleven scope checks pass. 44/44 proof checks PASS. 0 failed checks.

---

## Non-Blocking Notes

NB-1: C1-P1 correctly lists two open design questions in [Q]:

> "Should future live implementation keep `report.pass_result: ok` internally for
> all strict refusals, or only for digest-validation refusal paths?"

> "Should public `status: configuration_error` share the same allowlist
> permanently, or receive a smaller config-error-specific public surface?"

These are proof-local out-of-scope questions that are appropriately deferred.
C3-A should acknowledge them as open design questions to be resolved before any
live implementation authorization card, not as blockers for proof-local closure.
The first question is particularly important: if future live `refused` paths
reuse the `report` object from a baseline compile, preserving `pass_result: ok`
is the natural consequence of the accepted assembly boundary
(`report_for_assembly = report`). If `refused` is produced from a different
code path, the policy needs to be explicit.

---

## [Agree]

- The proof correctly limits write scope to `experiments/` and `docs/` only.
- Both `refused` and `configuration_error` target shapes are modeled with equal
  precision, satisfying the R80-C4-A carry-forward pressure requirement.
- The public key-set is machine-asserted exact: 13 keys, no more, no less, in
  accepted order.
- `compilation_report_path: null` null-present convention is machine-asserted for
  both target shapes.
- Raw validator code `compiler_profile_contract.contract_digest_mismatch` is
  machine-asserted absent from public result and machine-asserted present in
  nested validation diagnostics.
- Wrapper `compiler_profile_contract_refusal.contract_digest_mismatch` carries
  `evidence_code` back-link to the nested raw validator code — this is the correct
  pattern for a future implementation to follow.
- The 6-anchor `legacy_report_only_anchors_referenced` case verifies that all
  upstream proof summaries remain PASS and that the three key isolation invariants
  (public result unchanged, nested diagnostics only, no refusal report written)
  are still asserted by the R67/R71/R77 anchors.
- `compile_refusal_authorized: false` is preserved in both modeled validation
  objects, consistent with current live validator behavior and the proof-local
  boundary.

## [Challenge]

None. The proof scope, shape, command matrix, and isolation claims all match the
R80-C4-A gate requirements without introducing scope creep, vocabulary
confusion, or hidden authorization.

## [Missing]

- The proof does not cover a "no-strict-source" case where neither `refused` nor
  `configuration_error` should appear. This is not required by R80-C4-A for this
  card — that regression is already anchored by `prop038_strict_mode_trigger`
  (anchor PASS, verified in this proof's anchor case). Noted as an informational
  gap, not a blocker.

## [Sharper Question]

When future live implementation is authorized, should `report.pass_result` remain
`"ok"` for strict-refusal paths, or should it be changed to reflect the refusal?
The current proof models it as `"ok"` because the report represents the baseline
compile result before the strict-refusal layer. C3-A should confirm the
`pass_result: ok` policy is the accepted design intent, not just a proof artifact.

## [Route]

route: C3-A acceptance gate — `prop038-strict-refusal-result-shape-proof-local-acceptance-decision-v0.md`

---

## Handoff

Card: S3-R81-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Track: prop038-strict-refusal-result-shape-proof-pressure-v0
Status: done

[D] Decisions

- Proof-pressure review of C1-P1 (proof-local strict-refusal result-shape
  experiment) completed.
- All 11 scope checks pass.
- No blockers found.
- One non-blocking note routed to C3-A: two open design questions (pass_result
  policy and configuration_error allowlist surface) should be acknowledged as open
  before live implementation authorization.

[S] Shipped / Signals

- Added this discussion document.

[T] Tests / Proofs

- Re-ran both C1-P1 command matrix commands independently:
  `ruby -c` → `Syntax OK`, `ruby` → `PASS, 3 cases, 44 checks, 0 failed checks`.
- Physical git diff scan confirmed zero `lib/` or `bin/` files in `345c1b79`.

[R] Risks / Recommendations

- Proof is proof-local only; no live surfaces touched. No risks found.
- C3-A should confirm `report.pass_result: ok` is an accepted design invariant
  for the strict-refusal internal shape, not merely a proof artifact.

[Next] Suggested next slice

- C3-A should accept proof-local closure, acknowledge NB-1 open questions, and
  authorize only the next design route toward live implementation authorization.
  No live implementation card may open directly from R81.
