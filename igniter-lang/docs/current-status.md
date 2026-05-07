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
Pass/Feature             PROP    Experiment                               Status
────────────────────────────────────────────────────────────────────────────────
Parser OOF hardening     PROP-026  parser_oof_hardening_stage2_proof/   ✅ PASS
Production compiler      PROP-027  production_compiler_cli/ PASS        ✅ CLI PASS
  package extraction               lib/igniter_lang/                    ✅ 3 libs extracted
                                   diagnostics.rb, compiler_result.rb,   ⏳ parser module next
                                   compilation_report.rb
Runtime eval surface     —         igapp_assembler_proof/               ✅ closed_in_proof
Option[T] encoding       PROP-022  canonical {kind,value} shape         ✅ normalized
History[T]               PROP-022  history_type_proof/                  ✅ point proof PASS
                                   History[Integer] + OOF-H1            ✅ parser accepted
BiHistory[T]             PROP-022  sparkcrm_bihistory_fixture/          ✅ fixture PASS
                                   typechecker_proof/                   ✅ axes typechecked
Temporal access          PROP-022  temporal_access_runtime/ shared      ✅ MemoryBackend
  runtime + SemanticIR             history_type_proof/ + bihistory/     ✅ temporal_access_node
                                   runtime evaluates SemanticIR node     evaluated end-to-end
Invariant severity       PROP-025  invariant_severity_proof/ PASS       ✅ proof PASS
  parser/TC spec                   parser/TC spec authored              ✅ spec done
                                   (PINV-1..4 + TINV-1..3 unimplemented) ⏳ impl deferred
stream T                 PROP-023  stream_t_proof/                      ✅ PASS
                                   fold_stream bounded window            (proof-local; parser
                                   → CORE fold; OOF-S1..5               classifier next)
OLAPPoint[T,Dims]        PROP-024  no experiment yet                    🔵 authored
────────────────────────────────────────────────────────────────────────────────
STAGE 2 CLOSED:   NO
Active priority:  Production compiler parser module → stream parser/classifier → OLAPPoint
New PROPs:        start from PROP-028
```

---

## PROP Canonical Map

```text
PROP-022   History[T] / BiHistory[T]     full proof stack PASS incl. SemanticIR temporal node
PROP-022A  .igapp assembler contract     Stage 1 frozen (accepted/)
PROP-023   stream T                      ✅ proof PASS (proof-local; parser/classifier next)
PROP-023A  ClassifiedExpr boundary       Stage 1 frozen (accepted/)
PROP-024   OLAPPoint[T,Dims]             Stage 2 authored; no experiment
PROP-025   Invariant severity            ✅ proof PASS; parser/TC spec authored; impl deferred
PROP-026   Parser OOF hardening          ✅ PASS
PROP-027   Production compiler diag.     ✅ CLI PASS; 3 libs extracted; parser module next
PROP-028+  next available
```

---

## Open Gaps

```text
1. Production compiler parser module extraction
   lib/: diagnostics.rb, compiler_result.rb, compilation_report.rb — done.
   Next: extract-parser-module-v0 → lib/igniter_lang/parser.rb.

2. stream T parser + classifier boundary
   stream_t_proof PASS (proof-local ESCAPE runtime).
   Next: stream-parser-classifier-boundary-v0.

3. Invariant severity parser + typechecker implementation
   Parser/TC spec (PINV-1..4, TINV-1..3) authored. Implementation deferred.
   Tier 1 — start after production compiler closes.

4. OLAPPoint[T,Dims]
   PROP-024 authored; no experiment yet.

5. Production RuntimeMachine temporal access integration
   temporal_access_node evaluated in proof. Production TBackend adapters remain.
   Next: production-runtime-temporal-access-integration-v0.
```

→ Full governance: `meta-proposals/META-EXPERT-008-stage2-implementation-governance-v0.md`
→ Proposals queue: `proposals/README.md`
