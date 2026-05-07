# Igniter-Lang Language Specification

Version: 1.0 — Stage 2 R9 sync
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
| Ch5 TypeChecker pass | PROP-021 | experiments/typechecker_proof/ | ✅ PASS ✅ boundary CLOSED |
| Ch5 TypeChecker module | PROP-021 | lib/igniter_lang/typechecker.rb | ✅ lib extracted; stream OOF-S3 + OLAP OOF-O2..O5 (R8) |
| Ch6 SemanticIR envelope | PROP-019.1 | experiments/source_to_semanticir_fixture/ | ✅ PASS ✅ golden check PASS |
| Ch6 SemanticIR emitter module | PROP-019.1 | lib/igniter_lang/semanticir_emitter.rb | ✅ lib extracted (R8) ⏳ stage2 surface lowering next |
| Ch6 CompilationReport | PROP-019.1 | source_to_semanticir_fixture --check-golden | ✅ PASS |
| Ch6 Assembler criteria A1–A6 | PROP-019.1 | experiments/igapp_assembler_proof/ | ✅ PASS A1–A6 all ok |
| Ch6 Assembler module | PROP-019.1 | lib/igniter_lang/assembler.rb | ✅ lib extracted (R9) |
| Ch6 Classifier module | PROP-018/020 | lib/igniter_lang/classifier.rb | ✅ lib extracted; ParsedProgram→ClassifiedProgram boundary |
| Ch7 RuntimeMachine lifecycle | PROP-011 | experiments/runtime_machine_memory_proof/ | ✅ proven |
| Ch7 CompatibilityReport gate | PROP-009, PROP-009.1 | igapp_assembler_proof runtime.* | ✅ proven (assembled igapp) |
| Ch7 Temporal access hook spec | PROP-022 | lib/igniter_lang/temporal_access_runtime.rb | ✅ RuntimeMachineHook spec + smoke |
| Ch7 Temporal access hook proof | PROP-022 | history_type_proof/ + sparkcrm_bihistory/ | ✅ hook PASS: valid-time + bitemporal paths |
| Ch7 Temporal access RM integration | PROP-022 | proof-local RuntimeMachine load/evaluate (R8) | ✅ proof-local PASS ⏳ production TBackend next |
| Ch8 Collection[T] ops | PROP-013 | stdlib_execution_kernel_stage1 | ✅ PASS |
| Ch8 fold/map/filter | PROP-013 | experiments/stdlib_execution_kernel_stage1/ | ✅ PASS |
| Ch9 History[T] | PROP-022 | experiments/history_type_proof/ | ✅ point proof PASS ✅ parser accepted |
| Ch9 BiHistory[T] | PROP-022 | sparkcrm_bihistory_fixture/ + typechecker_proof/ | ✅ fixture PASS ✅ axes typechecked |
| Ch9 Temporal access runtime | PROP-022 | experiments/temporal_access_runtime/ | ✅ MemoryBackend shared |
| Ch9 Temporal access SemanticIR | PROP-022 | history_type_proof/ + bihistory/ | ✅ temporal_access_node evaluated |
| Ch9 Temporal access lib | PROP-022 | lib/igniter_lang/temporal_access_runtime.rb | ✅ lib extracted; capability helper ⏳ RuntimeMachine hook |
| Ch9 Invariant severity | PROP-025 | experiments/invariant_severity_proof/ | ✅ proof PASS ✅ parser/TC spec done ⏳ impl deferred |
| Ch9 stream T runtime | PROP-023 | experiments/stream_t_proof/ | ✅ proof PASS |
| Ch9 stream T parser | PROP-023 | lib/igniter_lang/parser.rb | ✅ stream/fold_stream keywords ⏳ OOF-S2 next |
| Ch9 stream T classifier | PROP-023 | classifier_pass_proof/ (SC-1/2/3) | ✅ ESCAPE propagation PASS |
| Ch9 stream T OOF-S2 | PROP-023 | classifier.rb + classifier_pass_proof/ | ✅ OOF-S2 missing-window PASS |
| Ch9 stream T OOF-S3 | PROP-023 | typechecker.rb (R8) | ✅ OOF-S3 ESCAPE-in-fold PASS ⏳ SemanticIR lowering next |
| Ch9 OLAPPoint[T,Dims] | PROP-024 | experiments/olap_point_proof/ | ✅ proof + grammar spec PASS |
| Ch9 OLAPPoint parser | PROP-024 | lib/igniter_lang/parser.rb + spec 61 PASS | ✅ revenue_point.ig; olap_points[]; dims_record |
| Ch9 OLAPPoint TC/SemanticIR | PROP-024 | olap_point_proof/ + typechecker.rb (R8) | ✅ OOF-O2..O5 + olap_access_node lowering PASS |

---

## Coverage Summary

```
accepted + PASS   Ch1–Ch8 (all Stage 1 passes PASS; classifier + typechecker + emitter +
                  assembler modules extracted; 9 libs)
accepted partial  Ch2 (OOF syntax gap closed PROP-026)
Stage 2 partial   Ch9 (all stream OOF S1..S5 PASS; OLAP parser+TC+SemanticIR PASS;
                       hook+RM proof PASS; emitter stage2 surface lowering next)
```

---

## Stage 1 Remaining Gap

```
Stage 2 open gaps (after R9):
1. Assembler module extracted (R9). Next: compiler-orchestrator-v0.
2. Production SemanticIR stage2 surface lowering
   stream/invariant/OLAP rollup emitter lowering; production orchestration.
   Next: stream-semanticir-surface-lowering-v0.
3. Production RuntimeMachine temporal integration
   Proof-local PASS. TBackend adapter shape spec authored (R9, docs-only).
   Next: production TBackend adapter fixture.
4. Invariant severity parser + TC implementation
   Spec done. Impl deferred — Tier 1, after compiler spine stabilizes.

Closed post-Stage-1 and in Stage 2 R1–R9 (no longer gaps):
  OOF syntax rejection         — PASS: PROP-026
  Runtime eval surface         — closed_in_proof: igapp_assembler_proof
  History[T]+BiHistory[T]      — PASS: full proof stack (point, parser, axes, temporal node)
  Temporal access runtime      — PASS + lib extracted
  Temporal access hook         — PASS: valid-time + bitemporal paths via RuntimeMachineHook
  Temporal access RM proof     — PASS: proof-local load/evaluate integration (R8)
  Invariant severity proof     — PASS: proof + parser/TC spec done
  stream T runtime+OOF S1..S5  — PASS: all five stream OOF rules proven (S3 TypeChecker R8)
  OLAPPoint full stack         — PASS: proof + grammar + parser + TC/SemanticIR boundary (R8)
  Production compiler libs     — 9 libs: +semanticir_emitter.rb (R8) +assembler.rb (R9)
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
