# Igniter-Lang Language Specification

Version: 0.3 — Stage 1 crystallized from PROPs
Maintainer: `[Igniter-Lang Meta Expert]`
Status: living document
Last updated: 2026-05-06

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
| Ch2 Grammar BNF | PROP-014, PROP-015 | experiments/parser/ (61 specs) | ✅ partial — OOF rejection gap |
| Ch2 ParsedProgram shape | PROP-014, PROP-018 | experiments/parser/ | ✅ proven |
| Ch3 Type grammar | PROP-004 | experiments/typechecker_proof/ | ✅ PASS ⚠️ self-contained gap |
| Ch3 Decimal typing | PROP-021 | typechecker_proof TC cases | ✅ PASS |
| Ch4 Classifier pass | PROP-003, PROP-020 | experiments/classifier_pass_proof/ | ✅ PASS |
| Ch4 OOF rules P1/P2/P4 | PROP-020 | classifier negatives | ✅ PASS |
| Ch5 Four-stage pipeline | PROP-018, PROP-019.1 | — | accepted |
| Ch5 TypeChecker pass | PROP-021 | experiments/typechecker_proof/ | ✅ PASS ⚠️ reads two golden dirs |
| Ch6 SemanticIR envelope | PROP-019.1 | experiments/source_to_semanticir_fixture/ | ✅ PASS ⚠️ migration needed |
| Ch6 CompilationReport | PROP-019.1 | source_to_semanticir_fixture | ✅ PASS |
| Ch6 Assembler criteria A1–A6 | PROP-019.1 | no experiment yet | 🔴 blocked — Slice 0 first |
| Ch7 RuntimeMachine lifecycle | PROP-011 | experiments/runtime_machine_memory_proof/ | ✅ proven |
| Ch7 CompatibilityReport gate | PROP-009, PROP-009.1 | runtime_machine_memory_proof | ✅ proven |
| Ch8 Collection[T] ops | PROP-013 | runtime_machine_memory_proof (partial) | 🟡 stdlib not connected |
| Ch8 fold/map/filter | PROP-013 | no stdlib_execution_proof yet | 🔴 not started |
| Ch9 History[T] | PROP-022 | — | deferred Stage 2 |
| Ch9 stream T | PROP-023 | — | deferred Stage 2 |
| Ch9 OLAPPoint | PROP-024 | — | deferred Stage 2 |
| Ch9 Invariant severity | PROP-025 | — | deferred Stage 2 |

---

## Stage 1 Gaps (implementation-blocked)

```
1. OOF rejection at parse time — parser accepts some OOF source without error (no slice assigned)
2. TypeChecker self-contained gap — Slice B: standalone ClassifiedProgram → TypedProgram experiment
   (typechecker_proof.rb is PASS but reads from two external golden dirs, not pipeline-proper)
3. PROP-019.1 golden file migration — Slice 0 (active blocker for assembler)
4. igapp_assembler_proof — Slice A (blocked on Slice 0)
5. stdlib_execution_proof — Slice C (parallel, independent)
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
