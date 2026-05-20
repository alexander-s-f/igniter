# PROP-038 Strict Refusal Regression And Canon Map v0

Card: S3-R85-C2-P1  
Agent: [Igniter-Lang Research Agent]  
Role: research-agent  
Route: UPDATE  
Status: done  
Date: 2026-05-20

## Neighbor Roles

Affected neighbor roles:

- Compiler/Grammar Expert: future changes to strict-refusal internals, result shape, diagnostics, or compiler pipeline must preserve this map.
- Bridge Agent: future public API/CLI, loader/report, or CompatibilityReport exposure must treat this as an internal foundation, not a public contract.

## Scope

Read-only except for this track doc.

Read:

- `docs/gates/prop038-strict-refusal-live-implementation-acceptance-decision-v0.md`
- `docs/tracks/prop038-strict-refusal-live-implementation-v0.md`
- `docs/discussions/prop038-strict-refusal-live-implementation-pressure-v0.md`
- `experiments/prop038_strict_refusal_live_implementation_proof/out/prop038_strict_refusal_live_implementation_proof_summary.json`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/compiler_result.rb`

No code was edited. No broad proof suite was run.

## Accepted Canon

R84 accepts the R83 implementation as the live internal foundation only:

```text
internal strict requirement source
  -> orchestrator strict decision path
  -> report-only PROP-038 validation evidence
  -> non-persisting strict terminal result when selected
```

Accepted implementation surface:

- `CompilerOrchestrator` constructor seam: `compiler_profile_contract_strict_requirement: nil`.
- Strict requirement kind: `compiler_profile_contract_strict_requirement`.
- Strict mode: `strict_contract_digest`.
- Allowed strict sources: `proof_local_gate`, `internal_test_seam`.
- Strict refusal candidate: `compiler_profile_contract.contract_digest_mismatch`.
- Recompute-unavailable policy: `fail_open_report_only`.
- Validator remains evidence, not authority: nested `compile_refusal_authorized: false` remains preserved.
- `CompilerResult.strict_terminal` is the internal non-persisting terminal result constructor.

Accepted terminal statuses:

| Status | Trigger | Persistence |
| --- | --- | --- |
| `refused` | valid internal strict requirement + nested `compiler_profile_contract.contract_digest_mismatch` | no sidecar, no report path, no `.igapp` |
| `configuration_error` | malformed internal strict requirement | no sidecar, no report path, no `.igapp` |

Accepted terminal public key-set for both statuses:

```text
kind
format_version
status
program_id
source_path
source_hash
grammar_version
stages
igapp_path
contracts
compilation_report_path
diagnostics
warnings
```

Accepted public wrapper diagnostics:

- `compiler_profile_contract_refusal.contract_digest_mismatch`
- `compiler_profile_contract_refusal.strict_requirement_malformed`

Raw validator diagnostics remain nested under `compiler_profile_contract_validation`; they are not promoted to public top-level diagnostics.

## Code Canon Map

| Surface | Current canon |
| --- | --- |
| `CompilerOrchestrator#compile` | Validates provider output only after `pass_result == "ok"` and attaches report-only validation before strict terminal check. |
| `report_for_assembly` | Captured before PROP-038 annotation and still passed to assembler for non-terminal paths. |
| Existing refusal helper | `CompilerOrchestrator#refusal` still writes sidecars and is not used for strict terminal paths. |
| Strict terminal branch | Runs after existing `pass_result` OOF/error gate and before assembler/runtime smoke. |
| Strict requirement validation | Malformed requirement returns `configuration_error`; valid requirement only refuses on digest mismatch. |
| Provider nil/non-Hash/exception | Legacy no-field/no-refusal behavior remains. |
| `CompilerResult.refusal` | Preserved for ordinary OOF/error/assembler/runtime-smoke paths. |
| `CompilerResult.strict_terminal` | Produces `compilation_report_path: nil`, `igapp_path: nil`, empty contracts, wrapper diagnostics, internal `report`. |
| `CompilerResult.public_result` | Still strips only internal `report`; no public whitelist added. |

## Proof Summary

Proof summary:

```text
kind=prop038_strict_refusal_live_implementation_proof_summary
status=PASS
pass=true
cases=16
checks=46
failed_checks=0
```

Case summary:

| Case | Status | pass_result | Sidecar | `.igapp` | Canon signal |
| --- | --- | --- | --- | --- | --- |
| `baseline_no_provider` | `ok` | `ok` | no | yes | legacy success |
| `no_strict_source_mismatch_report_only` | `ok` | `ok` | no | yes | invalid validator remains report-only |
| `nil_strict_source_mismatch_report_only` | `ok` | `ok` | no | yes | nil strict source preserves report-only |
| `strict_valid_contract_allows` | `ok` | `ok` | no | yes | strict source allows valid contract |
| `strict_digest_mismatch_refused` | `refused` | `ok` | no | no | strict non-persisting refusal |
| `strict_malformed_configuration_error` | `configuration_error` | `ok` | no | no | strict malformed requirement terminal |
| `strict_provider_nil_legacy` | `ok` | `ok` | no | yes | provider nil fail-open legacy |
| `strict_provider_non_hash_legacy` | `ok` | `ok` | no | yes | provider non-Hash fail-open legacy |
| `strict_provider_exception_legacy` | `ok` | `ok` | no | yes | provider exception fail-open legacy |
| `parse_error_baseline` | `error` | `error` | yes | no | ordinary parse failure preserved |
| `parse_error_with_strict_requirement` | `error` | `error` | yes | no | strict source does not override parse failure |
| `oof_baseline` | `oof` | `oof` | yes | no | ordinary OOF preserved |
| `oof_with_strict_requirement` | `oof` | `oof` | yes | no | strict source does not override OOF |
| `assembler_refused_preserved` | `assembler_refused` | `error` | yes | no | ordinary assembler refusal preserved |
| `runtime_smoke_failed_preserved` | `runtime_smoke_failed` | `error` | yes | yes | post-assembly runtime smoke failure preserved |
| `internal_error_preserved` | `error` | `error` | yes | no | ordinary internal error preserved |

Named check groups:

- report-only preservation: no strict source, nil strict source, provider nil/non-Hash/exception.
- strict success: valid strict source + valid contract assembles.
- strict terminal refusal: exact key-set, wrapper diagnostics, nested raw diagnostics, no sidecar, assembler not called, existing refusal helper not called.
- configuration error: same key-set, wrapper diagnostic, no sidecar, assembler not called, existing refusal helper not called.
- ordinary failure preservation: parse, OOF, assembler, runtime smoke, internal error paths preserve existing sidecar/refusal behavior.

## Accepted Command Matrix

The accepted 11-command matrix from R83/R84:

| Command | Accepted result |
| --- | --- |
| `ruby -c igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` | PASS |
| `ruby -c igniter-lang/lib/igniter_lang/compiler_result.rb` | PASS |
| `ruby -c igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/prop038_strict_refusal_live_implementation_proof.rb` | PASS |
| `ruby igniter-lang/experiments/prop038_strict_refusal_live_implementation_proof/prop038_strict_refusal_live_implementation_proof.rb` | PASS |
| `ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | PASS |
| `ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | PASS |
| `ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb` | PASS |
| `ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb` | PASS |
| `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | PASS |
| `ruby igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb` | PASS |
| `ruby igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb` | PASS |

This card did not rerun the matrix; it reads the accepted command matrix and current summary as canon.

## Protected Closed Surfaces

Still closed after R84 acceptance:

- public API/CLI widening;
- `IgniterLang.compile` signature changes;
- env/config/manifest/default/generated strict source lookup;
- loader/report strict source or status;
- CompatibilityReport strict source or status;
- persisted strict terminal refusal reports;
- strict terminal sidecars;
- strict terminal `.igapp` artifacts or golden migration;
- parser, TypeChecker, SemanticIR, assembler, `CompilationReport`, and `IgniterLang::Diagnostics` changes;
- `.ilk`, receipts, signing, dispatch migration;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

## Regression Anchors

Future proof chains should keep these anchors unless an Architect decision replaces them:

| Anchor | Why it stays in chain |
| --- | --- |
| `prop038_strict_refusal_live_implementation_proof` | Canon proof for internal strict terminal behavior, ordinary preservation paths, and non-persisting result construction. |
| `compiler_profile_contract_proof` | Validator namespace and contract matrix; preserves validator-as-evidence boundary. |
| `prop038_contract_digest_shape_policy_proof` | Digest shape/policy diagnostic surface. |
| `prop038_contract_digest_recompute_match_proof` | Recompute mismatch/unavailable behavior and fail-open baseline. |
| `prop038_contract_digest_report_only_integration_proof` | Nested diagnostics isolation and report-only invariants. |
| `prop038_report_only_compiler_integration` | Live report-only integration; invalid contract still compiles/assembles. |
| `prop038_strict_mode_refusal_trigger_proof` | Historical proof-local trigger/evidence model; guards wrapper diagnostic intent. |
| `prop038_strict_refusal_result_shape_proof` | R81 target result shape and key-set baseline. |
| `production_compiler_cli_proof` | Public CLI output/exit/report behavior remains closed and stable. |
| `igapp_assembler_proof` | Artifact shape and assembler boundary remain unchanged. |

## Expansion Risks

| Future opening | Risk |
| --- | --- |
| Public API/CLI strict source | Constructor-only seam could become user-facing authority by accident; malformed input needs distinct CLI preflight vs compiler JSON policy. |
| Loader/report | Loader vocabulary could leak into compiler result/report surfaces and confuse report-only vs runtime-readiness status. |
| CompatibilityReport | Compiler-profile validation might be misread as runtime compatibility or execution readiness. |
| Persisted reports | Reusing `CompilerOrchestrator#refusal` would reintroduce sidecars and violate current strict terminal canon. |
| `.igapp`/assembler | Moving annotated report into assembler could mutate artifact hash/material and migrate goldens unintentionally. |
| Diagnostics centralization | Raw `compiler_profile_contract.*` diagnostics could be promoted publicly instead of wrapper `compiler_profile_contract_refusal.*` diagnostics. |
| `IgniterLang.compile` facade | Adding strict-source params would widen public API and require separate release/API proof. |
| Gate 3/runtime | Strict compiler refusal evidence is not runtime authorization, execution readiness, or Ledger/TBackend authority. |

## Future Expansion Guard Checklist

Before any future expansion, re-prove:

- strict terminal public key-set remains exact or a new accepted key-set replaces it;
- `compilation_report_path` remains `null` for non-persisting strict terminals unless persistence is explicitly authorized;
- strict terminal paths do not call `CompilerOrchestrator#refusal`;
- strict terminal paths do not call assembler and write no `.igapp`;
- ordinary parse/OOF/assembler/runtime-smoke/internal-error paths still use existing refusal behavior and sidecars;
- invalid validator without explicit internal strict source remains report-only and assembles;
- provider nil/non-Hash/exception behavior is explicitly preserved or intentionally changed under a named gate;
- raw validator diagnostics remain nested unless a public diagnostics decision changes that;
- wrapper diagnostics stay under `compiler_profile_contract_refusal.*`;
- public API/CLI behavior remains unchanged unless explicitly opened;
- loader/report and CompatibilityReport terms do not appear in compiler-result strict surfaces;
- RuntimeMachine, Gate 3, Ledger/TBackend, stream/OLAP/BiHistory/cache remain untouched unless separately authorized.

## Recommendation

Recommendation for C4-A: accept map.

The map is suitable as the compact canon/regression reference for the accepted internal-only PROP-038 strict-refusal foundation. It is not an implementation authorization and should not be used to open public API/CLI, loader/report, CompatibilityReport, runtime, or production behavior without a separate gate.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: prop038-strict-refusal-regression-and-canon-map-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Captured R84/R83 accepted strict-refusal live internal foundation as canon.
- Kept public/API/runtime expansion explicitly outside this map.
- Treated the accepted 11-command matrix and PASS summary as regression baseline.

[R] Recommendations:
- Accept map for C4-A.
- Future expansion should start by selecting which closed surface is being opened and rerunning the regression anchors named here.

[S] Signals:
- Current strict terminals are internal-only, non-persisting, pre-assembly, and use `CompilerResult.strict_terminal`.
- Current invalid validator evidence remains report-only unless explicit internal strict requirement is present.
- Ordinary failure paths keep existing sidecar/refusal behavior.

[T] Tests / Proofs:
- Read accepted proof summary: PASS, 16 cases, 46 checks, 0 failed checks.
- Read accepted command matrix: 11/11 PASS.
- No broad tests rerun; read-only canon map only.

[Files] Changed:
- igniter-lang/docs/tracks/prop038-strict-refusal-regression-and-canon-map-v0.md

[Q] Open Questions:
- Which future surface, if any, should open first: docs/spec sync, CLI/API design, loader/report, CompatibilityReport, or additional regression hardening?
- If public API/CLI opens, should strict source remain internal-only with no user-facing transport, or become an explicit artifact/flag with its own refusal grammar?

[X] Rejected:
- No code edits.
- No live behavior changes.
- No public API/CLI widening.
- No loader/report, CompatibilityReport, runtime, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

[Next] Proposed next slice:
- C4-A acceptance/redirect decision for this map, then a separately scoped route for whichever future surface is intentionally opened.
```
