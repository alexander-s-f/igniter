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
                                     add.ig, availability.ig,                (OOF syntax gap
                                     polymorphic_add.ig → PASS               → closed PROP-026)
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
Pass/Feature             PROP    Experiment / Library                     Status
────────────────────────────────────────────────────────────────────────────────
Parser OOF hardening     PROP-026  parser_oof_hardening_stage2_proof/   ✅ PASS
Production compiler      PROP-027  production_compiler_cli/ PASS        ✅ CLI PASS
  package extraction               lib/igniter_lang/                    ✅ 5 libs extracted
                                   diagnostics, compiler_result,          ⏳ classifier next
                                   compilation_report, parser,
                                   temporal_access_runtime
Runtime eval surface     —         igapp_assembler_proof/               ✅ closed_in_proof
History[T]               PROP-022  history_type_proof/                  ✅ full proof stack
  + BiHistory[T]                   sparkcrm_bihistory_fixture/          ✅ parser+typechecker
  + Temporal access                temporal_access_runtime lib           ✅ lib + SemanticIR node
Invariant severity       PROP-025  invariant_severity_proof/ PASS       ✅ proof + spec PASS
                                   parser/TC spec (PINV-1..4, TINV-1..3) ⏳ impl deferred
stream T                 PROP-023  stream_t_proof/ PASS                 ✅ runtime proof PASS
                                   lib/igniter_lang/parser.rb            ✅ stream keywords parsed
                                   (SC-1..3 classifier ESCAPE next)      ⏳ classifier next
OLAPPoint[T,Dims]        PROP-024  olap_point_proof/ PASS               ✅ PASS
                                   point access + rollup + OOF-O1..3     (proof-local; parser/
                                                                          TC boundary next)
────────────────────────────────────────────────────────────────────────────────
STAGE 2 CLOSED:   NO
Active priority:  Classifier module extraction → stream classifier SC-1..3 → OLAP parser/TC
New PROPs:        start from PROP-028
```

---

## PROP Canonical Map

```text
PROP-022   History[T] / BiHistory[T]     full proof stack PASS + lib extracted
PROP-022A  .igapp assembler contract     Stage 1 frozen (accepted/)
PROP-023   stream T                      ✅ runtime proof PASS; stream keywords parsed; classifier next
PROP-023A  ClassifiedExpr boundary       Stage 1 frozen (accepted/)
PROP-024   OLAPPoint[T,Dims]             ✅ proof PASS (proof-local; parser/TC boundary next)
PROP-025   Invariant severity            ✅ proof + spec PASS; impl deferred (Tier 1)
PROP-026   Parser OOF hardening          ✅ PASS
PROP-027   Production compiler diag.     ✅ CLI PASS; 5 libs extracted; classifier module next
PROP-028+  next available
```

---

## Open Gaps

```text
1. Production compiler classifier module extraction
   lib/igniter_lang/parser.rb done. Next: extract-classifier-module-v0.

2. stream T classifier ESCAPE propagation (SC-1..3)
   Parser accepts stream/fold_stream. Classifier ESCAPE rules unimplemented.
   Next: stream-classifier-escape-propagation-v0.

3. OLAPPoint parser + typechecker boundary
   olap_point_proof PASS (proof-local). Parser syntax and TypeChecker OOF codes not in grammar.
   Next: olap-point-parser-typechecker-boundary-v0.

4. Production RuntimeMachine temporal access hook
   lib/igniter_lang/temporal_access_runtime.rb extracted.
   Resolver hook in RuntimeMachine + TBackend capability checks remain.
   Next: runtime-machine-temporal-access-hook-v0.

5. Invariant severity parser + typechecker implementation
   Spec (PINV-1..4 + TINV-1..3) done. Impl deferred — Tier 1, after classifier closes.
```

→ Full governance: `meta-proposals/META-EXPERT-008-stage2-implementation-governance-v0.md`
→ Proposals queue: `proposals/README.md`
