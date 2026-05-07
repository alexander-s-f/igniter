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
All Stage 1 passes: ✅ PASS (classifier, typechecker, semanticir, assembler, runtime, stdlib)
STAGE 1 CLOSED: YES — CLOSE WITH DEFERRED GAP (META-EXPERT-007)
Close evidence: experiments/stage1_close_candidate/stage1_close_candidate.json
```

Run: `ruby igniter-lang/experiments/stage1_close_candidate/stage1_close_candidate.rb`

---

## Stage 2 — OPEN

```text
Pass/Feature             PROP    Experiment / Library                     Status
────────────────────────────────────────────────────────────────────────────────
Production compiler      PROP-027  production_compiler_cli/ PASS        ✅ CLI PASS
  package                          lib/igniter_lang/ (8 libs)           ✅ SemanticIR emitter extracted
History[T]+BiHistory[T]  PROP-022  history+bihistory proofs PASS        ✅ full proof stack
  + Temporal access hook           RuntimeMachineHook wired              ✅ hook proof PASS
                                   RuntimeMachine load/evaluate proof     ✅ proof-local RM integration
stream T                 PROP-023  stream_t_proof/ PASS                 ✅ runtime proof PASS
  + OOF-S1..S5                      all five stream OOF rules             ✅ S1..S5 PASS
OLAPPoint[T,Dims]        PROP-024  olap_point_proof/ PASS                ✅ PASS + grammar spec
  + parser impl                    revenue_point.ig parses live          ✅ parser impl PASS
  + TC/SemanticIR boundary          OOF-O2..O5 + olap_access_node         ✅ proof PASS
Invariant severity       PROP-025  invariant_severity_proof/ PASS       ✅ proof + spec PASS
                                   parser/TC spec (PINV-1..4, TINV-1..3) ⏳ impl deferred (Tier 1)
Parser OOF hardening     PROP-026  parser_oof_hardening_stage2_proof/   ✅ PASS
Runtime eval surface     —         igapp_assembler_proof/               ✅ closed_in_proof
────────────────────────────────────────────────────────────────────────────────
STAGE 2 CLOSED:   NO
Active priority:  Assembler extraction → compiler orchestrator → production TBackend adapter
New PROPs:        start from PROP-028
```

---

## lib/igniter_lang/ — 8 Libs Extracted

```text
diagnostics.rb            (R3)
compiler_result.rb        (R4)
compilation_report.rb     (R4)
parser.rb                 (R5) — parser + stream/fold_stream + olap_point/dims_record (R7)
temporal_access_runtime.rb (R5/R6) — MemoryBackend + RuntimeMachineHook (wired R7)
classifier.rb             (R6) — ParsedProgram → ClassifiedProgram; OOF-S2 (R7)
typechecker.rb            (R7/R8) — TypedProgram boundary; stream OOF-S3; OLAP OOF-O2..O5
semanticir_emitter.rb     (R8) — extracted SemanticIR emitter boundary
```

---

## PROP Canonical Map

```text
PROP-022   History[T] / BiHistory[T]     full proof stack PASS; hook proof PASS
PROP-022A  .igapp assembler contract     Stage 1 frozen (accepted/)
PROP-023   stream T                      ✅ runtime + SC-1/2/3 + OOF-S1..S5 PASS (all stream OOF done)
PROP-023A  ClassifiedExpr boundary       Stage 1 frozen (accepted/)
PROP-024   OLAPPoint[T,Dims]             ✅ proof + grammar spec + parser + TC/IR boundary PASS
PROP-025   Invariant severity            ✅ proof + spec PASS; impl deferred (Tier 1)
PROP-026   Parser OOF hardening          ✅ PASS
PROP-027   Production compiler diag.     ✅ CLI PASS; 8 libs extracted; assembler next
PROP-028+  next available
```

---

## Open Gaps

```text
1. Assembler module extraction
   Parser, Classifier, TypeChecker, and SemanticIR emitter are extracted.
   Next: extract-assembler-module-v0.

2. Compiler orchestrator
   After assembler extraction, wire Parser → Classifier → TypeChecker →
   SemanticIREmitter → Assembler → RuntimeSmoke behind a small production boundary.

3. Production SemanticIR emission for Stage 2 surfaces
   OLAP boundary proof exists; stream proof exists. The extracted emitter still needs
   production lowering for OLAP/stream/invariant surfaces.

4. Production RuntimeMachine temporal integration
   Proof-local RuntimeMachine load/evaluate integration PASS. Production TBackend
   adapter selection and Ledger/Durable Model bridge remain.

5. Invariant severity parser + typechecker implementation
   Spec done. Impl deferred — Tier 1, after compiler package spine stabilizes.
```

→ Full governance: `meta-proposals/META-EXPERT-008-stage2-implementation-governance-v0.md`
→ Proposals queue: `proposals/README.md`
