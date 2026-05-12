# Track: Full Stage 3 Language Regression Matrix v0

Card: S3-R37-C4-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `full-stage3-language-regression-matrix-v0`
Status: done
Date: 2026-05-12

Affected neighbor roles:

- `[Igniter-Lang Research Agent]` may consume the matrix as proof evidence for
  downstream fixture work.
- `[Igniter-Lang Bridge Agent]` may consume the recommendation when mapping
  language readiness into later platform-facing requests.

---

## Route

```text
Route: UPDATE / STAGE_LOOP
Card: S3-R37-C4-P
Role: compiler-grammar-expert
Stage/Round observed: Stage 3 / Round 37
Previous known card: S3-R36-C4-P
Same-role newer work: S3-R37-C1-P landed Ch2/Heat Map sync for PROP-032
```

---

## Goal

Run and document a broad Stage 3 language regression matrix after PROP-032
experiment-pass.

This track runs existing proofs only. It does not create new parser semantics,
runtime behavior, fixtures, or language entities.

---

## Inputs Read

- `AGENTS.md`
- `roles/README.md`
- `roles/compiler-grammar-expert.md`
- `handoff/onboarding-compiler-grammar-expert-v0.md`
- `docs/agent-context.md`
- `docs/current-status.md`
- `docs/operating-model.md`
- `docs/gates/prop032-assumptions-experiment-pass-decision-v0.md`
- `docs/tracks/stage3-round36-status-curation-v0.md`
- `docs/discussions/r36-deployment-prop032-prop036-prop037-mundane-pressure-v0.md`
- `docs/tracks/prop032-assumptions-phase3-semanticir-v0.md`
- `docs/tracks/prop032-assumptions-phase4-parser-proof-v0.md`

---

## Matrix Result

Verdict: **PASS 19/19**

Recommendation: **safe for downstream PROP-032 compiler-surface dependencies**.

This means later cards may depend on the bounded PROP-032 assumptions compiler
surface as experiment-pass evidence. It does not authorize PROP-033 evidence-list
validation, runtime receipts, runtime injection of assumption values, production
behavior, new parser syntax, or runtime execution.

No failures occurred, so there are no blocker / known-pending / unrelated-failure
classifications.

---

## Command Matrix

| # | Surface | Command | Result | Classification |
|---|---------|---------|--------|----------------|
| 1 | Parser/source OOF fixtures | `ruby igniter-lang/experiments/parser_oof_hardening_stage2_proof/parser_oof_hardening_stage2_proof.rb` | PASS | regression green |
| 2 | Classifier | `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden` | PASS | regression green |
| 3 | TypeChecker | `ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS | regression green |
| 4 | SemanticIR source fixture | `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS | regression green |
| 5 | Assumptions / PROP-032 | `ruby igniter-lang/experiments/assumptions_proof/assumptions_proof.rb --check-golden` | PASS | regression green |
| 6 | Contract modifiers / PROP-031 | `ruby igniter-lang/experiments/contract_modifiers_proof/contract_modifiers_proof.rb --check-golden` | PASS | regression green |
| 7 | Stream T / PROP-023 | `ruby igniter-lang/experiments/stream_t_proof/stream_t_proof.rb` | PASS | regression green |
| 8 | Temporal SemanticIR | `ruby igniter-lang/experiments/temporal_semanticir_access_node/temporal_semanticir_access_node.rb --check-golden` | PASS | regression green |
| 9 | History[T] temporal proof | `ruby igniter-lang/experiments/history_type_proof/history_type_proof.rb` | PASS | regression green |
| 10 | OLAPPoint | `ruby igniter-lang/experiments/olap_point_proof/olap_point_proof.rb` | PASS | regression green |
| 11 | Invariant severity | `ruby igniter-lang/experiments/invariant_severity_proof/invariant_severity_proof.rb` | PASS | regression green |
| 12 | Temporal assembler boundary | `ruby igniter-lang/experiments/temporal_assembler_boundary/temporal_assembler_boundary.rb` | PASS | regression green |
| 13 | Temporal runtime load guard | `ruby igniter-lang/experiments/temporal_runtime_load_guard/temporal_runtime_load_guard.rb` | PASS | regression green |
| 14 | Stage 1 assembler/load runtime | `ruby igniter-lang/experiments/igapp_assembler_proof/igapp_assembler_proof.rb` | PASS | regression green |
| 15 | Stage 1 close baseline | `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS | regression green |
| 16 | Stage 2 close baseline | `ruby igniter-lang/experiments/stage2_close_candidate/stage2_close_candidate.rb` | PASS | regression green |
| 17 | Requirements from escape boundaries | `ruby igniter-lang/experiments/temporal_requirements_from_escape_boundaries/temporal_requirements_from_escape_boundaries.rb` | PASS | regression green |
| 18 | Post-switch runtime smoke | `ruby igniter-lang/experiments/runtime_smoke_post_switch_full_coverage/runtime_smoke_post_switch_full_coverage.rb` | PASS | regression green |
| 19 | CompatibilityReport temporal load check | `ruby igniter-lang/experiments/runtime_compatibility_report_temporal_load_check/runtime_compatibility_report_temporal_load_check.rb` | PASS | regression green |

---

## Coverage Map

| Required area | Covered by commands |
|---------------|---------------------|
| Parser/source fixtures | 1, 4, 5, 6 |
| Classifier | 2, 5, 6 |
| TypeChecker | 3, 5, 6, 10 |
| SemanticIR | 4, 5, 6, 8, 10, 11 |
| TEMPORAL | 8, 9, 12, 13, 17, 19 |
| STREAM | 2, 3, 7, 17, 18 |
| Contract modifiers | 6 |
| Assumptions | 4, 5 |
| Assembler/load guard | 12, 13, 14, 15, 16, 18, 19 |
| Stage 1/2 baselines | 15, 16 |

---

## Observations

- PROP-032 assumptions remain green through Parser -> Classifier -> TypeChecker
  -> `SemanticIREmitter.emit_typed`.
- `source_to_semanticir_fixture --check-golden` includes the real source
  assumptions fixture and passed.
- OOF-A1, OOF-P28, and TASSUMP-1 remain covered by `assumptions_proof`.
- PROP-031 contract modifiers remain green, including observed+temporal
  precedence.
- Stream T remains green with SC-1/2/3 and OOF-S1..S4/S2 missing-window checks.
- TEMPORAL SemanticIR, assembler metadata, requirements, CompatibilityReport,
  and load-guard behavior remain green.
- Stage 1 and Stage 2 close candidates still pass after PROP-032
  experiment-pass.

---

## Regression Summary JSON

No new combined regression summary JSON was created.

Several existing proofs own and regenerate summary/output artifacts as part of
normal execution. The notable regenerated proof-owned outputs in this run are:

- `experiments/olap_point_proof/summary.json`
- `experiments/olap_point_proof/golden/typechecker_boundary.json`
- `experiments/stage2_close_candidate/stage2_close_candidate.json`
- `experiments/temporal_assembler_boundary/out/**`
- `experiments/temporal_runtime_load_guard/out/**`
- `experiments/temporal_requirements_from_escape_boundaries/summary.json`
- `experiments/runtime_compatibility_report_temporal_load_check/out/**`

The changes are proof-owned generated output churn, not new semantics. Examples:
OLAP regenerated parsed output now carries the parser's empty `assumptions: []`
field, temporal assembler/load-guard output hashes changed accordingly, and
Stage 2 close candidate refreshed its volatile timestamp.

Unrelated dirty files observed after the run, not touched by this slice:

- `docs/lineups/README.md`
- `docs/lineups/stage1-close-transition-evidence.md`
- `docs/lineups/stage2-close-proof-spine.md`
- `docs/lineups/stage2-proof-surface-spine.md`
- `docs/lineups/stage2-round-map-and-status-curation.md`

---

## Non-Authorization

This regression matrix does not authorize:

- PROP-033 evidence-list validation;
- runtime receipt propagation;
- runtime injection of assumption values;
- production RuntimeMachine behavior;
- new parser syntax;
- new TypeChecker, SemanticIR, assembler, or runtime semantics;
- production temporal/stream/OLAP executors;
- Ledger/TBackend binding or production cache.

---

## Handoff

```text
Card: S3-R37-C4-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: full-stage3-language-regression-matrix-v0
Status: done

[D] Decisions
- No new language decisions made.
- PASS 19/19 broad Stage 3 language regression matrix.
- Recommendation: safe for downstream PROP-032 bounded compiler-surface dependencies.

[S] Shipped / Signals
- Track doc with exact command matrix and coverage map.
- No combined regression summary JSON created.
- Existing proof-owned outputs regenerated where their proofs own those artifacts.

[T] Tests / Proofs
- parser/source, classifier, typechecker, SemanticIR, temporal, stream,
  contract modifiers, assumptions, assembler/load guard, Stage 1 baseline,
  and Stage 2 baseline all PASS.

[R] Risks / Recommendations
- Do not widen this PASS into PROP-033 or runtime authorization.
- Generated proof-output churn should be reviewed as artifact refresh, not a
  semantic implementation.

[Next]
- Downstream PROP-032-dependent compiler work may proceed from this matrix.
- PROP-033 evidence validation/runtime receipt work still needs its own proposal
  and implementation authorization.
```
