# Discussion: PROP-038 Contract Digest Report-Only Integration Proof Pressure v0

Card: S3-R71-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Borrowed lens: proof-pressure
Mode: discussion
Initiator: user
Track: prop038-contract-digest-report-only-integration-proof-pressure-v0

Depends on: S3-R71-C1-P1 delivered

Question:

Are all required report-only integration cases present and passing? Are
all four digest diagnostics covered? Do digest diagnostics stay nested
under `compiler_profile_contract_validation`? Do top-level report
diagnostics, `pass_result`, stages, compile status, public result,
assembler execution, `.igapp`, and refusal reports remain unchanged? Does
nil and exception provider behavior remain legacy/no field? Did no live
validator/compiler implementation change? Is no compile-refusal behavior
created? Is no public API/CLI, `CompilerResult`, loader/report,
CompatibilityReport, RuntimeMachine, Gate 3, or production authority
implied? Does the summary JSON include the required
`non_authorizations_preserved` block?

Context:
- R70-C3-A (gate): Accepts proof-local recompute-match closure;
  authorizes proof-local `prop038-contract-digest-report-only-integration-proof-v0`
  only; requires `non_authorizations_preserved` block; holds live
  validator implementation, compile refusal, and all production surfaces
- R70-C2-X (pressure): Proceed; no blockers; NB-1 (non-blocking):
  `non_authorizations_preserved` block absent in R70 summary
- R71-C1-P1: Research Agent — proof-local integration model; models
  `digest_validation` and `annotate_report_only` inside experiment script;
  does not edit live validator, compiler, or any production file;
  12 cases / 21 checks / PASS

---

## Scope Check 1 — All Required Report-Only Integration Cases Are Present And Pass

The summary JSON contains exactly 12 cases. All 12 pass:

| Case | Expected | Pass |
| --- | --- | --- |
| `valid_digest_report_only_valid_true` | `valid=true` nested validation, baseline outcome | ✓ |
| `shape_invalid_report_only_valid_false` | `contract_digest_invalid` nested, baseline outcome | ✓ |
| `unsupported_policy_report_only_valid_false` | `contract_digest_policy_unsupported` nested, baseline outcome | ✓ |
| `recompute_mismatch_report_only_valid_false` | `contract_digest_mismatch` nested, baseline outcome | ✓ |
| `recompute_unavailable_report_only_valid_false` | `contract_digest_recompute_unavailable` nested, baseline outcome | ✓ |
| `combined_shape_and_recompute_diagnostics_stay_nested` | multi-diagnostic nesting, top-level diagnostics unchanged | ✓ |
| `mismatch_compile_status_ok` | compile status `ok` | ✓ |
| `mismatch_public_result_unchanged` | public result unchanged | ✓ |
| `mismatch_igapp_manifest_unchanged` | manifest unchanged | ✓ |
| `mismatch_no_refusal_report_written` | no refusal report | ✓ |
| `provider_nil_preserves_legacy_behavior` | no nested field, baseline outcome | ✓ |
| `provider_exception_preserves_legacy_behavior` | no nested field, baseline outcome | ✓ |

The first five cases each independently verify both the diagnostic
result AND that the compile/report/manifest envelope is identical to
baseline (via `same_outcome?`). The `mismatch_*` block then drills into
each dimension of the mismatch case individually. The last two cases
verify the nil/exception provider paths. `cases_all_pass: true`
confirms the joint result. ✓

---

## Scope Check 2 — All Four Digest Diagnostics Are Covered

The check `diagnostic_coverage.all_four_codes: true` asserts that the
union of all diagnostic codes observed across all 12 cases equals the
required four-code set:

```json
"required_codes": [
  "compiler_profile_contract.contract_digest_invalid",
  "compiler_profile_contract.contract_digest_mismatch",
  "compiler_profile_contract.contract_digest_policy_unsupported",
  "compiler_profile_contract.contract_digest_recompute_unavailable"
],
"observed_codes": [
  "compiler_profile_contract.contract_digest_invalid",
  "compiler_profile_contract.contract_digest_mismatch",
  "compiler_profile_contract.contract_digest_policy_unsupported",
  "compiler_profile_contract.contract_digest_recompute_unavailable"
]
```

Required and observed sets are identical. The `diagnostic_coverage`
block in the summary is a machine-computed cross-case aggregate — the
proof collects all codes emitted by validation results across all cases
and compares the sorted unique set against the sorted required set.

Each code is observed from a distinct named case:
- `contract_digest_invalid` — `shape_invalid_report_only_valid_false`
- `contract_digest_policy_unsupported` — `unsupported_policy_report_only_valid_false`
- `contract_digest_mismatch` — `recompute_mismatch_report_only_valid_false`
- `contract_digest_recompute_unavailable` — `recompute_unavailable_report_only_valid_false`

All four `contract_digest_*` diagnostic candidates from R68-C1-P1 are
now proven to flow through the report-only validation result in the
expected nested form. ✓

---

## Scope Check 3 — Digest Diagnostics Stay Nested Under `compiler_profile_contract_validation`

Two named checks enforce nesting:

**`nested_diagnostics.only`**: Asserts that for all five annotated runs
with digest failures (`shape_invalid_run`, `unsupported_policy_run`,
`mismatch_run`, `unavailable_run`, `combined_run`):
1. `run["report"].key?("compiler_profile_contract_validation")` is true
   (the nested key is present).
2. `run["report"]["diagnostics"] == baseline["report"]["diagnostics"]`
   (top-level diagnostics are unchanged).

**`top_level_diagnostics_unchanged`**: Directly asserts `mismatch_run["report"]["diagnostics"] == baseline["report"]["diagnostics"]`.

The `combined_shape_and_recompute_diagnostics_stay_nested` case is the
most stringent nesting test: it constructs a validation result carrying
two diagnostic codes simultaneously and confirms they both land inside
`report["compiler_profile_contract_validation"]["diagnostics"]`:

```json
"diagnostics": [
  { "code": "compiler_profile_contract.contract_digest_invalid", ... },
  { "code": "compiler_profile_contract.contract_digest_recompute_unavailable", ... }
]
```

while `report["diagnostics"]` remains `[]`. The case assertion checks:

```ruby
combined_run["report"]["compiler_profile_contract_validation"]["diagnostic_codes"].sort ==
  %w[...contract_digest_invalid ...contract_digest_recompute_unavailable].sort &&
combined_run["report"]["diagnostics"] == baseline["report"]["diagnostics"]
```

The `annotate_report_only` function confirms how this is implemented:

```ruby
run["report"] = run.fetch("report").merge(
  "compiler_profile_contract_validation" => validation
)
```

This merges one new key into the report hash. It does not touch
`report["diagnostics"]`, `report["pass_result"]`, or any other key.
The nesting invariant is structural and cannot be violated by the
merge pattern. ✓

---

## Scope Check 4 — Top-Level Report Fields, Compile Status, Public Result, Assembler, Manifest, And Refusal Report Remain Unchanged

The `same_outcome?` function provides a 7-dimensional baseline
comparison used across 10 of the 12 cases:

```ruby
def same_outcome?(baseline, run)
  run.fetch("status") == baseline.fetch("status") &&
    run.fetch("public_result") == baseline.fetch("public_result") &&
    run.fetch("manifest") == baseline.fetch("manifest") &&
    run.fetch("report").fetch("pass_result") == baseline.fetch("report").fetch("pass_result") &&
    run.fetch("report").fetch("stages") == baseline.fetch("report").fetch("stages") &&
    run.fetch("report").fetch("diagnostics") == baseline.fetch("report").fetch("diagnostics") &&
    run.fetch("assembler_executed") == baseline.fetch("assembler_executed") &&
    run.fetch("refusal_report_written") == false
end
```

Eight named checks independently assert each dimension for the mismatch
case (the most important case since mismatch is an active error):

```text
pass_result_unchanged         → true
stages_unchanged              → true
compile_status_ok             → true
public_result_unchanged       → true
assembler_execution_unchanged → true
igapp_manifest_unchanged      → true
no_refusal_report_written     → true
top_level_diagnostics_unchanged → true
```

The `report_only_invariants` block in the summary records all nine
invariants from the R68-C1-P1 Phase 2 required integration check list:

```json
"report_only_invariants": {
  "diagnostics_nested_under": "compiler_profile_contract_validation.diagnostics",
  "top_level_report_diagnostics_unchanged": true,
  "pass_result_unchanged": true,
  "stages_unchanged": true,
  "compile_status_ok_when_source_compiles": true,
  "public_result_unchanged": true,
  "assembler_execution_unchanged": true,
  "igapp_manifest_unchanged": true,
  "refusal_report_written": false
}
```

The nine invariants match the Phase 2 required integration checks
specified in R68-C1-P1 exactly. Each is independently machine-asserted
either via `same_outcome?` (in the per-case assertion) or a named check
(in the aggregate assertions). ✓

---

## Scope Check 5 — Nil And Exception Provider Behavior Remains Legacy/No Field

**`provider_nil_preserves_legacy_behavior`**: Verifies `!nil_run["report"].key?("compiler_profile_contract_validation")` — the nested field is absent — and `same_outcome?(baseline, nil_run)` — the compile envelope is identical to baseline.

**`provider_exception_preserves_legacy_behavior`**: Verifies `exception_run["provider_exception_swallowed"] == true` (the exception was handled and suppressed, not re-raised), `!exception_run["report"].key?("compiler_profile_contract_validation")` — no nested field added — and `same_outcome?(baseline, exception_run)`.

Both cases use the same `same_outcome?` check as the digest-failure
cases, confirming the nil and exception paths preserve the compile
envelope in the same dimensions.

The `provider_nil_run` and `provider_exception_run` functions model the
correct handling: nil provider returns a clean copy of baseline;
exception provider returns a copy with `provider_exception_swallowed:
true` but without the nested validation field. This mirrors the
`rescue; nil` policy accepted in R67-C3-A and implemented in
`compiler_orchestrator.rb`. ✓

---

## Scope Check 6 — No Live Validator Or Compiler Implementation Changed

The proof loads the live validator for one specific regression check:

```ruby
live_invalid_digest_contract["contract_digest"] = "compiler_profile_contract/sha256:ABC"
live_validator_result = IgniterLang::CompilerProfileContractValidator.validate(live_invalid_digest_contract)
```

The live validator is called on a contract with an uppercase hex
`contract_digest`. Since the live validator does not currently validate
`contract_digest` format, it returns `valid: true` with no
`contract_digest_*` diagnostics. The check
`regression.live_validator_no_contract_digest_behavior` asserts:

```ruby
live_validator_result["valid"] == true &&
  live_validator_result["diagnostic_codes"].none? { |code| code.include?("contract_digest") }
```

This is the correct proof of unchanged live validator behavior: it
deliberately sends a contract with an invalid `contract_digest` to
confirm that the live validator produces no `contract_digest_*`
diagnostic. Any modification to the live validator that added
`contract_digest` checking would cause this assertion to fail.

Summary top-level:

```json
"live_validator_changed": false,
"compiler_integration_changed": false,
"digest_report_only_live_implemented": false
```

All proof-local validation functions (`digest_validation`,
`annotate_report_only`, `baseline_compile`, `canonical_material`, etc.)
are defined at script level and do not extend or monkey-patch the live
validator. `ruby -c lib/igniter_lang/compiler_profile_contract_validator.rb`
→ `Syntax OK` confirms the file is unchanged. ✓

---

## Scope Check 7 — No Compile-Refusal Behavior Created

Every validation result carries `"compile_refusal_authorized": false`.
Three named checks guard at every layer:

```text
compile_refusal_false.proof_local   → true  (all 6 proof-local validations)
compile_refusal_false.live_validator → true  (live validator sample)
compile_refusal_false.r67_report_only → true  (R67 integration cases)
```

Physical scans:

```text
no_igapp_mutation_from_this_proof       → true  (no *.igapp in out/)
no_refusal_report_created_by_this_proof → true  (no "refusal" filenames in out/)
```

The `mismatch_no_refusal_report_written` case explicitly asserts
`mismatch_run["refusal_report_written"] == false`. The `same_outcome?`
check also asserts `run.fetch("refusal_report_written") == false` for
every annotated run. Refusal is guarded at both case level and aggregate
check level. ✓

---

## Scope Check 8 — No Public API/CLI, CompilerResult, Loader/Report, CompatibilityReport, RuntimeMachine, Gate 3, Or Production Authority Implied

The summary carries `implementation_authorized: false` at the top level
and `digest_report_only_live_implemented: false` in every validation
result. The only files produced by this proof are:

```text
experiments/prop038_contract_digest_report_only_integration_proof/
  prop038_contract_digest_report_only_integration_proof.rb
  out/prop038_contract_digest_report_only_integration_proof_summary.json
docs/tracks/prop038-contract-digest-report-only-integration-proof-v0.md
```

All three are within the R70-C3-A authorized write boundary. The track
document non-authorization section enumerates each held surface
individually. The `recommendation_for_c3_a: "accept"` field includes
the guidance: "Do not authorize live implementation or compile refusal
from this proof." The suggested next route — if Architect authorizes
design — is `prop038-contract-digest-live-implementation-design-v0`,
which is correctly separated from this proof's authorization. ✓

---

## Scope Check 9 — Summary JSON Includes The Required `non_authorizations_preserved` Block

The R70-C3-A gate required: "must include `non_authorizations_preserved`."
The R70-C2-X NB-1 noted this block was absent from R70's summary.

The R71 summary restores the block with 10 keys, all false:

```json
"non_authorizations_preserved": {
  "live_validator_implementation": false,
  "compiler_orchestrator_integration": false,
  "compile_refusal": false,
  "public_api_cli_widening": false,
  "compiler_result_changes": false,
  "persisted_success_reports_or_sidecars": false,
  "parser_typechecker_semanticir_assembler_igapp": false,
  "loader_report_or_compatibility_report": false,
  "diagnostics_centralization": false,
  "runtime_gate3_ledger_tbackend_bihistory_stream_olap_cache_production": false
}
```

The key `compiler_orchestrator_integration` replaces
`recompute_match_proof_implementation` from R69, reflecting the correct
concern at this phase: the integration path was not touched. All ten
keys cover the full R57-R67 hold inventory. R70 NB-1 is closed. ✓

The `authority_ref` correctly cites the R70-C3-A gate:

```json
"authority_ref": "igniter-lang/docs/gates/prop038-contract-digest-recompute-match-proof-decision-v0.md"
```

---

[Agree]

1. **All 12 required cases present and passing.** `cases_all_pass:
   true`; `same_outcome?` confirms 7-dimensional baseline match in each
   digest-failure case; mismatch drill-downs independently assert each
   invariant dimension.

2. **All four digest diagnostic codes observed and machine-verified.**
   `diagnostic_coverage.all_four_codes: true`; cross-case code union
   equals required set exactly; each code traced to a distinct named
   case.

3. **Nesting invariant is structural and multi-diagnostic.** `annotate_report_only`
   merges exactly one key into the report hash without touching
   `diagnostics`; `nested_diagnostics.only` asserts this holds across
   all five failure cases; `combined_shape_and_recompute_diagnostics_stay_nested`
   proves two codes coexist inside the nested field while top-level
   `diagnostics` stays empty.

4. **Nine required report-only invariants machine-asserted.** Both via
   per-case `same_outcome?` and independent named checks; `report_only_invariants`
   summary block records all nine with named keys matching R68-C1-P1
   integration check list.

5. **Nil and exception provider paths confirmed legacy/no field.**
   Neither nil nor exception adds the nested validation key; both
   produce `same_outcome?` with baseline; exception correctly swallowed
   not re-raised.

6. **Live validator confirmed unchanged by deliberate negative probe.**
   A contract with invalid uppercase hex `contract_digest` passed to
   the live validator returns `valid: true` with no `contract_digest_*`
   diagnostics — proving the live validator still does not check
   `contract_digest` format. This is a stronger regression check than
   R69/R70's passive `valid == false` assertions.

7. **Compile refusal blocked at three layers plus two physical scans.**
   Per-validation result flag, live validator flag, R67 integration
   flag; no `.igapp` in output; no refusal filename in output.

8. **No production surface implied.** Write boundary is experiment
   directory only; suggested next route correctly separated as a
   design card.

9. **`non_authorizations_preserved` block restored.** R70 NB-1 closed.
   10-key block present with correct key names for this phase.

---

[Challenge]

None that rise to blocking level.

---

[Missing]

None required before the C3-A acceptance decision.

---

## Verdict

**Proceed.**

All nine scope checks pass. The 12-case integration matrix covers all
four `contract_digest_*` diagnostic codes in report-only nested form,
verified by a machine-computed cross-case code union check. The nesting
invariant is proven both structurally (the `annotate_report_only` merge
pattern cannot affect `report["diagnostics"]`) and empirically (named
checks across all five failure cases, plus a multi-diagnostic combined
case). Nine report-only invariants — from the R68-C1-P1 required
integration check list — are machine-asserted via both per-case
`same_outcome?` comparisons and independent named checks. Nil and
exception provider paths are confirmed to preserve baseline behavior
with no nested validation field. The live validator regression uses a
deliberate negative probe (invalid uppercase hex) to actively confirm no
`contract_digest_*` behavior was introduced. Compile refusal is guarded
at three independent layers and two physical output scans. R70 NB-1 is
closed — the `non_authorizations_preserved` block is restored with 10
keys. 21 checks / 0 failures.

No blockers. No non-blocking notes.

---

[Route]

**Verdict: proceed.**

No blockers. No non-blocking notes.

**Recommended Architect decision (C3-A):**

1. Accept the proof-local Phase 3 report-only integration closure. All
   12 required cases pass. 21 checks / 0 failures. R70 NB-1 closed.

2. Confirm the full three-phase proof chain is now complete:
   - Phase 1 (R69): 8-case shape-policy proof — `contract_digest_invalid`,
     `contract_digest_policy_unsupported`
   - Phase 2 (R70): 14-case recompute-match / canonicalization proof —
     `contract_digest_mismatch`, `contract_digest_recompute_unavailable`
   - Phase 3 (R71): 12-case report-only integration proof — all four
     codes flow through nested validation without changing compiler
     outcome

3. If authorizing the next step, two routes are available. Authorize
   only one per decision:
   - **PROP-038 errata route**: A Compiler/Grammar Expert card adds the
     four `contract_digest_*` diagnostic codes and the canonicalization
     policy text to PROP-038. Appropriate if diagnostic vocabulary
     should be formalized before implementation design begins.
   - **Live implementation design route**:
     `prop038-contract-digest-live-implementation-design-v0` —
     Compiler/Grammar Expert designs the exact bounded implementation
     slice (shape-only in the live validator first, or combined
     shape + recompute together; integration scope; report-only
     constraints). Appropriate if implementation design is the next
     priority.
   - Both routes require their own pressure review and Architect
     authorization before any code changes.

4. Hold live validator implementation until an explicit implementation
   authorization gate. The three proof phases together constitute the
   evidence base; they are not implementation authorization.

5. Hold compile refusal. The four-condition chain from R68-C3-A
   (condition 5) requires a separate compile-refusal gate even after
   implementation is live and proven stable.

6. All surfaces held by R70-C3-A remain closed: live validator/compiler
   implementation, compile refusal, public API/CLI, `CompilerResult`,
   persisted reports, sidecars, assembler/`.igapp`, loader/report,
   CompatibilityReport, `IgniterLang::Diagnostics`, RuntimeMachine,
   Gate 3, and production behavior.
