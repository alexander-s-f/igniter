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
  package                          lib/igniter_lang/ (6 libs)           ✅ 6 libs extracted
                                   +classifier.rb (R6)                    ⏳ typechecker next
History[T]+BiHistory[T]  PROP-022  history+bihistory proofs PASS        ✅ full proof stack
  + Temporal access                temporal_access_runtime lib           ✅ lib + hook spec
                                   RuntimeMachineHook smoke PASS          ⏳ hook proof next
stream T                 PROP-023  stream_t_proof/ PASS                 ✅ runtime proof PASS
  + classifier                     classifier_pass_proof/ PASS          ✅ SC-1/2/3 PASS
                                   source_to_semanticir goldens 9        ⏳ OOF-S2 classifier
                                   (OOF-S2 missing-window next)          ⏳ OOF-S3 typechecker
OLAPPoint[T,Dims]        PROP-024  olap_point_proof/ PASS (21 checks)   ✅ PASS + grammar spec
                                   dims_record AST; OOF-O1..5 owned      ⏳ parser/TC impl next
Invariant severity       PROP-025  invariant_severity_proof/ PASS       ✅ proof + spec PASS
                                   parser/TC spec (PINV-1..4, TINV-1..3) ⏳ impl deferred (Tier 1)
Parser OOF hardening     PROP-026  parser_oof_hardening_stage2_proof/   ✅ PASS
Runtime eval surface     —         igapp_assembler_proof/               ✅ closed_in_proof
────────────────────────────────────────────────────────────────────────────────
STAGE 2 CLOSED:   NO
Active priority:  TypeChecker module extraction → OLAPPoint parser impl → stream OOF-S2/S3
New PROPs:        start from PROP-028
```

---

## lib/igniter_lang/ — 6 Libs Extracted

```text
diagnostics.rb            (R3)
compiler_result.rb        (R4)
compilation_report.rb     (R4)
parser.rb                 (R5) — includes stream/fold_stream keywords
temporal_access_runtime.rb (R5) — MemoryBackend + RuntimeMachineHook spec (R6)
classifier.rb             (R6) — NEW; ParsedProgram → ClassifiedProgram boundary
```

---

## PROP Canonical Map

```text
PROP-022   History[T] / BiHistory[T]     full proof stack PASS; hook spec authored
PROP-022A  .igapp assembler contract     Stage 1 frozen (accepted/)
PROP-023   stream T                      ✅ runtime + SC-1/2/3 PASS; OOF-S2/S3 next
PROP-023A  ClassifiedExpr boundary       Stage 1 frozen (accepted/)
PROP-024   OLAPPoint[T,Dims]             ✅ proof PASS; grammar spec done; parser impl next
PROP-025   Invariant severity            ✅ proof + spec PASS; impl deferred (Tier 1)
PROP-026   Parser OOF hardening          ✅ PASS
PROP-027   Production compiler diag.     ✅ CLI PASS; 6 libs extracted; typechecker next
PROP-028+  next available
```

---

## Open Gaps

```text
1. Production compiler typechecker module extraction
   classifier.rb extracted (R6). Next: extract-typechecker-module-v0.

2. OLAPPoint parser + typechecker implementation
   Grammar spec done (dims_record, OOF-O1..5). Parser impl deferred (risk of golden drift).
   Next: olap-point-parser-implementation-v0.

3. stream T OOF-S2 classifier + OOF-S3 typechecker
   SC-1/2/3 landed; OOF-S2 (missing window) classifier slice is small and bounded.
   Next: stream-oof-s2-classifier-v0 → stream-oof-s3-typechecker-v0.

4. RuntimeMachine temporal access hook proof
   Hook spec + smoke in lib. Proof wiring into HistoryRuntimeMachine load/evaluate remains.
   Next: runtime-machine-temporal-access-hook-proof-v0.

5. Invariant severity parser + typechecker implementation
   Spec done. Impl deferred — Tier 1, after typechecker module closes.
```

→ Full governance: `meta-proposals/META-EXPERT-008-stage2-implementation-governance-v0.md`
→ Proposals queue: `proposals/README.md`
