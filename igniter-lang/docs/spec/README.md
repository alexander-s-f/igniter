# Igniter-Lang Language Specification

Version: 0.4 — Stage 2 R2 sync
Maintainer: `[Igniter-Lang Meta Expert]`
Status: living document
Last updated: 2026-05-07

> Source of truth for each section is the cited PROP.
> This document is the readable synthesis — not the decision record.

---

## Chapters

| # | Chapter | Status |
|---|---------|--------|
| [1](ch1-identity.md) | Identity and Semantic Model | accepted |
| [2](ch2-source-surface.md) | Source Surface and Grammar | accepted |
| [3](ch3-type-system.md) | Type System | accepted |
| [4](ch4-fragment-classification.md) | Fragment Classification | accepted |
| [5](ch5-compiler-pipeline.md) | Compiler Pipeline | accepted |
| [6](ch6-semanticir.md) | SemanticIR and CompilationReport | accepted |
| [7](ch7-runtime.md) | RuntimeMachine | accepted |
| [8](ch8-stdlib.md) | Stdlib | accepted |
| [9](ch9-stage2-reserved.md) | Stage 2 Reserved Primitives | deferred |

---

## Implementation Coverage Matrix

| Spec Section | PROP | Experiment | Status |
|---|---|---|---|
| Ch1 Identity | PROP-001 | — | accepted / no proof needed |
| Ch2 Grammar BNF | PROP-014, PROP-015 | experiments/parser/ (61 specs) | ✅ partial — OOF syntax gap closed PROP-026 |
| Ch2 ParsedProgram shape | PROP-014, PROP-018 | experiments/parser/ | ✅ proven |
| Ch3 Type grammar | PROP-004 | experiments/typechecker_proof/ | ✅ PASS ✅ boundary fixture CLOSED |
| Ch3 Decimal typing | PROP-021 | typechecker_proof TC cases | ✅ PASS |
| Ch4 Classifier pass | PROP-003, PROP-020 | experiments/classifier_pass_proof/ | ✅ PASS |
| Ch4 OOF rules P1/P2/P4 | PROP-020 | classifier negatives | ✅ PASS |
| Ch5 Four-stage pipeline | PROP-018, PROP-019.1 | — | accepted |
| Ch5 TypeChecker pass | PROP-021 | experiments/typechecker_proof/ | ✅ PASS ✅ boundary CLOSED (own classified/ dir) |
| Ch6 SemanticIR envelope | PROP-019.1 | experiments/source_to_semanticir_fixture/ | ✅ PASS ✅ golden check PASS |
| Ch6 CompilationReport | PROP-019.1 | source_to_semanticir_fixture --check-golden | ✅ PASS |
| Ch6 Assembler criteria A1–A6 | PROP-019.1 | experiments/igapp_assembler_proof/ | ✅ PASS A1–A6 all ok |
| Ch7 RuntimeMachine lifecycle | PROP-011 | experiments/runtime_machine_memory_proof/ | ✅ proven |
| Ch7 CompatibilityReport gate | PROP-009, PROP-009.1 | igapp_assembler_proof runtime.* | ✅ proven (assembled igapp) |
| Ch8 Collection[T] ops | PROP-013 | stdlib_execution_kernel_stage1 | ✅ PASS |
| Ch8 fold/map/filter | PROP-013 | experiments/stdlib_execution_kernel_stage1/ | ✅ PASS |
| Ch9 History[T] | PROP-022 | experiments/history_type_proof/ | ✅ point proof PASS ✅ parser accepted |
| Ch9 BiHistory[T] | PROP-022 | experiments/sparkcrm_bihistory_fixture/ | ✅ fixture PASS ⏳ axes gap |
| Ch9 stream T | PROP-023 | — | deferred Stage 2 |
| Ch9 OLAPPoint | PROP-024 | — | deferred Stage 2 |
| Ch9 Invariant severity | PROP-025 | — | deferred Stage 2 |

---

## Coverage Summary

```
accepted + PASS   Ch3 (TypeChecker + boundary), Ch4 (classifier), Ch5 (pipeline + assembler),
                  Ch6 (SemanticIR + assembler), Ch7 (RuntimeMachine), Ch8 (stdlib kernel)
accepted partial  Ch2 (OOF syntax gap closed PROP-026; semantic OOF caught at Classify/TypeCheck)
Stage 2 partial   Ch9 (History[T] point proof PASS; BiHistory fixture PASS; stream/OLAP/severity deferred)
```

---

## Stage 1 Remaining Gap

```
Stage 2 open gaps:
1. BiHistory[T] axes — parser/typechecker for bitemporal axes not generalized
   (sparkcrm_bihistory_fixture PASS; axes generalization pending)
2. Runtime temporal access extraction — History/BiHistory runtime behavior is proof-local
   (History point proof and SparkCRM BiHistory fixture PASS)
3. Production compiler package — CLI proof PASS; diagnostics extraction started (PROP-027)

Closed post-Stage-1 (no longer gaps):
  OOF syntax rejection — PASS: PROP-026 + parser_oof_hardening_stage2_proof
  Runtime eval surface — closed_in_proof: igapp_assembler_proof (all 3 contracts)
  Option[T] encoding normalization — PASS: canonical `{kind,value}` shape in history proof
  History[T] parser acceptance — PASS: structured TypeRef for generic types
```

---

## Proposal Lifecycle

```
proposal (authored)
  → verification (experiment proves the spec)
  → approval (Meta Expert + Architect review)
  → spec chapter (extracted into docs/spec/chN)
  → implementation (Ruby Igniter or Igniter-Lang runtime)
```

During Stage 1: proposals/ is the active working intake.
After Stage 1 closes: accepted PROPs are frozen (see post-Stage-1 plan below).
