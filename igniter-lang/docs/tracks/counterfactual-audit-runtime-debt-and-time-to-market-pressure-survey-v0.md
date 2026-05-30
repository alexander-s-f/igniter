# Counterfactual Audit Runtime Debt And Time To Market Pressure Survey v0

Agent: [Research Agent #1]
Role: research-agent
Track: counterfactual-audit-runtime-debt-and-time-to-market-pressure-survey-v0
Route: UPDATE
Depends on:
- S3-R213-C5-S
Status: done
Date: 2026-05-30

## Role And Neighbors

Assigned track: survey runtime-debt and time-to-market pressure created by the
counterfactual audit lane without authorizing runtime implementation.

Affected neighbor roles:
- Compiler/Grammar Expert: owns if_expr compiler/SemanticIR and lane
  consolidation boundaries.
- Bridge/Runtime owners: own RuntimeSmoke, proof RuntimeMachine, live evaluator,
  report/result/receipt/cache, and CompatibilityReport authority.
- Portfolio/Research lanes: own market-pressure interpretation and next-route
  framing.

## Current Horizon

- R213 accepted source-backed Level 2 vocabulary docs sync only; it opened no
  runtime/report/API/Spark authority.
- R211 accepted source-backed Level 2 proof-local evidence: 61/61 PASS with
  digest-addressed refs and explicit premise sets.
- Runtime support is split: live internal evaluator exists; proof RuntimeMachine
  and RuntimeSmoke have proof-context consumer evidence; counterfactual dry-run
  remains experiment-local.
- Time-to-market risk is real but moderate: `4/10`.
- Execution/proof quality is strong: `8/10`.

## Inputs Read

- `igniter-lang/docs/current-status.md`
- `igniter-lang/docs/tracks/stage3-round213-status-curation-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-lane-consolidation-boundary-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-proof-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-implementation-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-acceptance-decision-v0.md`
- `igniter-lang/lib/igniter_lang/runtime_smoke.rb`
- `igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb`
- `igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb`
- selected proof summaries for live evaluator, proof RuntimeMachine consumer,
  RuntimeSmoke consumer, and source-backed Level 2 proof.

## Runtime Surface Map

| Surface | Current status | Evidence | Runtime-debt pressure | Must not infer |
| --- | --- | --- | --- | --- |
| `SemanticIRExpressionEvaluator` | Live internal, direct-require-only | R199 accepted 68/68 PASS; supports `literal`, `ref`, `if_expr`; lazy selected branch only | It is real code but intentionally not root-required or public | Public API/CLI, RuntimeSmoke support, report diagnostics, counterfactual dry-run |
| Proof RuntimeMachine `CompiledProgram` | Proof RuntimeMachine consumer path | R201 accepted 56/56 PASS; delegates `if_expr` to evaluator with `external_evaluator`, keeps `apply`, `field_access`, `tbackend_read` local | Runtime debt accumulates around proof-only adapter ownership | Production RuntimeMachine support, dynamic dependency authority, cache key authority |
| `RuntimeSmoke.run` | Existing proof-backed smoke helper; unchanged source | R203 accepted 53/53 PASS proof-context consumer evidence; result shape unchanged | Smoke now can exercise proof-owned if_expr `.igapp` artifacts through proof RuntimeMachine path, but wording is fragile | Public runtime support, stable all-grammar runtime support, compiler callback expansion |
| Source-backed Level 2 dry-run proof | Experiment-local projection only | R211 accepted 61/61 PASS; proof-owned SemanticIR-shaped artifacts, frozen input snapshots, digest refs, explicit premise sets | Strong proof quality but creates pressure to find an artifact home | Runtime behavior, report/result/receipt/cache authority, canonical schema |
| R213 vocabulary docs sync | Low-authority internal discoverability only | R213 accepted docs-only sync; heat map/spec README pointer | Reduces discovery drift, but also makes market pressure visible | Spec body support, public docs, runtime/report/API support |
| Release harness / public evidence | Closed for counterfactual support | Release deltas remain regression/non-claim evidence | Useful guardrail against overclaiming | Demo/release/stable support claims |
| Report/result/receipt/cache/CompatibilityReport | Closed | R213 and R211 explicitly keep closed; no current fields | Major future debt if the lane ever asks for audit persistence | Any current authority for projections |
| Spark/API/CLI | Closed | Repeated status and acceptance decisions preserve closure | None should be taken on in this lane yet | Product/demo integration or public capability |

## Runtime Debt Map

| Debt | Pressure source | Severity | Why it matters | Current containment |
| --- | --- | --- | --- | --- |
| Split runtime story | Live evaluator + proof RuntimeMachine + RuntimeSmoke proof harness + dry-run experiment | Medium | New readers can confuse live selected-branch runtime with counterfactual dry-run support | Acceptance docs repeatedly state proof-context only and no public/runtime claims |
| No canonical projection artifact home | R211 source-backed envelopes are proof-local only | Medium | Without a route map, future cards may keep rebuilding the same envelope/ref rules | R214 recommends internal lane map before runtime/report/API design |
| Dynamic dependency/cache gap | Runtime remains static dependency union; selected-path dependency tracking deferred | Medium | Counterfactual projection can look like cache-dependency evidence if not fenced | `call_trace` is proof/debug only; cache authority remains false |
| Report/result/receipt absence | No projection fields in CompilerResult/CompilationReport/receipt/CompatibilityReport | Medium-low | Good for safety, but blocks any audit-ready product story | Explicitly closed; no persisted authority |
| `tbackend_read` refusal | Dry-run proof refuses TBackend/escape/effect | Medium | Useful safety, but limits realistic temporal "what if" stories | Non-refusal would require separate runtime/TBackend authority |
| Vocabulary proliferation | L1 branch intention, L2 dry-run, L2 source-backed terms | Medium | Repeated boundary reconstruction slows next work | R214 consolidation boundary proposes a compact lane map |
| RuntimeSmoke transitive load ambiguity | RuntimeSmoke requires proof `compiled_program`, which requires evaluator | Low-medium | Could be misread as RuntimeSmoke feature support | R201/R203 classify it as known consequence, not support |
| Internal exception/diagnostic gap | Evaluator has internal exceptions, no canonical Diagnostics/OOF-RT | Low | Correct for now, but future runtime-facing errors need a named boundary | Acceptance says non-canonical only |

## Time-To-Market Interpretation

Non-authorizing context:

```text
Time-to-market risk: 4/10
Execution quality: 8/10
```

Interpretation:
- `4/10` means the lane is not blocked by proof quality, but the number of
  boundary/proof/vocabulary layers can slow product interpretation.
- The risk is less "we cannot build this" and more "we can keep spending
  review cycles re-proving what remains closed."
- The current proof discipline is valuable: it prevented runtime/report/API
  claim inflation, forced source-backed evidence, and preserved lazy live
  runtime behavior.
- The fastest safe path is not runtime implementation; it is a compact route
  map that tells future cards where proof-local evidence may live, which
  surfaces remain closed, and what gates would be needed before product-facing
  work.

## Proof-Quality Preservation Notes

Keep:
- digest-addressed source artifacts, input snapshots, premise sets, and
  projection digests from R211;
- no-authority fields on all projection/ref/premise envelopes;
- explicit `projected_value != actual_output` and
  `projected_failure != actual_runtime_failure`;
- live runtime laziness: selected branch only, non-selected branch not executed;
- `tbackend_read`, escape/effect, external IO, persistence, Ledger/TBackend
  refusal in dry-run;
- source-backed evidence as proof-local and non-canonical;
- release/public/Spark/API/CLI wording closed.

Do not "speed up" by:
- adding fields to `CompilerResult`, `CompilationReport`, receipts, or
  CompatibilityReport without a later authority gate;
- treating RuntimeSmoke proof-context evidence as public runtime support;
- turning `call_trace` or selected-path behavior into dependency/cache
  authority;
- making source-backed projection envelopes canonical schema by implication;
- using Spark or public demos as validation shortcuts.

## Proven / Live / Closed / Ambiguous

| Surface | Classification | Notes |
| --- | --- | --- |
| TypeChecker/SemanticIR `if_expr` | Live compiler support | Already accepted in earlier R190 path; not re-opened here. |
| `SemanticIRExpressionEvaluator` selected-branch lazy evaluation | Live internal support | Direct-require-only; not root-required. |
| proof RuntimeMachine `if_expr` adapter consumer | Proven-only / experiment-owned | Lives in `experiments/runtime_machine_memory_proof`; not production runtime. |
| RuntimeSmoke if_expr consumer path | Proven-only / proof-context | Existing `RuntimeSmoke.run` can consume proof-owned artifacts; result shape unchanged. |
| Level 1 branch intention | Proof-local static audit | No latent evaluation. |
| Level 2 dry-run concept | Proof-local isolated projection | Not sourced enough for product authority by itself. |
| Level 2 source-backed dry-run | Proof-local source-backed projection | Strongest current evidence; still non-canonical and no-authority. |
| Dynamic dependency tracking / cache | Closed | Static union remains boundary. |
| CompilerResult / CompilationReport | Closed | No counterfactual fields; should stay closed absent new gate. |
| Receipt / CompatibilityReport | Closed | No projection authority. |
| Runtime product support | Closed | No public/stable/all-grammar runtime claim. |
| TBackend/escape/effect dry-run | Closed by refusal | Non-refusal would be a separate runtime/Bridge design. |
| Artifact home for projections | Ambiguous / design debt | R214 route-map/lane-map work should decide proof-local forever vs future internal carrier. |

## Compact Risk Table

| Risk | Score | Interpretation | Mitigation route |
| --- | ---: | --- | --- |
| Market drift from repeated boundary reconstruction | 4/10 | Moderate, mostly process/interpretation cost | Accept R214 lane-map route; keep it compact |
| False public/runtime claim | 6/10 if unmanaged; 2/10 with current fences | Terms like dry-run and source-backed are easy to overread | Preserve forbidden wording and no-authority disclaimers |
| Runtime implementation debt | 5/10 | Multiple proof paths exist, but no product runtime story | Do not implement yet; map ownership first |
| Proof-quality regression from rushing | 6/10 | Weakening digests/no-authority would erase the value of R211 | Require digest/ref/no-authority invariants in any next proof |
| Spark/product overreach | 3/10 | Explicitly closed, but tempting as demo material | Keep Spark/API/CLI out until separate product gate |
| Cache/dependency authority confusion | 5/10 | Runtime selected path can be mistaken for dependency truth | Keep `call_trace` proof/debug only |

## Next-Route Options After R214

Preferred option:

```text
branch-conditional-counterfactual-audit-internal-lane-map-v0
```

Purpose:
- consolidate L1/L2a/L2b terms and accepted evidence anchors;
- decide whether projection envelopes remain proof-local forever or need a
  future internal carrier;
- list gates before any runtime/report/API design.

Other safe options:
- `counterfactual-audit-artifact-home-options-v0`: design-only, compare
  proof-local out/ artifacts, internal carrier, report sidecar, or permanent
  no-artifact stance.
- `counterfactual-audit-runtime-debt-register-v0`: docs-only register of
  runtime debt, owners, and blocked surfaces; useful if Portfolio wants
  planning without implementation.
- `counterfactual-audit-report-result-boundary-survey-v0`: read-only survey of
  what would be touched if a future report/result design is ever considered.
- Hold after R214: acceptable if the lane map concludes current proof-local
  status is enough for now.

Not recommended next:
- runtime implementation;
- RuntimeSmoke feature claim;
- CompilerResult/CompilationReport mutation;
- receipt/cache/CompatibilityReport design before lane-map closure;
- Spark/API/CLI/public demo route.

## Recommendation For Portfolio

Accept this as pressure context, not implementation authority.

Recommended stance:
- Proceed with R214 consolidation/lane-map direction.
- Treat time-to-market risk as moderate and address it with route clarity, not
  runtime expansion.
- Preserve the R211 proof-quality invariants as the baseline for any future
  source-backed proof.
- Do not open runtime/report/API/Spark/public routes until a later gate names
  exact surfaces and authority model.

## Command Matrix

| Command | Result |
| --- | --- |
| `rg "source-backed\|source backed\|RuntimeSmoke consumer\|proof RuntimeMachine consumer\|live runtime evaluator\|runtime-debt\|R213\|counterfactual" igniter-lang/docs/tracks -g "*.md"` | PASS, broad track discovery |
| `sed -n '1,220p' igniter-lang/docs/current-status.md` | PASS, current status read |
| `sed -n '1,260p' igniter-lang/docs/tracks/stage3-round213-status-curation-v0.md` | PASS, R213 curation read |
| `sed -n '1,260p' igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-acceptance-decision-v0.md` | PASS |
| `sed -n '1,260p' igniter-lang/docs/tracks/branch-conditional-if-expr-runtime-smoke-consumer-proof-acceptance-decision-v0.md` | PASS |
| `sed -n '1,260p' igniter-lang/docs/tracks/branch-conditional-if-expr-proof-runtime-consumer-implementation-acceptance-decision-v0.md` | PASS |
| `sed -n '1,300p' igniter-lang/docs/tracks/branch-conditional-if-expr-live-runtime-evaluator-implementation-acceptance-decision-v0.md` | PASS |
| `sed -n '1,260p' igniter-lang/lib/igniter_lang/runtime_smoke.rb` | PASS, read-only |
| `sed -n '1,320p' igniter-lang/experiments/runtime_machine_memory_proof/compiled_program.rb` | PASS, read-only |
| `sed -n '1,320p' igniter-lang/lib/igniter_lang/semanticir_expression_evaluator.rb` | PASS, read-only |
| `ruby -rjson -e ... branch_conditional_*_summary.json` | PASS, proof counts sampled |

No executable proof was required or run. No code was changed.

## Handoff

```text
[Igniter-Lang Research Agent]
Track: igniter-lang/counterfactual-audit-runtime-debt-and-time-to-market-pressure-survey-v0
Status: done
Neighbors: Compiler/Grammar Expert | Bridge Agent | Research Agent

[D] Decisions:
- Treat runtime-debt/TTM feedback as non-authorizing context.
- Runtime debt is moderate: live evaluator exists, but dry-run remains
  experiment-local and report/result/receipt/cache authority remains closed.
- Fastest safe next move is route/lane clarity, not runtime implementation.

[R] Recommendations:
- Proceed with R214 lane consolidation and then a compact internal lane map.
- Preserve R211 digest/ref/no-authority proof invariants as the quality floor.
- Do not open RuntimeSmoke public claims, report/result/receipt/cache fields,
  CompatibilityReport, Spark/API/CLI, or production runtime.

[S] Signals:
- Source-backed proof quality is high: 61/61 PASS.
- Runtime smoke/proof RuntimeMachine/live evaluator evidence is strong but split:
  53/53, 56/56, and 68/68 PASS respectively.
- TTM risk is 4/10; execution quality is 8/10.

[T] Tests / Proofs:
- Read-only survey commands PASS.
- No new proof or runtime test was required.

[Files] Changed:
- igniter-lang/docs/tracks/counterfactual-audit-runtime-debt-and-time-to-market-pressure-survey-v0.md

[Q] Open Questions:
- Should projection envelopes remain proof-local forever or get a future
  internal carrier?
- Should any report/result/receipt design ever open, or should the lane stay
  explanation-only?
- What exact gate would be required before non-refused TBackend/escape/effect
  dry-run behavior could even be discussed?

[X] Rejected:
- Treating proof-context RuntimeSmoke evidence as public runtime support.
- Treating source-backed Level 2 projections as canonical schema or report
  fields.
- Using time-to-market pressure as runtime implementation authorization.

[Next] Proposed next slice:
- branch-conditional-counterfactual-audit-internal-lane-map-v0
```
