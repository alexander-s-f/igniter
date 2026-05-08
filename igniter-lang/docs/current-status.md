# Igniter-Lang Current Status

Stage 1: **CLOSED** (2026-05-06) — META-EXPERT-007
Stage 2: **CLOSED** (2026-05-07) — META-EXPERT-009.1
Stage 3: **OPEN** (2026-05-08) — META-EXPERT-011
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-08
Policy: `meta-proposals/META-EXPERT-011-stage3-governance-opening-v0.md`

> Full history in:
> `docs/archive/snapshots/2026-05-06-stage1-close/`
> `docs/archive/snapshots/2026-05-07-stage2-close/`
> `experiments/stage2_close_candidate/stage2_close_candidate.json`

---

## Stage 1 — CLOSED (2026-05-06)

```text
All Stage 1 passes: ✅ PASS (classifier, typechecker, semanticir, assembler, runtime, stdlib)
STAGE 1 CLOSED: YES — CLOSE WITH DEFERRED GAP (META-EXPERT-007)
Close evidence: experiments/stage1_close_candidate/stage1_close_candidate.json
```

---

## Stage 2 — CLOSED (2026-05-07)

```text
Verdict: CLOSE WITH DEFERRED GAPS (META-EXPERT-009.1)
Close evidence: experiments/stage2_close_candidate/stage2_close_candidate.json
  status: PASS  |  verdict: stage2_close_candidate
  proofs_run: 8  |  surface_checks: 7  |  deferred_gaps: 5
```

### What Stage 2 Closed

```text
Surface / PROP                                                         Status
────────────────────────────────────────────────────────────────────────────
Parser (61 specs + stream + OLAP + invariant)       PROP-014/015/026  ✅ PASS
Classifier (CORE/ESCAPE/OOF + SC-1/3 + OOF-S1..5)  PROP-018/020      ✅ PASS
TypeChecker (BiHistory + OOF-S3 + OLAP + TINV-1..3) PROP-021/025     ✅ PASS
SemanticIR Emitter (OLAP + stream + invariant)       PROP-019.1       ✅ PASS
Assembler (A1–A6)                                    PROP-022A        ✅ PASS
RuntimeMachine (lifecycle + temporal hook)           PROP-011/022     ✅ PASS
Stdlib kernel                                        PROP-013         ✅ PASS
History[T] / BiHistory[T]                            PROP-022         ✅ PASS
stream T (OOF-S1..5 + SemanticIR)                   PROP-023         ✅ PASS
OLAPPoint[T,Dims] (parser + TC + SemanticIR)         PROP-024         ✅ PASS
Invariant severity (PINV-1..4 + TINV-1..3 + obs)    PROP-025         ✅ PASS
TBackend descriptor (conformance + fixture)          PROP-008         ✅ PASS
Compiler package (11 modules + facade + igc)         PROP-027         ✅ PASS
Stage 2 close candidate                              —                ✅ PASS
────────────────────────────────────────────────────────────────────────────
IgniterLang::VERSION: 0.1.0.pre.stage2
```

### Deferred Gaps (carried to Stage 3)

```text
1. production_tbackend_adapter_binding  — Ledger/Durable adapter; no runtime binding
2. olap_distributed_execution           — OLAP scatter/gather, rollup, distributed
3. invariant_persistence                — production persistence for violation observations
4. deferred_invariant_oofs             — OOF-I1 (@bitemporal), OOF-I3 (~T), OOF-I5
5. gem_release_readiness                — final metadata, CI, RubyGems release policy
```

---

## Stage 3 — OPEN (2026-05-08)

Governance: `meta-proposals/META-EXPERT-011-stage3-governance-opening-v0.md`

```text
Lane              Status    First Track
─────────────────────────────────────────────────────────────────
Release           ✅ policy gem-release-policy-v0 done; CI/release automation open
TBackend          ✅ bridge compatibility-report-descriptor-consumption-v0 done;
                            report-only descriptor metadata, no runtime binding
Runtime           ⏳ open   invariant-persistence-boundary-v0
                            temporal-cache-key-proof-v0 done; no memoization yet
Language          ⚙️ partial PROP-028 classifier/typechecker proof done;
                            SemanticIR temporal_access_node/runtime/parser syntax open
                            spec-entrypoint-sync-v0 (prereq for PROP-029)
Compiler Internals ⚠️ blocked typed-emission canonical shape fixed;
                            parity PASS / verdict blocked / 7 blockers
─────────────────────────────────────────────────────────────────
STAGE 3 CLOSED:   NO
Round 1 landed:
  S3-R1-C1-S: stage3-governance-opening-v0      ✅ Stage 3 OPEN
  S3-R1-C2-P: prop-028-temporal-fragment-v0     ✅ proposal written
  S3-R1-C3-P: typed-emission-main-path-parity   ⚠️ PASS runner / verdict blocked / 9 blockers
  S3-R1-C4-P: stage2-close-snapshot-archive     ✅ cold archive done
  S3-R1-C5-P: axiomatic/system-forming lens     ✅ research note
Round 2 landed:
  S3-R2-C1-P: typed-emission-canonical-shape    ⚠️ Add parity PASS; verdict blocked / 7 blockers
  S3-R2-C2-P: temporal classifier/typechecker   ✅ PROP-028 first implementation boundary
  S3-R2-C3-P: temporal-cache-key-proof          ✅ CORE vs TEMPORAL key proof
  S3-R2-C4-P: gem-release-policy-v0             ✅ release policy + metadata; publish gated
  S3-R2-C5-P: compatibility-report descriptor   ✅ report-only bridge proposal; no binding
  S3-R2-C6-P: syntax-pressure-registry-v0       ✅ pressure registry; no canon promotion
New PROPs:        start from PROP-028
Arch approval required for: gem publish, Ledger read/write, MCP/mesh
```

### Stage 3 Inherited State

```text
IgniterLang::VERSION: 0.1.0.pre.stage2
Compiler pipeline:   Parser → Classifier → TypeChecker → SemanticIREmitter → Assembler
emit_typed:          exists in semanticir_emitter.rb ⏳ not yet wired in orchestrator
typed emission path: canonical identity/shape fixed; parity runner PASS, verdict blocked, 7 blockers; do not switch orchestrator yet
Ledger descriptor:   metadata-only ✅ package specs PASS
CompatibilityReport: descriptor-consumption bridge proposal ✅ report-only metadata; runtime_enforced false
Runtime observations: proof-backed ⏳ production persistence open
Temporal cache key:  proof PASS; CORE key for TEMPORAL is semantic bug; RuntimeMachine memoization not implemented
Stage 2 close:       PASS (stage2_close_candidate.json)
Stage 1 regression:  PASS
Archive:             Stage 2 close snapshot ✅ docs/archive/snapshots/2026-05-07-stage2-close/
АИ/СОИ lens:         soft Stage 3 governance/review vocabulary; not a hard gate
Syntax pressure:     registry done; fixture spellings remain pressure/non-canon unless promoted by proposal/proof
```

### Stage 2 Deferred Gaps → Stage 3 Lanes

```text
1. gem_release_readiness               → Release lane
2. production_tbackend_adapter_binding → TBackend lane   (Arch approval for prod read/write)
3. invariant_persistence               → Runtime lane
4. deferred_invariant_oofs             → Language lane   (after PROP-028)
5. olap_distributed_execution          → Language lane   (after TBackend lane)
```

---

## PROP Canonical Map (Stage 2 final)

```text
PROP-022   History[T] / BiHistory[T]     ✅ CLOSED IN STAGE 2
PROP-022A  .igapp assembler contract     Stage 1 frozen (accepted/)
PROP-023   stream T                      ✅ CLOSED IN STAGE 2 (all OOF + SemanticIR)
PROP-023A  ClassifiedExpr boundary       Stage 1 frozen (accepted/)
PROP-024   OLAPPoint[T,Dims]             ✅ CLOSED IN STAGE 2 (parser + TC + SemanticIR)
PROP-025   Invariant severity            ✅ CLOSED IN STAGE 2 (partial: OOF-I1/I3/I5 deferred)
PROP-026   Parser OOF hardening          ✅ CLOSED IN STAGE 2
PROP-027   Production compiler           ✅ CLOSED IN STAGE 2 (package + facade + igc)
PROP-028   TEMPORAL fragment class       ⚙️ proposal + classifier/typechecker + cache-key proof done;
                                         SemanticIR/runtime/parser coordinates pending
PROP-029+  Stage 3 — not open without governance/prerequisite track
```

→ Close governance: `meta-proposals/META-EXPERT-009.1-stage2-close-decision-v0.md`
→ Stage 1 governance: `meta-proposals/META-EXPERT-007-stage1-close-governance-v0.md`
