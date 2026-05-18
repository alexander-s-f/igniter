# PROP-038 Contract Digest Report-Only Integration Proof v0

Card: S3-R71-C1-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/prop038-contract-digest-report-only-integration-proof-v0
Route: UPDATE
Status: done
Date: 2026-05-18

Authority ref:

- `docs/gates/prop038-contract-digest-recompute-match-proof-decision-v0.md`

Affected neighbor roles:

- [Igniter-Lang Compiler/Grammar Expert] - future PROP-038 diagnostic/report wording.
- [Igniter-Lang Bridge Agent] - future report-only consumer; no bridge behavior changed.

---

## Scope

Build a proof-local experiment showing that PROP-038 digest diagnostics from the
shape-policy and recompute-match models can flow through a report-only
validation result without changing compiler outcomes or public surfaces.

Read:

- `docs/gates/prop038-contract-digest-recompute-match-proof-decision-v0.md`
- `docs/gates/prop038-contract-digest-shape-policy-proof-decision-v0.md`
- `docs/gates/prop038-contract-digest-validation-policy-decision-v0.md`
- `docs/gates/prop038-report-only-compiler-integration-acceptance-decision-v0.md`
- `docs/gates/prop038-library-validator-extraction-acceptance-decision-v0.md`
- `docs/tracks/prop038-contract-digest-recompute-match-proof-v0.md`
- `docs/discussions/prop038-contract-digest-recompute-match-proof-pressure-v0.md`
- `docs/tracks/stage3-round70-status-curation-v0.md`
- `experiments/prop038_contract_digest_recompute_match_proof/out/prop038_contract_digest_recompute_match_proof_summary.json`
- `experiments/prop038_contract_digest_shape_policy_proof/out/prop038_contract_digest_shape_policy_proof_summary.json`
- `experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json`

The proof models digest validation and report-only annotation locally inside the
experiment. It does not edit the live validator, compiler, orchestrator,
CompilationReport, public API/CLI, assembler, runtime, or `.igapp` artifacts.

---

## Produced

```text
igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/
  prop038_contract_digest_report_only_integration_proof.rb
  out/prop038_contract_digest_report_only_integration_proof_summary.json
```

Track doc:

```text
igniter-lang/docs/tracks/prop038-contract-digest-report-only-integration-proof-v0.md
```

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb` | `PASS prop038_contract_digest_report_only_integration_proof` |
| `ruby -c igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb` | `Syntax OK` |
| `ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb` | `PASS prop038_contract_digest_recompute_match_proof` |
| `ruby -c igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb` | `Syntax OK` |
| `ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | `PASS prop038_contract_digest_shape_policy_proof` |
| `ruby -c igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | `Syntax OK` |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | `PASS prop038_report_only_compiler_integration` |
| `ruby -c igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | `Syntax OK` |
| `ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | `PASS compiler_profile_contract_proof` |
| `ruby -c igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb` | `Syntax OK` |

---

## Case Matrix

| Case | Expected | Result |
| --- | --- | --- |
| `valid_digest_report_only_valid_true` | valid nested report-only validation | PASS |
| `shape_invalid_report_only_valid_false` | `compiler_profile_contract.contract_digest_invalid` nested | PASS |
| `unsupported_policy_report_only_valid_false` | `compiler_profile_contract.contract_digest_policy_unsupported` nested | PASS |
| `recompute_mismatch_report_only_valid_false` | `compiler_profile_contract.contract_digest_mismatch` nested | PASS |
| `recompute_unavailable_report_only_valid_false` | `compiler_profile_contract.contract_digest_recompute_unavailable` nested | PASS |
| `combined_shape_and_recompute_diagnostics_stay_nested` | digest diagnostics live only under `compiler_profile_contract_validation.diagnostics` | PASS |
| `mismatch_compile_status_ok` | compile status remains `ok` | PASS |
| `mismatch_public_result_unchanged` | public result unchanged | PASS |
| `mismatch_igapp_manifest_unchanged` | manifest unchanged | PASS |
| `mismatch_no_refusal_report_written` | no refusal report | PASS |
| `provider_nil_preserves_legacy_behavior` | no validation report and baseline outcome | PASS |
| `provider_exception_preserves_legacy_behavior` | no validation report and baseline outcome | PASS |

---

## Diagnostic Coverage

All four digest diagnostic candidates are observed:

```text
compiler_profile_contract.contract_digest_invalid
compiler_profile_contract.contract_digest_policy_unsupported
compiler_profile_contract.contract_digest_mismatch
compiler_profile_contract.contract_digest_recompute_unavailable
```

All digest diagnostics are nested under:

```text
compiler_profile_contract_validation.diagnostics
```

Top-level `report["diagnostics"]` remains unchanged.

---

## Report-Only Invariants

The proof records these invariants as true:

- digest diagnostics live under `compiler_profile_contract_validation.diagnostics`;
- top-level `report["diagnostics"]` remains unchanged;
- `pass_result` remains unchanged;
- `stages` remain unchanged;
- compile status remains `ok` when source otherwise compiles;
- public result remains unchanged;
- assembler execution remains unchanged;
- `.igapp` manifest remains unchanged;
- no refusal report is written.

The proof uses a modeled compile/report/manifest envelope to keep this card
proof-local. It references and reruns the existing R67 report-only integration
proof as the live compiler behavior regression.

---

## Regression Checks

Summary state:

```json
{
  "status": "PASS",
  "failed_checks": [],
  "shape_policy_proof_status": "PASS",
  "recompute_match_proof_status": "PASS",
  "report_only_integration_status": "PASS",
  "live_validator_changed": false,
  "compiler_integration_changed": false,
  "digest_report_only_live_implemented": false,
  "compile_refusal_authorized": false,
  "implementation_authorized": false
}
```

Regression signals:

- R70 recompute-match proof remains PASS;
- R69 shape-policy proof remains PASS;
- R67 report-only integration remains PASS;
- existing 13-case validator matrix remains PASS;
- live validator still has no `contract_digest_*` behavior;
- `compile_refusal_authorized=false` remains true for proof-local, live
  validator, and report-only integration paths;
- proof output contains no `.igapp` artifact;
- proof output contains no refusal report.

---

## Non-Authorizations Preserved

```json
{
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

No live validator implementation.

No compiler/orchestrator integration implementation.

No compile refusal.

No public API/CLI widening.

No `CompilerResult` changes.

No persisted success reports or sidecars.

No parser, TypeChecker, SemanticIR, assembler, or `.igapp` mutation except
proof-local generated output and allowed rerun of existing proof-local outputs.

No loader/report or CompatibilityReport.

No `IgniterLang::Diagnostics` centralization.

No RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or
production behavior.

---

## Recommendation For C3-A

Recommendation:

```text
accept
```

Reason:

- all required report-only cases pass;
- all four digest diagnostics flow through nested validation diagnostics;
- compile/report/public/manifest/refusal invariants remain unchanged;
- provider nil and exception behavior preserve legacy behavior;
- R70, R69, R67, and 13-case validator regressions remain PASS;
- live implementation and compile refusal remain closed.

Recommended next route after acceptance:

```text
prop038-contract-digest-live-implementation-design-v0
```

only if Architect explicitly authorizes design. This proof does not itself
authorize implementation.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/prop038-contract-digest-report-only-integration-proof-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Modeled shape and recompute digest diagnostics flowing through a report-only validation result.
- Kept all digest diagnostics nested under compiler_profile_contract_validation.diagnostics.
- Kept top-level compiler diagnostics, pass_result, stages, public result, manifest, assembler execution, and refusal behavior unchanged.

[S] Signals:
- Summary status PASS with failed_checks [].
- All 12 required cases pass.
- All four contract_digest diagnostic candidates are covered.
- R70, R69, R67, and 13-case validator regressions remain PASS.

[T] Tests / Proofs:
- PASS: ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
- PASS: ruby -c igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
- PASS: ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb
- PASS: ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb
- PASS: ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb
- PASS: ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb

[R] Recommendations:
- C3-A can accept this proof-local report-only integration closure.
- Do not authorize live implementation or compile refusal from this proof.
- If continuing, open a separate design card before any live validator/compiler implementation.

[Files] Changed:
- igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb
- igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/out/prop038_contract_digest_report_only_integration_proof_summary.json
- igniter-lang/docs/tracks/prop038-contract-digest-report-only-integration-proof-v0.md

[Q] Open Questions:
- Should the next card be live implementation design or PROP-038 errata wording?
- If live implementation opens later, should shape and recompute diagnostics be introduced together or in two report-only phases?

[X] Rejected:
- No live validator implementation, compiler/orchestrator integration, compile refusal, public API/CLI widening, `CompilerResult` changes, loader/report behavior, CompatibilityReport behavior, RuntimeMachine behavior, or production behavior was added.

[Next] Proposed next slice:
- Architect C3-A acceptance decision; if accepted, decide whether to route to implementation design or PROP-038 errata.
```
