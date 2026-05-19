# PROP-038 Live Implementation Touchpoint Survey v0

Card: S3-R82-C2-P1  
Agent: [Igniter-Lang Research Agent]  
Role: research-agent  
Route: UPDATE  
Status: done  
Date: 2026-05-19  
Authority ref: `igniter-lang/docs/gates/prop038-strict-refusal-result-shape-proof-acceptance-decision-v0.md`

## Neighbor Roles

Affected neighbor roles:

- Compiler/Grammar Expert: future strict-refusal implementation would need compiler/result/orchestrator authority, but this card does not grant it.
- Bridge Agent: future CLI/API exposure and caller-facing behavior may depend on this map, but no bridge behavior is authorized.

## Scope

Read-only survey of current live code touchpoints a future PROP-038 strict-refusal implementation would need to name.

Read:

- `docs/gates/prop038-strict-refusal-result-shape-proof-acceptance-decision-v0.md`
- `docs/tracks/prop038-strict-refusal-result-shape-proof-local-v0.md`
- `docs/tracks/prop038-refusal-report-and-result-surface-survey-v0.md`
- `docs/tracks/prop038-public-result-and-diagnostics-proof-surface-survey-v0.md`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/compiler_result.rb`
- `lib/igniter_lang/compilation_report.rb`
- `lib/igniter_lang/diagnostics.rb`
- `lib/igniter_lang/assembler.rb`
- `lib/igniter_lang/cli.rb`
- `lib/igniter_lang.rb`
- `bin/igc`
- `lib/igniter_lang/compiler_profile_contract_validator.rb`
- `lib/igniter_lang/semanticir_emitter.rb`
- `rg "compiler_profile_contract_provider|compiler_profile_contract_validation|CompilerResult|public_result|refusal\\(|report_for_assembly|Assembler\\.assemble_artifacts|pass_result|diagnostics|compilation_report_path|runtime_smoke" igniter-lang/lib igniter-lang/bin`

No code was edited. This survey does not propose implementation code and does not authorize any surface.

## Current Horizon

- R81 accepted the strict-refusal result-shape proof locally only.
- Current live PROP-038 behavior remains report-only.
- Current live compiler has no `status: "refused"` compile path.
- Current invalid compiler-profile-contract validation still compiles and assembles.
- A future live implementation must name exact touchpoints before any code card opens.

## Current Live Pipeline Facts

```text
ParsedProgram
  -> Classifier
  -> TypeChecker
  -> SemanticIREmitter.emit_typed
  -> CompilationReport.enrich
  -> report_for_assembly = report
  -> optional compiler_profile_contract_provider
  -> CompilerProfileContractValidator.validate
  -> CompilationReport.with_compiler_profile_contract_validation(report_only: true)
  -> existing pass_result refusal gate
  -> Assembler.assemble_artifacts(report: report_for_assembly)
  -> optional runtime_smoke
  -> CompilerResult.ok
  -> CLI public_result JSON
```

Key code facts:

- `CompilerOrchestrator#compile` captures `report_for_assembly = report` before PROP-038 validation is attached.
- `CompilationReport.with_compiler_profile_contract_validation` adds nested `compiler_profile_contract_validation` and preserves existing `pass_result`.
- `compiler_profile_contract_validation` returns `nil` for no provider, non-Hash provider output, or provider exception.
- `CompilerProfileContractValidator.validate` emits `compile_refusal_authorized: false`.
- `CompilerOrchestrator#refusal` always writes a sidecar report before returning a refusal-shaped result.
- `CompilerResult.public_result` removes only the internal `report` key; it is not a whitelist.
- `CLI.run` prints `CompilerResult.public_result(...)` to stdout and returns false for any non-`ok` orchestration status.

## Future Touchpoint Candidate Table

These are non-authority observations. A future implementation card would need to name any touched file/method explicitly.

| Area | Current touchpoint | Current behavior | Future strict-refusal pressure |
| --- | --- | --- | --- |
| Orchestrator provider entry | `CompilerOrchestrator#initialize`, lines 20-31 | Optional `compiler_profile_contract_provider` dependency, default nil. | Strict mode needs an explicit source of authority; must not be inferred from provider presence alone. |
| Main compile pipeline | `CompilerOrchestrator#compile`, lines 34-113 | Validates profile contract only when `report["pass_result"] == "ok"`. | Strict refusal must decide whether it triggers here, before assembly and runtime smoke. |
| Report-only attachment | `CompilerOrchestrator#compile`, lines 58-69 and `CompilationReport.with_compiler_profile_contract_validation`, lines 68-73 | Nested validation is attached without changing `pass_result`. | Live strict refusal must not accidentally mutate report-only semantics for existing callers. |
| Existing refusal gate | `CompilerOrchestrator#compile`, line 71 | Only `report["pass_result"] != "ok"` enters current refusal. | R81 target keeps internal `report.pass_result: "ok"` for modeled strict paths, so using this gate would require a separate explicit decision. |
| Assembly boundary | `CompilerOrchestrator#compile`, lines 77-83 | Assembler receives `report_for_assembly`, not the annotated report. | Strict refusal must skip assembler without mutating current `.igapp` artifact material. |
| Runtime smoke boundary | `CompilerOrchestrator#compile`, lines 84-93 | Runtime smoke happens after assembly and can call current refusal with status `runtime_smoke_failed`. | Strict refusal should be pre-assembly; runtime smoke must remain a separate post-assembly failure path. |
| Existing sidecar refusal | `CompilerOrchestrator#refusal`, lines 143-158 | Computes report path, writes JSON, returns `CompilerResult.refusal`. | Non-persisting strict refusal cannot reuse this unchanged. |
| Report path derivation | `CompilerOrchestrator#report_path_for`, lines 160-167 | `OUT.igapp` maps to `OUT.compilation_report.json`. | Future no-sidecar proof must assert this path is not produced for strict refusal. |
| Report write helper | `CompilerOrchestrator#write_json`, lines 169-172 | Creates parent dir and writes report. | Must not be called by non-persisting strict refusal. |
| Provider failure behavior | `CompilerOrchestrator#compiler_profile_contract_validation`, lines 174-188 | No provider, non-Hash result, or exception fails open to nil validation. | Strict-source malformed/configuration behavior needs explicit policy before implementation. |
| Result success constructor | `CompilerResult.ok`, lines 9-27 | Public success contains `compilation_report_ref`, `semantic_ir_ref`, and `runtime_smoke`. | Must remain stable for report-only and success paths. |
| Result refusal constructor | `CompilerResult.refusal`, lines 30-47 | Requires `report_path`; exposes `compilation_report_path`; pulls only top-level report diagnostics. | R81 target has `compilation_report_path: null` and wrapper diagnostics, so reuse is not shape-compatible without changes. |
| Public result shaping | `CompilerResult.public_result`, lines 50-52 | Drops only `report`. | Any new internal top-level strict evidence leaks public unless this surface is explicitly changed or avoided. |
| Diagnostics split | `Diagnostics.errors/warnings`, lines 82-88 | Splits only top-level report diagnostics by severity. | Nested validator diagnostics remain hidden unless wrapper diagnostics are explicitly modeled. |
| Report constructors | `CompilationReport.parse_failure/runtime_smoke_failure/internal_error`, lines 9-55 | Current error/OFF reports set `pass_result` to `error` or `oof`. | Strict refusal must not blur parse/internal/runtime failure categories. |
| Validator result | `CompilerProfileContractValidator.validate`, lines 40-95 and result lines 149-159 | Returns validation object with `compile_refusal_authorized: false`. | Any live refusal must have new authority; validator result alone is not enough. |
| Assembler pass gate | `Assembler#assemble_artifacts`, lines 76-86 | Refuses non-`ok` pass_result and writes `.igapp` artifacts for ok. | Strict refusal must not enter assembler or change report_for_assembly. |
| Assembler writes | `Assembler#write_artifact_to`, lines 657-672 | Writes manifest, SemanticIR, compilation report, diagnostics, classified AST, projections, compatibility metadata, contract files. | Future strict mismatch must prove none of these paths are written. |
| CLI output/exit | `CLI.run`, lines 15-34 and `bin/igc`, lines 4-7 | Prints public JSON for compiler result; exits 1 for non-ok status. | Any live `refused` or `configuration_error` becomes caller-visible immediately. |
| Ruby facade | `IgniterLang.compile`, lines 9-26 | Passes through `compiler_profile_source` and optional orchestrator/runtime smoke. | Strict-source parameters or provider selection must not be added without API authority. |

## Coupling Risk Table

| Risk | Current coupling | Why it matters |
| --- | --- | --- |
| Sidecar leakage | `CompilerOrchestrator#refusal` always writes report JSON. | R81 target is non-persisting with `compilation_report_path: null`; current helper violates that target. |
| Public key leakage | `CompilerResult.public_result` strips only `report`. | New internal keys such as wrapper evidence or validation state would become public by default. |
| Diagnostic promotion drift | `CompilerResult.refusal` consumes only top-level `report["diagnostics"]`. | Raw nested validator diagnostics would stay hidden; wrapper diagnostics need a named public path. |
| `pass_result` mismatch | Current main refusal gate keys off `report["pass_result"] != "ok"`. | R81 accepted modeled `report.pass_result: "ok"` for strict paths, so strict refusal needs a separate trigger. |
| Artifact mutation | Assembler artifact material includes the report and writes `.igapp/compilation_report.json`. | Passing annotated or changed reports into assembler can alter artifact hash/material. |
| Provider fail-open | Provider exceptions currently return nil validation. | Changing to fail-closed would alter legacy/report-only behavior and public compile outcomes. |
| Status vocabulary leak | CLI treats any non-ok orchestration status as exit 1 and prints public JSON. | `refused` and `configuration_error` status exposure needs explicit API/CLI approval. |
| Existing OOF conflation | Current `CompilerResult.refusal` covers OOF/error/assembler/runtime-smoke paths. | PROP-038 strict refusal should not accidentally inherit OOF report-write semantics. |
| Runtime smoke ordering | Runtime smoke runs after assembly and uses current refusal. | Strict refusal should happen before assembly and must not touch runtime smoke behavior. |
| Validator authority confusion | Validator returns `compile_refusal_authorized: false`. | A future implementation must introduce separate authority rather than treating invalid validation as permission to refuse. |

## Regression Anchor Table

| Anchor | Command / artifact | Risk covered |
| --- | --- | --- |
| R81 strict result-shape proof | `ruby igniter-lang/experiments/prop038_strict_refusal_result_shape_proof/prop038_strict_refusal_result_shape_proof.rb` | Target public key-set, wrapper diagnostics, nested raw diagnostics, non-persisting strict shape. |
| R67 report-only compiler integration | `ruby igniter-lang/experiments/prop038_report_only_compiler_integration/prop038_report_only_compiler_integration.rb` | Invalid contract still status `ok`, public result unchanged, assembler executes, no refusal report. |
| R71 digest report-only integration | `ruby igniter-lang/experiments/prop038_contract_digest_report_only_integration_proof/prop038_contract_digest_report_only_integration_proof.rb` | Digest diagnostics nested; top-level report diagnostics/pass_result/stages/public result unchanged. |
| R70 recompute-match proof | `ruby igniter-lang/experiments/prop038_contract_digest_recompute_match_proof/prop038_contract_digest_recompute_match_proof.rb` | Digest mismatch and recompute-unavailable model diagnostics; fail-open/report-only baseline. |
| R69 shape-policy proof | `ruby igniter-lang/experiments/prop038_contract_digest_shape_policy_proof/prop038_contract_digest_shape_policy_proof.rb` | Digest shape/policy diagnostics and no live validator/compiler mutation assumptions. |
| R58/R60 contract validator proof | `ruby igniter-lang/experiments/compiler_profile_contract_proof/compiler_profile_contract_proof.rb` | Validator diagnostic namespace, one-owner/rule/digest matrix, `compile_refusal_authorized=false`. |
| R77 strict trigger proof | `ruby igniter-lang/experiments/prop038_strict_mode_refusal_trigger_proof/prop038_strict_mode_refusal_trigger_proof.rb` | Proof-local wrapper evidence and `would_refuse` trigger remains non-live. |
| Production compiler CLI proof | `ruby igniter-lang/experiments/production_compiler_cli/production_compiler_cli_proof.rb` | Public CLI stdout JSON, OOF sidecar report behavior, diagnostics categories, exit behavior. |
| Assembler proof | `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | `.igapp` artifact shape and assembler pass/refusal boundary remain stable. |

## Must Not Change Without Implementation Gate

- `CompilerOrchestrator#compile` live status or branch behavior.
- `CompilerOrchestrator#refusal` report-write behavior or report path policy.
- `CompilerResult.ok`, `CompilerResult.refusal`, or `CompilerResult.public_result`.
- `CompilationReport` `pass_result` vocabulary or report-only validation placement.
- `Diagnostics` top-level/nested diagnostic extraction rules.
- `CompilerProfileContractValidator` authority fields or invalid-result semantics.
- `Assembler#assemble_artifacts`, `report_for_assembly`, artifact hash material, or `.igapp` writes.
- `IgniterLang.compile` public Ruby facade parameters.
- `CLI.run` flags, preflight behavior, stdout/stderr split, or exit status.
- `bin/igc` process exit mapping.
- Loader/report, CompatibilityReport, RuntimeMachine, Gate 3, Ledger/TBackend, BiHistory, stream/OLAP, cache, or production behavior.

## Questions For C3-X / C4-A

[Q] Should a future strict-refusal path add a new orchestrator branch before the current `pass_result` gate, or should `pass_result` gain a strict-refusal value?

[Q] Should a future implementation introduce a new `CompilerResult` constructor for non-persisting strict refusal instead of reusing `CompilerResult.refusal`?

[Q] Does `configuration_error` permanently share the R81 public key-set, or should it receive a smaller shape?

[Q] What is the exact live authority source that allows invalid validator output to become compile refusal, given live validator results still say `compile_refusal_authorized: false`?

[Q] Should provider nil/non-Hash/exception remain fail-open under strict mode, or become `configuration_error` only when an explicit strict requirement is malformed?

[Q] Should public wrapper diagnostics be built as top-level result diagnostics only, or also appear in a non-persisted internal report object?

[Q] What proof owns the canonical no-sidecar/no-`.igapp` assertion for live strict mismatch?

[Q] Should CLI/API remain closed for the first live implementation, with strict behavior only injectable through internal orchestrator test seams?

## Command Matrix

| Command | Purpose | Result |
| --- | --- | --- |
| `rg "compiler_profile_contract_provider|compiler_profile_contract_validation|CompilerResult|public_result|refusal\\(|report_for_assembly|Assembler\\.assemble_artifacts|pass_result|diagnostics|compilation_report_path|runtime_smoke" igniter-lang/lib igniter-lang/bin` | Discover current live compiler/result/report/CLI touchpoints. | PASS |
| targeted `nl -ba` / `sed` reads of listed code files | Capture exact method/line-level surfaces. | PASS |
| targeted reads of R79/R80/R81 docs | Preserve accepted non-authorizations and prior survey facts. | PASS |

No proof suite was run because this card is a read-only survey and does not change code or generated artifacts.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: prop038-live-implementation-touchpoint-survey-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent

[D] Decisions:
- Mapped future strict-refusal live implementation touchpoints as code facts only.
- Confirmed current live PROP-038 behavior remains report-only and invalid validation still compiles/assembles.
- Confirmed current live compiler has no `status: "refused"` path.

[R] Recommendations:
- Do not open implementation until C3-X/C4-A names exact write scopes for `CompilerOrchestrator`, `CompilerResult`, report persistence, assembler skip, public result key-set, and CLI/API shielding.
- Treat `CompilerOrchestrator#refusal` as incompatible with R81 non-persisting target unless a later implementation gate explicitly changes report persistence policy.

[S] Signals:
- `report_for_assembly` currently protects `.igapp` artifacts from PROP-038 report-only annotation.
- `CompilerResult.public_result` is not a whitelist; any new top-level key leaks public.
- `CompilerResult.refusal` requires a report path and cannot directly produce the R81 `compilation_report_path: null` target.

[T] Tests / Proofs:
- Read-only `rg` and targeted source/doc reads completed.
- No proof suite was run; no code or generated artifacts changed.

[Files] Changed:
- igniter-lang/docs/tracks/prop038-live-implementation-touchpoint-survey-v0.md

[Q] Open Questions:
- Should strict refusal be a new orchestrator branch before the pass_result gate, or a new report/pass_result state?
- Should strict refusal use a new `CompilerResult` constructor?
- What explicit authority source upgrades invalid validation from report-only evidence to live refusal?
- Should malformed strict requirement share the R81 public key-set permanently?

[X] Rejected:
- No code changes.
- No live refusal.
- No public API/CLI widening.
- No `CompilerResult` mutation.
- No persisted report policy, loader/report, CompatibilityReport, runtime, or production behavior.

[Next] Proposed next slice:
- C3-X/C4-A implementation-scope review that chooses exact write scopes and regression assertions before any live strict-refusal code card opens.
```
