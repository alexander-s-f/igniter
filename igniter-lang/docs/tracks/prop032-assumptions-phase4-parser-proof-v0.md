# Track: PROP-032 Assumptions Phase 4 Parser Proof v0

Card: S3-R35-C5-P
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `prop032-assumptions-phase4-parser-proof-v0`
Status: done
Date: 2026-05-11

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Bridge Agent]`

---

## Goal

Close PROP-032 Phase 4 parser/source proof path for assumptions:

- parse `assumptions { assumption NAME { ... } }`;
- parse `uses assumptions NAME` in contract bodies;
- prove P28 unnamed assumption parse-error behavior;
- prove real source syntax can reach SemanticIR through the typed pipeline.

---

## Inputs Read

- `handoff/onboarding-compiler-grammar-expert-v0.md`
- `roles/compiler-grammar-expert.md`
- `docs/current-status.md`
- `docs/tracks/prop032-assumptions-phase3-semanticir-v0.md`
- `docs/proposals/PROP-032-assumptions-block-v0.md`
- `docs/spec/ch6-semanticir.md`
- `lib/igniter_lang/parser.rb`
- `experiments/assumptions_proof/assumptions_proof.rb`
- `experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb`

---

## Decisions

[D] Implement only the PROP-032 parser/source surface.

No constraints/form/ESM/runtime receipts were added. Output `evidence [...]` is
parsed as a passive list so existing PROP-032 source examples can round-trip, but
there is no PROP-033 validation.

[D] Use `OOF-P28` for unnamed assumption declarations.

`assumption { ... }` inside `assumptions {}` is rejected at parser boundary with
a parse error. The program does not reach Classifier in the P28 fixture.

[D] Keep source-to-SemanticIR assumptions on the typed path.

The existing `source_to_semanticir_fixture` still uses the legacy parsed emitter
for old cases. The new assumptions case uses Parser -> Classifier -> TypeChecker
-> `emit_typed`, matching the current production compiler direction.

---

## Shipped

[S] Updated `lib/igniter_lang/parser.rb`:

- recognizes top-level `assumptions` blocks;
- parses named `assumption` declarations with `kind`, `statement`, `strength`,
  and `source` fields;
- parses body-level `uses assumptions NAME`;
- parses output `evidence [name, ...]` passively without validation;
- emits `assumptions` in `ParsedProgram#to_h`;
- returns `grammar_version: "assumptions-v0"` for assumptions surfaces;
- emits `OOF-P28` for unnamed assumption declarations.

[S] Added real source fixtures:

- `experiments/assumptions_proof/fixtures/assumption_basic.ig`
- `experiments/assumptions_proof/fixtures/epistemic_only_pure.ig`
- `experiments/assumptions_proof/fixtures/oof_a1_undeclared_assumption.ig`
- `experiments/assumptions_proof/fixtures/oof_p28_unnamed_assumption_body.ig`
- `experiments/source_to_semanticir_fixture/assumption_basic.ig`

[S] Updated proofs/goldens:

- `assumptions_proof` now prefers source fixtures when present;
- adds parser checks for assumptions grammar and P28;
- writes a P28 parser-error golden;
- `source_to_semanticir_fixture` now has a typed-pipeline assumptions source case.

---

## Proof Coverage

| Fixture | Expectation | Result |
| --- | --- | --- |
| `assumption_basic.ig` | parses source, classifies escape, typechecks accepted, emits assumptions SemanticIR | PASS |
| `epistemic_only_pure.ig` | parses source, classifies epistemic, typechecks accepted, preserves no PROP-033 validation | PASS |
| `oof_a1_undeclared_assumption.ig` | parses source, OOF-A1 report-only, SemanticIR nil | PASS |
| `oof_p28_unnamed_assumption_body.ig` | parser emits OOF-P28 and stops before classifier path | PASS |
| `source_to_semanticir_fixture/assumption_basic.ig` | real source reaches SemanticIR via typed pipeline | PASS |

---

## Command Matrix

| Command | Result |
| --- | --- |
| `ruby igniter-lang/experiments/assumptions_proof/assumptions_proof.rb` | PASS |
| `ruby igniter-lang/experiments/assumptions_proof/assumptions_proof.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb` | PASS |
| `ruby igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/typechecker_proof/typechecker_proof.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/classifier_pass_proof/classifier_pass_proof.rb --check-golden` | PASS |
| `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb` | PASS |
| `ruby -c igniter-lang/lib/igniter_lang/parser.rb` | PASS |
| `ruby -c igniter-lang/experiments/assumptions_proof/assumptions_proof.rb` | PASS |
| `ruby -c igniter-lang/experiments/source_to_semanticir_fixture/source_to_semanticir_fixture.rb` | PASS |

---

## Experiment-Pass Recommendation

[D] Recommendation: PROP-032 is ready for experiment-pass review.

Reason: all PROP-032 compiler acceptance criteria are now covered:

- parser accepts assumptions block syntax;
- parser accepts `uses assumptions NAME`;
- classifier builds registry/refs and OOF-A1;
- TypeChecker propagates OOF-A1 and validates strength;
- SemanticIR lowers registry/refs/ref nodes;
- positive and negative fixtures pass;
- P28 unnamed assumption parse-error fixture passes;
- existing regression matrix remains green.

[R] Do not bundle PROP-033 or runtime receipt work into the experiment-pass
decision. Evidence-list validation and runtime receipt propagation remain
separate future scopes unless explicitly assigned.

[R] Spec-lag note: `docs/spec/ch2-source-surface.md` should receive a bounded
PROP-032 source grammar sync when the governance/status promotion card runs.
This slice updated proofs and the parser, but did not perform a broad source
chapter rewrite.

---

## Non-Authorization

[X] No PROP-033 evidence-list validation.

[X] No constraints/form/ESM behavior.

[X] No runtime receipt implementation.

[X] No cross-module assumption sharing.

---

## Handoff

```text
Card: S3-R35-C5-P
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: prop032-assumptions-phase4-parser-proof-v0
Status: done

[D] Decisions
- Implemented only PROP-032 parser/source surface.
- OOF-P28 is the parser error for unnamed assumption declarations.
- Kept source-to-SemanticIR assumptions on typed pipeline.
- Parsed evidence lists passively; no PROP-033 validation.

[S] Shipped / Signals
- Parser supports assumptions block + uses assumptions body declarations.
- P28 unnamed-assumption source fixture and golden landed.
- assumptions_proof now runs from real source fixtures.
- source_to_semanticir_fixture has a real assumptions source case.

[T] Tests / Proofs
- assumptions_proof -> PASS
- assumptions_proof --check-golden -> PASS
- source_to_semanticir_fixture -> PASS
- source_to_semanticir_fixture --check-golden -> PASS
- typechecker_proof --check-golden -> PASS
- classifier_pass_proof --check-golden -> PASS
- stage1_close_candidate -> PASS

[R] Risks / Recommendations
- PROP-032 is ready for experiment-pass review.
- Do not include PROP-033 evidence validation or runtime receipt work in this
  closure decision.

[Next]
- Route a governance/status update card to promote PROP-032 if Architect/Meta
  accepts the experiment-pass evidence.
```
