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
                                     (incl. boundary fixture)
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
Pass/Feature           PROP    Experiment                                Status
──────────────────────────────────────────────────────────────────────────────
Parser OOF hardening   PROP-026  experiments/parser_oof_hardening_      ✅ PASS
                                  stage2_proof/
Production compiler    PROP-027  experiments/production_compiler_cli/    ✅ diagnostics
                                  canonical diagnostics implemented       ⏳ package gap
Runtime eval surface   —         igapp_assembler_proof/                  ✅ closed_in_proof
                                  Add, ClaimEvidence, EvidenceAlert
History[T]             PROP-022  experiments/history_type_proof/         ✅ point proof
                                  History[Integer] + OOF-H1              ⏳ parser gap
Option[T] encoding     PROP-022  proof/docs mismatch                     ⚠ normalize next
BiHistory[T]           PROP-022  sparkcrm_bihistory fixture planned      🔵 next proof
Invariant severity     PROP-025  no experiment yet                       🔵 authored
stream T               PROP-023  no experiment yet                       🔵 authored
OLAPPoint[T,Dims]      PROP-024  no experiment yet                       🔵 authored
──────────────────────────────────────────────────────────────────────────────
STAGE 2 CLOSED:   NO
Active priority:  Normalize Option[T] → History parser acceptance → BiHistory fixture
New PROPs:        start from PROP-028
```

---

## PROP Canonical Map

```text
PROP-022   History[T]                    point proof PASS; parser gap remains
PROP-022A  .igapp assembler contract     Stage 1 frozen (accepted/)
PROP-023   stream T                      Stage 2 authored
PROP-023A  ClassifiedExpr boundary       Stage 1 frozen (accepted/)
PROP-024   OLAPPoint[T,Dims]             Stage 2 authored
PROP-025   Invariant severity            Stage 2 authored
PROP-026   Parser OOF hardening          ✅ PASS
PROP-027   Production compiler diag.     ✅ CLI diagnostics implemented; package extraction remains
PROP-028+  next available
```

## Immediate Normalization

```text
Option[T] encoding:
  history_type_proof currently uses:      { "some": value } / { "none": true }
  temporal shape doc recommends:          { "kind":"some","value":value } / { "kind":"none" }
  next action: normalize proof + goldens to the canonical kind/value shape.
```

→ Full governance: `meta-proposals/META-EXPERT-008-stage2-implementation-governance-v0.md`
→ Proposals queue: `proposals/README.md`
→ Stage 2 agent routing: `meta-proposals/META-EXPERT-008`
