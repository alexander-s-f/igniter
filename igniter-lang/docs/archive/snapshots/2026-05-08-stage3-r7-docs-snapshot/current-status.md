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
Lane              Status    Current Evidence
─────────────────────────────────────────────────────────────────
Release           ✅ gate    gem-release-policy + release-gate PASS;
                            local .gem/.sha256 rebuilt; publish not attempted
TBackend          ✅ gate2   descriptor package exposure ratification recommended;
                            descriptor-to-CompatibilityReport map done;
                            Gate 3 closed, no runtime binding
Runtime           ⏳ open   CompatibilityReport load/evaluate split PASS;
                            post-switch CORE/TEMPORAL smoke PASS;
                            invariant persistence open; no prod execution/cache
Language          ⚙️ partial TEMPORAL through .igapp manifest index + load guard;
                            parser coordinate syntax and production runtime remain open
                            entrypoint/section disposition set; PROP track still needed
Compiler Internals ✅ switched CompilerOrchestrator now uses emit_typed(typed);
                            invariant typed-shape delta accepted/discharged;
                            parsed emitter retained as Stage 1 legacy/comparison
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
Round 3 landed:
  S3-R3-C1-P: typed source lowering parity      ⚠️ typed blockers 0; legacy deltas 11; switch false
  S3-R3-C2-P: temporal SemanticIR access node   ✅ temporal_input/access nodes; assembler open
  S3-R3-C3-P: runtime temporal cache contract   ✅ design/proof; no production memoization
  S3-R3-C4-P: gem release automation            ✅ release-gate PASS; publish not attempted
  S3-R3-C5-P: descriptor consumption fixture    ✅ proof-local PASS; runtime_enforced false
  S3-R3-C6-P: syntax pressure specimens         ✅ fixtures/guides; no canon promotion
  S3-R3-X1-S: temporal manifest/cache pressure  ⚠️ assembler boundary blocker routed
Round 4 landed:
  S3-R4-C1-P: temporal assembler boundary       ✅ temporal nodes assemble; runtime unsupported guard
  S3-R4-C2-P: PROP-022A temporal manifest errata ✅ dual-index spec written
  S3-R4-C3-P: requirements from escape boundaries ✅ static requirements replaced
  S3-R4-C4-S: typed switch decision             ✅ Option B adopted; gate defined
  S3-R4-C5-P: proof-local runtime cache         ✅ memory cache proof PASS; no prod cache
  S3-R4-C6-G: descriptor Gate 2 decision        ⏳ ratification requested
  S3-R4-C7-P: syntax review results             ✅ route-to-proposal signals; no canon
  S3-R4-X1-S: temporal igapp runtime pressure   ⚠️ contract_index/load guard gaps routed
  META-EXPERT-012: doc lifecycle/rotation       ✅ lifecycle/stale markers introduced
Round 5 landed:
  S3-R5-C1-P: temporal manifest contract index  ✅ manifest.fragment_summary + contract_index PASS
  S3-R5-C2-P: temporal runtime load guard       ✅ load_accept_evaluate_refuse proof PASS
  S3-R5-C3-P: BiHistory source parity gate      ✅ sparkcrm_bihistory measured; gate PROCEED
  S3-R5-C4-P: orchestrator emit_typed switch    ✅ production path switched; Stage 1/2 PASS
  S3-R5-C5-G: descriptor Gate 2 ratification    ✅ recommend ratify; package spec 9/0 PASS
Round 6 landed:
  S3-R6-C2-S: agent context capsule             ✅ trusted read order + gates + proof budget
  S3-R6-C3-P: spec ch6 SemanticIR sync          ✅ temporal nodes + manifest + guard synced
  S3-R6-C4-P: spec ch4 fragment sync            ✅ TEMPORAL class + node/value split synced
  S3-R6-C5-P: spec ch7 runtime/cache sync       ✅ cache schema + load guard synced
  S3-R6-C6-P: spec ch5 emit_typed sync          ✅ production typed pipeline synced
  S3-R6-C7-S: parity stale header sweep         ✅ 4 superseded parity/cache tracks marked stale
  S3-R6-C8-S: proposal lifecycle index sync     ✅ PROP-022..025 closed; PROP-028 partial
  S3-R6-X1-S: docs context/spec sync pressure   ✅ docs layer reviewed; remaining debt routed
Round 7 landed:
  S3-R7-C1-P: runtime compatibility load check  ✅ CompatibilityReport separates load from evaluation
  S3-R7-C2-P: invariant typed shape discharge   ✅ invariant_valid delta accepted; C-8 debt closed
  S3-R7-C3-P: runtime post-switch smoke         ✅ CORE evaluates; TEMPORAL loads/refuses structurally
  S3-R7-C4-P: spec entrypoint sync              ✅ entrypoint/section are proposal candidates only
  S3-R7-C5-G: descriptor compatibility package  ✅ package descriptor mapping to report-only backend_check
  S3-R7-X1-S: runtime/typed pressure review     ✅ no hold; pre-Gate-3 proof gaps routed
Active PROPs:     PROP-028 + PROP-022A temporal errata; new syntax candidates require proposal tracks
Arch approval required for: gem publish, Ledger read/write, MCP/mesh
```

### Trusted Read Order

```text
1. igniter-lang/AGENTS.md
2. igniter-lang/roles/README.md
3. assigned role profile
4. igniter-lang/docs/agent-context.md
5. igniter-lang/docs/current-status.md
6. igniter-lang/docs/operating-model.md
7. assigned track/proposal/source files
8. relevant spec chapters only when the card touches language semantics
```

Do not reread archives, old tracks, package docs, or broad proof history unless
the card explicitly asks. `agent-context.md` is the trusted compact context
capsule; `current-status.md` is the fuller scoreboard.

### Current Horizon Diagram

```text
Source .ig
  -> Parser -> Classifier -> TypeChecker
  -> SemanticIREmitter.emit_typed(typed)        ✅ production path (S3-R5-C4)
  -> SemanticIR: CORE / STREAM / TEMPORAL nodes ✅ temporal_input/access proven
  -> Assembler .igapp
       manifest.fragment_summary               ✅ S3-R5-C1
       manifest.contract_index                 ✅ S3-R5-C1
       requirements from escape_boundaries      ✅ S3-R4-C3
       compatibility_metadata guard_policy      ✅ S3-R5-C2
  -> RuntimeMachine
       load TEMPORAL for inspection             ✅ proof-local + report shape
       CompatibilityReport load/eval split      ✅ S3-R7-C1
       evaluate TEMPORAL                        🚫 refused until runtime executor/TBackend
       memoize TEMPORAL                         🚫 proof-local only, no production cache
  -> Ledger / TBackend
       descriptor metadata                      ✅ Gate 2 ratify recommended
       descriptor report mapping                ✅ report-only; runtime_enforced=false
       live reads/writes/replay                 🚫 Gate 3 closed
  -> Release
       release-gate + artifact/checksum         ✅ PASS
       RubyGems publish                         🚫 approval/MFA required
```

### Stage 3 Inherited State

```text
IgniterLang::VERSION: 0.1.0.pre.stage2
Compiler pipeline:   Parser → Classifier → TypeChecker → SemanticIREmitter.emit_typed → Assembler
emit_typed:          ✅ wired in CompilerOrchestrator production path
parsed emitter:      retained as Stage 1 legacy/internal comparison path
typed emission path: BiHistory source gate closed; production switch done; Stage 1/2 close candidates PASS
invariant_valid delta: accepted/discharged ✅ typed path adds invariant nodes + coverage as public production shape
Ledger descriptor:   metadata-only ✅ package specs PASS
CompatibilityReport: load/evaluate split + descriptor mapping ✅; report-only metadata; runtime_enforced false
Runtime observations: proof-backed ⏳ production persistence open
Temporal cache key:  proof + runtime contract + proof-local memoization ✅; production memoization not implemented
TEMPORAL lowering:   classifier/typechecker/SemanticIR/assembler manifest ✅; runtime evaluate refused by guard
Release gate:        bin/release-gate ✅ PASS; local artifact + checksum rebuilt; publish.status=not_attempted
Gate 2 descriptor:   ratification recommended ✅; Gate 3 production binding closed
Stage 2 close:       PASS (stage2_close_candidate.json)
Stage 1 regression:  PASS
Archive:             Stage 2 close snapshot ✅ docs/archive/snapshots/2026-05-07-stage2-close/
АИ/СОИ lens:         soft Stage 3 governance/review vocabulary; not a hard gate
Syntax pressure:     registry + specimens + review routing done; threshold/external pure/entrypoint-section are proposal candidates, not parser canon
Discussion pressure: S3-R4-X1 resolved to contract_index/load-guard tracks; both landed in R5
Runtime pressure:    S3-R7-X1 says no current production bug; expand smoke/report boundary before Gate 3
```

### Spec Freshness

| Surface | Freshness | Current anchor | Remaining doc debt |
|---------|-----------|----------------|--------------------|
| Agent context | ✅ current S3-R7 | `docs/agent-context.md` | Keep next movement in sync after each status round |
| Ch4 Fragment Classification | ✅ synced S3-R6 | `spec-ch4-temporal-fragment-sync-v0` | Parser coordinate syntax remains proposal/runtime work, not spec-lag |
| Ch5 Compiler Pipeline | ✅ synced S3-R6 + R7 discharge | `spec-ch5-emit-typed-sync-v0`; `invariant-typed-shape-discharge-v0` | C-8 invariant typed-shape delta discharged; remaining legacy deltas are not production blockers |
| Ch6 SemanticIR / .igapp | ✅ synced S3-R6 | `spec-ch6-semanticir-temporal-sync-v0` | Future runtime executor/Gate 3 changes will need another sync |
| Ch7 Runtime | ✅ synced S3-R6 + R7 report/smoke | `spec-ch7-runtime-temporal-cache-sync-v0`; `runtime-compatibility-report-temporal-load-check-v0`; `runtime-smoke-temporal-post-switch-v0` | TBackend/live temporal executor remains closed; full post-switch surface smoke and executor-boundary case routed before Gate 3 |
| Proposal index | ✅ synced S3-R6 | `proposal-lifecycle-index-sync-v0` | PROP-028/022A close awaits parser syntax/runtime decision |
| Stale parity/cache tracks | ✅ marked S3-R6 | `parity-track-stale-header-sweep-v0` | Archive move optional later, no current blocker |
| Entrypoint/section syntax | ✅ disposition set S3-R7 | `spec-entrypoint-sync-v0` | Stage 3 proposal candidate; future PROP-029-style track needed before parser/canon |

### Remaining Doc Debt Only

```text
DOC-DEBT-01  Update agent-context.md next movement after each status round.
DOC-DEBT-02  Keep S3-R7 runtime pressure gaps visible until routed:
             full post-switch smoke, executor-boundary case, C1/C3 cross-check.
DOC-DEBT-03  Keep entrypoint/section as proposal-candidate only until a PROP is accepted.
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
PROP-022A  .igapp assembler contract     Stage 1 frozen; TEMPORAL errata + manifest index landed
PROP-023   stream T                      ✅ CLOSED IN STAGE 2 (all OOF + SemanticIR)
PROP-023A  ClassifiedExpr boundary       Stage 1 frozen (accepted/)
PROP-024   OLAPPoint[T,Dims]             ✅ CLOSED IN STAGE 2 (parser + TC + SemanticIR)
PROP-025   Invariant severity            ✅ CLOSED IN STAGE 2 (partial: OOF-I1/I3/I5 deferred)
PROP-026   Parser OOF hardening          ✅ CLOSED IN STAGE 2
PROP-027   Production compiler           ✅ CLOSED IN STAGE 2 (package + facade + igc)
PROP-028   TEMPORAL fragment class       ⚙️ proposal + classifier/typechecker + SemanticIR + assembler
                                         manifest/load guard/cache proof done; runtime executor/parser pending
PROP-029+  Stage 3 syntax candidates     queued by pressure review; not canon without proposal/proof
```

→ Close governance: `meta-proposals/META-EXPERT-009.1-stage2-close-decision-v0.md`
→ Stage 1 governance: `meta-proposals/META-EXPERT-007-stage1-close-governance-v0.md`
