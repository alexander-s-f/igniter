# Counterfactual Audit Runtime Bridge Authority Facts Packet v0

Card: S3-R220-C2-P1
Skill: IDD Agent Protocol
Agent: Research Agent #1
Role: research-agent
Track: counterfactual-audit-runtime-bridge-authority-facts-packet-v0
Route: UPDATE
Depends on: S3-R219-C4-A
Status: complete
Date: 2026-05-31

## IDD Classification

Mode: standard, compact facts packet.

Contract:

- collect current Runtime/Bridge authority facts that could affect Option B
  proof-owned artifacts, Option D carrier options, or future report/API
  boundaries;
- do not decide the route;
- do not authorize implementation or public claims.

Authority rule:

```text
evidence != authority
proof-context runtime evidence != runtime/report/API support
```

## Inputs Read

- `stage3-round219-status-curation-v0.md`
- `counterfactual-audit-docs-status-index-companion-acceptance-decision-v0.md`
- `counterfactual-audit-proof-owned-artifact-home-design-acceptance-decision-v0.md`
- `counterfactual-audit-runtime-report-api-gate-survey-v0.md`
- `counterfactual-audit-runtime-bridge-architecture-survey-v0.md`
- `lib/igniter_lang/semanticir_expression_evaluator.rb`
- `experiments/runtime_machine_memory_proof/compiled_program.rb`
- `lib/igniter_lang/runtime_smoke.rb`
- `lib/igniter_lang/compiler_orchestrator.rb`
- `lib/igniter_lang/compiler_result.rb`
- `lib/igniter_lang/compilation_report.rb`

## Fixed Current State

R218 accepted Option B:

```text
proof-owned, non-canonical Option B artifact home evidence
```

R219 accepted Option C:

```text
internal docs/status index companion
discoverability aid only
not canonical authority
not artifact authority
```

R220 C1-D recorded these architecture-survey facts:

- Runtime/Bridge survey is sufficient for this round;
- Option D carrier is not structurally needed next;
- the immediate risk is accidental promotion through report/result/smoke/API
  surfaces;
- RuntimeSmoke remains proof-context only;
- `CompilerResult` and `CompilationReport` remain closed;
- dependency/cache authority remains closed.

This C2 packet records facts only. It does not accept, reject, or amend the C1-D
route recommendation.

## Surface Authority Table

| Surface | Current authority | Authority-confusion risk | Closed status |
| --- | --- | --- | --- |
| Option B artifact home | Proof-owned, non-canonical evidence only. | Machine-readable files can be mistaken for compiler-emitted artifact schema or reportable support. | Closed to runtime, report, API, public, Spark, compiler-emitted, cache/dependency, production authority. |
| Option C docs/status index | Internal discoverability aid only. | Repeated index/status wording can look like canon by repetition. | Closed to canonical/artifact authority and all runtime/report/API surfaces. |
| Option D carrier | Held; no accepted carrier boundary. | A carrier object could become an internal API or report/result payload by accident. | Held; not root-required, not compiler-consumed, not report/projected. |
| `SemanticIRExpressionEvaluator` | Internal direct-require evaluator for selected-branch lazy `if_expr`; supports `literal`, `ref`, `if_expr`. | `call_trace` or branch selection can be overread as counterfactual runtime or dependency authority. | Not root-required; not integrated into RuntimeSmoke, CompilerOrchestrator, CompilerResult, CompilationReport, Diagnostics, public API/CLI, release harness, or Spark. |
| Evaluator `external_evaluator` hook | Selected-path-only delegation for unsupported expression kinds. | A future projection engine could use it as live latent-branch execution by accident. | Non-selected branches remain unevaluated; hook is not report/cache/dependency authority. |
| Proof `CompiledProgram` loader | Experiment-owned `.igapp` loader and validator for proof RuntimeMachine. | Load validation and proof descriptors can look like production loader/report evidence. | Proof-local; not production RuntimeMachine, not loader/report, not CompatibilityReport authority. |
| Proof RuntimeMachine `load_program` | Emits proof descriptor observations, classified AST packet, and load receipt in memory backend. | Proof receipts/observations may be mistaken for durable audit/report authority. | Experiment-owned proof evidence only; no production receipt or audit authority. |
| Proof RuntimeMachine `evaluate_program` | Evaluates loaded proof program and emits proof value/eval observations. | Output observations can be mistaken for actual public runtime support. | Proof-context only; not public runtime, report, receipt, or cache authority. |
| Proof RuntimeMachine `tbackend_read` path | Requires backend and `as_of`; proof-local memory backend. | Could pressure live TBackend or temporal read authority. | No live TBackend, effect, external IO, or temporal authority from counterfactual lane. |
| `RuntimeSmoke.run` | Proof-backed wrapper around proof RuntimeMachine returning load/evaluate/resume status and outputs. | Its output can be embedded in compiler results and mistaken for feature support. | Proof-context only; result shape unchanged; must not carry Option B projections. |
| `RuntimeSmoke.callback` | Optional callback wrapper for `CompilerOrchestrator`. | A callback can turn proof evidence into compile gating or result payload. | Only current smoke status path exists; no counterfactual callback authority. |
| `CompilerOrchestrator.compile` | Parser -> classifier -> typechecker -> emitter -> assembler, optional runtime smoke after assembly. | Future counterfactual evidence could be smuggled through smoke or provider hooks. | No Option B/Option D counterfactual path; no report/API fields authorized. |
| Orchestrator refusal path | Writes compilation report sidecar for parse/OOF/internal/smoke/assembler refusal. | Projection failure could be promoted to actual compile/runtime failure. | Counterfactual projected failure remains non-actual and non-reportable. |
| Orchestrator strict terminal path | Internal compiler-profile strict terminal support for contract digest mismatch. | Could be confused with counterfactual strict/refusal authority. | Separate PROP-038 surface; no counterfactual authority. |
| `CompilerResult.ok` | Includes `runtime_smoke` and private `report` in result. | Any new positive field may leak because `public_result` strips only `report`. | No counterfactual fields; report/API survey required before any field design. |
| `CompilerResult.refusal` | Includes `compilation_report_path`, diagnostics, warnings, and report. | A projected failure could become a refusal diagnostic or persisted report path. | No projected failure/value diagnostics authorized. |
| `CompilerResult.strict_terminal` | Non-persisting terminal shape with `compilation_report_path: nil`. | Could look like a model for counterfactual refusal if copied. | PROP-038-only; not a counterfactual report/API authority. |
| `CompilerResult.public_result` | Removes only the `report` key. | Deny-one filtering means new fields are public by default. | Future counterfactual result fields are high risk and closed. |
| `CompilationReport.runtime_smoke_failure` | Converts untrusted smoke result into diagnostics on a compile report. | Projection failures could be misclassified as runtime smoke failures. | No counterfactual projection route into diagnostics. |
| `CompilationReport.with_compiler_profile_contract_validation` | Adds nested report-only compiler profile contract validation. | Nested report-only pattern may tempt counterfactual nested report fields. | PROP-038 report-only path only; not Option B authority. |
| Diagnostics | Parse/runtime-smoke/internal/profile validation helpers. | Counterfactual projected values/failures could be promoted to diagnostics. | No counterfactual diagnostics namespace or public diagnostics authority. |

## Existing Runtime / Evaluator Boundaries

Facts:

- `SemanticIRExpressionEvaluator` is explicitly internal and direct-require-only.
- It supports selected-branch lazy `if_expr`; it does not evaluate non-selected
  branches.
- Its `call_trace` is documented as proof/debug evidence only and must not be
  treated as dependency authority.
- The optional external evaluator is selected-path-only and does not run for
  non-selected branches.
- Errors are internal exception classes, not canonical diagnostics, not OOF-RT,
  and not report/API surface.

Authority risk:

- If Option B projection traces are routed through this evaluator, they may look
  like runtime traces. Current facts say they are not runtime, report,
  dependency, or cache authority.

## Proof RuntimeMachine Consumer Boundaries

Facts:

- The proof `CompiledProgram` lives under `experiments/`.
- It loads `.igapp` artifacts for proof RuntimeMachine use, validates manifest,
  semantic IR program, compilation report, contract files, specialization
  manifest, and metadata-only templates.
- It delegates selected `if_expr` evaluation to
  `SemanticIRExpressionEvaluator`.
- `apply`, `field_access`, and `tbackend_read` remain proof RuntimeMachine-local.
- `load_program` and `evaluate_program` emit observations/receipts into a proof
  memory backend.

Authority risk:

- Proof loader validation, descriptor observations, value observations, and eval
  receipts can look like production loader/report/audit evidence. Current facts
  keep them proof-local only.

## RuntimeSmoke Boundaries

Facts:

- `RuntimeSmoke` directly requires the proof RuntimeMachine compiled-program
  experiment.
- `RuntimeSmoke.run` loads, validates, evaluates, checkpoints, and resumes the
  proof program, then returns load/evaluate/resume status, outputs, and trusted
  boolean.
- `RuntimeSmoke.callback` can be passed into `CompilerOrchestrator.compile`.
- The orchestrator can put smoke output into `CompilerResult.ok` or convert
  failed smoke into `CompilationReport.runtime_smoke_failure`.

Authority risk:

- RuntimeSmoke is the easiest accidental promotion path because it already has
  a callback boundary and result slot. Current facts say RuntimeSmoke remains
  proof-context only and must not carry Option B projections or an Option D
  carrier without a separate gate.

## Compiler Report / Result Exposure Points

Facts:

- `CompilerOrchestrator` validates compiler profile contracts report-only before
  assembly when compilation has `pass_result: ok`.
- `report_for_assembly` is captured before profile-contract validation is added,
  so assembly is isolated from that nested report-only validation data.
- `CompilerOrchestrator` writes a compilation report sidecar on ordinary refusal.
- Strict terminal results do not write a report path and use
  `compilation_report_path: nil`.
- `CompilerResult.ok` includes `runtime_smoke` and `report`.
- `CompilerResult.public_result` strips only `report`.
- `CompilationReport.runtime_smoke_failure` appends runtime-smoke diagnostics.

Authority risk:

- A future positive counterfactual field in `CompilerResult` would likely be
  exposed by `public_result`.
- A future projection failure routed through runtime smoke could become a public
  diagnostic and persisted refusal report.
- Nested report-only validation precedent exists for PROP-038, but it does not
  authorize counterfactual nested report fields.

## Existing Report/API Gate Conclusions

From the prior gate survey:

- runtime/report/API design remains blocked until artifact-home and authority
  decisions close;
- report/result/receipt/API surfaces have no counterfactual fields;
- dependency/cache authority must stay closed unless a dedicated route opens;
- RuntimeSmoke proof-context evidence is not feature support;
- public API/CLI/Spark/release gates remain closed.

From R218/R219:

- Option B is accepted as proof-owned, non-canonical evidence only;
- Option C is accepted as internal discoverability aid only;
- Option D remains held;
- Options E/F remain comparison-only and closed.

From R220 C1-D:

- Option D carrier is not structurally needed next;
- report/API boundary survey was named as the next risk reducer by C1-D;
- runtime/evaluator implementation remains closed.

This C2 packet records those as facts, not as a new route decision.

## Confusion Hotspots

| Hotspot | Why it matters | Fact to preserve |
| --- | --- | --- |
| `RuntimeSmoke` callback | Existing compiler hook can affect compile result and diagnostics. | Do not use RuntimeSmoke as Option B/D carrier. |
| `CompilerResult.public_result` | Only strips `report`, so new keys leak. | Any counterfactual result field is public-risk until surveyed. |
| `CompilationReport.runtime_smoke_failure` | Converts smoke failure into diagnostics. | `projected_failure != actual_runtime_failure`. |
| Proof RuntimeMachine receipts | Proof packets look receipt-like. | Proof receipts are not production receipts/audit. |
| Evaluator `call_trace` | Trace can look like dependency graph. | Trace is proof/debug only, not cache/dependency authority. |
| Option C status index | Internal docs can become pseudo-canon by repetition. | Index remains discoverability-only. |
| PROP-038 nested validation | Report-only nested data exists. | Report-only precedent is not counterfactual field authority. |

## Closed Surfaces

Remain closed:

- code implementation and `lib/**` changes;
- parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator changes;
- runtime/evaluator behavior changes;
- proof RuntimeMachine production use;
- RuntimeSmoke behavior/result-shape changes;
- CompilerResult, CompilationReport, Diagnostics, report/result/receipt, and
  CompatibilityReport shape changes;
- Option D carrier design or implementation;
- compiler-emitted artifact authority;
- dependency/cache authority;
- TBackend/effect/external IO non-refusal;
- public API/CLI;
- public docs/body spec/PROP-032 support claims;
- Spark authority or integration;
- release evidence, release execution, publish, tag, push, deploy;
- production behavior.

## Exact Facts Handoff For C3-X

C3-X should pressure these facts:

- Whether this packet accurately separates proof-owned evidence from runtime,
  report, API, and public authority.
- Whether `RuntimeSmoke` is correctly identified as the highest accidental
  promotion path.
- Whether `CompilerResult.public_result` deny-one filtering makes future
  positive fields high risk.
- Whether proof RuntimeMachine observations/receipts are adequately fenced as
  proof-local only.
- Whether PROP-038 report-only nested validation is correctly treated as a
  separate precedent, not counterfactual authority.
- Whether the closed-surface list is complete enough for C4-A.

Do not pressure this packet as an implementation proposal; it is facts-only.

## Exact Facts Handoff For C4-A

C4-A can use this packet to decide only the next review route. Facts available:

- Option B and C are accepted as non-authority evidence/discoverability aids.
- Option D remains held and has no accepted consumer.
- RuntimeSmoke has an existing compiler callback path and result slot.
- `CompilerResult.public_result` would expose new keys unless separately
  redesigned.
- `CompilationReport.runtime_smoke_failure` can turn smoke failures into
  diagnostics, so projection failures must not enter that path by default.
- Proof RuntimeMachine observations and receipts remain proof-local.
- Evaluator trace remains proof/debug only.

Held risk note:

```text
Any future implementation route should first fence report/result/API exposure;
implementation remains closed here.
```

## Command Matrix

| Command / read | Result |
| --- | --- |
| `git status --short` | PASS; workspace was clean before this packet. |
| `rg -n "counterfactual-audit-..." igniter-lang/docs/tracks -g "*.md"` | PASS; located R219/R220 inputs. |
| `sed -n` read of R219 status, Option C acceptance, Option B acceptance, runtime/report/API gate survey | PASS. |
| `sed -n` read of R220 C1-D runtime/bridge architecture survey | PASS. |
| `sed -n` read of evaluator, proof RuntimeMachine, RuntimeSmoke, CompilerOrchestrator, CompilerResult, CompilationReport | PASS. |

No executable proof was required or run. No code/runtime/report/API/public
surface was changed.

## Compact Handoff

[D] This packet records Runtime/Bridge authority facts only. It does not decide
the next route.

[S] Main confusion hotspot: RuntimeSmoke already bridges proof RuntimeMachine
output into compiler result/smoke failure paths, so it must not carry Option B
projection evidence by default.

[T] `CompilerResult.public_result` exposes any new positive key except `report`,
which makes future counterfactual result fields high-risk without a boundary
survey.

[R] For C3-X/C4-A: pressure report/result/API fences before any Option D carrier
or RuntimeSmoke-carrier route. Implementation remains held.

[Next] C3-X can pressure this facts packet; C4-A can decide whether to accept it
as the current Runtime/Bridge authority fact basis.
