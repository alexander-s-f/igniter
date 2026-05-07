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
  package                          igniter-lang/lib (14 files)          ✅ packaging skeleton PASS (R13)
                                   IgniterLang.compile facade            ✅ Ruby API facade PASS (R11)
                                   CLI/API package boundary              ✅ shared facade proof PASS (R12)
                                   prerelease gem + igc                  ✅ installed gem/bin smoke PASS (R13)
History[T]+BiHistory[T]  PROP-022  history+bihistory proofs PASS        ✅ full proof stack
  + Temporal access hook           RuntimeMachineHook wired              ✅ hook proof PASS
                                   RuntimeMachine load/evaluate proof     ✅ proof-local RM integration
stream T                 PROP-023  stream_t_proof/ PASS                 ✅ runtime proof PASS
  + OOF-S1..S5                     all five stream OOF rules             ✅ S1..S5 PASS
                                   SemanticIR emission                   ✅ emitter lowering PASS (R10)
OLAPPoint[T,Dims]        PROP-024  olap_point_proof/ PASS                ✅ PASS + grammar spec
  + parser impl                    revenue_point.ig parses live          ✅ parser impl PASS
  + TC/SemanticIR boundary          OOF-O2..O5 + olap_access_node         ✅ proof PASS
Invariant severity       PROP-025  invariant_severity_proof/ PASS       ✅ proof + spec PASS
                                   PINV-1..4 (parser) PASS               ✅ PINV-1..4 done (R10)
                                   TINV-1..3 (TypeChecker) PASS          ✅ TINV-1..3 done (R10)
                                   SemanticIR invariant_node lowering    ✅ emitter lowering PASS (R11)
                                   Runtime violation observations        ✅ observation proof PASS (R12)
TBackend bridge          PROP-008  tbackend-ledger-bridge-conformance    ✅ docs-only conformance done (R11)
                                   ledger descriptor fixture             ✅ metadata diagnostics PASS (R12)
                                   descriptor package plan               ✅ package plan done (R13)
                                   package descriptor impl               ✅ 9 specs PASS (R14)
Parser OOF hardening     PROP-026  parser_oof_hardening_stage2_proof/   ✅ PASS
Runtime eval surface     —         igapp_assembler_proof/               ✅ closed_in_proof
Stage 2 close candidate  —         stage2_close_candidate/              ✅ PASS verdict stage2_close_candidate (R14)
────────────────────────────────────────────────────────────────────────────────
STAGE 2 CLOSED:   NO
Active priority:  R15 Stage 2 close decision → archive exact close JSON → Stage 3 intake routing
New PROPs:        start from PROP-028
```

---

## igniter-lang/lib — 14 Files (13 package/internal + facade)

```text
igniter_lang.rb           (R11/R13) — package facade; exposes VERSION + compile
igniter_lang/version.rb   (R13) — prerelease package version
igniter_lang/cli.rb       (R13) — thin package CLI for igc compile
diagnostics.rb            (R3)
compiler_result.rb        (R4)
compilation_report.rb     (R4)
parser.rb                 (R5/R7/R10) — parser + stream + olap_point + invariant
temporal_access_runtime.rb (R5–R7) — MemoryBackend + RuntimeMachineHook
runtime_smoke.rb          (R12) — reusable proof-backed RuntimeSmoke callback
classifier.rb             (R6/R7) — ParsedProgram→ClassifiedProgram; OOF-S1/2
typechecker.rb            (R7/R8/R10) — TypedProgram boundary; stream OOF-S3; OLAP OOF-O2..O5; TINV-1..3
semanticir_emitter.rb     (R8/R9/R10/R11) — SemanticIR emitter; OLAP/stream/invariant lowering added
assembler.rb              (R9) — .igapp/ assembler boundary
compiler_orchestrator.rb  (R10) — NEW; compiler pass orchestration spine
```

---

## PROP Canonical Map

```text
PROP-022   History[T] / BiHistory[T]     full proof stack PASS; hook proof PASS
PROP-022A  .igapp assembler contract     Stage 1 frozen (accepted/)
PROP-023   stream T                      ✅ runtime + SC-1/2/3 + OOF-S1..S5 PASS (all stream OOF done)
PROP-023A  ClassifiedExpr boundary       Stage 1 frozen (accepted/)
PROP-024   OLAPPoint[T,Dims]             ✅ proof + grammar spec + parser + TC/IR boundary PASS
PROP-025   Invariant severity            ✅ proof + parser/TC + SemanticIR + runtime observations PASS
PROP-026   Parser OOF hardening          ✅ PASS
PROP-027   Production compiler diag.     ✅ CLI PASS; package skeleton + Ruby facade + igc proof
PROP-028+  next available
```

---

## Open Gaps

```text
1. Compiler package boundary
   ✅ Ruby-facing IgniterLang.compile facade done (S2-R11-C1-P).
   ✅ Shared CLI/API facade + load-path proof done (S2-R12-C2-P).
   ✅ Gem skeleton, prerelease version, and installed igc smoke done (S2-R13-C1-P).
   Remaining: gem-native package specs, final metadata/URL/contact policy,
   final executable naming, and release/CI policy.

2. Stage 2 close candidate
   ✅ Close candidate plan and JSON schema done (S2-R13-C2-P).
   ✅ Runner implemented and JSON verdict PASS / stage2_close_candidate (S2-R14-C1-P).
   Remaining: R15 formal close decision (CLOSE or CLOSE WITH DEFERRED GAPS).

3. Stage 2 invariant runtime observation boundary
   ✅ Stream, OLAP, and invariant_node emitter lowering PASS.
   ✅ Runtime invariant_violation_observation proof done (S2-R12-C4-P).
   Remaining: production RuntimeMachine emission/persistence boundary.

4. Production RuntimeMachine temporal integration
   Proof-local adapter registry and shim selected. Ledger conformance is descriptor-first
   (S2-R11-C3-P). Descriptor fixture + diagnostics PASS (S2-R12-C3-P).
   ✅ Package-side descriptor plan done (S2-R13-C3-P).
   ✅ Metadata-only package descriptor implementation + targeted specs PASS (S2-R14-C2-P).
   Remaining: any CompatibilityReport consumption or RuntimeMachine binding requires
   separate Architect approval; no read/write/replay/runtime binding is closed.

5. Invariant severity parser + typechecker implementation
   ✅ DONE (S2-R10-C4-P). PINV-1..4 (parser) + TINV-1..3 (TypeChecker) implemented.
   ✅ SemanticIR invariant_node lowering DONE (S2-R11-C2-P).
   ✅ Runtime violation observations DONE (S2-R12-C4-P).
   Remaining: OOF-I1 (@bitemporal deferred), OOF-I3 (~T deferred), OOF-I5
   (requirements DB), OOF-I2 advisory caller-warning analysis.

6. Human-agent symbiosis vision
   ✅ META-EXPERT-010 authored (S2-R13-M0-S).
   Routing: Stage 3 / PROP-028+ after Stage 2 close; not a Stage 2 close blocker.
```

→ Full governance: `meta-proposals/META-EXPERT-008-stage2-implementation-governance-v0.md`
→ Proposals queue: `proposals/README.md`
