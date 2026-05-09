# Igniter-Lang Agent Context

Status: active current-context capsule
Maintained by: `[Igniter-Lang Meta Expert]` in Status Curator mode
Last updated: 2026-05-09

---

## Purpose

This file is the trusted first context layer for new Igniter-Lang agents.

Use it to avoid reconstructing the whole project from old tracks, archives, or
stale spec copies. It is a compact map of the current horizon, source-of-truth
rules, active gates, and proof budget.

If your card asks for archaeology, bridge/package review, or spec-lag repair,
read the named older materials. Otherwise, start here and stay narrow.

---

## Read First

Every non-discussion slice should read, in order:

1. `igniter-lang/AGENTS.md`
2. `igniter-lang/roles/README.md`
3. assigned role profile in `igniter-lang/roles/`
4. `igniter-lang/docs/agent-context.md`
5. `igniter-lang/docs/current-status.md`
6. `igniter-lang/docs/operating-model.md`
7. assigned track/proposal/source files
8. relevant spec chapters only when the card touches language semantics

Read `igniter-lang/docs/value-index.md` when the card asks for strategy,
documentation compaction, archaeology routing, applied pressure, or next-round
planning. It is a hoisted durable-idea map, not required context for every
implementation slice.

Discussion cards should also read:

```text
igniter-lang/docs/discussions/README.md
```

Bridge/package cards should read package docs only when the card names that
boundary.

---

## Do Not Reread By Default

Do not reread these unless the card explicitly asks:

- `docs/archive/`
- old completed tracks not named by the card
- package docs outside the assigned bridge/package boundary
- pre-crystallization archaeology
- broad proposal history unrelated to the slice
- full proof suites not named by the card

Completed track docs are evidence, not required context for every slice.

---

## Current Horizon

```text
Source .ig
  -> Parser -> Classifier -> TypeChecker
  -> SemanticIREmitter.emit_typed(typed)        ✅ production path
  -> SemanticIR temporal/core/stream nodes      ✅ proven
  -> Assembler .igapp
       manifest.fragment_summary               ✅ emitted
       manifest.contract_index                 ✅ emitted
       requirements from escape_boundaries      ✅ emitted
       compatibility_metadata guard_policy      ✅ emitted
  -> RuntimeMachine
       load TEMPORAL for inspection             ✅ proof-local + report shape
       CompatibilityReport load/eval split      ✅ report-only
       package descriptor backend_check         ✅ report-only
       full post-switch smoke                   ✅ all six emit_typed surfaces
       executor/live-binding report profiles    ✅ modeled; still blocked
       ExecutorApprovalToken proposal           ✅ prerequisite only
       ExecutorApprovalToken report matrix      ✅ report-only
       executor cache-key boundary              ✅ TEMPORAL key or L-T5 refusal
       C2 guarded-runtime consistency           ✅ mapped refusal
       guarded approval enforcement             ✅ proof-local refusal
       Gate 3 Phase 1 decision                  ✅ approved-restricted implementation
       CompatibilityReport composition          ✅ proof-local composed shape
       temporal_read_observation envelope       ✅ proof-local minimum envelope
       temporal_scope_exclusion reason          ✅ PROP-030A
       Phase1TemporalExecutor preflight         ✅ proof-local 9/9; experiments-local only
       report enforcement preflight             ✅ proof-local matrix; ordering amendment needed
       temporal scope exclusion fixture         ✅ excluded surfaces refuse before live paths
       Ch7 Gate 3 approval sync                 ✅ approved-restricted semantics synced
       report preflight ordering                ✅ token-before-gate fixed
       AT-2 composed report integration         ✅ closed
       AT-9 authority_ref exact match           ✅ proof-local PASS
       pre-live regression chain                ✅ 17/17 PASS
       runtime temporal executor lib-prep       ✅ lib/ Phase1 PASS 17/17
       post-C1 lib-prep regression rerun        ✅ 14/14 PASS
       lib boundary spec sync                   ✅ Ch7 proof-local boundary sync
       lib-prep safety pressure                 ✅ PROCEED for proof-local Phase 1
       live-read addendum draft                 ⚠️ draft-not-signed; ready for signature review
       proof-local docstring warnings           ✅ authority/observation/honor-system comments
       scope-exclusion reason aliases           ✅ canonical runtime.temporal_scope_exclusion
       backend identity guard                   ✅ blocks unmarked/Ledger/proxy backends before live paths
       R18 cleanup regression rerun             ✅ 15/15 PASS
       addendum pre-signature pressure          ✅ PROCEED to Architect signature review
       evaluate TEMPORAL Phase 1 live           🚫 blocked; addendum not signed
       memoize TEMPORAL                         🚫 proof-local only
  -> Ledger / TBackend
       descriptor metadata                      ✅ Gate 2 ratified
       descriptor report mapping                ✅ report-only
       Gate 2 ratification record               ✅ ratified
       Phase 1 abstract non-Ledger adapter      ✅ implementation authorized
       Ledger adapter / package binding         🚫 Phase 2 addendum required
       live Ledger operations                   🚫 closed
  -> Stream replay
       assembled stream_nodes metadata          ✅ emitted
       production stream executor               🚫 not authorized
  -> Invariant metadata
       source_metadata/source_span              ✅ preserved
       runtime persistence                      🚫 still open
  -> Release
       release-gate artifact/checksum           ✅ PASS
       RubyGems publish                         🚫 approval/MFA required
```

Current production compiler path:

```text
Parser -> Classifier -> TypeChecker -> SemanticIREmitter.emit_typed -> Assembler
```

`SemanticIREmitter#emit(parsed, sample_input:)` remains as Stage 1
legacy/internal comparison, not the production path.

---

## Active Gates

| Gate | State | Rule |
|------|-------|------|
| Stage 1 | CLOSED | Preserve regression proof unless card says otherwise. |
| Stage 2 | CLOSED WITH DEFERRED GAPS | Do not reopen closed Stage 2 surfaces casually. |
| Stage 3 | OPEN | Work within current lane/card. |
| Typed emission | SWITCHED | Production orchestrator uses `emit_typed(typed)`. |
| TEMPORAL load | PROOF-LOCAL | Load accepts valid TEMPORAL `.igapp/` for inspection. |
| TEMPORAL evaluate | READY FOR SIGNATURE REVIEW / LIVE BLOCKED | R19 closed pre-signing repair: 15/15 regression PASS, backend_identity observation asserted, guard order amended, and X1 says PROCEED to Architect signature review. Live reads remain blocked until the addendum is signed. |
| Runtime cache | PROOF-LOCAL | Cache key/memoization proofs exist; no production cache. |
| TBackend Gate 1 | PASS | Report-only descriptor consumption fixture. |
| TBackend Gate 2 | RATIFIED | Metadata-only package descriptor exposure and report-only descriptor mapping are trusted report metadata; no runtime authority. |
| Gate 3 prerequisite package | LANDED | Gate 2 ratified, PROP-030 drafted, token report proof, guarded enforcement, executor cache-key proof, and package descriptor report consumption landed; this is not Gate 3 authorization. |
| Gate 3 Phase 1 | APPROVED-RESTRICTED / READY FOR SIGNATURE REVIEW | Addendum remains draft-not-signed, but evidence blockers 1-5 are closed. Blocker 6 is the Architect signature/status update. Non-proof live reads remain blocked until signed. Phase 2 stays closed. |
| TBackend Gate 3 Phase 2 | CLOSED | Real Ledger adapter/package binding, BiHistory, stream/OLAP, writes/replay/compact/subscribe, and production cache need separate Architect approval/addendum as specified. |
| Release publish | CLOSED | `bin/release-gate` may build artifacts; RubyGems publish needs explicit approval and MFA owner action. |
| Syntax pressure | PRESSURE ONLY | Review routes proposal candidates; S3-R14 C7-C10 added truth-system, HTTP/knowledge/legal, emergency mesh, and marketplace pressure; no syntax is canon without proposal/proof. |

---

## Source-Of-Truth Hierarchy

Use this hierarchy for routine reads:

```text
agent-context.md
  -> current-status.md
  -> accepted spec / accepted proposals
  -> latest landed track evidence
  -> code + proof artifacts
  -> old tracks / archives
```

For conflicts, apply the conflict rule below.

---

## Conflict Rule

When documents disagree, do not average them. Resolve by question type:

| Conflict | Prefer | Reason |
|----------|--------|--------|
| `agent-context.md` vs `current-status.md` | `current-status.md` for detailed scoreboard; update `agent-context.md` later in Status Curator mode | Context is compact; status is fuller. |
| `current-status.md` vs latest landed track | latest landed track for exact evidence; update `current-status.md` if assigned status curation | Tracks are landing evidence. |
| spec vs current-status/latest track | spec for canon; latest track/status for implemented or proven-but-not-yet-spec-synced state | Spec lag is allowed but must be named. |
| spec vs code/proof | code/proof for observed implementation; Compiler/Grammar Expert owns spec-lag repair | Running evidence beats stale text, but not canon. |
| latest track vs code/proof | code/proof if directly verified; otherwise track | Proof artifacts are the executable truth. |
| discussion vs anything | discussion never wins by itself | Discussions route pressure; they do not authorize implementation. |

If a conflict affects behavior, record it under `[R]` or `[Q]` and route it to
the owner instead of silently fixing unrelated documents.

---

## Ownership Reminders

| Role | Current ownership |
|------|-------------------|
| Research Agent | executable proofs, fixtures, proof-local runtime/cache work; not round-close status by default |
| Compiler/Grammar Expert | formal semantics, grammar, type system, accepted proposals, spec-lag stewardship |
| Bridge Agent | bridge/package mapping and approval gates; no package/runtime production binding without approval |
| Meta Expert | Status Curator mode for round-close maps, current-status, tracks index, lifecycle/debt routing |
| Archive/Form Expert | archaeology, pressure fixtures, registry/review routing; no canon promotion by fixture |
| History Curator | compact history reports, archive compression, duplicate-removal recommendations, value preservation |
| External Pressure Reviewer | critique and pressure routing; may use borrowed `runtime-pressure` lens only when assigned |

---

## Proof/Test Budget Protocol

Default to the smallest proof that can validate the slice.

| Slice type | Default verification |
|------------|----------------------|
| Status/map/doc curation | `git diff --check`, link/path existence checks, no proof suite unless requested |
| Track/proposal docs only | `git diff --check`; validate named links/files when practical |
| Parser/classifier/typechecker/compiler code | targeted proof for touched surface + closest golden check |
| Orchestrator/compiler path | production compiler CLI proof + Stage 1/Stage 2 close candidates when path-wide behavior changes |
| Assembler/.igapp artifact shape | `igapp_assembler_proof` or the named temporal assembler proof + relevant regression |
| Runtime/cache proof-local work | named proof fixture + syntax check; do not run production suites unless path-wide |
| Release work | `bin/release-gate`; publish remains not attempted |
| Package bridge work | targeted package spec named by the card; avoid full package suite unless needed |

Escalate proof scope when:

- production compiler path changes;
- manifest or `.igapp/` load contract changes;
- Stage 1/Stage 2 close candidate evidence may be affected;
- a card explicitly asks for broader verification;
- a targeted proof fails and the failure may be systemic.

Do not run broad expensive suites just to curate maps.

---

## Current Next Movement

Recommended next routing from the latest status map:

1. Architect signature review for `gate3-live-read-decision-addendum-v0.md`; live reads remain blocked until signed
2. signing record should cite S3-R19-C1-P 15/15 PASS and attribute guard-order amendment to S3-R18-X1 PS-2
3. first post-signature fixture after any signed status change; verify no behavior change accompanies signing
4. `compatibility-report-persistence-audit-v0`
5. optional addendum §6 wording update to cite 15/15 PASS as current evidence
6. `gate3-authority-registry-v0` before Phase 2
7. `gate3-phase2-addendum-process-v0` before Phase 2
8. `invariant-persistence-boundary-v0`
9. `spec-ch6-invariant-source-metadata-sync-v0`
10. `external-http-json-capability-pressure-v0` as pressure backlog, not parser/runtime implementation
11. `controlled-agent-replication-boundary-pressure-v0` as pressure backlog before any emergency mesh fixture
