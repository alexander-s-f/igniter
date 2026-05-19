# PROP-038 Strict-Mode Refusal Trigger Proof-Local Pressure v0

Card: S3-R77-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Borrowed lens: refusal-pressure
Track: prop038-strict-mode-refusal-trigger-proof-local-pressure-v0

Question:
Does the proof-local strict-mode refusal trigger experiment (C1-I) stay inside
authorized write scope, correctly model `would_refuse` as proof-local vocabulary
only, hold all three non-mismatch candidates as control/fail-open, preserve
report-only live behavior, and satisfy the required command matrix without
implying any live compile refusal or forbidden surface widening?

Context:
- `docs/gates/prop038-strict-mode-refusal-trigger-design-decision-v0.md`
- `docs/tracks/prop038-strict-mode-refusal-trigger-proof-local-v0.md`
- `docs/tracks/stage3-round76-status-curation-v0.md`
- experiment: `experiments/prop038_strict_mode_refusal_trigger_proof/`

---

## Inputs Read

- `igniter-lang/docs/gates/prop038-strict-mode-refusal-trigger-design-decision-v0.md` (S3-R76-C4-A)
- `igniter-lang/docs/tracks/prop038-strict-mode-refusal-trigger-proof-local-v0.md` (S3-R77-C1-I)
- `igniter-lang/docs/tracks/stage3-round76-status-curation-v0.md` (S3-R76-C5-S)
- `igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb`
- `igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/out/prop038_strict_mode_refusal_trigger_proof_summary.json`
- git commit history for C1-I (HEAD commit `1a99f57e`)

---

## Scope Checks

### Check 1: Experiment stayed inside authorized write scope; no `lib` files changed

C4-A authorized write scope:

```text
igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/
igniter-lang/docs/tracks/prop038-strict-mode-refusal-trigger-proof-local-v0.md
```

C1-I git commit changes (HEAD):

```text
igniter-lang/docs/tracks/prop038-strict-mode-refusal-trigger-proof-local-v0.md
igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/out/prop038_strict_mode_refusal_trigger_proof_summary.json
igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb
igniter-lang/experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json
```

Three of four changed files are inside the authorized scope. The fourth
(`prop038_report_only_compiler_integration/out/...`) was refreshed as a side
effect of the required regression rerun command. This is addressed separately in
NB-1.

Physical scan confirms zero `igniter-lang/lib` files in the C1-I commit.

The experiment file uses:

```ruby
require_relative "../../lib/igniter_lang/compiler_profile_contract_validator"
```

This consumes the live validator as a read dependency only. No live validator file
was edited.

**Pass.** No `lib` files changed. Authorized write paths respected.

---

### Check 2: `would_refuse` is proof-local vocabulary only; `refused` is not introduced

The proof script defines the decision vocabulary:

```ruby
"decision_vocabulary" => %w[not_evaluated allow would_refuse configuration_error]
```

`refused` does not appear anywhere in the proof script or summary JSON. A scan of
the entire proof file confirms zero occurrences of the string `"refused"` except
as a substring of `"would_refuse"` and `"compiler_refusal_authorized"`.

All `trigger_evaluation` result objects set:

```json
"compiler_refusal_authorized": false
```

The summary check `compile_refusal_authorized_false` (pass: true) machine-asserts
this across all 12 cases.

The `would_refuse` decision appears only in the `trigger_evaluation` sub-object
of the proof case. It is not promoted to `CompilerResult`, report `pass_result`,
`stages`, or public result.

**Pass.** `would_refuse` is proof-local only; `refused` is not introduced.

---

### Check 3: Only `contract_digest_mismatch` maps to `would_refuse`

The strict requirement object used in the proof:

```json
{
  "refusal_candidates": [
    "compiler_profile_contract.contract_digest_mismatch"
  ]
}
```

In `trigger_evaluation`, the `would_refuse` branch is guarded by:

```ruby
if codes.include?(MISMATCH_CODE) && candidates.include?(MISMATCH_CODE)
```

This is a double gate: the diagnostic code must be present AND the strict
requirement must list it as a candidate. Only `MISMATCH_CODE` is in
`refusal_candidates`; no other code can satisfy both sides.

Verified from the summary:
- `strict_source_invalid_digest_held_control`: decision = `allow`, `held_control_diagnostics: ["compiler_profile_contract.contract_digest_invalid"]`
- `strict_source_unsupported_policy_configuration_error`: decision = `configuration_error`, not `would_refuse`
- `strict_source_recompute_unavailable_fail_open`: decision = `allow`, `recompute_unavailable_policy: "fail_open_report_only"`
- Only `strict_source_digest_mismatch_would_refuse` reaches `would_refuse`

Check `strict_invalid_digest.not_would_refuse` (pass: true) machine-asserts
`contract_digest_invalid` case does not reach `would_refuse`.

**Pass.** Only `contract_digest_mismatch` maps to `would_refuse`. All three
remaining candidates are held as control, `configuration_error`, or fail-open.

---

### Check 4: `contract_digest_invalid`, `policy_unsupported`, `recompute_unavailable` remain held/control/fail-open

Per C4-A candidate status:

| Diagnostic | C4-A decision |
| --- | --- |
| `contract_digest_invalid` | Held; control case only |
| `contract_digest_policy_unsupported` | Held; optional `configuration_error`, not refusal |
| `contract_digest_recompute_unavailable` | Held; `fail_open_report_only` |

Proof results:

- `contract_digest_invalid` → `allow` with `held_control_diagnostics: ["compiler_profile_contract.contract_digest_invalid"]`. Correct held/control.
- `contract_digest_policy_unsupported` → `configuration_error` with `configuration_error.path: "digest_reference_policy"`. Correctly not refusal.
- `contract_digest_recompute_unavailable` → `allow` with `held_control_diagnostics: ["compiler_profile_contract.contract_digest_recompute_unavailable"]` and `recompute_unavailable_policy: "fail_open_report_only"`. Correctly fail-open.

In `trigger_evaluation`, code paths explicitly demonstrate:

- `contract_digest_policy_unsupported` is checked before the held-controls block and yields `configuration_error_evaluation`
- `contract_digest_invalid` and `contract_digest_recompute_unavailable` fall into `held_controls` and yield `allow_evaluation`
- Neither path reaches the `would_refuse` return statement

**Pass.** All three non-mismatch candidates are correctly held/control/fail-open.

---

### Check 5: Report-only behavior remains the current live behavior

Report-only cases:

- `report_only_valid_contract`: decision = `not_evaluated`, `outcome_unchanged: true`
- `report_only_digest_mismatch_nested_only`: decision = `not_evaluated`, `outcome_unchanged: true`
- `no_strict_source_not_evaluated`: decision = `not_evaluated`, `outcome_unchanged: true`

In all three report-only cases:
- top-level diagnostics remain `[]`
- `pass_result`, `stages`, and `manifest` are unchanged
- `public_result` is unchanged
- `assembler_executed` is unchanged
- `refusal_report_written`, `compiler_result_changed`, `igapp_mutated`,
  `loader_report_touched`, `compatibility_report_touched`, `runtime_touched`,
  `production_touched` all remain false

The `same_outcome?` helper machine-asserts all of these dimensions in a single
call. Checks `report_only_valid_contract.unchanged` and `public_result_unchanged`
(both pass: true) verify this.

Check `report_only_mismatch.nested_diagnostic_only` (pass: true) verifies that
digest mismatch under report-only mode: (a) does have the mismatch code in
`validation_diagnostic_codes`; AND (b) has empty `top_level_diagnostics`.

**Pass.** Report-only behavior is preserved exactly.

---

### Check 6: Nil, non-Hash, provider-error, validator-error paths stay no-field/no-refusal

Four legacy path cases:

| Case | `report_has_validation_field` | `compiler_refusal_decision` |
| --- | --- | --- |
| `nil_provider_no_field_no_refusal` | false | `not_evaluated` |
| `non_hash_provider_no_field_no_refusal` | false | `not_evaluated` |
| `provider_error_no_field_no_refusal` | false | `not_evaluated` |
| `validator_error_no_field_no_refusal` | false | `not_evaluated` |

All four have `outcome_unchanged: true` and `pass: true`.

In the proof script:

- `nil_validation = validate_contract(nil)` — `nil.is_a?(Hash)` is false; returns nil
- `non_hash_validation = validate_contract("not a contract hash")` — `String.is_a?(Hash)` is false; returns nil
- `provider_error_validation = nil` — directly nil
- `validator_error_validation = validate_contract(canonical_contract, validator_error: true)` — raises; rescued to nil

When `validation` is nil, `annotate_report_only` returns the unannotated baseline
(no validation field added). When `trigger_evaluation` receives nil validation
and any strict_requirement, it hits `return not_evaluated_evaluation unless validation`
at line 153, returning `not_evaluated` before reaching any refusal logic.

Notably: even with `strict_requirement: STRICT_REQUIREMENT` present, all four
nil/non-Hash/error cases still return `not_evaluated`. The strict requirement
cannot force evaluation without a valid validation result.

Check `legacy_paths.no_field_no_refusal` (pass: true) machine-asserts all four
paths simultaneously.

**Pass.** All legacy/error paths stay no-field/no-refusal.

---

### Check 7: Required command matrix passed

C4-A required commands:

| Command | Required result |
| --- | --- |
| `ruby -c ...proof.rb` | PASS (Syntax OK) |
| `ruby ...proof.rb` | PASS |
| `ruby ...compiler_profile_contract_proof.rb` | PASS |
| `ruby ...prop038_report_only_compiler_integration.rb` | PASS |

C1-I command matrix table confirms all four PASS.

Regression summaries:

```text
compiler_profile_contract_proof_summary.json: status=PASS cases=13 checks=30 failed=0
prop038_report_only_compiler_integration_summary.json: status=PASS cases=5 checks=20 failed=0
```

Both counts match the accepted R74 case/check numbers exactly (13/30 and 5/20).

**Pass.** All four required commands passed; regression counts are unchanged.

---

### Check 8: No public API/CLI, `CompilerResult`, `.igapp`, loader/report, CompatibilityReport, RuntimeMachine, Gate 3, or production authority implied

The proof script requires only:

```ruby
require "fileutils"
require "json"
require_relative "../../lib/igniter_lang/compiler_profile_contract_validator"
```

No `IgniterLang::CompilerOrchestrator`, `IgniterLang::CLI`, `IgniterLang::CompilerResult`,
`IgniterLang::Assembler`, or any loader/report/CompatibilityReport class is
referenced. The proof uses only the internal validator.

The baseline and outcome models (`baseline_compile`, `same_outcome?`) are
proof-local stubs. No real compiler is invoked. No file is written to `lib/`,
`.igapp` paths, or any production artifact location. The proof writes only to
its own `out/` directory.

The `non_authorizations_preserved` summary block (all values false):

```json
"non_authorizations_preserved": {
  "live_compiler_orchestrator_behavior": false,
  "live_compile_refusal": false,
  "public_api_cli_widening": false,
  "compiler_result_changes": false,
  "persisted_reports_or_sidecars_outside_proof": false,
  "parser_typechecker_semanticir_assembler_igapp": false,
  "loader_report_or_compatibility_report": false,
  "diagnostics_centralization": false,
  "runtime_gate3_ledger_tbackend_bihistory_stream_olap_cache_production": false
}
```

**Pass.** No forbidden surfaces are implied or touched.

---

### Check 9: Wrapper codes appear only in proof-local trigger evaluation; not in validator or live report

The wrapper code `compiler_profile_contract_refusal.contract_digest_mismatch`
appears only inside `wrapper_evidence` arrays within trigger evaluation results.
It does not appear in:
- `validation_diagnostic_codes` (which come from the live validator)
- `top_level_diagnostics` (the report-level field)
- any `CompilerResult` or public result field
- any `IgniterLang::Diagnostics` reference

Check `wrapper_codes_proof_local_only` (pass: true) verifies that every entry in
every `wrapper_evidence` array across all 12 cases has `code.start_with?("compiler_profile_contract_refusal.")`.

Only one case (`strict_source_digest_mismatch_would_refuse`) has a non-empty
`wrapper_evidence` array.

**Pass.** Wrapper codes are correctly scoped to proof-local trigger evaluation.

---

## Verdict

```text
proceed
blockers: none
non-blocking notes: 1
```

---

## Non-Blocking Note

### NB-1: Rerun artifact outside primary authorized write scope — expected and correct

The C4-A authorized write scope names two paths:

```text
igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/
igniter-lang/docs/tracks/prop038-strict-mode-refusal-trigger-proof-local-v0.md
```

The required regression rerun command:

```bash
ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
```

writes a refreshed summary to:

```text
igniter-lang/experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json
```

This path is outside the primary authorized scope. However:

1. The rerun command is explicitly required by C4-A (required command matrix, item 4).
2. No R67 code was edited; only the output artifact was refreshed.
3. The semantic delta is the addition of `compiler_profile_contract.contract_digest_mismatch`
   alongside the existing `compiler_profile_contract.wrong_kind` in the
   invalid-contract case — precisely the R74 live validator behavior that was
   accepted before this card.
4. This output was always expected to change after R74's live validator landed,
   since the rerun now exercises a live validator that knows how to compute digest
   diagnostics. The delta is correct, not a scope violation.

C3-A should acknowledge that the rerun artifact update was a natural consequence
of running the required command and represents accepted R74 live behavior, not
unauthorized code change. This is documentation confirmation only.

---

## Summary

The proof-local experiment is correctly contained. The proof script creates and
consumes a gate-controlled strict requirement object, evaluates it against live
`IgniterLang::CompilerProfileContractValidator` output, and produces a 12-case
trigger evaluation matrix. Only `contract_digest_mismatch` produces `would_refuse`.
The remaining three digest candidates are held as control (`contract_digest_invalid`),
policy-error (`contract_digest_policy_unsupported`), and fail-open
(`contract_digest_recompute_unavailable`). All four legacy/error paths produce
`not_evaluated` and no validation field even when a strict requirement is
present. `compile_refusal_authorized` is hard-coded false across all 12 cases.
The `refused` vocabulary is absent. All 15 checks pass. Four required commands
pass with unchanged regression counts.

The only note for C3-A is the expected rerun artifact delta (NB-1), which is
correct R74 live behavior and not a scope issue.

---

## [Agree]

- Proof scope is correctly bounded: only `lib/` is consumed (not edited), only
  the authorized experiment directory is written, and the trigger evaluator is
  entirely proof-local Ruby code.
- `would_refuse` + `compiler_refusal_authorized: false` is the correct
  proof-local vocabulary — it models what a live refusal gate would decide
  without actually refusing anything.
- The double-guard `codes.include?(MISMATCH_CODE) && candidates.include?(MISMATCH_CODE)`
  correctly prevents any future expansion of `refusal_candidates` from
  accidentally widening the proof without explicit change.
- The nil/non-Hash/error paths returning `not_evaluated` even when strict
  requirement is present is the correct behavior — strict requirement cannot
  override missing validation.
- The recompute-unavailable `allow` with `recompute_unavailable_policy: "fail_open_report_only"`
  in the trigger evaluation correctly records the policy alongside the decision,
  providing clear evidence for future fail-closed design.

## [Challenge]

None. All 9 scope checks pass. The proof model is faithful to C4-A's authorized
vocabulary and candidate table.

## [Missing]

- C3-A should formally acknowledge NB-1 (rerun artifact outside primary write
  scope is expected/authorized by the required-command mandate and represents
  accepted R74 live behavior). This closes the scope ambiguity without opening
  additional work.

## [Sharper Question]

Does C3-A accept this proof as closing the proof-local strict-mode refusal trigger
experiment, such that the remaining open blockers for live refusal implementation
(production source, live compiler/orchestrator boundary, `CompilerResult` model,
refusal report shape, fail-closed policy, assembly boundary) are acknowledged as
the only remaining gates before any live refusal authorization?

## [Route]

```text
track: C3-A acceptance gate
```

C3-A should accept the proof-local experiment and record the remaining open
blockers before any live refusal implementation. No further proof-local work is
needed unless a fail-closed policy experiment or `contract_digest_invalid` as
refusal candidate is separately authorized.
