# Compiler Mainline Touchpoint And Proof Gap Survey v0

Card: S3-R89-C2-P1  
Agent: `[Igniter-Lang Research Agent]`  
Role: `research-agent`  
Track: `compiler-mainline-touchpoint-and-proof-gap-survey-v0`  
Route: UPDATE  
Status: done  
Date: 2026-05-20

---

## Role And Neighbor Awareness

Assigned track: compiler/profile mainline touchpoint survey.

Affected neighbor roles:

- `[Igniter-Lang Compiler/Grammar Expert]` — compiler pipeline, SemanticIR,
  CompilationReport, and profile contract boundaries.
- `[Igniter-Lang Bridge Agent]` — future public API/CLI, package, loader/report,
  and CompatibilityReport exposure must not infer authority from this survey.

This is a no-code survey. It does not authorize implementation.

---

## Current Horizon

```text
Compiler mainline is active and separate from Spark applied pressure.
CompilerProfile has identity, source transport, contract validation, report-only evidence, digest policy, and internal strict terminal foundation.
The only live strict-refusal authority is the bounded internal CompilerOrchestrator seam.
Public strict source, loader/report, CompatibilityReport, dispatch, RuntimeMachine, and production behavior remain closed.
Preferred next route remains a no-code compiler-pack boundary report before code movement.
```

---

## Read Set

Dependency:

- `docs/org/tracks/compiler-mainline-reentry-boundary-map-v0.md`

Code surfaces:

- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/compiler_result.rb`
- `lib/igniter_lang/compilation_report.rb`
- `lib/igniter_lang/compiler_profile_contract_validator.rb`
- `lib/igniter_lang/assembler.rb`
- `lib/igniter_lang/cli.rb`
- `lib/igniter_lang.rb`
- `bin/igc`

Spec/status context:

- `docs/current-status.md`
- `docs/spec/ch5-compiler-pipeline.md`
- `docs/spec/ch6-semanticir.md`
- `docs/spec/ch7-runtime.md`

Proof summaries sampled:

- `experiments/minimal_compiler_profile_finalization_proof/out/minimal_compiler_profile_finalization_summary.json`
- `experiments/assembler_compiler_profile_id_field/out/assembler_compiler_profile_id_field_summary.json`
- `experiments/compiler_profile_obligation_coverage_proof/out/compiler_profile_obligation_coverage_summary.json`
- `experiments/compiler_profile_contract_proof/out/compiler_profile_contract_proof_summary.json`
- `experiments/prop038_report_only_compiler_integration/out/prop038_report_only_compiler_integration_summary.json`
- `experiments/prop038_contract_digest_report_only_integration_proof/out/prop038_contract_digest_report_only_integration_proof_summary.json`
- `experiments/prop038_strict_refusal_result_shape_proof/out/prop038_strict_refusal_result_shape_proof_summary.json`
- `experiments/prop038_strict_refusal_live_implementation_proof/out/prop038_strict_refusal_live_implementation_proof_summary.json`

No broad proof suite was run.

---

## Dependency Readout

S3-R89-C0-O establishes the lane boundary:

- Spark applied pressure remains active but separate from the compiler mainline.
- Compiler mainline may plan the next compiler/profile route under governance.
- Accepted foundations include PROP-036 profile identity/source transport,
  obligation coverage proof, PROP-038 contract validation/report-only/digest
  evidence, and the bounded internal strict terminal foundation.
- The preferred conservative route is `compiler-pack-boundary-report-v0`.
- No implementation, dispatch migration, loader/report, CompatibilityReport,
  runtime, production, Spark fixture, or Spark implementation behavior is opened.

---

## Touchpoint Map

| Surface | Current touchpoint | Current behavior | Mainline implication |
| --- | --- | --- | --- |
| Compiler pipeline | `CompilerOrchestrator#compile` | Parse -> classify -> typecheck -> `emit_typed` -> report -> optional PROP-038 validation -> optional strict terminal -> assemble -> runtime smoke. | Mainline route should respect the existing typed production path; no parsed-emitter revival. |
| Report-only contract provider | `CompilerOrchestrator#compiler_profile_contract_validation` | Internal constructor provider only; non-callable, non-Hash, nil, or exception returns nil/no field. | Provider is an internal evidence seam, not public API/CLI authority. |
| Report annotation | `CompilationReport.with_compiler_profile_contract_validation` | Adds nested `compiler_profile_contract_validation` with `report_only: true`; preserves `pass_result`, stages, and top-level diagnostics. | Evidence can be observed without changing compiler outcome. |
| Assembly boundary | `report_for_assembly = report` before annotation | Assembler receives the pre-annotation report. | Report-only validation does not mutate `.igapp` material or artifact hash. |
| Ordinary refusal | `CompilerOrchestrator#refusal` + `CompilerResult.refusal` | Writes sidecar compilation report and returns `status: "error" | "oof" | assembler/runtime variants`. | Ordinary OOF/error path remains separate from strict terminal. |
| Strict terminal | `compiler_profile_contract_strict_terminal` | Runs only after report-only validation and only while `pass_result == "ok"`; returns `CompilerResult.strict_terminal`. | Accepted internal foundation; not public strict mode. |
| Strict requirement validation | `validate_compiler_profile_contract_strict_requirement` | Allows only internal source values, one strict mode, mismatch candidate, fail-open recompute-unavailable policy, and `compile_refusal_authorized=false`. | Strict authority is the orchestrator decision path, not validator output alone. |
| Strict terminal result | `CompilerResult.strict_terminal` | Non-persisting `refused` or `configuration_error`; `compilation_report_path: nil`, `igapp_path: nil`, empty contracts, wrapper diagnostics. | Future expansion must preserve or explicitly replace the 13-key terminal shape. |
| Public result shaping | `CompilerResult.public_result` | Removes only internal `report`; it is not a whitelist for ordinary success. | Future public-surface work needs explicit key-set assertions, especially if adding fields. |
| Validator | `CompilerProfileContractValidator.validate` | Live internal validator covers required slots, digests, one-owner checks, ordered rules, non-authority flags; emits `compile_refusal_authorized=false`. | Validator is real code, but still evidence unless strict terminal requirement selects a refusal. |
| Profile source transport | `IgniterLang.compile`, `CLI`, `Assembler` | Public facade/CLI support only `compiler_profile_source` / `--compiler-profile-source PATH.json`; assembler validates finalized source and writes `compiler_profile_id`. | This is PROP-036 source transport, distinct from PROP-038 strict requirement. |
| CLI | `bin/igc`, `IgniterLang::CLI` | JSON path loading for compiler profile source only; no strict contract provider/requirement. | Public CLI widening remains closed. |
| Runtime metadata | `Assembler#compatibility_metadata_for` | TEMPORAL runtime execution remains unsupported/guarded; compiler-profile strict status is not loader/runtime metadata. | Loader/report and CompatibilityReport must not infer strict readiness. |

---

## Report-Only Evidence Touchpoints

| Evidence | Current proof signal |
| --- | --- |
| Minimal profile source finalization | `minimal_compiler_profile_finalization_summary.json`: PASS, 27 checks. |
| Assembler `compiler_profile_id` field | `assembler_compiler_profile_id_field_summary.json`: PASS, 19 checks. |
| Obligation coverage report | `compiler_profile_obligation_coverage_summary.json`: PASS, 18 checks; output-only, no gate/CLI/assembler/runtime change. |
| Contract validator matrix | `compiler_profile_contract_proof_summary.json`: PASS, 13 cases, 30 checks; `compiler_integrated=false`, `compile_refusal_authorized=false`. |
| Live report-only integration | `prop038_report_only_compiler_integration_summary.json`: PASS, 5 cases, 20 checks; invalid contract still compiles and assembles. |
| Digest report-only integration | `prop038_contract_digest_report_only_integration_proof_summary.json`: PASS, 12 cases, 21 checks; digest diagnostics stay nested. |
| Strict result-shape target | `prop038_strict_refusal_result_shape_proof_summary.json`: PASS, 3 cases, 44 checks; proof-local target before live implementation. |
| Live internal strict terminal | `prop038_strict_refusal_live_implementation_proof_summary.json`: PASS, 16 cases, 46 checks; accepted internal foundation. |

---

## Main Proof Gaps

| Gap | Current evidence | Why it matters | Suggested route owner |
| --- | --- | --- | --- |
| Compiler pack boundary is not mapped against live files | C0-O recommends `compiler-pack-boundary-report-v0`; current code still has direct orchestrator composition. | The next route needs a pack map before dispatch or extraction pressure. | C1 no-code report; C3 pressure; C4 decision. |
| Profile slot obligations are report-only, not enforced | Obligation proof PASS; validator has required slots; no compiler gate except internal strict digest mismatch. | Prevents accidental "slot covered" -> "compile authorized/refused" inference. | C1/C3 proof-gap map; C4 decides if enforcement is ever opened. |
| Strict terminal success-path instrumentation is narrower than terminal instrumentation | Live proof asserts strict terminal skips assembler/refusal and valid strict assembles; ordinary success relies on existing public/manifest checks. | Future mainline route may need exact ordinary success-path assertions before touching result/report surfaces. | C1 proof hardening if implementation route opens. |
| `CompilerResult.public_result` is deny-one, not allowlist, for ordinary paths | Strict terminal key-set is proven; ordinary success public shape is protected by existing proofs but not by the constructor itself. | Any future added internal field risks public leakage unless proof asserts key-set. | C1 proof/design; C3 pressure. |
| Ch6 CompilationReport chapter lags PROP-038 detail | Ch5 and Ch7 include R84 strict-refusal semantics; Ch6 still describes generic CompilationReport shape and Stage 3 TEMPORAL status only. | Readers may miss nested `compiler_profile_contract_validation`, report-only invariants, and strict non-persisting terminal relation. | Compiler/Grammar or Meta doc sync. |
| Assembler report isolation is behaviorally proven but easy to regress | `report_for_assembly` is captured before annotation; R67 proof says manifest unchanged. | Future pack/report refactors could accidentally pass annotated reports into artifact hash material. | C1 regression anchor; C3 pressure. |
| Loader/report and CompatibilityReport remain proof-local or closed | C0-O, Ch7, current-status all keep these closed for compiler profile strict status. | Avoids turning compiler evidence into runtime readiness. | C4 gate only; Bridge Agent after authorization. |
| Public strict source is absent | `IgniterLang.compile` and CLI expose only `compiler_profile_source`; strict requirement is constructor-only. | Any public/API strict route needs separate API/CLI design, preflight, docs, and release proof. | C4 gate before any C1 implementation. |
| Profile-assembled compiler migration is unimplemented | Architecture direction and C0-O list it as future/post-POC. | Mainline cannot assume pack dispatch, registry, or profile-assembled pass ordering yet. | No-code pack report first. |

---

## Ch6 / CompilationReport Staleness Notes

Ch5 and Ch7 are current for the accepted PROP-038 strict terminal boundary.
Ch6 appears potentially stale or underspecified for compiler-profile report
details:

- Ch6 status header is synced for Stage 3 TEMPORAL + PROP-032 assumptions, not
  R84/R86 PROP-038 strict-refusal canon.
- Ch6 6.1 says the compiler writes a `CompilationReport` for every attempted
  compile, which remains true for ordinary OOF/error, but does not mention that
  strict terminal paths are non-persisting `CompilerResult`s with
  `compilation_report_path: null`.
- Ch6 6.1 does not show the nested
  `compiler_profile_contract_validation` report-only field.
- Ch6 6.1 does not state that report-only validation preserves `pass_result`,
  stages, top-level diagnostics, and assembler artifact material.
- Ch6 6.1 does not distinguish ordinary refusal reports from PROP-038 strict
  terminal wrapper diagnostics.

Recommended doc route: small Ch6 CompilationReport sync, owned by
Compiler/Grammar or Meta status/spec stewardship, before any public
compiler-profile result/report expansion.

---

## Closed Surfaces

This survey preserves the C0-O closed list:

- code edits and implementation;
- compiler dispatch migration;
- profile-assembled compiler rewrite;
- parser/classifier/TypeChecker/SemanticIR/assembler rewrites;
- public API/CLI widening;
- profile discovery/defaulting/finalization in public surfaces;
- `.igapp` golden migration;
- `.ilk` profile references;
- CompilationReceipt links;
- signing / production verification;
- loader/report compiler-profile status;
- CompatibilityReport compiler-profile section;
- obligation enforcement or compile refusal beyond the accepted internal strict path;
- RuntimeMachine or Gate 3 widening;
- Ledger/TBackend binding;
- BiHistory, stream/OLAP production executors;
- production cache;
- production deployment;
- Spark fixtures/specs or Spark implementation from this compiler-lane card.

---

## Command Matrix

| Command / read | Result | Purpose |
| --- | --- | --- |
| `nl -ba igniter-lang/docs/org/tracks/compiler-mainline-reentry-boundary-map-v0.md` | PASS | Read C0-O dependency. |
| `nl -ba igniter-lang/lib/igniter_lang/compiler_orchestrator.rb` | PASS | Inspect live orchestration, report-only, and strict terminal branch. |
| `nl -ba igniter-lang/lib/igniter_lang/compiler_result.rb` | PASS | Inspect ordinary refusal and strict terminal result shapes. |
| `nl -ba igniter-lang/lib/igniter_lang/compilation_report.rb` | PASS | Inspect report enrichment and nested validation helper. |
| `nl -ba igniter-lang/lib/igniter_lang/compiler_profile_contract_validator.rb` | PASS | Inspect live validator coverage and non-authority flags. |
| `nl -ba igniter-lang/lib/igniter_lang/assembler.rb` | PASS | Inspect profile source validation, artifact writes, and report isolation. |
| `nl -ba igniter-lang/lib/igniter_lang/cli.rb` | PASS | Confirm public CLI exposes profile source path only. |
| `ruby -rjson -e '<summary readout>'` | PASS | Read selected proof summary statuses; no proof suite run. |
| `rg "CompilationReport|compilation_report|compiler_profile|strict" ...` | PASS | Locate spec/report sync status and potential Ch6 lag. |

No tests or broad regression commands were run.

---

## Recommendation

Recommended safest next route:

```text
compiler-pack-boundary-report-v0
```

Reason:

```text
It extends the accepted C0-O direction by mapping the current live compiler,
profile slots, validator/report evidence, OOF boundaries, proofs, and closed
surfaces into candidate compiler packs without code churn or authority widening.
```

Secondary route if the Architect wants a profile-specific map first:

```text
compiler-profile-slot-contract-map-v0
```

Hold:

```text
profile-assembled compiler migration
public strict API/CLI source
loader/report or CompatibilityReport profile status
dispatch/runtime/production binding
```

until a later Architect gate explicitly opens them.

---

## Handoff

```text
[Igniter-Lang Research Agent]
Track: compiler-mainline-touchpoint-and-proof-gap-survey-v0
Status: done
Card: S3-R89-C2-P1
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D]
- Current live foundation is CompilerOrchestrator-centered: report-only
  validation plus bounded internal strict terminal.
- Public API/CLI exposes PROP-036 compiler_profile_source only; no public strict
  contract source exists.
- Ch5/Ch7 carry R84/R86 strict-refusal canon; Ch6 CompilationReport appears to
  need a small compiler-profile sync.

[S]
- Mainline can proceed independently from Spark applied pressure.
- Existing proof summaries show PASS for profile source finalization, assembler
  profile id, obligation report, validator, report-only integration, digest
  report-only integration, strict result-shape, and live internal strict terminal.
- Assembler artifact isolation depends on keeping report_for_assembly captured
  before report-only annotation.

[T]
- No code edits.
- No broad tests.
- Track doc added only.

[R]
- Route next to compiler-pack-boundary-report-v0.
- Add Ch6 CompilationReport sync as a small follow-up or include it in the pack
  boundary report as a spec-lag item.

[Next]
- [Q] Compiler/Grammar Expert: confirm whether Ch6 should be updated now or
  after the compiler-pack boundary report.
- [Q] Bridge Agent: hold public/API/CLI, loader/report, CompatibilityReport, and
  package bridge work until Architect opens a specific surface.
```
