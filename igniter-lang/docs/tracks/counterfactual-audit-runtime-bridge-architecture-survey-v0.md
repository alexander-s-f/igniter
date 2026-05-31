# Counterfactual Audit Runtime Bridge Architecture Survey v0

Card: S3-R220-C1-D
Skill: IDD Agent Protocol
Agent: [Framework Supervisor]
Role: framework-supervisor
Track: counterfactual-audit-runtime-bridge-architecture-survey-v0
Route: UPDATE
Status: done / design-survey-only
Date: 2026-05-31

Depends on:
- S3-R219-C4-A

---

## IDD Lane Classification

Lane:

```text
standard
```

Reason:

- this is an internal architecture/design survey with cross-lane implications;
- it edits one internal track doc only;
- it does not edit code, public docs, body spec chapters, reports/results/API
  shapes, runtime behavior, Spark surfaces, release evidence, or production
  claims.

---

## Purpose

Survey the Runtime/Bridge implications of accepted Option B proof-owned artifact
home evidence and accepted Option C docs/status index companion.

This card answers whether the next route should be:

- Option D internal non-canonical carrier boundary;
- report/API boundary survey;
- runtime/evaluator design-only route;
- continued hold.

This survey does not authorize implementation, runtime/report/API/public/Spark
authority, release execution, or public claims.

---

## IDD Evidence / Decision / Next Contract

Evidence:

- Source: accepted R218 Option B artifact-home proof, accepted R219 Option C
  docs/status index, and current Runtime/Bridge code surfaces.
- Scope: read-only architecture survey; one internal track doc.
- Strongest facts: Option B/C reduce evidence rediscovery drift; current runtime
  support remains selected-branch/proof-context only; `CompilerResult` and
  `CompilationReport` have no counterfactual fields.
- Missing / ambiguous: whether any report/API/result surface should ever accept
  Option B evidence, and whether any future internal carrier has a concrete
  consumer.

Decision:

- Status: pass / redirect next route.
- Why: Runtime/Bridge survey is sufficient for this round; the next risk is
  accidental report/API/result promotion, not missing runtime code.
- Evidence only: Option B artifacts, Option C index, RuntimeSmoke proof output,
  evaluator traces, proof RuntimeMachine observations.
- Authority remains: no runtime, report, API, public, Spark, release,
  dependency, cache, or compiler-emitted authority.

Next contract:

- Card/doc: `counterfactual-audit-report-api-boundary-survey-v0`.
- Allowed: read-only/design-only survey of `CompilerResult`,
  `CompilationReport`, RuntimeSmoke output, CompatibilityReport, receipt/result
  sidecars, public API/CLI, and docs/status surfaces.
- Closed: code edits, runtime/evaluator integration, result/report field
  changes, Option D carrier design, public docs/body spec edits, Spark,
  release/public claims.
- Verification: closed-surface matrix plus explicit yes/no answers.

---

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round219-status-curation-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-docs-status-index-companion-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-docs-status-index-companion-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-proof-owned-artifact-home-design-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-artifact-home-and-authority-decision-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-report-api-gate-survey-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-current-source-evidence-surface-survey-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-and-time-to-market-decision-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-artifact-home-and-authority-options-v0.md`
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/lib/igniter_lang/compiler_orchestrator.rb`
- `igniter-lang/lib/igniter_lang/compiler_result.rb`
- `igniter-lang/lib/igniter_lang/compilation_report.rb`
- `CLAUDE.md` Agent Protocol note

---

## Accepted Fixed Point

Accepted state after R219:

- Option B is accepted as proof-owned, non-canonical evidence only.
- Option C is accepted as an internal docs/status discoverability companion
  only.
- Option C does not create canonical, artifact, runtime, report, API, public,
  Spark, release, cache, dependency, or compiler-emitted authority.
- Option D remains held.
- Options E/F remain comparison-only and closed.
- Runtime/Bridge architecture survey may open as read-only/design-survey only.

Binding no-authority posture:

```text
canonical:            false
runtime_authority:    false
report_authority:     false
cache_authority:      false
dependency_authority: false
public_api_authority: false
compiler_emitted:     false
spark_authority:      false
production_authority: false
```

Binding disclaimers:

```text
projected_value != actual_output
projected_failure != actual_runtime_failure
```

---

## Compact Runtime / Bridge Surface Map

| Surface | Current execution / evidence meaning | Promotion risk | R220 stance |
| --- | --- | --- | --- |
| `SemanticIRExpressionEvaluator` | Internal direct-require evaluator for selected-branch lazy `if_expr`; supports `literal`, `ref`, `if_expr`; optional selected-path `external_evaluator`; `call_trace` is proof/debug only. | Could be overread as runtime counterfactual evaluator or dependency authority if projection traces are routed through it. | Keep internal selected-branch evaluator only; no counterfactual runtime route. |
| Proof `CompiledProgram` / proof `RuntimeMachine` | Experiment-owned proof RuntimeMachine loads proof `.igapp` artifacts, delegates selected `if_expr`, owns `apply`, `field_access`, `tbackend_read`, emits proof observations/receipts in memory backend. | Proof receipts/observations can look like production runtime/report evidence. | Keep proof-context only; not a production RuntimeMachine or receipt authority. |
| `RuntimeSmoke` | Proof-backed wrapper around proof RuntimeMachine; returns load/evaluate/resume status and outputs; transitive proof load is accepted known proof harness behavior. | `RuntimeSmoke.run` output can be embedded in `CompilerResult.runtime_smoke` and later mistaken for feature support. | RuntimeSmoke remains proof-context only; no result-shape or feature-support claim. |
| `CompilerOrchestrator` | Optional `runtime_smoke` callback after assembly; blocks compile result if smoke exists and is not trusted; writes refusal report on failure. | Any future counterfactual callback could turn proof evidence into compiler gate behavior or persisted report diagnostics. | Do not route Option B evidence through orchestrator callbacks. |
| `CompilerResult` | `ok` includes `runtime_smoke` and internal `report`; `public_result` strips only `report`; no counterfactual fields. | Adding carrier/projection fields could leak through public result because filtering is deny-one, not allow-list. | Remains closed; needs report/API boundary survey before any field design. |
| `CompilationReport` | Parse/runtime/internal/profile validation report helper; `runtime_smoke_failure` converts smoke failure into diagnostics; no counterfactual fields. | Projection failures could become diagnostics and be mistaken for actual runtime failures. | Remains closed; projected failure must stay non-actual evidence only. |
| Option B artifact home | Proof-owned artifact directory with manifest/source refs/input snapshots/premise sets/projections; non-canonical evidence only. | Machine-readable artifacts can be mistaken for compiler-emitted artifacts or reportable support. | Sufficient evidence home for now; no runtime/report/API authority. |
| Option C docs/status index | Internal discoverability aid pointing to Option B evidence and no-authority flags. | Canon-by-repetition or status wording could imply canonical home. | Accepted only as index; not artifact authority. |

---

## Where Runtime / Bridge Carries Execution Or Evidence Meaning

Runtime execution meaning exists only in these bounded places:

- selected-branch evaluation inside `SemanticIRExpressionEvaluator`;
- proof-owned selected-path execution inside the RuntimeMachine memory proof;
- proof-context smoke execution through `RuntimeSmoke.run`;
- optional compiler smoke callback behavior in `CompilerOrchestrator`.

Evidence meaning exists only as:

- proof summaries and digests;
- proof-owned artifact-home files from Option B;
- internal docs/status index references from Option C;
- RuntimeSmoke proof-context output when explicitly passed as a compiler smoke
  callback.

None of these creates:

- latent branch live evaluation;
- counterfactual runtime support;
- report/result/receipt authority;
- dependency/cache authority;
- public API/CLI/Spark support;
- release or production evidence.

---

## Accidental Promotion Paths

| Promotion path | How it could happen | Required fence |
| --- | --- | --- |
| Option B -> `RuntimeSmoke` | A future smoke callback reads Option B projections and returns them as smoke output. | Keep Option B out of `RuntimeSmoke`; RuntimeSmoke remains selected execution proof-context only. |
| Option B -> `CompilerResult.runtime_smoke` | Orchestrator already embeds smoke output in successful results. | Do not use smoke output as carrier for counterfactual evidence. |
| Option B -> `CompilationReport` diagnostics | Projection failure could be emitted through `runtime_smoke_failure`. | Projected failure is not actual runtime failure; no diagnostics route without separate gate. |
| Option B -> `CompilerResult.public_result` | New result keys could leak because `public_result` removes only `report`. | Report/API boundary survey before any field design; prefer no new keys now. |
| Option B -> proof RuntimeMachine receipts | Proof observations/receipts could be treated as production receipts. | Proof RuntimeMachine remains experiment-owned; receipts are proof evidence only. |
| Option B -> dependency/cache | `call_trace` or projection trace could be used as selected-path dependency truth. | Keep call/projection traces proof/debug only; cache/dependency authority closed. |
| Option C -> canon by repetition | Internal status/index repeats accepted home/digests. | Keep "discoverability aid only" and all no-authority flags with every index reference. |

---

## Option D Carrier Need Assessment

Decision:

```text
Option D carrier boundary should not open next.
```

Assessment:

- Option B now supplies a proof-owned machine-readable evidence home.
- Option C now supplies internal human discoverability.
- No accepted consumer currently needs a normalized internal carrier object.
- Opening a carrier before report/API boundary review would increase leakage
  risk into `CompilerResult`, `CompilationReport`, `RuntimeSmoke`, receipts, or
  public API.

Structural need:

```text
not structurally needed yet
```

Option D becomes reasonable later only if a future internal tool needs to read
Option B evidence repeatedly and cannot safely use the proof-owned artifact home
plus docs/status index. Even then, it must be design-only first and must carry:

- `canonical:false`;
- `runtime_authority:false`;
- `report_authority:false`;
- `cache_authority:false`;
- `dependency_authority:false`;
- `public_api_authority:false`;
- `compiler_emitted:false`;
- `spark_authority:false`;
- `production_authority:false`;
- projected value/failure disclaimers;
- no root require;
- no compiler pipeline integration;
- no `CompilerResult` / `CompilationReport` / `RuntimeSmoke` / receipt shape
  change.

---

## Report / API Timing Assessment

Decision:

```text
report/API boundary survey should open next.
```

Why now:

- R215 listed report/result/receipt/API gates as a blocker before runtime or L4
  pressure.
- R218/R219 closed artifact-home and docs/status index decisions enough to give
  report/API review a concrete object to fence: Option B evidence plus Option C
  index.
- The most immediate time-to-market risk is not lack of a carrier; it is future
  accidental leakage through existing result/report/smoke surfaces.
- A report/API boundary survey can be read-only/design-only and can reduce
  repeated reconstruction without weakening proof quality.

Recommended survey questions:

- Should `CompilerResult` remain closed to all Option B fields? Default: yes.
- Should `CompilationReport` remain closed to projected failure/value fields?
  Default: yes.
- Should `RuntimeSmoke` output remain selected execution proof-context only?
  Default: yes.
- Should `CompilerResult.public_result` be treated as unsafe for future
  positive counterfactual fields without allow-list review? Default: yes.
- Should any future report/result/receipt/API route be held until Option D has
  a consumer need? Default: yes.

---

## Runtime / Evaluator Recommendation

Decision:

```text
runtime/evaluator implementation remains closed.
```

No runtime/evaluator design-only route should open next.

Reasons:

- live evaluator already has a precise selected-branch-only boundary;
- proof RuntimeMachine already supplies proof-context selected-path evidence;
- RuntimeSmoke already has accepted proof-context evidence only;
- Option B projections are explanatory counterfactual evidence, not selected
  runtime execution;
- opening runtime/evaluator design now would blur
  `projected_value != actual_output` and
  `projected_failure != actual_runtime_failure`.

Runtime/Bridge architecture survey is sufficient for this round because the
current question is routing/authority, not missing evaluator behavior.

---

## RuntimeSmoke Assessment

Decision:

```text
RuntimeSmoke remains proof-context only.
```

Accepted maximum meaning:

- RuntimeSmoke can consume proof-owned `.igapp` artifacts in a bounded proof
  context through the proof RuntimeMachine;
- RuntimeSmoke transitive loading of proof machinery is proof harness behavior;
- RuntimeSmoke output is not public runtime support;
- RuntimeSmoke output shape remains unchanged;
- RuntimeSmoke must not carry Option B projections or Option D carrier payloads
  without a separate authority route.

---

## CompilerResult / CompilationReport Assessment

Decision:

```text
CompilerResult and CompilationReport remain closed.
```

`CompilerResult` remains closed because:

- it has no counterfactual fields;
- successful results can include `runtime_smoke`;
- `public_result` strips only `report`, so any new positive field could leak;
- no public/API support is authorized.

`CompilationReport` remains closed because:

- it has no counterfactual/projection fields;
- `runtime_smoke_failure` can turn smoke failure into diagnostics;
- projected failures must not become actual runtime diagnostics.

Any later field design requires a separate report/API boundary decision and
pressure review.

---

## Dependency / Cache Authority Assessment

Decision:

```text
dependency/cache authority remains closed.
```

Current closed stance:

- evaluator `call_trace` is proof/debug only;
- proof RuntimeMachine execution trace is proof/debug only;
- Option B projection trace is explanatory evidence only;
- static dependency union remains the compiler/runtime baseline;
- no path-sensitive cache key, invalidation, freshness, dependency truth, or
  TBackend read authority is created by Option B/C.

No dependency/cache route should open next.

---

## Closed-Surface Matrix

| Surface | R220 status | Reason |
| --- | --- | --- |
| Code / `lib/**` edits | Closed | Survey-only card; no implementation. |
| Runtime/evaluator implementation | Closed | Selected-branch evaluator remains enough; counterfactual runtime is not authorized. |
| Proof RuntimeMachine production use | Closed | Experiment-owned proof machinery only. |
| RuntimeSmoke behavior/result shape | Closed | Proof-context only; no feature-support claim. |
| CompilerOrchestrator integration | Closed | Option B must not become compile gate or smoke callback payload. |
| `CompilerResult` | Closed | No projection fields; public result leakage risk. |
| `CompilationReport` | Closed | No projected failure/value diagnostics. |
| Report/result/receipt/CompatibilityReport | Closed pending survey | Needs next report/API boundary survey. |
| Option D carrier | Held | Not structurally needed yet; wait for report/API boundary survey and consumer need. |
| Compiler-emitted artifact | Closed | Option E remains comparison-only. |
| Public API/CLI | Closed | No support/feature claim. |
| Spark | Closed | No Spark authority or integration. |
| Cache/dependency | Closed | Traces remain proof/debug only. |
| Public docs/body spec/PROP-032 | Closed | No public/spec mutation in this route. |
| Release evidence/execution | Closed | No release, publish, tag, push, deploy, or public claim. |
| Production behavior | Closed | No production runtime/readiness claim. |

---

## Exact Explicit Answers

| Question | Answer |
| --- | --- |
| Is Runtime/Bridge architecture survey sufficient for this round? | Yes. It resolves route timing and authority fences without code or public-surface edits. |
| Should Option D carrier boundary open next? | No. It is not structurally needed yet; hold until report/API boundary survey and a concrete internal consumer need. |
| Should report/API boundary survey open next or wait? | Open next, design-only/read-only. It is the safest next risk reducer. |
| Does runtime/evaluator implementation remain closed? | Yes. |
| Does runtime/evaluator design-only route open next? | No. Hold. |
| Does RuntimeSmoke remain proof-context only? | Yes. |
| Do `CompilerResult` and `CompilationReport` remain closed? | Yes. |
| Does dependency/cache authority remain closed? | Yes. |
| Do public/Spark/API/release claims remain closed? | Yes. |

---

## Recommended Next Route For C4-A

Open next:

```text
Card: S3-R220-C4-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: counterfactual-audit-runtime-bridge-architecture-survey-acceptance-decision-v0
Route: UPDATE
Depends on:
- S3-R220-C1-D
```

Acceptance recommendation:

```text
accept Runtime/Bridge architecture survey
open report/API boundary survey next
keep Option D held
keep runtime/evaluator implementation held
keep RuntimeSmoke proof-context only
keep CompilerResult and CompilationReport closed
keep dependency/cache authority closed
keep public/Spark/API/release claims closed
```

Then open:

```text
Card: S3-R221-C1-D
Skill: IDD Agent Protocol
Agent: [Framework Supervisor] or [Research Agent]
Role: framework-supervisor
Track: counterfactual-audit-report-api-boundary-survey-v0
Route: UPDATE
Depends on:
- S3-R220-C4-A
```

Goal:

```text
Survey whether CompilerResult, CompilationReport, RuntimeSmoke output,
CompatibilityReport, receipt/result sidecars, public API/CLI, and docs/status
surfaces must remain closed around Option B/C counterfactual audit evidence, or
whether any later design-only non-authority route should open.
```

Boundary:

- read-only/design-only;
- no code edits;
- no report/result/API field changes;
- no runtime/evaluator integration;
- no public docs/body spec edits;
- no Spark authority;
- no release/public claims.

Do not open next:

- Option D carrier implementation or design;
- runtime/evaluator implementation;
- RuntimeSmoke feature-support route;
- compiler-emitted artifact route;
- report/result/receipt field design;
- public API/CLI/Spark/demo/release route.

---

## Command / Evidence Matrix

| Command / read | Result |
| --- | --- |
| `rg -n "IDD Agent Protocol\|IDD\|agent protocol\|Protocol" . igniter-lang ...` | PASS; found project IDD Agent Protocol note in `CLAUDE.md`. |
| `sed -n` reads for R219 status, Option C acceptance/index, Option B acceptance, artifact-home authority decision, runtime/report/API gate survey | PASS; accepted B/C and closed surfaces confirmed. |
| `sed -n` reads for evaluator, proof RuntimeMachine, RuntimeSmoke, CompilerOrchestrator, CompilerResult, CompilationReport | PASS; current Runtime/Bridge surfaces mapped. |
| `rg -n "Round 219\|RuntimeSmoke\|CompilerResult\|CompilationReport..."` | PASS; status/context scan confirmed current R219 boundary and historical closure language. |

No executable proof was required or run. No code, public docs, body spec
chapters, runtime/report/API surfaces, or release artifacts were changed.

---

## Compact Handoff

```text
[Framework Supervisor]
Track: counterfactual-audit-runtime-bridge-architecture-survey-v0
Status: done

[D] Decisions:
- Runtime/Bridge survey is sufficient for this round.
- Option D carrier is not structurally needed next.
- Report/API boundary survey should open next.
- Runtime/evaluator implementation remains closed.
- RuntimeSmoke remains proof-context only.
- CompilerResult and CompilationReport remain closed.
- Dependency/cache authority remains closed.
- Public/Spark/API/release claims remain closed.

[R] Recommendation:
- Accept this survey, then open
  counterfactual-audit-report-api-boundary-survey-v0 as read-only/design-only.

[S] Signals:
- B/C already reduce evidence rediscovery drift.
- The main next risk is accidental promotion through report/result/smoke/API
  surfaces, not missing runtime code or missing carrier shape.

[T] Tests / Proofs:
- Read-only survey only; no executable proof required.

[Files] Changed:
- igniter-lang/docs/tracks/counterfactual-audit-runtime-bridge-architecture-survey-v0.md

[X] Rejected / held:
- Option D next.
- Runtime/evaluator design or implementation next.
- CompilerResult / CompilationReport mutation.
- RuntimeSmoke support route.
- Public/Spark/API/release claims.
```
