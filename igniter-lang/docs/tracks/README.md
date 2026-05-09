# Igniter-Lang Tracks

Status: active index
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-09

---

## Purpose

Track documents are slice evidence, not the global project log.

New agents should start from `docs/README.md`, `docs/operating-model.md`,
`docs/agent-context.md`, `docs/current-status.md`, and the assigned track only.

---

## Current Navigation

| Need | Start here |
|------|------------|
| Trusted current context | `../agent-context.md` |
| Current language state | `../current-status.md` |
| Process / handoff rules | `../operating-model.md` |
| Canonical spec | `../spec/` |
| Proposal queue | `../proposals/README.md` |
| Historical archaeology | `../archive/` or git history |

---

## Stage 3 Round 19 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `phase1-r18-cleanup-regression-rerun-v0.md` | done | Post-R18 full regression rerun PASS 15/15; includes R18 backend identity guard proof and `observation.backend_identity_emitted: ok` |
| `../discussions/gate3-live-read-addendum-pre-signature-pressure-v0.md` | complete — PROCEED to Architect signature review | Evidence blockers 1-5 closed; blocker 6 remains Architect signature/status update; no hidden Ledger/BiHistory/stream/OLAP/cache/write path |
| `stage3-round19-status-curation-v0.md` | done | R19 status/index/context/gate sync — this track |

---

## Stage 3 Round 18 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `../gates/gate3-live-read-decision-addendum-v0.md` | draft-not-signed | Addendum drafted for restricted Phase 1 non-proof read path; explicitly does not open live reads or authorize `gate3_authorized: true` |
| `temporal-executor-proof-local-docstring-amendment-v0.md` | done | Source comments clarify `GATE3_AUTHORITY_REF` is source-code-parity only, `observations` are in-memory/non-audit, and `gate3_authorized` is caller honor-system |
| `runtime-temporal-scope-exclusion-reason-alias-v0.md` | done | Lib emissions canonicalized to `runtime.temporal_scope_exclusion`; legacy narrow strings retained as aliases; proof PASS |
| `phase1-backend-identity-guard-v0.md` | done | Code-level backend identity guard blocks unmarked, Ledger-backed, Ledger proxy, and malformed backends before scope/cache/kernel/read; proof PASS |
| `../discussions/live-read-addendum-draft-safety-pressure-v0.md` | complete — proceed; two pre-signing conditions | Cleanup tracks correctly scoped and non-authorizing; two pre-signing conditions were routed and later closed by R19 |
| `stage3-round18-status-curation-v0.md` | done | R18 status/index/context/gate sync — this track |

---

## Stage 3 Round 17 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `phase1-lib-prep-regression-chain-rerun-v0.md` | done | Post-C1 lib-prep regression rerun PASS 14/14 across S3-R7..R10, S3-R13..R16, Stage 1, and Stage 2; safety pressure may proceed |
| `runtime-temporal-executor-lib-boundary-spec-sync-rerun-v0.md` | done | Ch7 now names `IgniterLang::TemporalExecutor::Phase1` as proof-local implementation boundary with `gate3_authorized: false`, guard order, composed report, and exact authority_ref |
| `../discussions/runtime-temporal-executor-lib-prep-safety-pressure-v0.md` | complete — PROCEED | All eight scope guarantees confirmed for proof-local Phase 1; routes docstring amendments, reason-code alias, backend identity guard, and live-read addendum track |
| `stage3-round17-status-curation-v0.md` | done | R17 status/index/context/gate sync — this track |

---

## Stage 3 Round 16 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `runtime-temporal-executor-lib-prep-v0.md` | done | S3-R16 C1 landed `IgniterLang::TemporalExecutor::Phase1` in lib/ with `gate3_authorized: false` default, exact authority_ref, CompatibilityReport-shaped hash, token-before-gate order, and targeted proof PASS 17/17; live reads still blocked |
| `phase1-lib-prep-regression-chain-v0.md` | stale-blocked | S3-R16 C2 track was written before C1 landed and records dependency absent; superseded by R17 rerun |
| `runtime-temporal-executor-lib-boundary-spec-sync-v0.md` | stale no-op | S3-R16 C3 track was written before C1 landed and made no Ch7 edit; superseded by R17 spec-sync rerun |
| `stage3-round16-status-curation-v0.md` | done | R16 status/index/context/gate sync — this track |

---

## Stage 3 Round 15 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `runtime-report-enforcement-order-amendment-v0.md` | done | Ordering drift fixed: canonical `CompatibilityReport -> approval_token -> gate_state -> scope -> cache_key -> executor_backend`; no PROP-030 errata needed |
| `runtime-report-enforcement-preflight-v0.md` | amended | Preflight doc and proof now use token-before-gate ordering; mixed failure proves missing approval wins before Gate 3 closed |
| `runtime-temporal-executor-composition-integration-v0.md` | done | AT-2 closed: Phase1TemporalExecutorWithReport consumes one composed CompatibilityReport and rejects split fragments before executor/gate/token/cache/backend paths |
| `executor-approval-authority-ref-proof-v0.md` | done | AT-9 proof-local PASS: exact decision-record `authority_ref` accepted; missing/wrong/stale/self-issued refs refused before live paths |
| `phase1-prelive-regression-chain-v0.md` | done | Base S3-R7..R10 chain PASS 9/9; added pre-live surface PASS 6/6; Stage 1 and Stage 2 close candidates PASS; lib-prep allowed next |
| `stage3-round15-status-curation-v0.md` | done | R15 status/index/context/gate sync — this track |

---

## Stage 3 Round 14 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `../gates/gate3-decision-record-v0.md` | amended | Phase 1 authority URI constant and active revocation paths recorded; runtime authority registry remains future Phase 2/prod work |
| `runtime-temporal-executor-phase1-preflight-v0.md` | done | Proof-local `Phase1TemporalExecutor` 9/9 PASS; initial composition/authority gaps closed by R15; experiments-local only |
| `temporal-scope-exclusion-runtime-fixture-v0.md` | done | `runtime.temporal_scope_exclusion` proved for CORE, STREAM, OLAP, BiHistory, Ledger write/replay, and unknown surfaces before live paths; History valid-time control accepted |
| `runtime-report-enforcement-preflight-v0.md` | amended in R15 | Composed-report preflight matrix PASS with blocked operation flags false; R15 fixed canonical token-before-gate ordering |
| `spec-ch7-gate3-approval-sync-v0.md` | done | Ch7 now reflects approved-restricted Phase 1, pre-live block, AT-1..AT-12, scope exclusion, and closed adjacent surfaces |
| `../discussions/phase1-implementation-prep-safety-pressure-v0.md` | complete — PROCEED | No live-eval/Ledger/BiHistory/cache leak; proof-local Phase 1 may continue; production/live blockers are C4 ordering, AT-2 integration, AT-9 URI comparison |
| `news-clarity-aggregator-syntax-pressure-form-v0.md` | done | Non-canon syntax/product pressure only; no parser/runtime/spec authorization |
| `truth-systems-osint-applied-pressure-v0.md` | done | Applied truth-system/OSINT pressure; synthetic/public-style safety boundary; no canon promotion |
| `general-purpose-fixtures-syntax-pressure-form-v0.md` | done | Cross Test 2 syntax/product pressure for HTTP API, AgentKnowledgeMesh, ClarityDuelEngine, LegalAdvocateOSINT; raw snippets should not become parser fixtures verbatim |
| `general-purpose-and-legal-osint-applied-pressure-v0.md` | done | Applied pressure routes HTTP/JSON baseline, agent knowledge conflict, truth-system evidence bundles, legal safety, and agent authority profiles; no implementation authorization |
| `general-purpose-fixtures-syntax-pressure-form-cross-test-3-v0.md` | done | Cross Test 3 pressure for EmergencyAgentMeshReplicator and DecentralizedMarketplace; self-replication/self-modification/escrow remain high-risk product pressure only |
| `general-purpose-emergency-mesh-marketplace-pressure-v0.md` | done | Applied emergency mesh/marketplace pressure; recommends controlled synthetic fixtures before any live spawn/patch/escrow adapter discussion |
| `stage3-round14-status-curation-v0.md` | done | R14 status/index/context/gate sync — this track |

---

## Stage 3 Round 13 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `../gates/gate3-decision-record-v0.md` | approved-restricted-phase1 | Architect decision authorizes Phase 1 TEMPORAL History[T] valid_time executor implementation via abstract proof-local/non-Ledger TBackend; live reads remain blocked until pre-live conditions, AT-1..AT-12, and regression proof chain pass |
| `../proposals/PROP-030A-temporal-scope-exclusion-errata-v0.md` | proposal | Canonical scope-exclusion refusal code: `runtime.temporal_scope_exclusion`; does not authorize new executor/backend scope |
| `prop-030-temporal-scope-exclusion-errata-v0.md` | done | Formalizes PROP-030A errata and refusal mapping for out-of-scope TEMPORAL executor attempts |
| `prop-005-temporal-read-observation-v0.md` | done | Defines minimum `temporal_read_observation` envelope for authorized live History[T] reads; proof PASS; no live TBackend/Ledger eval |
| `compatibility-report-composition-v0.md` | done | Defines single composed CompatibilityReport shape for readiness + enforcement; proof PASS; split report/enforcement fragments rejected |
| `../discussions/gate3-decision-safety-pressure-v0.md` | complete — PROCEED | X1 finds no hidden authorization leaks; recommends non-blocking wording amendments and Phase 2 authority/addendum follow-ups |
| `stage3-round13-status-curation-v0.md` | done | R13 status/index/context/gate sync — this track |

---

## Stage 3 Round 12 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `runtime-temporal-executor-gate3-request-revision-v0.md` | done | S3-R11-X1 HOLD resolved: authority ref is gate-opening precondition; AT-10 unconditional (Q5 closed); AT-12 added (CORE refusal); Q3 Option C phases defined; scope-not-expanded binding added; routed to R13 Architect decision |
| `gate3-request-revision-spec-review-v0.md` | done | Compiler/Grammar review found no semantic/spec blocker for Architect review; superseded by R13 approved-restricted decision; no parser, SemanticIR node-kind, BiHistory, stream/OLAP, or production-cache authorization |
| `gate3-regression-proof-chain-index-v0.md` | done | S3-R7..R10 proof-chain index added with commands, expected outputs, risk coverage, and proof-local vs production-required boundaries; no named proof missing |
| `gate3-tbackend-adapter-phase-plan-v0.md` | done | Bridge phase plan: base Gate 3 may authorize abstract History[T] valid_time read interface only; Phase 1 non-Ledger/proof-local; Phase 2 real Ledger adapter requires Architect addendum |
| `../discussions/gate3-request-revision-safety-pressure-v0.md` | complete — PROCEED | X1 confirms both S3-R11 HOLD blockers closed; no new blocker-level ambiguity; request is safe to route to Architect review, not approved |
| `stage3-round12-status-curation-v0.md` | done | R12 status/index/context/value sync — this track |

---

## Stage 3 Round 11 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `../gates/runtime-temporal-executor-gate3-request-v0.md` | revised / decided | Gate 3 opening request; S3-R11-X1 HOLD resolved (S3-R12-C1-S); restricted scope became R13 approved-restricted Phase 1; live reads still blocked |
| `gate3-acceptance-condition-matrix-v0.md` | done | Extracts prerequisite matrix from S3-R7..R10 evidence; marks production RuntimeMachine binding, authority/revocation/signature, report persistence/audit, unified report composition, physical TBackend serving proof, and cache enforcement as missing production items |
| `gate3-ledger-tbackend-scope-and-bihistory-exclusion-v0.md` | done | Recommends first Gate 3 request be History[T] valid_time read-only; BiHistory, writes, replay, compact, subscriptions, stream binding, and migrations excluded |
| `gate3-request-spec-consistency-check-v0.md` | done | Request shape is coherent with PROP-028/PROP-030/Ch6/Ch7; no parser/syntax authorization; C4 noted the request artifact missing at its review point, while current discovery finds C1 in `docs/gates/` |
| `../discussions/gate3-request-safety-pressure-v0.md` | complete — HOLD | X1 says request intent/scope are sound but routing is held for two edits: authority ref must be in the decision record and live-read audit trace must not remain optional |
| `stage3-round11-status-curation-v0.md` | done | R11 status/index/context/value sync — this track |

---

## Stage 3 Round 10 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `executor-approval-token-report-proof-v0.md` | done | PROP-030 token validation matrix covered in report-only CompatibilityReport; valid token still blocks while Gate 3 is closed; no executor/TBackend/Ledger/cache call attempted |
| `guarded-runtime-executor-approval-enforcement-v0.md` | done | proof-local GuardedRuntimeMachine enforces missing approval, Gate 3 closed, and CORE-shaped TEMPORAL cache-key refusal before executor/cache/backend paths |
| `compatibility-report-package-descriptor-consumption-v0.md` | done | ratified Gate 2 package descriptor metadata consumed into report-only `backend_check.temporal_backend_descriptor`; `runtime_enforced=false`; Gate 3 closed |
| `invariant-source-metadata-preservation-v0.md` | done | parser/classifier/typechecker/SemanticIR preserve descriptive invariant source metadata and start span; no new invariant semantics |
| `stage3-round10-status-curation-v0.md` | done | R10 status/index/context sync — this track |

## Stage 3 Round 9 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `descriptor-gate2-architect-ratification-record-v0.md` | ratified | Gate 2 ratified for metadata-only descriptor exposure; trusted report metadata only; Gate 3 closed |
| `prop-030-executor-approval-token-contract-v0.md` | done | PROP-030 drafted; ExecutorApprovalToken is a Gate 3 prerequisite backed by Architect authority; proposal-only, no executor implementation |
| `executor-boundary-cache-key-contract-v0.md` | done | executor boundary must use `manifest.contract_index.cache_key_schema_hint`; TEMPORAL keys require temporal coordinates; CORE-shaped TEMPORAL keys refuse with L-T5-style fault |
| `guarded-runtime-c2-profile-consistency-v0.md` | done | S3-R8 C2 claimed-executor and approved-placeholder profiles are blocked in CompatibilityReport and refused by GuardedRuntimeMachine with explicit reason mapping |
| `stream-replay-metadata-emission-v0.md` | done | stream replay metadata now emitted into SemanticIR nodes and assembled `stream_nodes`; full smoke uses assembled metadata, no proof-local defaults |
| `stage3-round9-status-curation-v0.md` | done | R9 status/index/context sync — this track |

## Stage 3 Round 8 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `runtime-smoke-post-switch-full-coverage-v0.md` | done | all six current `emit_typed` surfaces covered: Add, stream_fold, OLAPPoint, History, BiHistory, invariant severity; TEMPORAL still refuses evaluation; C1/C3 report/guard cross-check included |
| `runtime-compatibility-report-executor-boundary-v0.md` | done | positive executor/live-binding report profiles added; capability flags and approved placeholder remain blocked without explicit approval and Gate 3 authorization; no live operations attempted |
| `descriptor-gate2-ratification-decision-v0.md` | ratify-recommended | Bridge recommendation for formal Gate 2 ratification; metadata-only descriptor exposure/report use allowed if Architect ratifies; Gate 3 closed |
| `prop-029-entrypoint-section-surface-v0.md` | done | PROP-029 authored; `entrypoint` proposed as named evaluation/run profile over existing contract, `section` as grouping-only source organization; no parser implementation |
| `../discussions/stage3-round8-pre-gate3-pressure-v0.md` | complete — routed | X1 grouped executor approval token, executor cache-key proof, report/runtime enforcement, and stream metadata as pre-Gate-3 prerequisite package |
| `stage3-round8-status-curation-v0.md` | done | R8 status/index/context sync — this track |

## Stage 3 Round 7 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `docs-value-hoisting-micro-round-v0.md` | done | docs micro-round: cold snapshot after S3-R7 plus `../value-index.md` as hoisted durable-idea map |
| `runtime-compatibility-report-temporal-load-check-v0.md` | done | CompatibilityReport-shaped boundary separates bundle load from evaluation readiness; TEMPORAL loads for inspection while evaluation remains blocked; report-only and `runtime_enforced=false` |
| `invariant-typed-shape-discharge-v0.md` | done | `invariant_valid` typed shape accepted as production shape; C-8 delta discharged; no rollback to parsed emitter |
| `runtime-smoke-temporal-post-switch-v0.md` | done | post-switch CORE Add bundle evaluates (`sum=42`); TEMPORAL BiHistory bundle loads for inspection and refuses evaluation structurally |
| `spec-entrypoint-sync-v0.md` | done | `entrypoint`/`section` disposition set: Stage 3 proposal candidates only; no parser support, no hard keyword reservation, `contract` remains canonical boundary |
| `descriptor-compatibility-package-consumption-v0.md` | done | package descriptor fields mapped to report-only `backend_check.temporal_backend_descriptor`; Gate 2 ratification still formal approval point; Gate 3 remains closed |
| `../discussions/runtime-compatibility-and-typed-delta-pressure-v0.md` | complete — routed | X1 found no current production bug; routes full post-switch smoke, executor-boundary case, and C1/C3 cross-validation before Gate 3 |
| `stage3-round7-status-curation-v0.md` | done | R7 status/index/context sync — this track |

## Stage 3 Round 6 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `../agent-context.md` | done | trusted first context layer added: read order, do-not-reread guard, active gates, conflict rule, ownership reminders, proof/test budget |
| `spec-ch6-semanticir-temporal-sync-v0.md` | done | Ch6 synced to current Stage 3 SemanticIR/.igapp shape: temporal nodes, `temporal_nodes`, `fragment_summary`, `contract_index`, requirements derivation, guard policy |
| `spec-ch4-temporal-fragment-sync-v0.md` | done | Ch4 synced with TEMPORAL as first-class fragment, node/value/contract split, History/BiHistory classification, OOF-TM aliases, parser syntax caveat |
| `spec-ch7-runtime-temporal-cache-sync-v0.md` | done | Ch7 synced with CORE/TEMPORAL cache key schemas, freshness states, and `load_accept_evaluate_refuse` policy; no production cache/executor |
| `spec-ch5-emit-typed-sync-v0.md` | done | Ch5 synced after `CompilerOrchestrator` switch; `emit_typed` is production path and parsed emitter is Stage 1 legacy/comparison |
| `parity-track-stale-header-sweep-v0.md` | done | stale/superseded headers added to 4 old parity/cache tracks so old blocked states are not treated as current truth |
| `proposal-lifecycle-index-sync-v0.md` | done | PROP-022..025 → closed (Stage 2 PASS); PROP-028 → implementation-partial; PROP-022A added to index as experiment-pass; proposals/README.md restructured into 3 sections with lifecycle vocabulary; Stage 1 deferred gap resolved |
| `../discussions/docs-context-and-spec-sync-pressure-v0.md` | complete — routed | X1 confirmed spec ch4–ch7 and role profiles are fresh; routed remaining scoreboard/agent-context/invariant/entrypoint doc debt |
| `stage3-round6-docs-status-curation-v0.md` | done | R6 docs round close map sync — this track |

## Spec Freshness Table

| Surface | Freshness | Anchor | Notes |
|---------|-----------|--------|-------|
| `docs/agent-context.md` | current | `../agent-context.md` | Trusted read order, gates, conflict rule, proof budget; S3-R15 next movement refreshed |
| `docs/spec/ch4-fragment-classification.md` | synced | `spec-ch4-temporal-fragment-sync-v0.md` | TEMPORAL fragment and node/value split current |
| `docs/spec/ch5-compiler-pipeline.md` | synced + discharged + metadata | `spec-ch5-emit-typed-sync-v0.md`; `invariant-typed-shape-discharge-v0.md`; `invariant-source-metadata-preservation-v0.md` | `emit_typed` production path current; invariant source metadata preservation landed |
| `docs/spec/ch6-semanticir.md` | synced + stream/invariant metadata | `spec-ch6-semanticir-temporal-sync-v0.md`; `stream-replay-metadata-emission-v0.md`; `invariant-source-metadata-preservation-v0.md` | STREAM replay metadata emitted; invariant source_metadata/source_span needs spec sync |
| `docs/spec/ch7-runtime.md` | synced + R15 green | `spec-ch7-runtime-temporal-cache-sync-v0.md`; `executor-approval-token-report-proof-v0.md`; `guarded-runtime-executor-approval-enforcement-v0.md`; `compatibility-report-package-descriptor-consumption-v0.md`; `../gates/gate3-decision-record-v0.md`; `../proposals/PROP-030A-temporal-scope-exclusion-errata-v0.md`; `prop-005-temporal-read-observation-v0.md`; `compatibility-report-composition-v0.md`; `spec-ch7-gate3-approval-sync-v0.md`; `runtime-temporal-executor-composition-integration-v0.md`; `executor-approval-authority-ref-proof-v0.md`; `phase1-prelive-regression-chain-v0.md` | Lib-prep may proceed; live reads remain blocked until prepared boundary proves same constraints |
| `docs/proposals/README.md` | synced + PROP-030A pending index check | `proposal-lifecycle-index-sync-v0.md`; `prop-029-entrypoint-section-surface-v0.md`; `prop-030-executor-approval-token-contract-v0.md`; `../proposals/PROP-030A-temporal-scope-exclusion-errata-v0.md` | Stage 2 closed, PROP-028 implementation-partial, PROP-022A experiment-pass, PROP-029/030 proposal-only; PROP-030A landed as proposal evidence |

---

## Stage 3 Round 5 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `temporal-assembler-manifest-contract-index-v0.md` | done | assembler now emits `manifest.fragment_summary` and per-contract `manifest.contract_index`; TEMPORAL cache hints and mismatch negatives proven; cache proof now prefers manifest index |
| `temporal-runtime-load-guard-v0.md` | done | proof-local `GuardedRuntimeMachine` uses `load_accept_evaluate_refuse`; valid TEMPORAL artifacts load for inspection; evaluation refuses unsupported runtime or missing caps |
| `bihistory-source-fixture-parity-gate-v0.md` | done | SparkCRM-shaped BiHistory source fixture added to parity harness; `sparkcrm_bihistory` moved from NOT_COMPARABLE to measured FAIL due to legacy parsed OOF; switch gate status PROCEED |
| `orchestrator-emit-typed-switch-v0.md` | done | `CompilerOrchestrator` production path switched to `emit_typed(typed)`; Stage 1, Stage 2, production compiler CLI, and release gate PASS; parsed emitter retained as Stage 1 legacy/comparison |
| `descriptor-package-exposure-gate2-ratification-v0.md` | ratify | recommends Gate 2 ratification for metadata-only package descriptor exposure; package spec 9 examples, 0 failures; Gate 3 remains closed |
| `stage3-round4-and-round5-status-curation-v0.md` | done | R4 repair + R5 close map sync — this track |
| `spec-stage3-sync-and-doc-compaction-plan-v0.md` | done | S3-R1..R5 evidence → spec backlog per chapter; CRITICAL stale sections in ch6/ch7 identified; 4 spec sync cards + 1 stale sweep card defined; 7 debt items registered |

## Stage 3 Round 4 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `temporal-assembler-boundary-v0.md` | done | temporal SemanticIR now assembles into `.igapp/`; temporal nodes stored as non-compute `temporal_nodes`; runtime execution marked unsupported; Stage 1/2 regressions PASS |
| `prop-022a-temporal-manifest-errata-v0.md` | done | docs-only errata chooses ContractIR canonical source plus manifest `contract_index` load-time projection; `fragment_class: mixed` rejected as TEMPORAL authority |
| `temporal-requirements-from-escape-boundaries-v0.md` | implemented | `requirements.json` now derives caps/effects/fragments from SemanticIR `escape_boundaries`; CORE, History, BiHistory, and Stream requirements differ in proof |
| `typed-emission-stage2-switch-decision-v0.md` | done | Meta Expert governance decision: Option B adopted — typed emission becomes sole Stage 2+ lowering path; switch gate = BiHistory source fixture parity PASS + stage2_close_candidate post-switch; next cards C5+C6 defined |
| `runtime-cache-proof-local-memoization-v0.md` | done | proof-local MemoryCacheStore validates CORE/TEMPORAL keys, stale/unknown rejection, provisional downgrade, and no raw input payload observations; no production cache |
| `descriptor-package-exposure-gate2-decision-v0.md` | decision-request | Gate 2 metadata-only package exposure request written; Gate 1 PASS reviewed; Gate 3 production binding explicitly closed |
| `../meta-proposals/syntax-pressure-review-results-v0.md` | research-review | S3-R3 pressure specimens reviewed; threshold, external pure, entrypoint/section routed toward proposal candidates; no syntax promoted to canon |
| `../meta-proposals/META-EXPERT-012-document-lifecycle-and-rotation-v0.md` | governance | document lifecycle/rotation methodology added; stale/lifecycle markers introduced for debt control |
| `../discussions/temporal-igapp-runtime-boundary-pressure-v0.md` | complete — routed | X1 pressure says deep-read proof-local load works, but manifest dispatch needed `contract_index` and load guard; both became R5 C1/C2 |

---

## Stage 3 Round 3 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `typed-emission-stage2-source-lowering-parity-v0.md` | done/blocked | typed source blockers dropped to 0; parity runner PASS with verdict blocked; `legacy_parity_delta_items=11`, `blocked_items=13`, `safe_to_switch_production_path=false` |
| `temporal-semanticir-access-node-v0.md` | done | typed History/BiHistory lower to `temporal_input_node` + `temporal_access_node`; fragment/capability/coordinate refs preserved; no parser syntax, cache, or production TBackend binding |
| `runtime-temporal-cache-contract-v0.md` | done | RuntimeMachine cache key/entry/freshness/observation contract defined from proof; no production memoization, cache store, or manifest change |
| `gem-release-automation-v0.md` | done | `bin/release-gate` PASS; gemspec, gem-native boundary, Stage 1, Stage 2, artifact build all PASS; local `.gem` and `.sha256` built; publish not attempted |
| `compatibility-report-descriptor-consumption-fixture-v0.md` | done | proof-local descriptor consumption fixture PASS; trusted/provisional/blocked cases covered; `runtime_enforced=false`; Gate 2 package exposure and Gate 3 production binding remain closed |
| `../meta-proposals/syntax-pressure-specimens-v0.md` | research-fixtures | Field Supply Watch v3 and Primitive Surface specimens/guides added as pressure artifacts only; no parser/spec/proposal/runtime changes |
| `../discussions/temporal-manifest-and-cache-boundary-pressure-v0.md` | complete — routed | S3-R3-X1 pressure: TEMPORAL survives through SemanticIR but not assembler boundary; `contract_file` temporal-node crash and manifest/requirements gaps routed |
| `stage3-round3-status-curation-v0.md` | done | S3-R3 map sync and R4 prep — this track |

## Stage 3 Round 2 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `typed-emission-canonical-shape-v0.md` | done/blocked | source-hash public identity and canonical compute JSON shape fixed; `package_facade_add` parity PASS; overall verdict still blocked with 7 remaining source-path blockers |
| `temporal-fragment-classifier-typechecker-v0.md` | done | PROP-028 first implementation boundary: History/BiHistory reads classify as TEMPORAL nodes that bind CORE values; TypeChecker preserves temporal metadata; SemanticIR/runtime/parser syntax still open |
| `temporal-cache-key-proof-v0.md` | done | proof-local CORE vs TEMPORAL cache-key model PASS; CORE-shaped keys for temporal evaluation are stale-collision bugs; no RuntimeMachine memoization added |
| `gem-release-policy-v0.md` | done | gem metadata placeholders closed; local release gate named; RubyGems publish requires Architect approval and human owner; CI/release automation still open |
| `../bridge/compatibility-report-descriptor-consumption-v0.md` | done | report-only bridge proposal: CompatibilityReport may consume descriptor metadata as backend evidence with `runtime_enforced: false`; no Ledger read/write/replay/runtime binding |
| `../meta-proposals/syntax-pressure-registry-v0.md` | research-registry | comprehension fixtures indexed as canon/proposal/pressure/non-canon experiment; no fixture syntax promoted to canon |
| `stage3-round2-status-curation-v0.md` | done | S3-R2 map sync and R3 prep — this track |

## Stage 3 Round 1 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `stage3-governance-opening-v0.md` | done | Stage 3 formally OPEN (2026-05-08); META-EXPERT-011; 5 lanes authorized; PROP-028 authorized; R1 cards issued |
| `../proposals/PROP-028-temporal-fragment-class-v0.md` | proposal | TEMPORAL fragment class proposal written; OOF > TEMPORAL > STREAM > CORE; cache key semantics specified |
| `typed-emission-main-path-parity-v0.md` | blocked | parity runner PASS with verdict blocked; do not switch orchestrator to `emit_typed` yet; 9 blocked items recorded |
| `../archive/snapshots/2026-05-07-stage2-close/README.md` | done | Stage 2 close snapshot archived as cold archaeology context |
| `../meta-proposals/axiomatic-and-system-forming-ideas-lens-v0.md` | research-note | АИ/СОИ captured as soft Stage 3 design lens, not spec/canon and not a hard gate |
| `stage3-round1-status-curation-v0.md` | done | S3-R1 map sync and R2 prep — this track |

## Stage 2 Round 15 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `../meta-proposals/META-EXPERT-009.1-stage2-close-decision-v0.md` | decision | Stage 2 formally CLOSED WITH DEFERRED GAPS on 2026-05-07; close candidate PASS, 8 proofs, 7 surface checks, 5 deferred gaps |
| `gem-native-package-boundary-specs-v0.md` | done | installed gem require/compile/igc proof PASS from isolated gem home; 7 checks PASS, 4 release-readiness gaps remain |
| `../meta-proposals/human-agent-comprehension-synthesis-v0.md` | research-synthesis | comprehension pressure synthesized; routes Stage 3 syntax experiments without canon promotion |
| `future-syntax-pressure-formalization-v0.md` | done | formal grammar questions extracted from pressure fixtures; no parser changes and no canon promotion |
| `stage2-round15-status-curation-v0.md` | done | R15 map sync and Stage 3 intake prep — this track |

## Stage 2 Round 14 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `stage2-close-candidate-v0.md` | done | close candidate runner PASS; JSON status `PASS`, verdict `stage2_close_candidate`, proofs_run=8, surface_checks=7, deferred_gaps=5 |
| `packages/igniter-ledger/docs/tracks/ledger-tbackend-adapter-descriptor-package-v0.md` | done | package-side metadata-only descriptor implemented; targeted package spec 9 examples, 0 failures |
| `stage2-round14-status-curation-v0.md` | done | R14 map sync — this track |

## Stage 2 Round 13 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `compiler-packaging-skeleton-v0.md` | done | prerelease gem skeleton, `IgniterLang::VERSION`, package CLI, and `bin/igc`; gem build/install and installed `igc compile` smokes PASS |
| `stage2-close-candidate-planning-v0.md` | done | planning-only R14 close runner design; target JSON schema, proof list, fixtures, and deferred gaps defined |
| `ledger-tbackend-adapter-descriptor-package-plan-v0.md` | done | package-side descriptor-only implementation plan; no runtime/Ledger operation binding authorized |
| `stage2-round13-status-curation-v0.md` | done | R13 map sync — this track |

## Stage 2 Round 12 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `runtime-smoke-extraction-v0.md` | done | `IgniterLang::RuntimeSmoke` extracted; CLI uses reusable callback; production compiler, assembler, and Stage 1 proofs PASS |
| `compiler-package-boundary-v0.md` | done | direct API, CLI, and load-path proof share `IgniterLang.compile(...)`; no gemspec/bin/version release packaging yet |
| `ledger-tbackend-adapter-descriptor-v0.md` | done | metadata-only Ledger descriptor fixture PASS; descriptor hash, registry hash, and missing-history diagnostics proven |
| `runtime-invariant-violation-observations-v0.md` | done | invariant violations emit runtime observation records linked to source `invariant_node`; invariant proof and Stage 1 PASS |
| `stage2-round12-status-curation-v0.md` | done | R12 map sync — this track |

## Stage 2 Round 11 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `packageable-compiler-api-v0.md` | done | top-level `IgniterLang.compile(...)` facade added; CLI delegates to facade; production compiler, SemanticIR, assembler, and Stage 1 proofs PASS |
| `invariant-severity-semanticir-lowering-v0.md` | done | typed invariants lower to `invariant_node`; output effect propagation and invariant coverage preserved; invariant proof PASS |
| `tbackend-ledger-bridge-conformance-v0.md` | done | docs-only Ledger-backed TBackend conformance map; descriptor-first, metadata-only package slice recommended |
| `stage2-round11-status-curation-v0.md` | done | R11 map sync — this track |

## Stage 2 Round 10 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `compiler-orchestrator-v0.md` | done | lib/igniter_lang/compiler_orchestrator.rb extracted |
| `stream-semanticir-surface-lowering-v0.md` | done | stream SemanticIR lowering PASS; stream_t_proof PASS |
| `production-tbackend-adapter-fixture-v0.md` | done | proof-local AdapterRegistry + CompatibilityReport persistence |
| `invariant-severity-parser-impl-v0.md` | done | PINV-1..4 + TINV-1..3 PASS; +3 typechecker cases |
| `stage2-round10-map-and-role-profile-refresh-v0.md` | done | R10 map sync — this track |

## Stage 2 Round 9 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `extract-assembler-module-v0.md` | done | lib/igniter_lang/assembler.rb extracted; Stage 1 goldens PASS; CLI PASS |
| `production-tbackend-adapter-shape-v0.md` | done | Docs-only: TBackend adapter shape spec; no code changes |
| `semanticir-stage2-surface-lowering-v0.md` | done | OLAP SemanticIR lowering in emitter; olap_point_proof PASS; stage1 PASS |
| `stage2-round9-map-refresh-v0.md` | done | R9 map sync — this track |

## Stage 2 Round 8 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `extract-semanticir-emitter-module-v0.md` | done | `lib/igniter_lang/semanticir_emitter.rb` extracted; source→SemanticIR golden PASS |
| `olap-point-typechecker-semanticir-v0.md` | done | OOF-O2..O5; `olap_access_node`; explicit `dims_record`; OLAP proof PASS |
| `stream-oof-s3-typechecker-v0.md` | done | ESCAPE-in-fold TypeChecker rule; stream OOF-S1..S5 all proven |
| `production-runtime-machine-temporal-access-integration-v0.md` | done | RuntimeMachine load/evaluate proof-local hook integration; TBackend adapter still future |

## Stage 2 Round 7 Evidence

| Track | Status | Notes |
|-------|--------|-------|
| `extract-typechecker-module-v0.md` | done | lib/igniter_lang/typechecker.rb extracted; typechecker_proof + CLI PASS |
| `stream-oof-s2-classifier-v0.md` | done | OOF-S2 missing-window classifier rule; golden PASS; semanticir golden PASS |
| `runtime-machine-temporal-access-hook-proof-v0.md` | done | RuntimeMachineHook wired in history+bihistory proofs; both PASS |
| `olap-point-parser-implementation-v0.md` | done | revenue_point.ig parses live; olap_points[]; dims_record; parser spec 61 PASS |
| `stage2-round7-map-refresh-v0.md` | done | R7 map sync — this track |

## Stage 2 Round 6 Evidence (summary)

| Track | Status | Notes |
|-------|--------|-------|
| `extract-classifier-module-v0.md` | done | lib/igniter_lang/classifier.rb extracted |
| `stream-classifier-escape-propagation-v0.md` | done | SC-1/2/3 ESCAPE propagation; semanticir goldens 6→9 |
| `runtime-machine-temporal-access-hook-v0.md` | done | RuntimeMachineHook spec + smoke |
| `olap-point-parser-typechecker-boundary-v0.md` | done | Grammar spec: dims_record, OOF-O1..5; olap_point_proof 21 PASS |

---

## igniter-lang/lib — Current State (14 files)

```text
igniter_lang.rb           (R11/R13) — package facade; exposes VERSION + compile
igniter_lang/version.rb   (R13) — prerelease package version
igniter_lang/cli.rb       (R13) — thin package CLI for igc compile
diagnostics.rb            (R3)
compiler_result.rb        (R4)
compilation_report.rb     (R4)
parser.rb                 (R5/R7/R10) — parser + stream + olap_point + invariant
temporal_access_runtime.rb (R5–R7) — MemoryBackend + RuntimeMachineHook
temporal_executor.rb    (S3-R16) — proof-local Phase1 History[T] valid_time executor boundary; live blocked by default
runtime_smoke.rb          (R12) — reusable proof-backed RuntimeSmoke callback
classifier.rb             (R6/R7/S3-R2/R3) — ParsedProgram→ClassifiedProgram; stream/temporal metadata
typechecker.rb            (R7/R8/R10/S3-R2/R3) — TypedProgram boundary; stream/OLAP/invariant/TEMPORAL
semanticir_emitter.rb     (R8/R9/R10/R11/S3-R3) — SemanticIR emitter; typed temporal lowering
assembler.rb              (R9/S3-R4/R5) — .igapp/ assembler; temporal nodes + manifest contract_index
compiler_orchestrator.rb  (R10/S3-R5) — compiler pass orchestration; production path uses emit_typed
```

---

## Stage 3 Next Recommendations

| Candidate | Purpose | Role | Status |
|-----------|---------|------|--------|
| Architect signature review for `gate3-live-read-decision-addendum-v0.md` | Review addendum for explicit signed/status update; signing is the first possible live-read authorization event | Architect Supervisor | ready for review |
| signing-record citation notes | Cite S3-R19-C1-P 15/15 PASS and attribute guard-order amendment to S3-R18-X1 PS-2 | Architect Supervisor | non-blocking note |
| first post-signature fixture | If addendum is signed, verify no behavior change accompanies signing and caller must reference signed document | Research Agent | after signature only |
| `phase1-r18-cleanup-regression-rerun-v0` | Re-run the full proof chain after R18 C2/C3/C4 code changes; include observation backend_identity assertion | Research Agent | done |
| `gate3-live-read-decision-addendum-v0` guard-order amendment | Amend draft order to `approval_token -> gate_state -> backend_identity -> scope -> cache_key -> executor_backend` | Architect Supervisor / Meta Expert | done |
| `gate3-live-read-decision-addendum-v0` | Draft Architect decision addendum for Phase 1 live reads only; drafting is done; live reads still blocked until signed | Architect Supervisor | draft-not-signed / ready for signature review |
| proof-local authority/observation docstring amendments | Add source comments clarifying `GATE3_AUTHORITY_REF` is not cryptographic authorization and `observations` are in-memory, not audit receipts | Implementation Agent | done |
| `runtime-temporal-scope-exclusion-reason-alias-v0` | Reconcile lib proof-local reason codes with canonical `runtime.temporal_scope_exclusion` before operators see codes | Compiler/Grammar Expert | done |
| `phase1-backend-identity-guard-v0` | Add backend identity guard before any Phase 2 adapter binding can make `gate3_authorized: true` reach a real backend | Implementation Agent / Bridge Agent | done |
| `phase1-lib-prep-regression-chain-rerun-v0` | Re-run S3-R7..R10 plus R13..R16 lib-prep fixtures against landed C1 | Research Agent | done |
| `runtime-temporal-executor-lib-boundary-spec-sync-rerun-v0` | Re-evaluate Ch7/runtime docs now that C1 exists; document only stable implementation boundary, no new semantics | Compiler/Grammar Expert | done |
| `runtime-temporal-executor-lib-prep-safety-pressure-v0` | Review lib-prep for live-read leakage, Ledger/BiHistory/cache expansion, and preservation of blocked-before-call guarantees | External Pressure Reviewer | done — proceed proof-local |
| `runtime-temporal-executor-lib-prep-v0` | Prepare lib-bound Phase 1 History[T] valid_time path using composed CompatibilityReport, token-before-gate preflight, authority_ref exact match, scope/cache/observation guards | Implementation Agent | landed |
| `gate3-authority-registry-v0` | Define trusted authority/revocation source for PROP-030 tokens before Phase 2; do not imply live Ledger binding | Bridge Agent + Research Agent | before Phase 2 |
| `gate3-phase2-addendum-process-v0` | Define explicit Architect addendum route for real Ledger adapter/package binding after Phase 1 | Meta Expert / Bridge Agent | before Phase 2 |
| `compatibility-report-persistence-audit-v0` | Persist report decisions and audit receipts; keep live operations gated until Phase 1 AT/regression pass | Research Agent / Bridge Agent | after Phase 1 preflight |
| `external-http-json-capability-pressure-v0` | Define minimum HTTP/JSON capability profile: request, response, error, redaction, replay, receipt, and refusal cases | Compiler/Grammar Expert + Bridge Agent | pressure backlog |
| `controlled-agent-replication-boundary-pressure-v0` | Define spawn intent/receipt, resource budget, authority inheritance, and refusal diagnostics before emergency mesh fixtures | Research Agent + Bridge Agent | pressure backlog |
| `data-role-vocabulary-specimen-v0` | Narrow `packet/event/receipt` pressure into evidence/receipt/proof vocabulary candidates without parser promotion | Compiler/Grammar Expert | pressure backlog |
| `store-declaration-surface-pressure-v0` | Continue recurring `store` pressure across History/BiHistory/product fixtures without implying live evaluation | Compiler/Grammar Expert + Research Agent | pressure backlog |
| `compatibility-report-package-adoption-v0` | Package/Bridge adoption of report-only descriptor consumption shape while preserving `runtime_enforced=false` and no live binding | Bridge Agent / Package Agent | recommended |
| `spec-ch6-invariant-source-metadata-sync-v0` | Document optional `source_metadata` / `source_span` on `invariant_node` and invariant coverage report entries | Compiler/Grammar Expert | docs/spec sync |
| `entrypoint-section-parser-typechecker-v0` | Implement and prove PROP-029 contextual parser/typechecker behavior only after proposal acceptance | Compiler/Grammar Expert | gated |
| `gem-release-ci-wiring-v0` | Wire `bin/release-gate` into CI or preserve release artifacts/checksum under an approved release record; publish remains gated | Research Agent | optional |
| `syntax-thresholds-and-constants-prop-v0` | Draft proposal for named thresholds/constants from S3-R4 review signals; no parser implementation yet | Compiler/Grammar Expert | proposal |
| `syntax-external-pure-helper-signatures-prop-v0` | Draft proposal for `external pure fn(...) -> T` helper signatures and effect/evidence annotations | Compiler/Grammar Expert + Bridge Agent | proposal |
| `invariant-persistence-boundary-v0` | Production RuntimeMachine invariant observation persistence boundary remains open from Stage 3 intake | Research Agent | authorized |
| `typed-emission-post-switch-baseline-v0` | Archive/normalize post-switch public compile goldens and document parsed emitter as Stage 1 legacy comparison only | Research Agent | optional |

---

## Handoff Template

```text
Card:
Agent: [Igniter-Lang <Agent Name>]
Role: <role-profile-id>
Track:
Status:

[D] Decisions
- ...

[S] Shipped / Signals
- ...

[T] Tests / Proofs
- ...

[R] Risks / Recommendations
- ...

[Next] Suggested next slice
- ...
```
