# Counterfactual Audit Runtime Debt Facts Packet v0

Card: S3-R216-C2-P1
Agent: [Research Agent #1]
Role: research-agent
Track: counterfactual-audit-runtime-debt-facts-packet-v0
Route: UPDATE
Depends on:
- S3-R215-C4-A
Status: done
Date: 2026-05-30

## Purpose

Compact facts packet for runtime debt, current live/proof runtime surfaces, and
missing authority before the R216 Portfolio decision.

This packet does not authorize code changes, runtime/report/API design, public
claims, or RuntimeSmoke feature support.

## Inputs Read

- `igniter-lang/docs/tracks/stage3-round215-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-internal-lane-map-decision-v0.md`
- `igniter-lang/docs/tracks/counterfactual-audit-runtime-report-api-gate-survey-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-proof-acceptance-decision-v0.md`
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- selected proof summaries for R199/R201/R203/R211.

## Current Fixed Point

R215 accepted the internal Counterfactual Audit Lane map:

```text
L1  Static branch intention
L2a Isolated projection concept
L2b Source-backed isolated projection
L3  Route map / artifact home / authority design
L4  Runtime-report-API candidates
```

Binding facts:
- L3 must close artifact-home and authority questions before L4 can open.
- Runtime-debt / time-to-market review is non-authorizing.
- RuntimeSmoke proof-context evidence is not feature support.
- Report/result/receipt/CompatibilityReport/API/cache/Spark/public surfaces
  remain closed.

## Live Runtime Facts

| Fact | Evidence | Boundary |
| --- | --- | --- |
| `IgniterLang::SemanticIRExpressionEvaluator` exists in `lib/`. | `semanticir_expression_evaluator.rb`; R199 accepted 68/68 PASS. | Internal, direct-require-only, not root-required. |
| Supported evaluator kinds are `literal`, `ref`, `if_expr`. | `SUPPORTED_KINDS = %w[literal ref if_expr]`. | `apply`, `field_access`, `tbackend_read` are excluded from evaluator core. |
| `if_expr` runtime semantics are lazy. | Source comments and R199 acceptance: condition first, exact Bool, selected branch only. | No non-selected branch live evaluation. |
| `external_evaluator:` hook exists. | `evaluate(expr, values = {}, call_trace: nil, external_evaluator: nil)`. | Hook is Slice 2 adapter support, not public API. |
| `call_trace` is proof/debug only. | Source comments and R201/R215 fences. | Not dependency/cache/report authority. |
| Evaluator errors are internal/non-canonical. | Source class comments and exception classes. | No OOF-RT, Diagnostics, CompilerResult, CompilationReport, or public API integration. |

## Proof-Only Runtime Facts

| Fact | Evidence | Boundary |
| --- | --- | --- |
| Proof RuntimeMachine consumes `if_expr`. | `compiled_program.rb` delegates `if_expr` to `SemanticIRExpressionEvaluator`; R201 accepted 56/56 PASS. | Experiment-owned proof RuntimeMachine path, not production runtime. |
| Proof RuntimeMachine owns selected `apply`, `field_access`, and `tbackend_read` handling. | `compiled_program.rb` routes these kinds locally after evaluator delegation. | Not evaluator core and not production ownership. |
| Proof RuntimeMachine evaluates with explicit `as_of`. | `evaluate_program` refuses missing `as_of`. | Not a general counterfactual runtime authority. |
| RuntimeSmoke uses proof-backed compiled program loader. | `runtime_smoke.rb` requires `../../experiments/runtime_machine_memory_proof/compiled_program`. | Known proof harness consequence, not feature support. |
| RuntimeSmoke result shape is unchanged. | R203 acceptance: success keys and failure keys preserved. | No public/stable `if_expr` RuntimeSmoke support claim. |
| RuntimeSmoke can consume proof-owned if_expr `.igapp` artifacts. | R203 accepted 53/53 PASS. | Proof-context evidence only. |
| Source-backed Level 2 dry-run proof exists. | R211 accepted 61/61 PASS. | Experiment-local, source-backed, no-authority projection evidence. |

## Runtime Debt Table

| Debt | Current fact | Risk | Needed before promotion |
| --- | --- | --- | --- |
| Split runtime surfaces | Live evaluator, proof RuntimeMachine, RuntimeSmoke proof harness, and dry-run proof are separate. | Moderate confusion risk. | L3 route map plus exact owner handoffs. |
| Artifact home absent | R211 artifacts live under experiment `out/`. | Repeated proof reconstruction and no stable carrier. | Artifact-home decision. |
| Authority model absent | Refs/snapshots/premises/projections are no-authority proof fields. | Any report/runtime move could overclaim. | Authority model for every evidence/ref field. |
| Report/result/receipt closed | No current counterfactual fields. | Product/tool story blocked, intentionally. | Surface survey and explicit gate. |
| Dependency/cache authority closed | Static union remains boundary; `call_trace` proof/debug only. | Selected-path data could be misread as cache truth. | Dedicated dependency/cache stance. |
| TBackend/effect refusal | Dry-run refuses `tbackend_read`, escape/effect/external IO. | Realistic temporal what-if remains blocked. | Separate temporal/effect gate before non-refusal. |
| RuntimeSmoke wording fragile | Transitive evaluator load exists through proof RuntimeMachine require. | Easy to overread as feature support. | Preserve non-support wording in every follow-up. |

## Missing Authority Table

| Authority area | Current state | Missing before design/implementation |
| --- | --- | --- |
| Runtime dry-run | Closed. | Decision that dry-run should ever move beyond experiment-local isolation. |
| Live non-selected branch evaluation | Closed/forbidden. | No planned authority; would contradict current lazy invariant. |
| Artifact home | Open L3 blocker. | Permanent proof-local vs internal carrier vs other home decision. |
| Projection authority | No-authority proof object. | Semantics for `projected_value`, `projected_failure`, trace, and digest refs. |
| Source refs | Proof-owned, digest-addressed in R211. | Authority owner and stability policy outside experiment outputs. |
| Input snapshots | Frozen proof artifacts in R211. | Snapshot source, mutability, privacy, and persistence model. |
| Premise sets | Explicit proof objects in R211. | Owner, validation, and relationship to assumptions/PROP-032. |
| Report/result/receipt | Closed. | Whether any surface may even receive design-only consideration. |
| CompatibilityReport | Closed. | Bridge decision; current lane has no readiness/trust authority. |
| Dependency/cache | Closed. | Explicit cache/dependency route if ever needed. |
| Public API/CLI/Spark/release | Closed. | Separate public/product/release gates. |

## Time-To-Market Risk Facts

Accepted non-authorizing context from R214/R215:

```text
Time-to-market risk: 4/10
Execution quality: 8/10
```

Facts:
- Risk is moderate and mostly about repeated boundary reconstruction, not proof
  failure.
- Proof quality is high: R199 68/68, R201 56/56, R203 53/53, R211 61/61.
- Fastest safe path is route clarity around L3, not runtime implementation.
- Product/demo/Spark shortcuts would increase claim risk faster than they reduce
  runtime debt.

## Route Ranking For C4-A

| Rank | Route | Why | Authorization posture |
| ---: | --- | --- | --- |
| 1 | `counterfactual-audit-artifact-home-and-authority-options-v0` | Directly addresses the L3 blocker before runtime/report/API design. | Design-only; preferred. |
| 2 | `counterfactual-audit-runtime-bridge-architecture-survey-v0` | Useful if Portfolio wants Runtime/Bridge facts before artifact-home choice. | Read-only/design-only; safe. |
| 3 | `counterfactual-audit-report-result-boundary-survey-v0` | Maps report/result/receipt risk if artifact-home starts leaning toward a carrier. | Read-only; should not open fields. |
| 4 | Pause / hold lane | Safe if TTM pressure is judged acceptable for now. | No new authority. |
| 5 | Runtime implementation | Premature; L3 blockers still open. | Not recommended; not authorized. |
| 6 | Public API/CLI/Spark/demo route | Skips authority gates and risks support claims. | Reject for now. |

Recommended C4-A stance:

```text
accept facts packet
choose artifact-home-and-authority-options as the next technical L3 route
preserve runtime/report/API implementation closure
preserve RuntimeSmoke proof-context/non-support wording
```

## Closed Surfaces To Preserve

- Code implementation and `lib/**` changes.
- Parser, classifier, TypeChecker, SemanticIR, assembler, orchestrator changes.
- Runtime/evaluator/RuntimeSmoke/proof RuntimeMachine behavior changes.
- Live non-selected branch evaluation.
- CompilerResult / CompilationReport mutation.
- Report/result/receipt/CompatibilityReport fields.
- Dependency/cache authority.
- TBackend/effect/external IO non-refusal.
- `.igapp`, manifest, sidecar, artifact hash, golden migration.
- Public API/CLI, release/demo/stable/production/all-grammar claims.
- Spark data, fixtures, ids, integration, demo, or production behavior.

## Command Matrix

| Command | Result |
| --- | --- |
| `rg "if_expr\|counterfactual audit\|RuntimeSmoke\|proof-context\|without authorizing" /Users/alex/.codex/memories/MEMORY.md` | PASS, memory quick pass |
| `ls igniter-lang/docs/tracks \| rg 'stage3-round215\|internal-lane-map-decision\|runtime-report-api-gate\|runtime-debt-facts'` | PASS, located inputs |
| `sed -n '1,280p' igniter-lang/docs/tracks/stage3-round215-status-curation-v0.md` | PASS |
| `sed -n '1,300p' igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-internal-lane-map-decision-v0.md` | PASS |
| `sed -n '1,300p' igniter-lang/docs/tracks/counterfactual-audit-runtime-report-api-gate-survey-v0.md` | PASS |
| `sed -n '1,130p' igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb; sed -n '140,260p' ...` | PASS, read-only |
| `sed -n '1,36p' igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb; sed -n '377,425p' ...; sed -n '661,690p' ...` | PASS, read-only |
| `sed -n '1,120p' igniter-lang/lib/igniter_lang/runtime_smoke.rb` | PASS, read-only |
| `ruby -rjson -e ... R199/R201/R203/R211 summaries` | PASS; counts sampled as 68/68, 56/56, 53/53, 61/61 |

No executable proof was required or run. No code was changed.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/counterfactual-audit-runtime-debt-facts-packet-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent | Research Agent

[D] Decisions:
- Current runtime facts support route clarity, not runtime implementation.
- Live runtime surface is internal selected-branch `if_expr` evaluation only.
- Proof RuntimeMachine and RuntimeSmoke evidence remain proof-context only.

[R] Recommendations:
- C4-A should choose `counterfactual-audit-artifact-home-and-authority-options-v0`
  as the next technical L3 route.
- Preserve RuntimeSmoke non-support wording and no dependency/cache authority.
- Keep report/result/receipt/API/Spark/runtime implementation closed.

[S] Signals:
- Proof counts: R199 68/68, R201 56/56, R203 53/53, R211 61/61.
- TTM risk: 4/10; execution quality: 8/10.
- Main missing authority: artifact home, authority model, report/result/receipt
  decision, dependency/cache stance, TBackend/effect policy.

[T] Tests / Proofs:
- Read-only survey commands PASS.
- No new proof/test required.

[Files] Changed:
- igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-facts-packet-v0.md

[Q] Open Questions:
- Does L3 choose permanent proof-local evidence or an internal non-canonical
  carrier?
- Should report/result/receipt remain permanently closed for this lane?
- Is there a safe internal tool-only use case that does not imply API/runtime
  support?

[X] Rejected:
- Runtime implementation as next step.
- Treating RuntimeSmoke proof-context evidence as feature support.
- Using TTM pressure as authority to mutate report/result/API/cache/Spark.

[Next] Proposed next slice:
- counterfactual-audit-artifact-home-and-authority-options-v0
```
