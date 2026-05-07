# Igniter-Lang Current Status

Stage 1: **CLOSED** (2026-05-06) — META-EXPERT-007
Stage 2: **OPEN** (2026-05-06) — META-EXPERT-008
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-07
Policy: `meta-proposals/META-EXPERT-008-stage2-implementation-governance-v0.md`

> Full history in: `docs/archive/snapshots/2026-05-06-stage1-close/`

---

## Stage 1 — CLOSED

```text
Pass                   PROP          Experiment                              Status
──────────────────────────────────────────────────────────────────────────────────
Parser                 PROP-014/015  experiments/parser/                    ✅ partial
                                     add.ig, availability.ig,                (OOF gap →
                                     polymorphic_add.ig → PASS               closed PROP-026)
Classifier             PROP-018/020  experiments/classifier_pass_proof/     ✅ PASS
SemanticIR Emitter     PROP-019.1    experiments/source_to_semanticir_      ✅ PASS
                                     fixture/ --check-golden
TypeChecker            PROP-021      experiments/typechecker_proof/         ✅ PASS
                                     (incl. boundary + BiHistory axes)
.igapp/ Assembler      PROP-022A     experiments/igapp_assembler_proof/     ✅ PASS
                                     A1-A6 + runtime.evaluate → trusted
RuntimeMachine         PROP-011      experiments/runtime_machine_memory_    ✅ proven
                                     proof/
Stdlib kernel          PROP-013      experiments/stdlib_execution_          ✅ PASS
                                     kernel_stage1/
──────────────────────────────────────────────────────────────────────────────────
STAGE 1 CLOSED:   YES — CLOSE WITH DEFERRED GAP (META-EXPERT-007)
Close evidence:   experiments/stage1_close_candidate/stage1_close_candidate.json
```

Run: `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb`

---

## Stage 2 — OPEN

```text
Pass/Feature             PROP    Experiment                               Status
────────────────────────────────────────────────────────────────────────────────
Parser OOF hardening     PROP-026  parser_oof_hardening_stage2_proof/   ✅ PASS
Production compiler      PROP-027  production_compiler_cli/             ✅ CLI PASS
  diagnostics lib                  lib/igniter_lang/diagnostics.rb      ✅ lib extracted
                                   (package boundary remains)            ⏳ package gap
Runtime eval surface     —         igapp_assembler_proof/               ✅ closed_in_proof
Option[T] encoding       PROP-022  canonical {kind,value} shape         ✅ normalized
History[T]               PROP-022  history_type_proof/                  ✅ point proof PASS
                                   History[Integer] + OOF-H1            ✅ parser accepted
BiHistory[T]             PROP-022  sparkcrm_bihistory_fixture/          ✅ fixture PASS
                                   typechecker_proof/                   ✅ axes typechecked
Temporal access runtime  PROP-022  temporal_access_runtime/             ✅ MemoryBackend
                                   TemporalAccessRuntime::MemoryBackend  shared history+bi
Invariant severity       PROP-025  invariant_severity_proof/            ✅ PASS
                                   severity :error/:warn/:soft/:metric   (proof-local)
stream T                 PROP-023  no experiment yet                    🔵 authored
OLAPPoint[T,Dims]        PROP-024  no experiment yet                    🔵 authored
────────────────────────────────────────────────────────────────────────────────
STAGE 2 CLOSED:   NO
Active priority:  SemanticIR temporal node generalization → production compiler package
New PROPs:        start from PROP-028
```

---

## PROP Canonical Map

```text
PROP-022   History[T] / BiHistory[T]     point+axes proof PASS; TemporalAccessRuntime shared
PROP-022A  .igapp assembler contract     Stage 1 frozen (accepted/)
PROP-023   stream T                      Stage 2 authored
PROP-023A  ClassifiedExpr boundary       Stage 1 frozen (accepted/)
PROP-024   OLAPPoint[T,Dims]             Stage 2 authored
PROP-025   Invariant severity            ✅ proof PASS (proof-local; parser/TC next)
PROP-026   Parser OOF hardening          ✅ PASS
PROP-027   Production compiler diag.     ✅ CLI PASS; lib extracted; package boundary open
PROP-028+  next available
```

---

## Open Gaps

```text
1. SemanticIR temporal node generalization
   History/BiHistory temporal_access_node evaluation is proof-local (TemporalAccessRuntime).
   Next: map SemanticIR temporal_access_node onto TemporalAccessRuntime API.

2. Production compiler package boundary
   lib/igniter_lang/diagnostics.rb extracted. CompilerResult/CompilationReport helpers remain.
   Next: compiler-result-report-boundary-v0.

3. Invariant severity parser + typechecker ownership
   invariant_severity_proof PASS (proof-local). Parser syntax and TypeChecker OOF codes deferred.
   Next: invariant-severity-parser-and-typechecker-ownership-v0.

4. stream T / OLAPPoint
   PROP-023 / PROP-024 authored; no experiments yet.
```

→ Full governance: `meta-proposals/META-EXPERT-008-stage2-implementation-governance-v0.md`
→ Proposals queue: `proposals/README.md`
