# Compiler Release Acceptance Harness Implementation Proof v0

Card: S3-R161-C2-I  
Agent: [Igniter-Lang Implementation Agent]  
Role: implementation-agent  
Track: compiler-release-acceptance-harness-implementation-proof-v0  
Route: UPDATE  
Status: done  
Date: 2026-05-24

---

## Authorization

- S3-R161-C1-A: authorized bounded proof-local harness runner implementation
- S3-R161-C2-S: c2_i_authorized_open

---

## Authorized Write Scope

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/**
igniter-lang/docs/tracks/compiler-release-acceptance-harness-implementation-proof-v0.md
```

No other files were edited.

---

## Implementation Summary

Runner path:

```text
igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb
```

Harness layout:

```text
corpus/positive/add_baseline.ig            Add-style baseline (2 Integer inputs)
corpus/positive/boolean_gate.ig            Boolean gate/conjunction (2 Bool inputs)
corpus/positive/integer_arithmetic.ig      Integer arithmetic (3 Integer inputs, chained compute)
corpus/positive/multi_input_diverse.ig     Mixed types (Integer + Bool) — NB-1 multi-input diversity
corpus/positive/poc_derived.ig             POC-derived synthetic micro-app unit
corpus/negative/parse_refusal.ig           Parse refusal specimen
corpus/negative/type_mismatch.ig           Type mismatch refusal (OOF-TY0)
corpus/negative/unresolved_symbol.ig       Unresolved symbol refusal (OOF-P1)
fixtures/finalized_profile_source.json     Finalized PROP-036 profile source (harness-local copy)
fixtures/malformed_profile_source.json     Invalid JSON for CLI preflight refusal test
fixtures/semantic_profile_source_wrong_kind.json  Wrong kind for assembler semantic refusal test
out/compiler_release_acceptance_harness_summary.json  Required summary output
```

---

## Required Proof Commands

```bash
ruby -c igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb
# => Syntax OK

ruby igniter-lang/experiments/compiler_release_acceptance_harness_v0/compiler_release_acceptance_harness_v0.rb --mode acceptance
# => HOLD compiler_release_acceptance_harness_v0
# => positive_corpus_entries=5
# => negative_corpus_entries=3
# => command_matrix_entries=14
# => failed_checks=0
# => hold_reasons=1
# => summary=igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json
```

---

## Harness Status

```text
HOLD
```

HOLD is the correct and expected result per C1-A NB-1: TypeChecker does not support
`if_expr` (OOF-TY0 Unsupported expression kind: if_expr). Branch/conditional coverage
requires new semantics. Multi-input diversity is satisfied via mixed input types
(Integer + Bool) in `multi_input_diverse.ig`.

Status precedence verified: FAIL > HOLD > PASS. `failed_checks` is empty; HOLD
triggered by branch/conditional gap.

---

## Command Matrix (14/14 PASS)

| # | Kind | Name | Pass |
|---|------|------|------|
| 1 | load_path_smoke | — | PASS |
| 2 | cli_positive_compile | add_baseline | PASS |
| 3 | cli_positive_compile | boolean_gate | PASS |
| 4 | cli_positive_compile | integer_arithmetic | PASS |
| 5 | cli_positive_compile | multi_input_diverse | PASS |
| 6 | cli_positive_compile | poc_derived | PASS |
| 7 | cli_positive_compile_with_profile | add_baseline_with_profile | PASS |
| 8 | api_positive_compile | api_add_baseline | PASS |
| 9 | cli_refusal | parse_refusal | PASS |
| 10 | cli_refusal | type_mismatch | PASS |
| 11 | cli_refusal | unresolved_symbol | PASS |
| 12 | cli_preflight_bad_path | bad_profile_path | PASS |
| 13 | cli_preflight_malformed_json | malformed_profile_json | PASS |
| 14 | cli_semantic_profile_refusal | semantic_profile_wrong_kind | PASS |

---

## Artifact Checks: compatibility_metadata.json (5/5 PASS)

All five generated positive `.igapp` outputs include `compatibility_metadata.json`
with shape: `kind=igapp_compatibility_metadata`, `format_version=0.1.0`,
`canonical_artifact` present. Checked shape only per NB-3. Not a public CompatibilityReport.

---

## Normalization (PASS)

Strategy: two-run stability check (NB-2).

```text
stable_fields: format_version, kind, contract_names, input_type_signatures
normalized_fields: compiled_at_excluded
excluded_fields: compiled_at, source_hash, artifact_hash, program_id,
                 semantic_ir_ref, compilation_report_ref
fields_compared: 4 / fields_stable: 4
```

---

## Closed-Surface Scan (PASS)

Scan targets: 5 positive .ig corpus files + 3 negative .ig corpus files +
generated `.igapp/*.json` files.

Hits: 0

Allowed-context exceptions applied:
- `stream` as a bare JSON string in fragment `precedence_high_to_low` arrays
  (assembler-generated manifest.json metadata, not a runtime surface claim)
- `RuntimeMachine` in `compatibility_metadata.json` notes field
  (assembler-generated metadata, not a public surface claim)

---

## NB-1: Multi-Input Diversity

Branch/conditional if_expr not supported by TypeChecker. HOLD reason recorded.
Multi-input diversity satisfied via mixed input types (Integer + Bool) in
`multi_input_diverse.ig`: `base: Integer`, `adjustment: Integer`, `active: Bool`.

---

## NB-2: Normalization

Two-run stability check implemented. Fixture-based normalization specimen is deferred
as follow-up (NB-2 policy: if only one fits, choose two-run check with follow-up note).

---

## NB-3: compatibility_metadata.json

Required for all 5 generated positive `.igapp` outputs. Shape checked only
(`kind`, `format_version`, `canonical_artifact`). Not treated as public CompatibilityReport.

---

## NB-4: claimed_surfaces

`release_scope.claimed_surfaces` is present and enumerates positive scope:
- repo_local_compiler_cli_positive_compile
- repo_local_compiler_cli_refusal
- repo_local_compiler_api_positive_compile
- repo_local_load_path_smoke
- proof_local_runtime_smoke

---

## NB-5: FAIL/HOLD Precedence

`FAIL > HOLD > PASS` implemented. Top-level `status` is `HOLD` because
`failed_checks` is empty and `hold_reasons` contains the branch/conditional entry.
If both FAIL and HOLD triggers appeared, `status` would be `FAIL`.

---

## Closed Surfaces

This implementation does not open:

```text
official RC evidence gathering
release execution
public release or public demo claims
public analyzer/tracer/visualizer
public API/CLI widening
root require changes
parser, classifier, TypeChecker, SemanticIR, or assembler changes
CompilationReport, CompilerResult, or CompatibilityReport widening
Spark access, fixtures, specs, integration, or production pressure
Ruby Framework docs/release/tag/package/compatibility claims
runtime, production, Ledger/TBackend, BiHistory, stream/OLAP, cache, signing
```

---

## Non-Claims

```text
no_official_rc_evidence: generated outputs are proof-local harness evidence only
no_release_execution: release execution not authorized
no_public_demo_claim: public demo claims not authorized by C1-A
no_spark_integration: Spark remains sanitized future fixture/design pressure only
no_ruby_framework_release: Ruby Framework held until stable Lang RC export fixture
no_public_api_cli_widening: runner uses existing compiler CLI/API/load-path surfaces only
no_compatibility_report_public: compatibility_metadata.json checked as shape only
no_rubygems_push: no gem tag, package, or publish
no_production_runtime: proof-local runtime smoke only
no_public_analyzer_tracer_visualizer: internal machine-readable summary only
```

---

## Command Surface Delta

The runner uses `ruby -I igniter-lang/lib` to invoke the CLI since the lang gem
is not installed globally. No new command shapes were added. The CLI surface
`ruby -I lib igniter-lang/bin/igc compile SOURCE --out OUT.igapp [--compiler-profile-source PATH.json]`
is unchanged. No new flags or API signatures were introduced.

---

## Round Receipt

```text
card: S3-R161-C2-I
track: compiler-release-acceptance-harness-implementation-proof-v0
status: done
harness_status: HOLD
failed_checks: 0
hold_reasons: 1
hold_reason_1: branch_conditional_if_expr_unsupported
command_matrix: 14/14 PASS
positive_corpus_entries: 5
negative_corpus_entries: 3
compat_meta_checks: 5/5 PASS
normalization: PASS (two_run_stability)
closed_surface_scan: PASS (0 hits)
nb1_disposition: multi_input_diversity_achieved_via_mixed_types
nb2_disposition: two_run_stability_implemented; fixture_specimen_deferred_follow_up
nb3_disposition: shape_only_checked; not_public_report
nb4_disposition: claimed_surfaces_present_and_accurate
nb5_disposition: fail_over_hold_over_pass_implemented
write_scope_respected: yes
no_compiler_changes: yes
no_public_api_cli_widening: yes
no_rc_evidence_gathered: yes
no_release_execution: yes
no_public_demo_claim: yes
summary_path: igniter-lang/experiments/compiler_release_acceptance_harness_v0/out/compiler_release_acceptance_harness_summary.json
```
