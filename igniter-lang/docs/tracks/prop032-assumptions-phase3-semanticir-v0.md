# Track: PROP-032 Assumptions Phase 3 SemanticIR v0

Card: S3-R34-C4-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop032-assumptions-phase3-semanticir-v0`
Status: done
Date: 2026-05-11

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Implement PROP-032 Phase 3 SemanticIR lowering for the already-typed
assumptions surface:

- top-level `assumption_registry`;
- contract-level `assumption_refs`;
- typed `uses_assumptions` declarations;
- OOF-A1 / TASSUMP-1 diagnostics propagation through report-only emission.

---

## Inputs Read

- `handoff/onboarding-compiler-grammar-expert-v0.md`
- `roles/compiler-grammar-expert.md`
- `docs/current-status.md`
- `docs/tracks/prop032-assumptions-phase2-typechecker-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`
- `docs/spec/ch6-semanticir.md`
- `lib/igniter_lang/semanticir_emitter.rb`
- `experiments/assumptions_proof/assumptions_proof.rb`

---

## Decisions

[D] Lower only from typed programs.

This slice uses `SemanticIREmitter#emit_typed` and does not widen parser grammar
or revive parsed-emitter assumptions support.

[D] Emit assumptions metadata only when present.

Existing no-assumption SemanticIR goldens remain unchanged. Assumption programs
lower top-level `assumption_registry` and contract-level `assumption_refs`.

[D] Represent typed `uses_assumptions NAME` as `assumption_ref_node`.

This is a descriptive provenance node:

- it names the referenced assumption;
- carries `type: Assumption`;
- keeps `fragment: "epistemic"`;
- does not inject runtime values or enforce output evidence lists.

[D] Keep diagnostics in `CompilationReport`, not `SemanticIRProgram`.

OOF-A1 and TASSUMP-1 typed diagnostics suppress SemanticIR emission through the
existing `emit_typed` report-only path.

---

## Shipped

[S] Updated `lib/igniter_lang/semanticir_emitter.rb`:

- lowers `typed_program.assumption_registry` to top-level
  `assumption_registry` entries with `kind: "assumption_ir"`;
- lowers non-empty typed contract `assumption_refs`;
- lowers `uses_assumptions` typed declarations to `assumption_ref_node`;
- preserves report-only behavior for blocked typed programs.

[S] Updated `experiments/assumptions_proof/`:

- emits SemanticIR and CompilationReport outputs from typed assumptions fixtures;
- adds `.semantic_ir.json` goldens for accepted fixtures;
- adds `.compilation_report.json` goldens for all fixtures;
- proves OOF-A1 and proof-local TASSUMP-1 remain report-only.

[S] Updated `docs/spec/ch6-semanticir.md` with the PROP-032 assumptions
SemanticIR shape.

---

## Proof Coverage

| Fixture | SemanticIR expectation | Result |
| --- | --- | --- |
| `assumption_basic` | emits top-level `assumption_registry`, contract `assumption_refs`, and `assumption_ref_node` | PASS |
| `epistemic_only_pure` | emits epistemic contract with assumption provenance metadata | PASS |
| `oof_a1_undeclared_assumption` | no SemanticIR; CompilationReport carries OOF-A1 | PASS |
| proof-local invalid strength mutation | no SemanticIR; CompilationReport carries TASSUMP-1 | PASS |

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby igniter-lang/experiments/assumptions_proof/assumptions_proof.rb` | PASS |
| `ruby igniter-lang/experiments/assumptions_proof/assumptions_proof.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/temporal_semanticir_access_node/temporal_semanticir_access_node.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS |
| `ruby -c igniter-lang/lib/igniter_lang/semanticir_emitter.rb` | PASS |
| `ruby -c igniter-lang/experiments/assumptions_proof/assumptions_proof.rb` | PASS |

---

## Experiment-Pass Readiness

[D] PROP-032 still needs Phase 4 before `experiment-pass`.

Phase 1-3 now prove the hand-authored AST path through Classifier, TypeChecker,
SemanticIR, and CompilationReport. However, PROP-032 acceptance still includes
parser grammar acceptance and the gate-added P28 unnamed-assumption parse-error
fixture. Those are not implemented in this slice.

[R] Recommended Phase 4 scope:

- parser grammar for `assumptions {}` and `uses assumptions NAME`;
- P28 unnamed assumption parse-error fixture;
- source-to-SemanticIR fixture using real source syntax if parser path lands;
- governance/status updates only after parser proof passes;
- keep PROP-033 evidence-list validation and runtime receipt behavior separate
  unless explicitly assigned.

---

## Non-Authorization

[X] No parser grammar implementation.

[X] No output evidence-list validation.

[X] No constraints/form/ESM/runtime behavior.

[X] No runtime assumption injection or receipt implementation.

---

## Handoff

```text
Card: S3-R34-C4-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop032-assumptions-phase3-semanticir-v0
Status: done

[D] Decisions
- Lowered assumptions only from typed programs via emit_typed.
- Emitted assumption metadata only when present to preserve existing goldens.
- Introduced assumption_ref_node for typed uses_assumptions declarations.
- Kept OOF-A1/TASSUMP-1 in CompilationReport with SemanticIR nil.

[S] Shipped / Signals
- SemanticIREmitter lowers assumption_registry, assumption_refs, and
  assumption_ref_node.
- assumptions_proof now writes/checks SemanticIR and CompilationReport goldens.
- Ch6 SemanticIR spec has a scoped PROP-032 assumptions section.

[T] Tests / Proofs
- assumptions_proof -> PASS
- assumptions_proof --check-golden -> PASS
- typechecker_proof --check-golden -> PASS
- source_to_semanticir_fixture --check-golden -> PASS
- temporal_semanticir_access_node --check-golden -> PASS
- stage1_close_candidate -> PASS

[R] Risks / Recommendations
- PROP-032 still needs Phase 4 before experiment-pass.
- Phase 4 should focus on parser grammar + P28 unnamed-assumption fixture.
- PROP-033 remains owner of evidence-list validation.

[Next]
- Implement/parser-proof PROP-032 Phase 4, then evaluate experiment-pass
  governance updates.
```
