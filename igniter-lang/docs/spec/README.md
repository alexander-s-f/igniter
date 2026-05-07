# Igniter-Lang Language Specification

Version: 0.7 — Stage 2 R5 sync
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
| Ch9 BiHistory[T] | PROP-022 | sparkcrm_bihistory_fixture/ + typechecker_proof/ | ✅ fixture PASS ✅ axes typechecked |
| Ch9 Temporal access runtime | PROP-022 | experiments/temporal_access_runtime/ | ✅ MemoryBackend shared |
| Ch9 Temporal access SemanticIR | PROP-022 | history_type_proof/ + bihistory/ | ✅ temporal_access_node evaluated |
| Ch9 Temporal access lib | PROP-022 | lib/igniter_lang/temporal_access_runtime.rb | ✅ lib extracted; capability helper ⏳ RuntimeMachine hook |
| Ch9 Invariant severity | PROP-025 | experiments/invariant_severity_proof/ | ✅ proof PASS ✅ parser/TC spec done ⏳ impl deferred |
| Ch9 stream T runtime | PROP-023 | experiments/stream_t_proof/ | ✅ proof PASS |
| Ch9 stream T parser | PROP-023 | lib/igniter_lang/parser.rb | ✅ stream/fold_stream keywords ⏳ classifier next |
| Ch9 OLAPPoint[T,Dims] | PROP-024 | experiments/olap_point_proof/ | ✅ proof PASS ⏳ parser/TC boundary next |

---

## Coverage Summary

```
accepted + PASS   Ch3 (TypeChecker + boundary + BiHistory axes), Ch4 (classifier),
                  Ch5 (pipeline + assembler), Ch6 (SemanticIR + assembler),
                  Ch7 (RuntimeMachine), Ch8 (stdlib kernel)
accepted partial  Ch2 (OOF syntax gap closed PROP-026; semantic OOF caught at Classify/TypeCheck)
Stage 2 partial   Ch9 (History[T]+BiHistory+stream T+OLAPPoint PASS; temporal lib+parser lib
                       extracted; severity proof+spec PASS; classifier/TC boundaries next)
```

---

## Stage 1 Remaining Gap

```
Stage 2 open gaps (after R5):
1. Production compiler classifier module — extract-classifier-module-v0
   lib/: parser.rb, temporal_access_runtime.rb now extracted (5 libs total).
2. stream T classifier ESCAPE propagation — SC-1..3
   stream/fold_stream keywords parsed; classifier ESCAPE rules unimplemented.
3. OLAPPoint parser + typechecker boundary — olap-point-parser-typechecker-boundary-v0
   olap_point_proof PASS (proof-local); grammar/TC surface next.
4. RuntimeMachine temporal access hook — runtime-machine-temporal-access-hook-v0
   temporal_access_runtime lib extracted; resolver hook in RuntimeMachine remains.
5. Invariant severity parser + TC implementation
   Spec done; impl deferred (Tier 1, after compiler closes).

Closed post-Stage-1 and in Stage 2 R1–R5 (no longer gaps):
  OOF syntax rejection     — PASS: PROP-026
  Runtime eval surface     — closed_in_proof: igapp_assembler_proof
  Option[T] normalization  — PASS: canonical {kind,value} shape
  History[T] parser        — PASS: structured TypeRef for generic types
  BiHistory[T] axes        — PASS: typechecker_proof (4 BiHistory cases)
  Temporal access runtime  — PASS: TemporalAccessRuntime::MemoryBackend + lib extracted
  Temporal access SemanticIR — PASS: temporal_access_node evaluated end-to-end
  Invariant severity proof — PASS: proof + parser/TC spec done
  stream T proof           — PASS: stream_t_proof; stream keywords parsed
  OLAPPoint proof          — PASS: olap_point_proof (point access + rollup + OOF-O1..3)
  Production compiler libs — 5 libs in lib/igniter_lang/ (diagnostics, result, report, parser, TAR)
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
