# Igniter-Lang Current Status

Stage 1: **CLOSED** (2026-05-06) — META-EXPERT-007
Stage 2: **CLOSED** (2026-05-07) — META-EXPERT-009.1
Stage 3: **OPEN** (2026-05-08) — META-EXPERT-011
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-09
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
TBackend          ✅ gate2   descriptor package exposure ratified;
                            package descriptor consumed into report-only CompatibilityReport;
                            Gate 2 record landed; Gate 3 approved-restricted Phase 1;
                            Ledger/BiHistory/Phase 2 closed
Runtime           ⏳ open   six-surface post-switch smoke PASS;
                            ExecutorApprovalToken report + guarded enforcement PASS;
                            Gate 3 Phase 1 implementation authorized;
                            R15 pre-live blocker closure PASS;
                            lib-prep may proceed; live reads still blocked
Language          ⚙️ partial TEMPORAL through .igapp manifest index + load guard;
                            parser coordinate syntax and production runtime remain open
                            PROP-029 entrypoint/section drafted; parser proof still open
Compiler Internals ✅ switched CompilerOrchestrator now uses emit_typed(typed);
                            invariant typed-shape delta accepted/discharged;
                            invariant source metadata preserved;
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
Round 8 landed:
  S3-R8-C1-P: runtime full coverage smoke       ✅ all 6 emit_typed surfaces covered; C1/C3 cross-check
  S3-R8-C2-P: executor boundary report          ✅ positive executor flags still blocked without approval/Gate3
  S3-R8-C3-G: descriptor Gate 2 decision        ✅ ratify recommended; Architect decision still needed
  S3-R8-C4-P: PROP-029 entrypoint/section       ✅ proposal drafted; no parser implementation
Round 9 landed:
  S3-R9-C1-G: descriptor Gate 2 record          ✅ ratified; metadata-only; Gate 3 closed
  S3-R9-C2-P: PROP-030 approval token           ✅ proposal drafted; Gate 3 prerequisite, not auth
  S3-R9-C3-P: executor cache-key contract       ✅ TEMPORAL keys required; CORE-shaped keys refused
  S3-R9-C4-P: guarded runtime consistency       ✅ C2 profiles blocked in report and runtime guard
  S3-R9-C5-P: stream replay metadata            ✅ stream_nodes emitted; smoke uses assembled metadata
Round 10 landed:
  S3-R10-C1-P: approval token report proof      ✅ PROP-030 validation matrix; valid token still Gate3-blocked
  S3-R10-C2-P: guarded approval enforcement     ✅ guard refuses missing token/Gate3 closed/bad cache key
  S3-R10-C3-P: package descriptor consumption   ✅ ratified metadata consumed as report-only backend_check
  S3-R10-C4-P: invariant source metadata        ✅ parser→SemanticIR preserves descriptive source metadata
Round 11 landed:
  S3-R11-C1-G: Gate 3 opening request           ⚠️ drafted; superseded by R12 revision/R13 decision
  S3-R11-C2-P: Gate 3 acceptance matrix         ✅ prerequisite matrix extracted; no live auth
  S3-R11-C3-G: Ledger/TBackend scope            ✅ recommend History[T] valid_time only; BiHistory excluded
  S3-R11-C4-P: spec consistency check           ✅ request shape coherent; no parser/syntax auth
  S3-R11-X1-S: Gate 3 request safety pressure   ⚠️ HOLD for two edits before Architect review
Round 12 landed:
  S3-R12-C1-S: Gate 3 request revision          ✅ HOLD fixed; routed to R13 Architect decision
  S3-R12-C2-P: request revision spec review     ✅ no semantic/spec blocker; superseded by R13 decision
  S3-R12-C3-P: Gate 3 proof-chain index         ✅ regression commands indexed; no proof missing
  S3-R12-C4-P: TBackend adapter phase plan      ✅ Phase 1 non-Ledger; Phase 2 addendum
  S3-R12-X1-S: revision safety pressure         ✅ PROCEED to Architect review; superseded by R13 decision
Round 13 landed:
  S3-R13-C1-A: Gate 3 decision record           ✅ approved-restricted-phase1; live reads blocked
  S3-R13-C2-P: PROP-030A scope exclusion        ✅ canonical runtime.temporal_scope_exclusion
  S3-R13-C3-P: temporal read observation        ✅ minimum AT-10 envelope + proof PASS
  S3-R13-C4-P: CompatibilityReport composition ✅ single composed report proof PASS
  S3-R13-X1-S: decision safety pressure         ✅ PROCEED; no hidden auth leaks
Round 14 landed:
  S3-R14-C1-A: Phase 1 authority amendment      ✅ authority URI constant + revocation paths recorded
  S3-R14-C2-P: Phase1TemporalExecutor preflight ✅ proof-local 9/9; initial gaps closed in R15
  S3-R14-C3-P: scope exclusion runtime fixture  ✅ 7 excluded surfaces refuse before live paths
  S3-R14-C4-P: report enforcement preflight     ✅ composed-report guard proof; ordering fixed in R15
  S3-R14-C5-P: spec Ch7 Gate 3 sync             ✅ approved-restricted/pre-live semantics synced
  S3-R14-X1-S: Phase 1 prep safety pressure     ✅ PROCEED for proof-local; no live-eval leak
  S3-R14-C7/C8: truth-system syntax pressure    ✅ non-canon pressure only; no parser/runtime auth
  S3-R14-C9/C10: general-purpose pressure       ✅ HTTP/knowledge/legal + emergency/marketplace pressure; no canon
Round 15 landed:
  S3-R15-C1-P: report order amendment           ✅ token-before-gate fixed; no PROP-030 errata
  S3-R15-C2-P: composition integration          ✅ AT-2 closed; composed report consumed
  S3-R15-C3-P: authority_ref proof              ✅ AT-9 proof-local PASS; exact decision URI match
  S3-R15-C4-P: pre-live regression chain        ✅ 17/17 PASS; lib-prep allowed next
Active PROPs:     PROP-028 + PROP-022A temporal errata + PROP-029 entrypoint/section
                  + PROP-030 executor approval token + PROP-030A scope exclusion;
                  other syntax candidates require proposal tracks
Arch approval required for: Gate 3 Phase 2 Ledger adapter, BiHistory, stream/OLAP,
                            production cache, gem publish, Ledger write, MCP/mesh
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
       package descriptor backend_check         ✅ report-only; S3-R10-C3
       six-surface post-switch smoke            ✅ S3-R8-C1
       executor/live-binding positive flags     ✅ modeled; still blocked
       ExecutorApprovalToken proposal           ✅ S3-R9-C2; prerequisite only
       ExecutorApprovalToken report matrix      ✅ S3-R10-C1; report-only
       executor cache-key boundary              ✅ S3-R9-C3; TEMPORAL key or L-T5 refusal
       guarded runtime C2 consistency           ✅ S3-R9-C4; mapped refusal
       guarded approval enforcement             ✅ S3-R10-C2; proof-local refusal
       Gate 3 decision                          ✅ approved-restricted Phase 1 implementation
       CompatibilityReport composition          ✅ S3-R13-C4 proof-local composed shape
       temporal_read_observation envelope       ✅ S3-R13-C3 proof-local envelope
       temporal_scope_exclusion code            ✅ PROP-030A
       Phase1TemporalExecutor preflight         ✅ proof-local 9/9; experiments-local only
       runtime report enforcement preflight     ✅ proof-local guard matrix; order amended in R15
       scope-exclusion runtime fixture          ✅ CORE/STREAM/OLAP/BiHistory/Ledger/unknown refused
       Ch7 Gate 3 approval sync                 ✅ spec lag closed for approved-restricted semantics
       report preflight ordering                ✅ S3-R15 token-before-gate fixed
       AT-2 composed report integration         ✅ S3-R15 executor consumes CompatibilityReport
       AT-9 authority_ref exact match           ✅ S3-R15 proof-local decision URI validation
       pre-live regression chain                ✅ 17/17 PASS; lib-prep may proceed
       evaluate TEMPORAL Phase 1 live           🚫 still blocked until lib-prep proves boundary
       memoize TEMPORAL                         🚫 proof-local only, no production cache
  -> Ledger / TBackend
       descriptor metadata                      ✅ Gate 2 ratified
       descriptor report mapping                ✅ report-only; runtime_enforced=false
       Gate 2 ratification record               ✅ ratified; metadata-only
       Phase 1 abstract non-Ledger adapter      ✅ implementation authorized
       Ledger adapter / package binding         🚫 Phase 2 addendum required
       live Ledger reads/writes/replay          🚫 closed
  -> Stream replay
       stream_nodes metadata                    ✅ emitted in SemanticIR/.igapp
       production stream executor               🚫 not authorized
  -> Invariant metadata
       source_metadata/source_span              ✅ preserved parser -> SemanticIR/report
       runtime persistence                      🚫 still open
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
Package descriptor:  ratified Gate 2 metadata consumed into CompatibilityReport ✅; report-only, no live binding
Executor boundary:   positive executor/live-binding flags modeled ✅; Phase 1 approval restricted; live/Phase2 gates still required
Gate 3 prerequisites: Gate 2 ratified ✅; PROP-030 drafted ✅; token report proof ✅; guarded enforcement ✅; cache-key proof ✅
Gate 3 decision:     approved-restricted-phase1 ✅; implementation-prep may continue; live reads blocked
Pre-live closed:      composition track ✅; observation track ✅; scope errata ✅; scope fixture ✅; authority URI wording ✅; Ch7 sync ✅;
                      ordering fixed ✅; AT-2 closed ✅; AT-9 proof-local exact URI match ✅; regression 17/17 PASS ✅
Pre-live remaining:   lib-prep must prove the same boundary in prepared code; production signing/registry/persistence remain later gaps
Runtime observations: proof-backed ⏳ production persistence open
Temporal cache key:  proof + runtime contract + proof-local memoization ✅; production memoization not implemented
TEMPORAL lowering:   classifier/typechecker/SemanticIR/assembler manifest ✅; runtime evaluate refused by guard
Release gate:        bin/release-gate ✅ PASS; local artifact + checksum rebuilt; publish.status=not_attempted
Gate 2 descriptor:   ratified ✅; report metadata only; Gate 3 Phase 2 production binding closed
Stage 2 close:       PASS (stage2_close_candidate.json)
Stage 1 regression:  PASS
Archive:             Stage 2 close snapshot ✅ docs/archive/snapshots/2026-05-07-stage2-close/
Docs memory:         S3-R7 docs snapshot ✅ + value-index hoisted memory layer ✅
АИ/СОИ lens:         soft Stage 3 governance/review vocabulary; not a hard gate
Syntax pressure:     registry + specimens + review routing done; threshold/external pure/entrypoint-section are proposal candidates, not parser canon
General-purpose pressure:
                      S3-R14 C9/C10 added HTTP/JSON, agent knowledge, legal OSINT,
                      emergency mesh, self-modification, and marketplace pressure;
                      all are non-canon/product pressure, no parser/runtime authorization
Discussion pressure: S3-R4-X1 resolved to contract_index/load-guard tracks; both landed in R5
Runtime pressure:    S3-R7-X1 says no current production bug; smoke/report boundary expanded before Gate 3 decision
S3-R8 runtime result: full smoke + executor-boundary report closed the named pre-Gate-3 pressure gaps;
                      decision was still closed at R8
S3-R9 package:        Gate 3 prerequisites landed as proposal/proofs/metadata; decision still closed at R9
S3-R10 result:        package descriptor consumption + approval-token report/runtime proofs landed; decision still closed at R10
S3-R11 result:        restricted Gate 3 request package drafted; X1 held routing until request revision
S3-R12 result:        Gate 3 request revision fixed HOLD blockers; X1 routed to Architect review
S3-R13 result:        Architect approved restricted Gate 3 Phase 1 implementation; X1 found no auth leaks;
                      live reads remain blocked until implementation/pre-live/regression pass
S3-R14 result:        Phase 1 proof-local implementation-prep landed; X1 found no live-eval/Ledger/BiHistory/cache leak;
                      live reads remain blocked until AT-2/AT-9/order gaps and regression pass;
                      C7-C10 pressure slices landed as non-canon product/syntax pressure
S3-R15 result:        ordering fixed; AT-2 closed; AT-9 proof-local PASS; regression chain 17/17 PASS;
                      runtime-temporal-executor-lib-prep-v0 may proceed, still not live-read authorization
```

### Spec Freshness

| Surface | Freshness | Current anchor | Remaining doc debt |
|---------|-----------|----------------|--------------------|
| Agent context | ✅ current S3-R15 | `docs/agent-context.md` | Keep next movement in sync after each status round |
| Value index | ✅ introduced docs micro-round | `docs/value-index.md`; `docs-value-hoisting-micro-round-v0` | Update sparingly when ideas should remain visible beyond one round |
| Ch4 Fragment Classification | ✅ synced S3-R6 | `spec-ch4-temporal-fragment-sync-v0` | Parser coordinate syntax remains proposal/runtime work, not spec-lag |
| Ch5 Compiler Pipeline | ✅ synced S3-R6 + R10 metadata | `spec-ch5-emit-typed-sync-v0`; `invariant-typed-shape-discharge-v0`; `invariant-source-metadata-preservation-v0` | Invariant source metadata preservation landed; Ch6 doc sync remains |
| Ch6 SemanticIR / .igapp | ✅ synced S3-R9 stream metadata + R10 invariant evidence | `spec-ch6-semanticir-temporal-sync-v0`; `stream-replay-metadata-emission-v0`; `invariant-source-metadata-preservation-v0` | Future Ch6 sync should document optional invariant source_metadata/source_span |
| Ch7 Runtime | ✅ synced + R15 pre-live proof green | `spec-ch7-runtime-temporal-cache-sync-v0`; `executor-approval-token-report-proof-v0`; `guarded-runtime-executor-approval-enforcement-v0`; `compatibility-report-package-descriptor-consumption-v0`; `docs/gates/gate3-decision-record-v0.md`; `PROP-030A-temporal-scope-exclusion-errata-v0.md`; `spec-ch7-gate3-approval-sync-v0`; `runtime-temporal-executor-composition-integration-v0`; `executor-approval-authority-ref-proof-v0`; `phase1-prelive-regression-chain-v0` | Phase 1 lib-prep may proceed; live reads still blocked until prepared boundary proves same constraints |
| Proposal index | ✅ synced S3-R9 | `proposal-lifecycle-index-sync-v0`; `PROP-029-entrypoint-section-surface-v0`; `PROP-030-executor-approval-token-contract-v0` | PROP-028/022A close awaits parser syntax/runtime decision; PROP-029/030 are proposal-only |
| Stale parity/cache tracks | ✅ marked S3-R6 | `parity-track-stale-header-sweep-v0` | Archive move optional later, no current blocker |
| Entrypoint/section syntax | ✅ PROP drafted S3-R8 | `PROP-029-entrypoint-section-surface-v0`; `spec-entrypoint-sync-v0` | Proposal-only; parser/typechecker proof needed before canon |

### Remaining Doc Debt Only

```text
DOC-DEBT-01  Update agent-context.md next movement after each status round.
DOC-DEBT-02  Keep S3-R10 runtime follow-ups visible:
             production RuntimeMachine report enforcement/preflight,
             production token authority/revocation, CompatibilityReport persistence/audit.
DOC-DEBT-03  Keep Gate 2/Gate 3 boundary visible after Gate 2 ratification:
             descriptor metadata is not runtime authority.
DOC-DEBT-04  Keep PROP-029 proposal-only until parser/typechecker proof acceptance.
DOC-DEBT-05  Sync Ch6 for optional invariant source_metadata/source_span.
DOC-DEBT-06  Keep value-index.md compact; hoist durable signals, not routine evidence.
DOC-DEBT-07  Gate 3 decision is approved-restricted-phase1:
             Phase 1 implementation may begin; live reads are blocked until
             AT-1..AT-12 implementation and S3-R7..R10 regression proof chain pass.
DOC-DEBT-08  S3-R14 proof-local Phase 1 prep landed:
             scope fixture, report preflight, executor preflight, Ch7 sync,
             and authority URI wording are current.
DOC-DEBT-09  S3-R15 pre-live blocker closure landed:
             C4 ordering fixed to token-before-gate; AT-2 closed by composed
             report integration; AT-9 proof-local exact URI match PASS;
             regression chain 17/17 PASS.
DOC-DEBT-10  Phase 2 remains closed:
             real Ledger adapter needs explicit Architect addendum and authority
             registry / revocation / addendum process definition.
DOC-DEBT-11  General-purpose pressure is pressure-only:
             HTTP/JSON, agent knowledge, legal OSINT, emergency replication,
             self-modification, and marketplace escrow need proposals/fixtures
             before syntax, runtime, or product claims.
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
PROP-029   Entrypoint/section surface    proposal; parser/typechecker proof pending
PROP-030   Executor approval token       proposal; Gate 3 prerequisite + Phase 1 authority check
PROP-030A  TEMPORAL scope exclusion      proposal; runtime.temporal_scope_exclusion
PROP-031+  Stage 3 candidates            queued by pressure review; not canon without proposal/proof
```

→ Close governance: `meta-proposals/META-EXPERT-009.1-stage2-close-decision-v0.md`
→ Stage 1 governance: `meta-proposals/META-EXPERT-007-stage1-close-governance-v0.md`
