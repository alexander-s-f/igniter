# Igniter-Lang Current Status

Stage 1: **CLOSED** (2026-05-06) — META-EXPERT-007
Stage 2: **CLOSED** (2026-05-07) — META-EXPERT-009.1
Stage 3: **OPEN** (2026-05-08) — META-EXPERT-011
Maintained by: `[Igniter-Lang Meta Expert]`
Last updated: 2026-05-11
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
                            R25 regression readiness 25/25 PASS;
                            production durable audit approved for design only;
                            R26 durable audit design ready for implementation review;
                            registry source-of-truth decided for design;
                            deterministic artifact policy implemented;
                            R27 implementation authorization HELD;
                            volatile lint + artifact survey done;
                            R28 durable-audit blocker amendments + bounded proofs landed;
                            post-R27/R28 matrix PASS 29/29 with volatile lint first;
                            production durable audit proof package ready;
                            PROP-031 contract modifiers implementation/proof PASS;
                            R29 startup_time override design closed; proof pending;
                            R29 Covenant/CSM governance docs landed;
                            R30 bounded durable-audit implementation authorized;
                            R36 restricted Phase 1 production durable audit deployment scope approved;
                            broad production deployment surfaces still closed;
                            startup_time override validator PASS 28/28;
                            Heat Map + Covenant enforcement registry landed;
                            R31 bounded audit proof-local surfaces PASS 29/29;
                            R32 hash/posture design amendment closed P-37/P-38;
                            R33 restart rebuild proof closed B-A;
                            R34 traversal/reader proof closed B-B;
                            R34 appender/reader role boundary closed B-C + P-43;
                            R35 post-implementation regression matrix closed B-D;
                            B-E restricted deployment scope approved; operational rollout follow-ups required;
                            concrete HSM/KMS and excluded runtime surfaces still closed
Language          ⚙️ partial TEMPORAL through .igapp manifest index + load guard;
                            parser coordinate syntax and production runtime remain open
                            PROP-029 entrypoint/section drafted; parser proof still open;
                            PROP-032 assumptions block drafted;
                            Phase 1 Classifier + Phase 2 TypeChecker + Phase 3 SemanticIR
                            + Phase 4 parser/P28/source proof landed;
                            PROP-032 experiment-pass for bounded compiler surface;
                            PROP-033 evidence validation/runtime receipts still closed
Compiler Internals ✅ switched CompilerOrchestrator now uses emit_typed(typed);
                            invariant typed-shape delta accepted/discharged;
                            invariant source metadata preserved;
                            parsed emitter retained as Stage 1 legacy/comparison;
                            Profile-Baseline-Pack target direction recorded;
                            shadow compiler-pack proofs are pre-POC/no-dispatch only;
                            compiler_profile_id accepted as PROP-036 proposal-only;
                            implementation authorization still blocked
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
Round 25 landed:
  S3-R25-C1-P: post-R24 regression rerun        ✅ PASS 25/25; regression readiness, not implementation auth
  S3-R25-C2-A: durable audit scope decision     ✅ approved-for-design-only; implementation still closed
  S3-R25-C3-P: registry ownership options       ✅ gate document store + generated index recommended; no binding
  S3-R25-X1-S: audit scope/registry pressure    ✅ PROCEED; non-blockers only; P-13 closed, P-14 added
Round 26 landed:
  S3-R26-C1-P: production durable audit design  ✅ ready for implementation auth review; design only
  S3-R26-C2-A: registry ownership decision      ✅ gate docs source of truth; generated index query artifact
  S3-R26-C3-P: deterministic artifact policy    ✅ policy implemented; tamper JSONL stable; stage2 timestamp volatile
  S3-R26-X1-S: durable audit design pressure    ✅ PROCEED; non-blockers only; implementation still closed
Round 27 landed:
  S3-R27-C1-A: audit implementation auth review ⏸ HOLD; implementation authorization not granted
  S3-R27-C2-P: volatile lint + artifact survey  ✅ lint PASS 4 artifacts; survey complete; grep hook open
  S3-R27-C3-P: PROP-031 contract modifiers      ✅ proposal; no parser/compiler implementation
  S3-R27-C4-P: contract modifier fixture plan   ✅ ready for implementation card; no PASS claims
  S3-R27-X1-S: audit/PROP-031 pressure          ✅ PROCEED; non-blockers only; R28 blockers routed
Round 28 landed:
  S3-R28-C1-P: audit blocker amendments/proofs  ✅ Blockers 1/2/3/7 closed; proofs 14/14 + 18/18 PASS
  S3-R28-C2-P: PROP-031 implementation          ✅ parser/classifier/typechecker/SemanticIR + proof PASS
  S3-R28-X1-S: audit/PROP-031 pressure          ⚠️ found interim 26/29 blocker; superseded by later fix/rerun
  S3-R28-C4-P: values/cross-review + fixture fix ✅ temporal precedence fix; 10/10 proof surfaces PASS
  S3-R28-C3-P: post-R27/R28 regression matrix   ✅ 29/29 PASS; volatile lint first; ready for Architect review
Round 29 landed:
  S3-R29-C1-A: audit implementation auth        ⏳ not found/deferred; no authorization landed
  S3-R29-C2-P: startup_time override interface  ✅ design-only; policy_ref + signed policy model; proof pending
  S3-R29-C3-P: PROP-031 compatibility addendum  ✅ §14 + errata; doc-only; no new grammar/code
  S3-R29-C4-P: Covenant accountability filter   ✅ Axiom 2, P27/P28, PROP Governance Filter; doc-only
  S3-R29-C5-P: canonical semantic model         ✅ CSM index created; implemented entities have golden anchors
  S3-R29-X1-S: auth/canon pressure              ✅ PROCEED; non-blockers only; P-28 deferred to R30
Round 30 landed:
  S3-R30-C1-A: durable audit implementation auth ✅ approved-bounded-implementation; deployment closed
  S3-R30-C2-P: startup_time override validator  ✅ proof-local 28/28 PASS; no gate authority enabled
  S3-R30-C3-P: observed+temporal V-3 golden     ✅ contract_modifiers proof 25/25 PASS; no grammar added
  S3-R30-C4-P: semantic governance heat map     ✅ living drift index; doc-only; two stale-credit rows noted by X1
  S3-R30-C5-P: Covenant enforcement registry    ✅ 28 postulates classified; P28 partial; OQ-Filter-1 routed
  S3-R30-C6-P: PROP-032 assumptions draft       ✅ proposal landed; no parser/classifier implementation/proof
  S3-R30-X1-S: decision/heatmap/PROP pressure   ✅ PROCEED; non-blockers P-33..P-36 routed
Round 31 landed:
  S3-R31-C1-P: bounded durable audit proof       ✅ surfaces 1/2/3/8 proof-local 29/29 PASS; deployment closed
  S3-R31-C2-A: PROP governance authority         ✅ Covenant normative; META-EXPERT-013 operational; PROP-032 not authorized by this decision
  S3-R31-C3-S: governance heat-map sync          ✅ GI-1/stale rows closed; proposals/CSM already current
  S3-R31-C4-P: startup D1/D2/D3 amendment        ✅ R29 design now matches R30 validator
  S3-R31-C5-P: PROP-032 implementation gate      ✅ Phase 1 gate satisfied; no compiler implementation landed
  S3-R31-C6-A: compiler profile architecture     ✅ post-POC Profile-Baseline-Pack direction; no rewrite authorized
  S3-R31-C7-P: compiler pack shadow/pre-POC      ✅ shadow reports/proofs; no dispatch, no .igapp change, no migration authorization
  S3-R31-shadow: compiler_profile_id boundary    ✅ proof-local plan PASS; manifest PROP required before implementation
  S3-R31-X1-S: bounded audit/governance pressure ✅ PROCEED; P-37..P-40 and B-A..B-D routed
Round 32 landed:
  S3-R32-C1-P: audit hash/posture amendment      ✅ P-37/P-38 closed; B-A/B-B/B-C unblocked; no deployment auth
  S3-R32-C2-S: governance authority sync         ✅ P-39/P-40 doc follow-ups closed; no PROP-032 implementation authorization
  S3-R32-C3-P: PROP-032 Classifier Phase 1       ✅ assumption_registry/uses_assumptions/epistemic/OOF-A1 proof PASS; TypeChecker/SemanticIR open
  S3-R32-X1-S: R32 pressure review               ✅ PROCEED; P-41/P-42 + B-A routed to R33
  S3-R32-shadow: compiler profile foundation     ✅ closure index/backreference; no dispatch/.igapp/.ilk/runtime authority
Round 33 landed:
  S3-R33-C1-P: durable audit restart rebuild     ✅ B-A PASS 21/21; proof-local restart rebuild, no deployment
  S3-R33-C2-P: PROP-032 TypeChecker Phase 2      ✅ OOF-A1 propagation + strength checks; SemanticIR still open at R33
  S3-R33-C3-A: compiler profile PROP number      ✅ PROP-036 assigned to compiler_profile_id manifest identity; numbering-only
  S3-R33-C4-S: compiler profile dependency index ✅ shadow/pre-POC map; no dispatch/.igapp/.ilk/runtime auth
  S3-R33-C5-P: external progression prep         ✅ progression/service-loop decision brief; no code/grammar/runtime auth
  S3-R33-X1-S: R33 pressure review               ✅ PROCEED; P-43/P-44 + B-B/B-C routed to R34
Round 34 landed:
  S3-R34-C1-P: audit reader/traversal proof      ✅ B-B PASS 26/26 + 4/4 invariants; reader cannot mutate/authorize
  S3-R34-C2-P: appender/reader role boundary     ✅ B-C PASS 21/21; P-43 closed with clean-rebuild append gate
  S3-R34-C3-S: PROP-036 placeholder sync         ✅ P-44 closed; managed recursion/service loop placeholder moved to PROP-037+
  S3-R34-C4-P: PROP-032 SemanticIR Phase 3       ✅ typed assumptions lower to SemanticIR/report outputs; Phase 4 parser still open
  S3-R34-C5-P: PROP-036 proposal authored        🟡 proposal only; acceptance + implementation authorization required
  S3-R34-C6-P: progression PROP scope draft      🟡 scope-ready for PROP-037+ assignment; no number/implementation auth
  S3-R34-X1-S: R34 pressure review               ✅ PROCEED non-blockers; B-D/P-45/P-46/PROP-032 Phase 4 routed
Round 35 landed:
  S3-R35-C1-P: durable audit B-D matrix          ✅ 9/9 commands PASS; 97/97 durable audit proof cases PASS
  S3-R35-C2-S: R35 status curation               ✅ B-D closed in maps; B-E review ready; no deployment auth
  S3-R35-C3-A: PROP-036 acceptance               ✅ accepted-proposal-only; implementation still closed
  S3-R35-C4-A: PROP-037 number assignment        ✅ progression/service liveness numbering-only; proposal not authored
  S3-R35-C5-P: PROP-032 parser Phase 4           ✅ parser/P28/source-to-SemanticIR proof PASS; experiment-pass decision still pending
  S3-R35-C6-S: proposal lifecycle labels sync    ✅ proposal labels clarified; Track done != Proposal accepted
Round 36 landed:
  S3-R36-C1-A: durable audit B-E decision         ✅ restricted Phase 1 production durable audit deployment scope approved; excluded surfaces closed
  S3-R36-C2-A: PROP-032 experiment-pass          ✅ bounded compiler surface promoted; PROP-033 evidence/runtime receipts excluded
  S3-R36-C3-S: R36 preflight status sync          ✅ R35 C2-S stale recommendations superseded before implementation/proposal work
Active PROPs:     PROP-028 + PROP-022A temporal errata + PROP-029 entrypoint/section
                  + PROP-030 executor approval token + PROP-030A scope exclusion
                  + PROP-031 contract modifiers + PROP-032 assumptions block;
                  queued slots include PROP-033 via profile, PROP-034 evidence,
                  PROP-035 profile declarations, PROP-036 compiler_profile_id accepted proposal,
                  PROP-037 progression/service liveness assigned slot,
                  PROP-038+ managed local recursion / loop-class placeholder;
                  other syntax candidates require proposal tracks
Arch approval required for: any durable-audit deployment outside S3-R36-C1-A restricted scope,
                            concrete HSM/KMS,
                            Gate 3 Phase 2 Ledger adapter, BiHistory, stream/OLAP,
                            production cache, broad RuntimeMachine binding,
                            gem publish, Ledger write, MCP/mesh
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
       post-R24 regression rerun                 ✅ S3-R25 C1 PASS 25/25; current regression readiness
       production durable audit scope            ✅ S3-R25 C2 design-only approval; implementation still closed
       registry ownership options                ✅ S3-R25 C3 recommends gate docs + generated index; no decision binding
       audit scope/ownership pressure            ✅ S3-R25 X1 PROCEED; design may continue, blockers remain
       production durable audit design           ✅ S3-R26 C1 ready for implementation authorization review
       registry ownership decision               ✅ S3-R26 C2 gate docs source of truth + generated index
       deterministic artifact policy             ✅ S3-R26 C3 implemented; no Gate 3 auth change
       durable audit design pressure             ✅ S3-R26 X1 PROCEED; low items routed before auth
       durable audit implementation auth         ⏸ S3-R27 HOLD; R28 evidence ready for Architect decision
       volatile fields lint/artifact survey       ✅ S3-R27 C2 PASS; R28 matrix integration closed
       PROP-031 contract modifiers               ✅ S3-R27 proposal/plan superseded by R28 implementation/PASS
       contract modifiers proof fixture plan      ✅ S3-R27 C4 plan only; implementation-ready, no fixtures created
       audit + PROP-031 pressure                  ✅ S3-R27 X1 PROCEED; non-blockers routed
       durable audit blocker amendments           ✅ S3-R28 C1 closes Blockers 1/2/3/7 by design + bounded proofs
       production durable audit bounded proofs     ✅ compliance posture 14/14 PASS; signer validation 18/18 PASS
       PROP-031 implementation/proof              ✅ parser/classifier/typechecker/SemanticIR + contract_modifiers proof PASS
       post-R28 regression matrix                 ✅ volatile lint first; final sequential matrix 29/29 PASS
       production durable audit implementation     ✅ authorized as bounded track; not landed/deployed
       startup_time override interface             ✅ R29 design; R30 proof-local validator PASS
       PROP-031 compatibility addendum             ✅ R29 §14 documents Stage 3 migration, OOF-M1 ownership, V-3
       Covenant accountability governance          ✅ R29 Axiom 2, P27/P28, PROP Governance Filter; no compiler semantics
       canonical semantic model                    ✅ R29 CSM index; golden anchors required for implemented entities
       startup_time override validator             ✅ R30 proof-local 28/28 PASS; gate authority false in outputs
       V-3 observed+temporal golden                ✅ R30 contract_modifiers_proof 25/25 PASS
       semantic governance heat map                ✅ R30 drift index; read for PROP/gov/language planning
       Covenant enforcement registry               ✅ R30 status vocabulary + P28 per-surface table
       bounded durable audit proof-local impl       ✅ R31 surfaces 1/2/3/8 PASS 29/29; deployment closed
       PROP governance authority                    ✅ R31 Covenant normative, META-EXPERT-013 operational
       audit hash/posture amendment                 ✅ R32 closes P-37/P-38; B-A unblocked
       audit restart rebuild                         ✅ R33 closes B-A; proof-local only, deployment closed
       audit traversal/reader                        ✅ R34 closes B-B; full-chain scan before filters, reader mutators refused
       audit appender/reader role boundary           ✅ R34 closes B-C and P-43; append requires clean rebuild status
       audit post-implementation matrix              ✅ R35 closes B-D; 9/9 commands, 97/97 audit cases PASS
       audit deployment review                       ✅ B-E restricted scope approved; concrete HSM/KMS/excluded surfaces closed
       PROP-032 assumptions                          ✅ experiment-pass for bounded compiler surface; PROP-033/runtime excluded
       compiler Profile-Baseline-Pack               🟡 post-POC direction + shadow proofs; no dispatch/migration
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
Regression readiness:
                     current Gate 3 Phase 1 / R28 matrix ✅ 29/29 PASS after R28; includes volatile_fields_lint
                     as the first command, prior 25-command Phase 1 chain, Stage 1/2 regressions, C1 compliance
                     posture + signer-validation proofs, and C2 contract-modifier proof. This is readiness
                     evidence only, not production implementation authorization.
Production durable audit:
                     approved for design only ✅ by S3-R25-C2-A. The next design track may specify signing
                     boundary, restart rebuild, format_version enforcement, retention/audit traversal semantics,
                     storage identity, audit reader role, compliance language, refusal codes, blockers, and proof
                     plan. Implementation, deployment, production signing execution/key management, Ledger/Phase 2,
                     BiHistory, stream/OLAP, production cache, writes/replay/compact/subscribe, runtime registry
                     implementation, and broader `gate3_authorized` remain closed.
Production durable audit design:
                     S3-R26-C1-P done ✅; design defines production audit record schema, HSM/KMS-backed signing
                     recommendation, restart rebuild, `format_version: 1.0.0` enforcement, retention/audit traversal,
                     off-process storage identity, audit reader role, compliance boundaries, refusal codes, 10
                     implementation blockers, and proof plan. Status is ready for implementation authorization
                     review, not implementation authorization.
Production registry ownership:
                     decided for design ✅; gate document store is Phase 1 source of truth, generated
                     content-addressed registry index is the query artifact, and package/runtime consumers may only be
                     read-only cache/validator. Registry implementation remains closed pending a later Architect
                     decision and implementation blockers.
Deterministic artifacts:
                     policy implemented ✅; proof artifacts should prefer deterministic-by-construction constants or
                     `_volatile_fields` annotations. Tamper-evidence JSONL now uses `PROOF_STORAGE_IDENTITY` and is
                     byte-stable across consecutive runs; stage2 summary marks `timestamp` volatile. Lint enforcement
                     and full artifact survey remain follow-ups.
Production durable audit authorization:
                     approved-bounded-implementation ✅ by S3-R30-C1-A. R28 closed the named design/proof blockers:
                     compliance_posture is
                     store-bound + verification-bound (14/14 PASS), production signer rejects nil/no-op/stub/local
                     patterns (18/18 PASS), startup_time has a 24h fail-closed design bound, the design amendment
                     landed, the final post-R27/R28 regression matrix is 29/29 PASS, and R29 added the override
                     design/governance inputs. R30 authorizes only the bounded Phase 1 implementation track:
                     audit record schema validation, signer abstraction proof, append-only audit store interface proof,
                     restart rebuild proof, startup freshness validator, audit traversal/reader proof, appender/reader
                     role boundary proof, excluded-surface regression, and post-implementation regression matrix.
                     Production deployment, concrete HSM/KMS onboarding, production signing execution/key management,
                     production authority registry implementation, broad RuntimeMachine binding, Ledger/Phase 2,
                     BiHistory, stream/OLAP, production cache, general write/replay/compact/subscribe, and broader
                     `gate3_authorized` remain closed until a later Architect decision.
Production durable audit bounded implementation:
                     R31 C1-P proof-local surfaces 1/2/3/8 landed ✅. The proof validates audit record schema,
                     signer abstraction, append-only store interface, and excluded-surface regression: 29/29 PASS,
                     5/5 invariant checks PASS. Proof classes live in the experiment script; no `lib/` writer,
                     production registry, Ledger, Phase 2, online lookup, HSM/KMS, or deployment path was added.
                     `gate3_authorized: false` and `production_durable_audit: false` remain true for all proof-local
                     outputs. R32 C1-P closes P-37/P-38: canonical record_hash excludes five fields and
                     compliance_posture is stored as an auditor-visible snapshot, derived as the authoritative value,
                     and mismatch-checked by reader/rebuild with `audit.record.compliance_posture_mismatch`.
                     R33 C1-P closes B-A restart rebuild: 21/21 PASS, proof-local only. R34 C1-P closes B-B
                     traversal/reader: 26/26 PASS and 4/4 invariants, with full-chain traversal before filters,
                     compliance_posture re-derivation, and reader mutating/authorizing operations refused. R34 C2-P
                     closes B-C appender/reader role boundary and P-43: 21/21 PASS, 6/6 invariants, and appends
                     require clean rebuild status (`audit.writer.rebuild_not_clean` on failure). R35 C1-P closes
                     B-D post-implementation regression matrix: 9/9 commands PASS and 97/97 durable audit proof cases
                     PASS across bounded implementation, restart rebuild, traversal/reader, and role-boundary scripts.
                     Remaining before production deployment: B-E separate Architect production deployment/signing/HSM/KMS
                     review. R35 C1-P is readiness for review, not deployment authorization.
Startup freshness override:
                     design closed ✅ by S3-R29-C2-P. Override authority is a deployment manifest `policy_ref` plus
                     bundled content-addressed, authority-signed freshness policy document. Direct env-var/config
                     seconds are rejected; env var may only point to a manifest path. Allowed range is 1h..72h, with
                     >24h requiring signed reason + expiry and >72h requiring new governance. R30 proof-local
                     validator PASSes 28/28 with 12/12 invariant checks. R30 tightens the design: all non-default
                     policies require `expires_at`; new fail-closed codes are
                     `audit.registry.freshness_policy_format_invalid` and
                     `audit.registry.direct_seconds_override_rejected`. R31 C4-P amended the R29 design track so
                     D1/D2/D3 match the proof. Proof-local only: no production writer, signing execution, Ledger,
                     Phase 2, online lookup, or enabled gate authority.
Deterministic artifact enforcement:
                     validator shipped ✅; `experiments/volatile_fields_lint/volatile_fields_lint.rb` PASSes with
                     4 annotated artifacts and 0 violations. Artifact stability survey is complete. R28 matrix
                     integration is closed: volatile_fields_lint runs as step 1 in the 29-command matrix. A
                     grep/pre-commit check for newly-added unannotated `Time.now` remains optional follow-up.
PROP-031:
                     contract modifiers implementation/proof ✅; optional `pure|observed|effect|privileged|irreversible`
                     prefix, implicit `pure` default, OOF-M1 only. Parser, Classifier, TypeChecker, and SemanticIR
                     emitter support landed; SemanticIR uses `contract_name`; OOF-M1 is detected in Classifier and
                     propagated by TypeChecker; contract_modifiers proof PASSes. No Effect Surface validation, no
                     `via profile`, no service-loop detection, no authority resolution, and no runtime enforcement.
                     R29 adds PROP-031 §14 compatibility addendum: Stage 1/2 backward compatibility confirmed,
                     Stage 3 `observed` migration documented, `stream` -> OOF-M1 via ESCAPE body documented,
                     temporal precedence (V-3) documented, and OOF-M1 pipeline ownership clarified.
Proof fixture readiness:
                     contract modifiers fixture plan was executed in R28 ✅; goldens and runner landed. Final evidence
                     records `contract_modifiers_proof` PASS in the 29-command matrix and
                     `contract_modifiers_proof --check-golden` PASS 22/22 in Agent-D cross-review. R30 adds the
                     dedicated V-3 observed+temporal precedence golden: `contract_modifiers_proof --check-golden`
                     PASS 25/25 and `classifier.temporal_precedence_over_modifier: ok`.
Covenant / CSM:
                     R29 governance docs landed ✅. The Language Covenant now separates Honesty and Accountability,
                     adds P27 Accountability as Architecture, P28 No Unnamed Block, and a PROP Governance Filter.
                     The Canonical Semantic Model lives at `docs/dev/canonical-semantic-model.md`; implemented or
                     experiment-pass entities require golden anchors, while unanchored entities remain
                     `spec_candidate`. R30 adds `docs/dev/semantic-governance-heat-map.md` and the Covenant Promise
                     Enforcement Registry: all 28 postulates have enforcement status; P28 is partial; escape naming is
                     Unknown and routed as OQ-P28-1. R31 C2-A closes OQ-Filter-1: the Covenant is normative and
                     META-EXPERT-013 is operational. R31 C3-S closes Heat Map stale-credit rows and GI-1 queue drift.
                     R32 C2-S applies the follow-up pointers in Covenant, META-EXPERT-013, and Heat Map Domain 8.
                     These are governance/context changes, not new compiler semantics.
PROP-032:
                     assumptions block proposal ✅ drafted in R30. PROP-032 is `assumptions {}` + `uses assumptions NAME`,
                     proposes new `epistemic` fragment class and OOF-A1 pipeline, and resolves the prior queue conflict
                     by renumbering `via profile` to PROP-033. R31 C5-P satisfies the Phase 1 implementation gate and
                     specifies OOF-A1, `epistemic` guard insertion, P28-AC-1, and the next implementation-card template.
                     R32 C3-P implements Phase 1 Classifier: `assumption_registry`, `uses_assumptions`,
                     `assumption_refs`, `epistemic` fragment precedence, and OOF-A1; assumptions_proof and regression
                     checks PASS. R33 C2-P closes Phase 2 TypeChecker. R34 C4-P closes Phase 3 SemanticIR for typed
                     assumptions: accepted fixtures emit SemanticIR/golden report outputs; OOF-A1/TASSUMP-1 stay
                     report-only with nil SemanticIR; no-assumption goldens remain unchanged. R35 C5-P closes Phase 4:
                     parser grammar, P28 unnamed-assumption parse-error fixture, and source-to-SemanticIR proof PASS.
                     R36 C2-A promotes PROP-032 to experiment-pass for the bounded compiler surface. Output
                     evidence-list validation (PROP-033), runtime receipts, and production behavior remain excluded.
Compiler profile/pack architecture:
                     R31 records Profile-Baseline-Pack as the post-POC compiler architecture direction. Shadow work
                     proves a compiler pack boundary, shadow profile, registry spike, ordered rule precedence, and
                     `compiler_profile_id` manifest boundary plan, but all are proof-local/pre-POC: no CompilerKernel
                     dispatch, no current compiler rewrite, no `.igapp`/`.ilk` manifest change, no real
                     `compiler_profile_id` adoption, and no native pack migration authorization. R32 shadow work adds
                     a closure index/backreference that answers the dependency-map pressure item. S3-R33-C3-A assigns
                     PROP-036 to the manifest identity as a numbering-only decision. S3-R34-C5-P authors
                     `PROP-036-compiler-profile-manifest-identity-v0.md`; S3-R35-C3-A accepts it as proposal-only.
                     A separate Architect implementation authorization is still required before assembler, loader,
                     artifact-hash/golden migration, or receipt-link implementation.
Reason codes:       LEGACY_ALIASES deprecation signal ✅; lib/ executor emits canonical
                     `runtime.temporal_scope_exclusion`; sealed old fixtures are not retroactively edited;
                     alias removal remains Phase 2 housekeeping.
Pre-signing remaining:
                      none for restricted Phase 1 live-read addendum; closed by S3-R20-C1-A.
Pre-production remaining:
                      restricted Phase 1 durable audit deployment follow-up: storage identity config,
                      signer abstraction validation, startup rebuild verification, appender/reader role wiring,
                      refusal-code export, rollback/disable plan, and post-deployment smoke/checklist;
                      concrete HSM/KMS provider onboarding remains separate;
                      production authority registry; proof-local freshness authority fixture rules before production signer work;
                      OQ-P28-1 escape naming answer;
                      PROP-036 implementation authorization before any `.igapp` implementation; PROP-037 formal proposal authoring;
                      real commit SHA / no `workspace-current`; optional Time.now grep hook; Phase 2 addendum gaps
Runtime observations: proof-backed ✅ proof-local file persistence + tamper-evidence shape; restricted Phase 1 durable audit deployment scope approved
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
S3-R25 result:        Regression readiness and production audit design scope landed without implementation authorization:
                      C1 PASS 25/25 expands the canonical Gate 3 Phase 1 matrix by adding R24 registry storage and
                      tamper-evidence fixtures; it is a regression record only. C2-A approves
                      `phase1-production-durable-audit-v0` for design only, with implementation/deployment/signing
                      execution/Ledger/Phase 2/BiHistory/stream/OLAP/cache/write/replay/compact/subscribe all closed
                      until a later Architect decision. C3 compares registry ownership options and recommends gate
                      document store plus generated content-addressed registry index as Phase 1 default, but no binding
                      Architect ownership decision exists yet. X1 says PROCEED with non-blockers only, closes P-13,
                      adds P-14 deterministic artifact policy, and recommends R26 design-only audit work plus registry
                      ownership decision.
S3-R26 result:        Production durable audit design, registry ownership decision, and deterministic artifact policy landed
                      without implementation authorization. C1 designs the production durable audit surface and is ready
                      for implementation authorization review, but it ships no executable implementation and keeps signing
                      execution, deployment, Ledger/Phase 2, BiHistory, stream/OLAP, cache, writes/replay/compact/
                      subscribe closed. C2-A decides the registry source-of-truth model for design: gate document store
                      plus generated content-addressed registry index; package/runtime are read-only cache/validator only.
                      C3 implements the deterministic artifact policy: tamper-evidence JSONL uses a proof constant and is
                      byte-stable, while stage2 summary marks `timestamp` volatile. X1 says PROCEED with non-blockers
                      only and routes implementation-authorization review, `_volatile_fields` lint, artifact survey,
                      post-R26 full regression rerun, and registry implementation planning.
S3-R27 result:        Implementation authorization remains held while deterministic enforcement and PROP-031 planning land.
                      C1-A explicitly holds production durable audit implementation authorization; the design remains
                      review-ready only. C2 ships `volatile_fields_lint`, applies missing `_volatile_fields` annotations,
                      and completes the artifact stability survey; matrix integration and Time.now grep/pre-commit hook
                      remain follow-ups. C3 authors PROP-031 contract modifiers as proposal only: optional modifier
                      prefix, implicit pure default, OOF-M1 only, no Effect Surface, no profiles, no runtime enforcement.
                      C4 prepares the contract modifier proof fixture plan with no fixtures/PASS claims. X1 says PROCEED
                      with non-blockers only and routes R28: durable-audit design amendment/proofs, post-R27 regression,
                      PROP-031 implementation with OOF-M1 stage + `contract_name` alignment, and volatile-field grep hook.
S3-R28 result:        Durable-audit design/proof blockers and PROP-031 implementation evidence landed, but production
                      durable audit implementation is still not authorized. C1 closes compliance_posture store-binding
                      and signer rejection with bounded proofs (14/14 + 18/18 PASS), adds the 24h startup_time
                      fail-closed design amendment, and keeps deployment/signing execution/Ledger/Phase 2/BiHistory/
                      stream/OLAP/cache/write/replay/compact/subscribe closed. C2 implements PROP-031 across parser,
                      classifier, typechecker, and SemanticIR; OOF-M1 stage and `contract_name` shape are machine
                      verifiable. X1 found an intermediate 26/29 regression blocker from Stage 3 fixture migration;
                      later Agent-D/final C3 evidence resolved it by adding `observed` to legacy temporal/stream
                      fixtures and rerunning a final sequential matrix: 29/29 PASS with volatile_fields_lint first.
                      R29 should route Architect implementation-authorization review only as a decision round, plus
                      startup_time override design and PROP-031 compatibility note if those non-blockers remain desired.
S3-R29 result:        Architect production durable audit implementation authorization did not land; this is a safe
                      deferral, not an implicit hold release. C2 closes startup_time override interface design only:
                      policy_ref + bundled authority-signed policy, no direct env/config seconds, no online lookup,
                      and no proof script yet. C3 adds PROP-031 §14 compatibility addendum and errata, documenting
                      Stage 3 migration, stream-triggered OOF-M1, V-3 temporal precedence, and Classifier->TypeChecker
                      OOF-M1 ownership. C4 adds Covenant Axiom 2, P27/P28, and the PROP Governance Filter as
                      governance only. C5 creates `docs/dev/canonical-semantic-model.md`; implemented entities need
                      golden anchors and unanchored entities stay `spec_candidate`. X1 says PROCEED with non-blockers
                      only and routes R30: Architect authorization decision, startup_time override validator,
                      V-3 dedicated golden, P28 enforcement gap table, META-EXPERT-013 reconciliation, and PROP-032.
S3-R30 result:        Architect authorized a bounded Phase 1 production durable audit implementation track, not
                      production deployment. C1-A scope is explicit: audit schema validation, signer abstraction,
                      append-only audit store interface, restart rebuild, startup freshness validator, traversal/reader,
                      appender/reader role boundary, excluded-surface regression, and post-implementation regression.
                      C2 proof-local startup_time override validator PASSes 28/28 and keeps `gate3_authorized: false`;
                      C3 adds the V-3 observed+temporal golden and contract modifiers proof now PASSes 25/25. C4/C5
                      add Heat Map and Covenant enforcement registry as governance maps; C6 drafts PROP-032 assumptions
                      only, with no parser/classifier/SemanticIR implementation or golden files. X1 says PROCEED with
                      non-blockers: heat map stale credits, startup override design lag, OQ-Filter-1, OQ-P28-1, and
                      explicit PROP-032 implementation gate before classifier work.
S3-R31 result:        Bounded durable-audit implementation began proof-locally: C1-P closes schema validation,
                      signer abstraction, append-only store, and excluded-surface regression with 29/29 PASS and
                      5/5 invariant checks. It does not close deployment or production signing/HSM/KMS. B-A restart
                      rebuild, B-B traversal/reader, B-C appender/reader role boundary, and B-D full regression remain
                      open. C2-A closes OQ-Filter-1 by making the Covenant normative and META-EXPERT-013 operational.
                      C3-S closes Heat Map stale rows/GI-1; C4-P amends startup freshness D1/D2/D3; C5-P satisfies
                      the PROP-032 Phase 1 gate, but no compiler implementation or experiment PASS has landed. C6/C7
                      and shadow tracks record Profile-Baseline-Pack / compiler-pack pre-POC direction only: no compiler
                      dispatch, rewrite, `.igapp` change, or migration authorization. X1 says PROCEED and routes P-37
                      through P-40 plus B-A/B-B/B-C/B-D to R32.
S3-R32 result:      C1-P closes P-37/P-38 by amending the durable-audit design with the five-field canonical hash
                      algorithm and stored+derived+mismatch-checked compliance_posture model. B-A/B-B/B-C are
                      unblocked, but not landed. C2-S closes P-39/P-40 by applying the C2-A authority hierarchy to
                      active docs. C3-P implements PROP-032 Phase 1 Classifier only: assumptions registry,
                      uses_assumptions, assumption_refs, epistemic fragment precedence, and OOF-A1 with proof PASS.
                      No parser grammar, TypeChecker, SemanticIR, evidence-list validation, runtime behavior, or
                      experiment-pass landed. Shadow compiler-profile work adds a closure index/backreference for the
                      dependency-map pressure item only; no dispatch, `.igapp`/`.ilk`, runtime, or migration authority.
                      X1 says PROCEED and routes B-A, PROP-032 Phase 2, and compiler_profile_id PROP numbering to R33.
S3-R33 result:      C1-P closes B-A restart rebuild with 21/21 PASS and proof-local boundaries only. C2-P closes
                      PROP-032 Phase 2 TypeChecker; Phase 3 SemanticIR remained open until R34. C3-A assigns PROP-036
                      to `compiler_profile_id` manifest identity as a numbering-only decision and does not authorize
                      `.igapp`, loader, assembler, runtime, or migration implementation. C4-S indexes the compiler
                      profile shadow dependency chain; C5-P prepares external progression semantics with no code,
                      grammar, or runtime authorization. X1 routes P-43/P-44 plus B-B/B-C to R34.
S3-R34 result:      C1-P closes B-B traversal/reader proof with 26/26 PASS and 4/4 invariants. C2-P closes B-C
                      appender/reader role boundary and P-43 clean-rebuild append gating with 21/21 PASS and 6/6
                      invariants; its local Open Blockers table was later cross-referenced by R35 curation to remove
                      the same-round B-B drift. C3-S closes P-44 by moving managed recursion/service-loop
                      placeholders to PROP-037+ across active maps. C4-P closes PROP-032 Phase 3 SemanticIR for typed
                      assumptions; Phase 4 parser grammar/P28/full experiment-pass remains open at R34 close. C5-P authors PROP-036
                      as proposal-only; P-45 acceptance gate is open before implementation. C6-P drafts progression
                      PROP scope without claiming a number; P-46 formal PROP-037+ assignment is open. B-D full
                      post-implementation regression matrix is the next audit prerequisite before B-E deployment review.
S3-R35 result:      C1-P closes B-D: 9/9 command matrix PASS and 97/97 durable audit proof cases PASS across the
                      bounded implementation, restart rebuild, reader traversal, and appender/reader role-boundary
                      proof scripts. P-43 remains enforced as `audit.writer.rebuild_not_clean`, B-B/B-C cumulative state
                      is closed, and excluded surfaces remain false/absent. This makes the system ready for B-E
                      Architect deployment review, but it does not authorize production deployment, production signing,
                      concrete HSM/KMS, Ledger/Phase 2, BiHistory, stream/OLAP, production cache, or broad RuntimeMachine
                      binding. C3-A accepts PROP-036 as proposal-only; implementation remains closed behind a separate
                      Architect authorization. C4-A assigns PROP-037 to external progression/service liveness as
                      numbering-only; PROP authoring and implementation remain closed. C5-P completes PROP-032 Phase 4
                      parser/P28/source proof and recommends experiment-pass review, but no lifecycle promotion decision
                      has landed. C6-S clarifies proposal lifecycle labels and the rule that Track done does not imply
                      Proposal accepted.
S3-R36 preflight:   C1-A approves a restricted Phase 1 production durable audit deployment scope for the bounded
                      append/read/rebuild surface only; Ledger, Phase 2, BiHistory, stream/OLAP, production cache,
                      broad RuntimeMachine binding, concrete HSM/KMS onboarding, and general persistence APIs remain
                      closed. C2-A promotes PROP-032 to experiment-pass for the bounded compiler surface only; PROP-033
                      evidence validation, runtime receipts, and production behavior remain excluded. C3-S preflights
                      living maps so R35 C2-S stale recommendations do not drive R36 work.
```

### Spec Freshness

| Surface | Freshness | Current anchor | Remaining doc debt |
|---------|-----------|----------------|--------------------|
| Agent context | ✅ current S3-R32 | `docs/agent-context.md` | R31 bounded audit + compiler-pack shadow boundary visible; R32 authority sync visible |
| Value index | ✅ introduced docs micro-round | `docs/value-index.md`; `docs-value-hoisting-micro-round-v0` | Update sparingly when ideas should remain visible beyond one round |
| Language Covenant | ✅ R34 placeholder sync | `covenant-accountability-postulates-r29-v0`; `covenant-promise-enforcement-path-rule-v0`; `docs/gates/prop-governance-authority-decision-v0.md`; `docs/language-covenant.md`; `prop036-placeholder-governance-sync-v0` | OQ-P28-1 escape naming remains; loop naming placeholder should move to PROP-038+ on next covenant touch after PROP-037 assignment |
| Canonical Semantic Model | ✅ R34 placeholder sync | `canonical-semantic-model-bootstrap-r29-v0`; `docs/dev/canonical-semantic-model.md`; `observed-temporal-precedence-golden-r30-v0`; `prop036-placeholder-governance-sync-v0` | Maintain entity rows when compiler entities are added/removed; add secondary observed+temporal anchor in next CSM touch |
| Semantic Governance Heat Map | ✅ PROP-036 sync S3-R34 | `semantic-governance-heat-map-v0`; `r31-governance-map-sync-v0`; `docs/dev/semantic-governance-heat-map.md`; `r32-governance-authority-sync-v0`; `prop036-placeholder-governance-sync-v0` | Maintain when new governance issues open/close |
| Ch4 Fragment Classification | ✅ synced S3-R6 | `spec-ch4-temporal-fragment-sync-v0` | Parser coordinate syntax remains proposal/runtime work, not spec-lag |
| Ch5 Compiler Pipeline | ✅ synced S3-R6 + R10 metadata | `spec-ch5-emit-typed-sync-v0`; `invariant-typed-shape-discharge-v0`; `invariant-source-metadata-preservation-v0` | Invariant source metadata preservation landed; Ch6 doc sync remains |
| Ch6 SemanticIR / .igapp | ✅ synced through R36 PROP-032 experiment-pass | `spec-ch6-semanticir-temporal-sync-v0`; `stream-replay-metadata-emission-v0`; `invariant-source-metadata-preservation-v0`; `prop032-assumptions-phase3-semanticir-v0`; `prop032-assumptions-phase4-parser-proof-v0`; `prop032-assumptions-experiment-pass-decision-v0` | PROP-032 experiment-pass landed; Ch2 grammar sync remains; PROP-033 evidence validation/runtime receipts excluded |
| Ch7 Runtime | ✅ R36 restricted durable-audit deployment scope approved | `spec-ch7-runtime-temporal-cache-sync-v0`; `executor-approval-token-report-proof-v0`; `guarded-runtime-executor-approval-enforcement-v0`; `compatibility-report-package-descriptor-consumption-v0`; `docs/gates/gate3-decision-record-v0.md`; `PROP-030A-temporal-scope-exclusion-errata-v0.md`; `spec-ch7-gate3-approval-sync-v0`; `runtime-temporal-executor-composition-integration-v0`; `executor-approval-authority-ref-proof-v0`; `phase1-prelive-regression-chain-v0`; `runtime-temporal-executor-lib-prep-v0`; `runtime-temporal-executor-lib-boundary-spec-sync-rerun-v0`; `gate3-first-post-signature-fixture-v0`; `compatibility-report-persistence-audit-v0`; `gate3-authority-registry-shape-v0`; `phase1-end-to-end-invocation-fixture-v0`; `phase1-addendum-content-address-ref-v0`; `phase1-durable-observation-persistence-shape-v0`; `gate3-authority-registry-v1-receipts-shape-v0`; `phase1-reason-code-legacy-aliases-deprecation-signal-v0`; `phase1-post-r23-regression-rerun-v0`; `phase1-durable-registry-storage-semantics-v0`; `phase1-observation-tamper-evidence-shape-v0`; `phase1-post-r24-regression-rerun-v0`; `phase1-production-durable-audit-scope-decision-v0`; `production-registry-ownership-options-v0`; `phase1-production-durable-audit-v0`; `phase1-production-registry-ownership-decision-v0`; `deterministic-regression-artifact-policy-v0`; `phase1-production-durable-audit-implementation-authorization-review-v0`; `production-durable-audit-blocker-amendment-and-validation-proofs-v0`; `post-r27-regression-matrix-with-volatile-lint-v0`; `phase1-production-durable-audit-implementation-authorization-decision-v0`; `startup-time-freshness-override-validator-v0`; `phase1-production-durable-audit-bounded-implementation-v0`; `durable-audit-hash-and-posture-design-amendment-v0`; `durable-audit-restart-rebuild-proof-v0`; `durable-audit-reader-traversal-proof-v0`; `durable-audit-append-reader-role-boundary-proof-v0`; `durable-audit-post-implementation-regression-matrix-v0`; `durable-audit-b-e-deployment-review-decision-v0` | Restricted audit append/read/rebuild deployment scope approved; Ledger/Phase2/BiHistory/stream/OLAP/cache/broad RuntimeMachine/concrete HSM-KMS remain closed |
| Proposal index | ✅ R36 preflight synced | `proposal-lifecycle-index-sync-v0`; `PROP-029-entrypoint-section-surface-v0`; `PROP-030-executor-approval-token-contract-v0`; `PROP-032-assumptions-block-v0`; `prop032-assumptions-implementation-gate-review-v0`; `prop032-assumptions-phase1-classifier-implementation-v0`; `prop032-assumptions-phase3-semanticir-v0`; `prop036-placeholder-governance-sync-v0`; `prop036-compiler-profile-id-manifest-proposal-v0`; `progression-prop-number-assignment-decision-v0`; `proposal-lifecycle-status-labels-sync-v0`; `stage3-round36-status-preflight-sync-v0` | PROP-036 accepted proposal-only; PROP-037 assigned numbering-only; PROP-038+ local recursion placeholder; PROP-032 experiment-pass |
| Contract modifiers | ✅ implementation/proof + R30 V-3 golden | `PROP-031-contract-modifiers-v0`; `contract-modifiers-proof-fixture-plan-v0`; `post-r27-regression-matrix-with-volatile-lint-v0`; `agent-d-cross-review-values-and-meta-cards-r28-v0`; `prop031-compatibility-addendum-r29-v0`; `observed-temporal-precedence-golden-r30-v0` | Parser/classifier/typechecker/SemanticIR support landed with proof PASS; §14 documents migration/OOF-M1/V-3; V-3 golden PASS 25/25; Effect Surface/Profile/authority/runtime enforcement still absent by design |
| Compiler pack architecture | 🟡 accepted proposal / implementation blocked | `compiler-profile-architecture-direction-v0`; `compiler-pack-boundary-report-v0`; `compiler-pack-shadow-profile-proof-v0`; `contract-modifiers-pack-native-boundary-v0`; `compiler-kernel-pack-registry-spike-v0`; `compiler-kernel-ordered-rule-precedence-v0`; `compiler-profile-id-manifest-boundary-plan-v0`; `compiler-profile-chain-closure-index-v0`; `compiler-profile-r32-shadow-chain-backreference-v0`; `docs/gates/compiler-profile-manifest-prop-number-decision-v0.md`; `prop036-compiler-profile-id-manifest-proposal-v0`; `prop036-compiler-profile-id-acceptance-decision-v0` | PROP-036 accepted proposal-only; no compiler dispatch, no rewrite, no real `.igapp`/`.ilk` profile id, no native migration authorization |
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
DOC-DEBT-27  S3-R25 regression/design split:
             post-R24 regression readiness is closed 25/25. Production durable
             audit is approved for design only by S3-R25-C2-A; do not mark
             implementation, deployment, signing execution/key management,
             Ledger/Phase 2, BiHistory, stream/OLAP, cache, writes/replay/
             compact/subscribe, or broader gate3_authorized as authorized.
DOC-DEBT-28  S3-R25 R26 carry:
             R26 should route `phase1-production-durable-audit-v0` as design
             only, Architect registry ownership/freshness/index-generation
             decision, and deterministic regression artifact policy. Registry
             options recommend gate document store + generated content-addressed
             index, but no binding Architect ownership decision exists yet.
DOC-DEBT-29  S3-R26 design/decision/policy landed:
             durable audit design is ready for implementation authorization
             review, not implementation. Registry ownership is decided for
             design purposes: gate docs are source of truth, generated index is
             query artifact, package/runtime are cache/validator only.
             Deterministic artifact policy is implemented for the known
             nondeterministic artifacts.
DOC-DEBT-30  S3-R26 R27 carry:
             before implementation authorization, route compliance_posture
             store-binding proof, signer-validation proof, startup-time
             staleness bound, `_volatile_fields` lint, full artifact stability
             survey, post-R26 full regression rerun, and registry implementation
             planning under the registry authorization gate.
DOC-DEBT-31  S3-R27 audit authorization status:
             production durable audit implementation authorization was HELD by
             S3-R27-C1-A. R28 later closed the named design/proof/regression
             blockers, but did not itself authorize implementation.
DOC-DEBT-32  S3-R27 PROP-031 status:
             PROP-031 was proposal-only at R27 close. R28 supersedes that state:
             implementation/proof landed, with OOF-M1 stage and `contract_name`
             SemanticIR shape resolved.
DOC-DEBT-33  S3-R28 durable audit status:
             R28 closes the design/proof/regression evidence package for
             implementation-authorization review: compliance posture 14/14,
             signer validation 18/18, startup_time design amendment, and final
             29/29 matrix PASS. It does not authorize or land production durable
             audit implementation, production signing execution, registry
             runtime binding, Ledger/Phase 2, or any excluded surface.
DOC-DEBT-34  S3-R28 PROP-031 status:
             PROP-031 implementation/proof landed for parser, classifier,
             typechecker, and SemanticIR. OOF-M1 stage and `contract_name` are
             resolved. Effect Surface validation, `via profile`, authority
             resolution, service-loop checks, and runtime enforcement remain
             future proposals/work.
DOC-DEBT-35  S3-R29 authorization status:
             Architect production durable audit implementation authorization did
             not land in R29. C1 deferral is safe and no unauthorized
             implementation/deployment/signing/storage was attempted. R30 may
             route the decision; do not infer authorization from readiness.
DOC-DEBT-36  S3-R29 startup_time override:
             override interface design is closed, but no proof-local validator
             exists yet. R30 should implement the matrix, decide whether all
             non-default policies require expiry, and specify accepted/rejected
             proof-local authority fixture patterns.
DOC-DEBT-37  S3-R29 Covenant/CSM follow-ups:
             P28 is a governing commitment and not fully current enforcement.
             Track Compiler/Grammar enforcement gap table, reconcile the PROP
             Governance Filter with META-EXPERT-013 §VI, add V-3 dedicated
             temporal+observed golden, and keep CSM rows synchronized with new
             compiler entities.
DOC-DEBT-38  S3-R30 bounded durable audit authorization:
             S3-R30-C1-A authorizes a bounded implementation track only.
             Production deployment, concrete HSM/KMS, production signing
             execution/key management, production authority registry, Ledger,
             Phase 2, BiHistory, stream/OLAP executors, production cache, broad
             RuntimeMachine binding, and general write/replay/compact/subscribe
             remain closed until a later Architect decision.
DOC-DEBT-39  S3-R30 startup/V-3 proof closures:
             startup_time override validator PASSes 28/28 and V-3 observed+
             temporal golden PASSes 25/25. R31/R32 map syncs closed the stale
             Heat Map rows and authority-split row.
DOC-DEBT-40  S3-R30 PROP-032 status:
             PROP-032 assumptions block is proposal/draft only. It proposes an
             `epistemic` fragment class and OOF-A1 but does not implement parser,
             classifier, TypeChecker, SemanticIR, or goldens. Establish explicit
             implementation gate before Classifier work starts.
DOC-DEBT-41  S3-R30 governance follow-ups:
             OQ-Filter-1 was open at R30 close and is now closed by S3-R31-C2-A.
             OQ-P28-1 remains open for escape declaration naming enforcement.
DOC-DEBT-42  S3-R31 bounded audit implementation:
             C1-P closes proof-local schema/signer/store/excluded-surface proof
             (29/29 PASS, 5/5 invariants). Production deployment, HSM/KMS,
             production signing/key management, Ledger, Phase 2, BiHistory,
             stream/OLAP, cache, and broad RuntimeMachine binding remain closed.
             B-A later closed in R33; B-B/B-C later closed in R34. B-D must
             close before any deployment review.
DOC-DEBT-43  S3-R31 audit design amendments:
             C1-P discovered D1 canonical hash excluded fields and Q2
             compliance_posture storage/re-derivation ambiguity. Closed by
             S3-R32-C1-P with five-field hash algorithm, stored+derived+
             mismatch-checked compliance_posture, and the C1-P wording ambiguity
             resolved.
DOC-DEBT-44  S3-R31 governance authority sync:
             C2-A closes OQ-Filter-1: Covenant normative, META-EXPERT-013
             operational. Closed by S3-R32-C2-S: Covenant pointer,
             META-EXPERT-013 authority note, and Heat Map Domain 8 closure
             are applied. No PROP-032 implementation authorization.
DOC-DEBT-45  S3-R31 compiler-pack shadow work:
             Profile-Baseline-Pack is post-POC direction only. Shadow profile,
             native-style ContractModifiersPack descriptor, kernel registry spike,
             ordered-rule precedence, and compiler_profile_id boundary proofs do
             not authorize compiler dispatch, `.igapp` changes, native migration,
             or PROP-032 implementation. Draft a manifest/profile PROP before
             assembler or loader work.
DOC-DEBT-46  S3-R32 durable audit unblock:
             P-37/P-38 are closed. The design now defines five hash-excluded
             fields and stored+derived+mismatch-checked compliance_posture.
             B-A was later closed by S3-R33-C1-P; B-B/B-C/P-43 were later
             closed by S3-R34-C1-P/C2-P. B-D full post-implementation
             regression matrix remains open before any deployment review.
DOC-DEBT-47  S3-R32 PROP-032 Phase 1:
             Classifier support landed with assumptions_proof and regression
             checks PASS. PROP-032 later reached experiment-pass in S3-R36-C2-A.
             TypeChecker Phase 2 landed in R33, SemanticIR Phase 3 landed in
             R34, and parser/P28/source proof Phase 4 landed in R35. Full
             experiment-pass is bounded to compiler behavior; PROP-033 evidence
             validation and runtime receipt behavior remain excluded.
DOC-DEBT-48  S3-R32 compiler profile governance:
             The shadow dependency-map item is answered by the closure index and
             backreference. Closed for numbering by S3-R33-C3-A: PROP-036 is
             assigned to `compiler_profile_id` manifest identity. R34 C5-P
             authored the proposal. Acceptance and implementation authorization
             remain open.
DOC-DEBT-49  S3-R34 durable audit closures:
             B-B traversal/reader and B-C appender/reader role boundary are
             closed by proof-local R34 evidence; P-43 is closed by the clean
             rebuild append gate. R35 C2-S adds a curation note to C2-P's Open
             Blockers table so the cumulative B-B/B-D/B-E state is visible from
             the old track.
DOC-DEBT-50  S3-R34 PROP-036 lifecycle:
             PROP-036 is accepted proposal-only by S3-R35-C3-A. Do not open assembler, loader,
             artifact-hash/golden migration, receipt-link, `.igapp`, `.ilk`,
             runtime, or dispatch implementation until a separate Architect
             implementation card lands.
DOC-DEBT-51  S3-R34 progression scope:
             Progression/service-liveness is assigned PROP-037 by S3-R35-C4-A,
             numbering-only. Formal proposal authoring is next; no parser syntax,
             fragment class, TypeChecker, SemanticIR, RuntimeMachine scheduler,
             durable queue, or production execution is authorized.
DOC-DEBT-52  S3-R34 R35 route:
             R35 C1-P closes B-D full regression matrix. Next round should
             prioritize restricted durable-audit deployment follow-up under
             S3-R36-C1-A, PROP-036 proof/design follow-up if authorized, and
             PROP-037 authoring.
DOC-DEBT-53  S3-R35 B-D closure:
             Post-implementation matrix PASSes 9/9 commands and 97/97 durable
             audit proof cases. This is readiness for B-E Architect deployment
             review, not deployment approval. Production deployment, production
             signing/key management execution, concrete HSM/KMS onboarding,
             Ledger/Phase 2, BiHistory, stream/OLAP, production cache, and broad
             RuntimeMachine binding remain closed until a later explicit
             Architect decision.
DOC-DEBT-54  S3-R35 proposal lifecycle labels:
             Proposal index now uses lifecycle labels (`draft`,
             `authored-pending-review`, `accepted`, `conditional-accepted`,
             `implemented-proof`, `experiment-pass`, `deferred`). Track `done`
             is card completion only and does not imply proposal acceptance.
DOC-DEBT-55  S3-R36 preflight sync:
             R35 C2-S forward recommendations for PROP-036 acceptance,
             PROP-037 assignment, and PROP-032 experiment-pass are superseded
             by S3-R35-C3-A, S3-R35-C4-A, and S3-R36-C2-A. Current maps now
             treat those as landed evidence. B-E is superseded by S3-R36-C1-A:
             restricted Phase 1 durable audit deployment scope is approved, but
             excluded runtime/Ledger/HSM/KMS surfaces remain closed.
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
PROP-031   Contract modifiers            experiment-pass; parser/classifier/typechecker/SemanticIR
                                         implementation + proof PASS; R29 §14 compatibility addendum;
                                         no Effect Surface/Profile/runtime enforcement
PROP-032   Assumptions block             experiment-pass; assumptions {} + uses assumptions NAME;
                                         bounded compiler surface only; PROP-033 evidence validation
                                         and runtime receipt behavior excluded
PROP-033   via profile binding           queued; not authored
PROP-034   output evidence syntax        queued; not authored
PROP-035   profile declarations          queued; not authored
PROP-036   compiler_profile_id manifest  accepted proposal-only; implementation blocked;
                                         no implementation or migration auth
PROP-037   progression/service liveness  assigned numbering-only; proposal not authored
PROP-038+  managed local recursion       placeholder only; not assigned, not canon without proposal/proof
```

→ Close governance: `meta-proposals/META-EXPERT-009.1-stage2-close-decision-v0.md`
→ Stage 1 governance: `meta-proposals/META-EXPERT-007-stage1-close-governance-v0.md`
