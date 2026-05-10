# Igniter-Lang Current Status

Stage 1: **CLOSED** (2026-05-06) — META-EXPERT-007
Stage 2: **CLOSED** (2026-05-07) — META-EXPERT-009.1
Stage 3: **OPEN** (2026-05-08) — META-EXPERT-011
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-10
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
                            R16 lib-prep C1 landed/PASS;
                            R17 post-C1 repair PASS + safety PROCEED;
                            R18 cleanup tracks done;
                            R19 pre-signing repair PASS;
                            R20 addendum signed for restricted Phase 1 live-read scope;
                            post-signature fixture PASS;
                            R21 audit-ready envelope + registry shape PASS;
                            R22 end-to-end invocation + content-addressed addendum ref PASS;
                            R23 proof-local persistence/registry receipts/alias signal PASS;
                            R24 post-R23 regression 23/23 PASS;
                            proof-local registry storage semantics + tamper-evidence PASS;
                            production durable audit/registry ownership/signing still closed
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
  S3-R13-C1-A: Gate 3 decision record           ✅ approved-restricted-phase1; pre-live at R13 close
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
Round 16 landed:
  S3-R16-C1-P: runtime executor lib-prep        ✅ lib/ Phase1 boundary PASS 17/17; live blocked by default
  S3-R16-C2-P: lib-prep regression chain        ⚠️ stale-blocked; superseded by R17 rerun
  S3-R16-C3-P: lib boundary spec sync           ⚠️ stale no-op; superseded by R17 spec-sync rerun
Round 17 landed:
  S3-R17-C1-P: post-C1 regression rerun         ✅ 14/14 PASS; safety pressure may proceed
  S3-R17-C2-P: lib boundary spec sync rerun     ✅ Ch7 names Phase1 as proof-local boundary; no new semantics
  S3-R17-X1-S: lib-prep safety pressure         ✅ PROCEED for proof-local Phase 1; pre-production items routed
Round 18 landed:
  S3-R18-C1-A: live-read addendum draft         ⚠️ draft-not-signed; superseded by R19 ready-review state
  S3-R18-C2-P: proof-local docstrings           ✅ GATE3_AUTHORITY_REF/observations/gate3_authorized warnings landed
  S3-R18-C3-P: scope-exclusion reason alias     ✅ canonical runtime.temporal_scope_exclusion emitted; legacy aliases retained
  S3-R18-C4-P: backend identity guard           ✅ code-level guard + proof fixture PASS; Ledger/proxy/unmarked blocked
  S3-R18-X1-S: addendum draft safety pressure   ⚠️ PROCEED for cleanup; two pre-signing conditions remain
Round 19 landed:
  S3-R19-C1-P: R18 cleanup regression rerun     ✅ 15/15 PASS; backend_identity observation asserted
  S3-R19-X1-S: addendum pre-signature pressure  ✅ PROCEED to Architect signature review
Round 20 landed:
  S3-R20-C1-A: live-read addendum signature     ✅ signed-approved-restricted-phase1-live-read
  S3-R20-C2-P: first post-signature fixture     ✅ PASS 10/10; policy-only change; executor unchanged
  S3-R20-X1-S: post-signature runtime pressure  ✅ PROCEED; no scope widening; low notes routed
Round 21 landed:
  S3-R21-C1-P: compatibility audit envelope     ✅ PASS 10/10; audit-ready, not persisted
  S3-R21-C2-P: authority registry shape         ✅ PASS 11/11; proof-local metadata, no signing/keys
  S3-R21-X1-S: audit/registry pressure          ✅ PROCEED; production checklist P-1..P-7 routed
Round 22 landed:
  S3-R22-C1-P: Phase 1 end-to-end invocation    ✅ PASS 9/9; registry→executor→audit proof-local
  S3-R22-C2-P: content-address addendum ref     ✅ PASS 9/9; path-only evidence non-compliant
  S3-R22-X1-S: e2e/content-address pressure     ✅ PROCEED; P-4/P-5 closed, P-8 added
Round 23 landed:
  S3-R23-C1-P: durable observation persistence shape ✅ PASS 9/9; proof-local JSONL only
  S3-R23-C2-P: registry v1 receipts shape       ✅ PASS 11/11; issuance→revocation→supersession
  S3-R23-C3-P: legacy alias deprecation signal  ✅ PASS 21/21; lib-prep 17/17 unaffected
  S3-R23-X1-S: audit/registry v1 pressure       ✅ PROCEED; non-blockers only; P-8/P-9 routed
Round 24 landed:
  S3-R24-C1-P: post-R23 regression rerun        ✅ PASS 23/23; no production auth
  S3-R24-C2-P: durable registry storage semantics ✅ PASS 10/10; proof-local, no signing/Ledger/executor
  S3-R24-C3-P: observation tamper-evidence shape ✅ PASS 23/23; SHA256 chain, not production audit
  S3-R24-X1-S: regression/durability pressure   ✅ PROCEED; non-blockers only; P-8/P-9 closed
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
       pre-live regression chain                ✅ 17/17 PASS; R15 allowed C1
       runtime temporal executor lib-prep       ✅ S3-R16 C1 lib/ Phase1 PASS 17/17
       post-C1 lib-prep regression rerun        ✅ S3-R17 C1 14/14 PASS
       lib boundary spec sync                   ✅ S3-R17 C2 Ch7 proof-local boundary sync
       lib-prep safety pressure                 ✅ S3-R17 X1 PROCEED for proof-local Phase 1
       R18 live-read addendum draft             ⚠️ superseded by R20 signed status
       proof-local docstring warnings           ✅ S3-R18 C2 landed
       scope-exclusion reason aliases           ✅ S3-R18 C3 canonicalized
       backend identity guard                   ✅ S3-R18 C4 PASS; blocks Ledger/proxy/unmarked backends
       R18 cleanup regression rerun             ✅ S3-R19 C1 15/15 PASS
       addendum pre-signature pressure          ✅ S3-R19 X1 PROCEED to Architect signature review
       signed live-read addendum                ✅ S3-R20 C1 signed-approved-restricted-phase1-live-read
       post-signature fixture                   ✅ S3-R20 C2 PASS 10/10; executor behavior unchanged
       post-signature runtime pressure          ✅ S3-R20 X1 PROCEED; no widened surface
       evaluate TEMPORAL Phase 1 live           ✅ authorized only for signed addendum scope:
                                                   History[T] valid_time, explicit as_of,
                                                   MemoryBackend or explicit non-Ledger Phase 1 backend
       audit-ready envelope                     ✅ S3-R21 C1 PASS; explicit export, not persisted
       proof-local authority registry shape     ✅ S3-R21 C2 PASS; caller policy metadata, no signing/keys
       audit/registry pressure                  ✅ S3-R21 X1 PROCEED; production gaps routed
       Phase 1 end-to-end invocation            ✅ S3-R22 C1 PASS 9/9; registry -> executor -> audit
       content-addressed addendum reference     ✅ S3-R22 C2 PASS 9/9; path-only evidence blocked
       e2e/content-address pressure             ✅ S3-R22 X1 PROCEED; P-4/P-5 closed, P-8 routed
       proof-local observation persistence      ✅ S3-R23 C1 PASS 9/9; JSONL only, not prod audit
       registry v1 transition receipts          ✅ S3-R23 C2 PASS 11/11; no signing/keys/executor
       legacy alias deprecation signal          ✅ S3-R23 C3 PASS 21/21; removal deferred to Phase 2
       audit/registry v1 pressure               ✅ S3-R23 X1 PROCEED; non-blockers only
       post-R23 regression rerun                 ✅ S3-R24 C1 PASS 23/23; R24 fixtures not yet in matrix
       durable registry storage semantics        ✅ S3-R24 C2 PASS 10/10; proof-local query/receipt semantics
       observation tamper-evidence shape         ✅ S3-R24 C3 PASS 23/23; content-integrity chain only
       post-R23 durability pressure              ✅ S3-R24 X1 PROCEED; high risks closed, low items routed
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
Gate 3 decision:     approved-restricted-phase1 ✅; R20 signed addendum authorizes restricted Phase 1 live reads only
                     inside the signed addendum scope; all excluded surfaces remain closed
Pre-live closed:      composition track ✅; observation track ✅; scope errata ✅; scope fixture ✅; authority URI wording ✅; Ch7 sync ✅;
                      ordering fixed ✅; AT-2 closed ✅; AT-9 proof-local exact URI match ✅; regression 17/17 PASS ✅;
                      R16 C1 lib-prep boundary PASS 17/17 ✅; post-C1 regression rerun 14/14 PASS ✅;
                      Ch7 lib-boundary sync rerun ✅; lib-prep safety pressure PROCEED ✅;
                      proof-local docstrings ✅; reason-code aliases ✅; backend identity guard ✅
Live-read addendum:  signed-approved-restricted-phase1-live-read ✅; caller may pass `gate3_authorized: true`
                     only with signed-addendum invocation evidence and only inside the restricted Phase 1 scope.
                     Executor behavior unchanged; Phase1 does not self-authorize.
Audit envelope:      proof-local audit-ready export ✅; explicit envelope over observation, CompatibilityReport ref,
                     authority_ref, signed_addendum_ref, backend_identity, and result reason; not automatic persistence,
                     not durable audit, not production storage, not Ledger write.
Authority registry: proof-local registry shape ✅; caller-side policy check before `gate3_authorized: true`;
                     active/revoked/superseded/missing/scope/capability/malformed cases PASS; no executor call,
                     no production signing, no keys, no production authority service.
End-to-end proof:   proof-local Phase 1 invocation ✅; active registry -> caller authorization ->
                     Phase1 executor -> explicit audit-ready envelope. MemoryBackend and explicit non-Ledger paths pass;
                     revoked registry and missing signed addendum evidence block before executor; Ledger-like backend
                     blocks before read; no production storage/signing/Ledger/durable audit.
Addendum reference: content-addressed proof-local reference ✅; signed addendum evidence carries human path plus
                     `git_commit`, `content_sha256`, status, signed date, and authority_ref. Hash mismatch,
                     unsigned status, and authority mismatch are non-compliant. Current proof permits
                     `git_commit: workspace-current`; real commit SHA remains pre-production.
Observation persistence:
                     proof-local file-backed JSONL shape ✅; `phase1_observation_persistence_record` appends only
                     allowed Phase 1 observation records and carries `production_durable_audit: false`,
                     `production_compliance_claim: false`, and `ledger: false`.
Observation tamper evidence:
                     proof-local SHA256 canonical JSON chain ✅; records carry sequence, previous_record_hash,
                     record_hash, storage_identity, and created_at. This is content-integrity/gap/reorder shape
                     only: not cryptographic authorization, not production durable audit, not production signing,
                     and chain state is not rebuilt from JSONL on restart.
Registry receipts:  proof-local registry v1 receipts shape ✅; issuance -> revocation -> supersession receipts
                     are linked by `caused_by_ref`; decision refs must be content-addressed; no production signing,
                     no keys, no durable registry service, no executor call.
Registry storage semantics:
                     proof-local durable/queryable registry semantics ✅; storage identity, query by authority_ref,
                     effective-time active/revoked/superseded lookup, receipt-chain verification, and
                     content-addressed decision-ref verification are proven. Direct active -> superseded is blocked
                     in v0; production registry ownership/signing/key management remain open.
Reason codes:       LEGACY_ALIASES deprecation signal ✅; lib/ executor emits canonical
                     `runtime.temporal_scope_exclusion`; sealed old fixtures are not retroactively edited;
                     alias removal remains Phase 2 housekeeping.
Pre-signing remaining:
                      none for restricted Phase 1 live-read addendum; closed by S3-R20-C1-A.
Pre-production remaining:
                      production durable audit with HSM/KMS signing, restart rebuild, retention/replay semantics,
                      version enforcement, off-process persistence, and compliance language; production registry
                      ownership/service; production signing/key management; real commit SHA / no
                      `workspace-current`; next regression matrix expansion to 25 commands; Phase 2 addendum gaps
Runtime observations: proof-backed ✅ proof-local file persistence + tamper-evidence shape; production durable audit still open
Temporal cache key:  proof + runtime contract + proof-local memoization ✅; production memoization not implemented
TEMPORAL lowering:   classifier/typechecker/SemanticIR/assembler manifest ✅; restricted Phase 1 eval now signed-scope only
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
                      at R13 close, live reads were blocked pending implementation/pre-live/regression pass
S3-R14 result:        Phase 1 proof-local implementation-prep landed; X1 found no live-eval/Ledger/BiHistory/cache leak;
                      at R14 close, live reads were blocked pending AT-2/AT-9/order gaps and regression pass;
                      C7-C10 pressure slices landed as non-canon product/syntax pressure
S3-R15 result:        ordering fixed; AT-2 closed; AT-9 proof-local PASS; regression chain 17/17 PASS;
                      runtime-temporal-executor-lib-prep-v0 may proceed, still not live-read authorization
S3-R16 result:        lib/ Phase1 executor boundary landed and proves AT-2/4/5/6/7/9/10/12 plus blocked-before-call 17/17 PASS;
                      C2/C3 were stale-blocked records from before C1 landed and are now superseded by R17 repair;
                      no R16 lib-prep safety-pressure verdict existed; live reads remained blocked at R16 close
S3-R17 result:        post-C1 repair closed the R16 async-order gap: regression rerun 14/14 PASS, Ch7 spec sync rerun done,
                      X1 safety pressure PROCEED for proof-local Phase 1. At R17 close, live-read addendum could be
                      drafted as an Architect route; R20 later signed the restricted Phase 1 addendum.
S3-R18 result:        addendum drafted with status draft-not-signed; proof-local docstrings, canonical reason aliasing,
                      and backend identity guard landed. X1 said cleanup tracks PROCEED and routed two pre-signing
                      conditions; R19 supersedes those conditions as closed. Live reads were not authorized.
S3-R19 result:        pre-signing repair closed the R18 hold: post-R18 regression rerun PASS 15/15, backend_identity
                      observation assertion covered, and addendum guard order now matches implementation. X1 said PROCEED
                      to Architect signature review. At R19 close, blocker 6 remained; R20 later closed it by signature.
S3-R20 result:        Architect signed the live-read addendum as `signed-approved-restricted-phase1-live-read`.
                      Restricted Phase 1 non-proof reads are authorized only within the signed addendum scope:
                      History[T] valid_time, single explicit as_of, MemoryBackend or explicitly named non-Ledger
                      Phase 1 backend, no durable side effects, no production cache, no Ledger binding.
                      First post-signature fixture PASS 10/10 and X1 PROCEED confirm policy-only change,
                      unchanged guard order, no scope widening, and all excluded surfaces remain closed.
S3-R21 result:        Phase 1 audit/registry shaping landed without production promotion:
                      C1 PASS 10/10 defines an explicit audit-ready envelope with `audit_ready_not_persisted`,
                      no automatic persistence, no durable audit, no production storage, and no Ledger write.
                      C2 PASS 11/11 defines proof-local authority registry metadata checked before caller passes
                      `gate3_authorized: true`; no executor calls, signing, keys, or production authority service.
                      X1 PROCEED confirms no hidden Ledger/BiHistory/cache/stream/write path and routes
                      pre-production checklist P-1..P-7.
S3-R22 result:        End-to-end invocation and content-addressed addendum reference proofs landed without
                      production promotion. C1 PASS 9/9 composes registry check -> caller authorization ->
                      Phase1 executor -> audit-ready envelope; revoked registry and missing signed addendum evidence
                      block before executor, Ledger-like backend blocks before read, and export remains not persisted.
                      C2 PASS 9/9 makes path-only addendum evidence insufficient by requiring content_sha256,
                      git_commit, signed status/date, and authority_ref. X1 PROCEED closes P-4/P-5 and adds P-8:
                      post-R22 regression matrix rerun including R20-R22 fixtures.
S3-R23 result:        Phase 1 persistence/registry hardening landed without scope widening:
                      C1 PASS 9/9 defines proof-local file-backed JSONL observation persistence only, with explicit
                      `production_durable_audit: false`, `production_compliance_claim: false`, and `ledger: false`.
                      C2 PASS 11/11 defines registry v1 transition receipts for issuance -> revocation -> supersession,
                      content-addressed decision refs, with signing/keys/executor calls absent. C3 PASS 21/21
                      adds the LEGACY_ALIASES deprecation signal and proves lib/ emits only canonical
                      `runtime.temporal_scope_exclusion`; lib-prep regression remains 17/17 PASS. X1 says PROCEED
                      with non-blockers only and recommends R24 run `phase1-post-r23-regression-rerun-v0`.
S3-R24 result:        Post-R23 consolidation and durability shaping landed without scope widening:
                      C1 PASS 23/23 reruns the full post-R23 proof chain and grants no production implementation auth.
                      C2 PASS 10/10 defines proof-local durable/queryable registry storage semantics, including
                      authority_ref lookup, effective-time status, receipt-chain verification, and blocked direct
                      active -> superseded transition; no signing, Ledger, executor, package, or production service.
                      C3 PASS 23/23 adds proof-local observation tamper-evidence fields and SHA256 canonical hash chain;
                      it is content integrity only, not HSM/KMS signing, production durable audit, Ledger, or compliance.
                      X1 says PROCEED with non-blockers only: P-8 and P-9 are closed; next matrix should expand to
                      25 commands, and production durable audit / registry ownership need Architect scope.
```

### Spec Freshness

| Surface | Freshness | Current anchor | Remaining doc debt |
|---------|-----------|----------------|--------------------|
| Agent context | ✅ current S3-R22 | `docs/agent-context.md` | Keep next movement in sync after each status round |
| Value index | ✅ introduced docs micro-round | `docs/value-index.md`; `docs-value-hoisting-micro-round-v0` | Update sparingly when ideas should remain visible beyond one round |
| Ch4 Fragment Classification | ✅ synced S3-R6 | `spec-ch4-temporal-fragment-sync-v0` | Parser coordinate syntax remains proposal/runtime work, not spec-lag |
| Ch5 Compiler Pipeline | ✅ synced S3-R6 + R10 metadata | `spec-ch5-emit-typed-sync-v0`; `invariant-typed-shape-discharge-v0`; `invariant-source-metadata-preservation-v0` | Invariant source metadata preservation landed; Ch6 doc sync remains |
| Ch6 SemanticIR / .igapp | ✅ synced S3-R9 stream metadata + R10 invariant evidence | `spec-ch6-semanticir-temporal-sync-v0`; `stream-replay-metadata-emission-v0`; `invariant-source-metadata-preservation-v0` | Future Ch6 sync should document optional invariant source_metadata/source_span |
| Ch7 Runtime | ✅ synced through R17 lib boundary; R24 proof-local durability shapes | `spec-ch7-runtime-temporal-cache-sync-v0`; `executor-approval-token-report-proof-v0`; `guarded-runtime-executor-approval-enforcement-v0`; `compatibility-report-package-descriptor-consumption-v0`; `docs/gates/gate3-decision-record-v0.md`; `PROP-030A-temporal-scope-exclusion-errata-v0.md`; `spec-ch7-gate3-approval-sync-v0`; `runtime-temporal-executor-composition-integration-v0`; `executor-approval-authority-ref-proof-v0`; `phase1-prelive-regression-chain-v0`; `runtime-temporal-executor-lib-prep-v0`; `runtime-temporal-executor-lib-boundary-spec-sync-rerun-v0`; `gate3-first-post-signature-fixture-v0`; `compatibility-report-persistence-audit-v0`; `gate3-authority-registry-shape-v0`; `phase1-end-to-end-invocation-fixture-v0`; `phase1-addendum-content-address-ref-v0`; `phase1-durable-observation-persistence-shape-v0`; `gate3-authority-registry-v1-receipts-shape-v0`; `phase1-reason-code-legacy-aliases-deprecation-signal-v0`; `phase1-post-r23-regression-rerun-v0`; `phase1-durable-registry-storage-semantics-v0`; `phase1-observation-tamper-evidence-shape-v0` | R24 adds full post-R23 regression and proof-local registry storage/tamper-evidence shapes; production durable audit, production registry ownership/service, production signing/key management, and Phase 2 remain closed |
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
             Phase 1 implementation-prep and R18 cleanup were proof-local;
             R20 signed the restricted Phase 1 live-read addendum. Do not
             infer Phase 2/Ledger/cache/audit authorization from that signature.
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
DOC-DEBT-12  S3-R16 lib-prep C1 landed:
             lib/igniter_lang/temporal_executor.rb provides a proof-local
             Phase1 boundary; targeted proof PASS 17/17; R20 later signed the
             restricted Phase 1 live-read addendum.
DOC-DEBT-13  S3-R16 async-order repair:
             phase1-lib-prep-regression-chain-v0 and
             runtime-temporal-executor-lib-boundary-spec-sync-v0 were recorded
             before C1 landed; R17 superseded this with post-C1 regression,
             spec-sync rerun, and safety pressure.
DOC-DEBT-14  S3-R17 post-C1 repair landed:
             regression rerun 14/14 PASS; Ch7 lib-boundary sync rerun done;
             safety pressure PROCEED for proof-local Phase 1. R20 later signed
             the restricted addendum; production/Phase 2 enablement still
             requires separate Architect decision and routed safeguards.
DOC-DEBT-15  S3-R18 addendum/cleanup landed:
             addendum is drafted-not-signed; proof-local docstrings,
             reason-code aliasing, and backend identity guard are done.
             R19 closed post-R18 full regression rerun and addendum guard-order
             amendment. R20 supersedes this with signed restricted Phase 1 status.
DOC-DEBT-16  S3-R19 pre-signing repair landed:
             regression rerun 15/15 PASS; addendum guard order matches
             implementation; X1 says PROCEED to Architect signature review.
             R20 signing record cites 15/15 PASS and attributes guard-order
             amendment to S3-R18-X1 PS-2.
DOC-DEBT-17  S3-R20 signature landed:
             live-read addendum is signed-approved for restricted Phase 1 only;
             first post-signature fixture PASS 10/10 proves policy-only change
             and no executor drift. Keep Phase 2, Ledger, BiHistory, stream,
             OLAP, production cache, production signing/registry, and durable
             audit closed unless a separate Architect decision opens them.
DOC-DEBT-18  S3-R20 post-signature low notes:
             draft-vs-signed comparison currently depends on git history;
             `gate3_authorized` remains caller honor-system in Phase 1;
             next code-touching track should rerun an equivalent full chain.
DOC-DEBT-19  S3-R21 audit/registry shaping landed:
             compatibility audit envelope is `audit_ready_not_persisted`;
             registry shape is proof-local caller policy metadata. Do not mark
             production durable audit, production storage, production registry,
             production signing, or key management as done.
DOC-DEBT-20  S3-R21 pre-production checklist:
             durable-observation-persistence-v0; content-addressed
             signed_addendum_ref; phase1-end-to-end-invocation-fixture-v0;
             gate3-authority-registry-v1; gate3-production-signing-v1 after
             registry; LEGACY_ALIASES deprecation signal; Phase 2 Ledger
             adapter addendum as a separate Architect decision.
DOC-DEBT-21  S3-R22 proof-local closures:
             P-4 content-addressed signed_addendum_ref is closed by
             phase1-addendum-content-address-ref-v0; P-5 end-to-end invocation
             fixture is closed by phase1-end-to-end-invocation-fixture-v0.
             These do not authorize production audit, registry, signing, or
             Phase 2.
DOC-DEBT-22  S3-R22 pre-production carry:
             durable-observation-persistence-v0; gate3-authority-registry-v1;
             gate3-production-signing-v1 after registry; production compliance
             must reject `git_commit: workspace-current`; phase1-post-r22-
             regression-rerun-v0 should add R20-R22 fixtures to the matrix.
DOC-DEBT-23  S3-R23 proof-local persistence/registry hardening:
             proof-local JSONL observation persistence shape and registry v1
             receipt shape are done, but production durable audit and durable
             registry service are still not done. LEGACY_ALIASES deprecation
             signal is done; removal waits for Phase 2.
DOC-DEBT-24  S3-R23 pre-production carry:
             phase1-post-r23-regression-rerun-v0 should consolidate post-R19
             fixtures before scope-widening work. Production audit still needs
             tamper evidence, storage identity, retention, replay semantics,
             and compliance language. Registry design still needs durable
             storage and the active -> superseded transition decision.
DOC-DEBT-25  S3-R24 proof-local durability shaping:
             post-R23 regression rerun is closed 23/23; registry storage
             semantics and observation tamper-evidence are proof-local and
             explicitly non-authorizing. Keep production durable audit,
             production registry ownership/service, signing/key management,
             and Phase 2 closed without Architect scope.
DOC-DEBT-26  S3-R24 pre-production carry:
             next regression rerun should expand to 25 commands by adding the
             R24 registry storage and tamper-evidence fixtures. Production
             durable audit still needs HSM/KMS signing, restart rebuild,
             version enforcement, retention/replay semantics, off-process
             persistence, and compliance language.
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
