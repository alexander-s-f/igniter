# Documentation Fate Inventory - Stage 1 / Stage 2 v0

Card: S3-R37-C6-P2
Agent: [Igniter-Lang Archive/Form Expert]
Role: archive-form-expert
Track: igniter-lang/documentation-fate-inventory-stage1-stage2-v0
Status: done
Date: 2026-05-12

---

## Scope

This is the first cleanup fate inventory for:

- completed Stage 1 / Stage 2 track docs still visible in hot
  `docs/tracks/`;
- completed old discussions that are not needed as default Stage 3 context.

No files are moved, deleted, or rewritten. This document classifies fate labels
only and routes follow-up work to History Curator and Line Up Summarizer.

Route used: `STALE_REFRESH` check. Newer documentation-metabolism and archive
history maps exist, but no prior same-source fate inventory was found.

Read set:

- [documentation-metabolism.md](../dev/documentation-metabolism.md)
- [archive/README.md](../archive/README.md)
- [archive/history/README.md](../archive/history/README.md)
- [tracks/README.md](README.md)
- [discussions/README.md](../discussions/README.md)
- [current-status.md](../current-status.md)
- [agent-context.md](../agent-context.md)
- Stage 1 / Stage 2 close snapshot READMEs

---

## Fate Labels

This inventory uses the labels from the documentation metabolism process:

```text
hot_current
active_reference
public_archive
private_archive
external_archive
delete_candidate
do_not_move
needs_archaeology
needs_canon_decision
```

No source in this first set is marked `delete_candidate`. The cleanup posture is
preserve first, summarize second, move only after explicit History Curator plan.

---

## Do-Not-Move Anchors

| Source | Fate | Why |
| --- | --- | --- |
| [tracks/README.md](README.md) | do_not_move / hot_current | Active navigation index for current and historical track rows. It may be edited by status/curation cards, but should not be archived wholesale. |
| [current-status.md](../current-status.md) | do_not_move / hot_current | Current scoreboard and source-of-truth summary. Not part of movement cleanup. |
| [agent-context.md](../agent-context.md) | do_not_move / hot_current | Trusted onboarding capsule for current agents. |
| [docs/README.md](../README.md) | do_not_move / hot_current | Public documentation navigation surface. |
| [archive/snapshots/2026-05-06-stage1-close/README.md](../archive/snapshots/2026-05-06-stage1-close/README.md) | do_not_move / public_archive | Read-only Stage 1 close evidence anchor. |
| [archive/snapshots/2026-05-07-stage2-close/README.md](../archive/snapshots/2026-05-07-stage2-close/README.md) | do_not_move / public_archive | Read-only Stage 2 close evidence anchor. |
| [META-EXPERT-007](../meta-proposals/META-EXPERT-007-stage1-close-governance-v0.md) | do_not_move / active_reference | Formal Stage 1 close governance. |
| [META-EXPERT-009.1](../meta-proposals/META-EXPERT-009.1-stage2-close-decision-v0.md) | do_not_move / active_reference | Formal Stage 2 close decision. |
| [proposals/README.md](../proposals/README.md) and accepted/closed PROPs | do_not_move / active_reference | Canon/proposal lifecycle authority. Stage 2 PROPs remain in proposals, not archive-only memory. |

---

## Fate Inventory Table

| Source cluster | Representative documents | Current fate label | Follow-up owner | Notes |
| --- | --- | --- | --- | --- |
| Stage 1 close authority | `stage1-close-candidate-proof-v0.md`; Stage 1 close snapshot; `META-EXPERT-007*` | active_reference | Line Up Summarizer | Keep readable as a baseline. Create one Line Up that says Stage 1 is closed, parsed emitter is legacy/comparison, and current work should not re-open Stage 1 except by explicit card. |
| Stage 1 pre-crystallization tracks still in hot tracks | `observable-spine-v0.md`, `runtime-machine-lifecycle-v0.md`, `semantic-domain-reconciliation-v0.md`, `source-to-semanticir-*`, `typed-pass-executable-proof-v0.md`, product/OSINT/Spark pressure tracks | public_archive / needs_archaeology for unhoisted value pockets | History Curator + Line Up Summarizer | The 2026-05-06 pre-crystallization snapshot already preserves the raw layer. Many values are covered by History-S1, S8-S12, S17-S19, but hot copies should not move until Line Ups point to preserved value routes. |
| Stage 2 close authority | `stage2-close-candidate-v0.md`, `stage2-close-candidate-planning-v0.md`, `stage2-round15-status-curation-v0.md`, Stage 2 close snapshot | active_reference | Line Up Summarizer | Keep exact close evidence easy to find. These are the main anchors for "Stage 2 closed with deferred gaps." |
| Stage 2 temporal/history proof cluster | `history-type-proof-v0.md`, `history-type-point-access-proof-v0.md`, `sparkcrm-bihistory-fixture-v0.md`, `runtime-machine-temporal-access-hook-proof-v0.md` | public_archive after summary | Line Up Summarizer, then History Curator | Snapshot-backed. Still historically important for `History[T]`, `BiHistory[T]`, and later Gate 3 temporal scope. Needs a compact Line Up before movement planning. |
| Stage 2 stream/OLAP/invariant proof cluster | `stream-t-proof-v0.md`, `stream-semanticir-surface-lowering-v0.md`, `olap-point-proof-v0.md`, `semanticir-stage2-surface-lowering-v0.md`, `invariant-severity-proof-v0.md`, `runtime-invariant-violation-observations-v0.md` | public_archive after summary | Line Up Summarizer, then History Curator | Snapshot-backed and closed by Stage 2. Keep public, but remove from hot default context after summary and link plan. |
| Stage 2 parser/OOF cluster | `parser-oof-hardening-stage2-proof-v0.md`, `stream-oof-s2-classifier-v0.md`, `stream-oof-s3-typechecker-v0.md`, `olap-point-parser-typechecker-boundary-v0.md`, `olap-point-parser-implementation-v0.md` | public_archive / active_reference for OOF rules | Line Up Summarizer | Current agents need OOF results through spec/CSM/current-status, not through all old proof files. Summary should preserve exact OOF names and proof outcomes. |
| Stage 2 compiler package/extraction spine | `extract-classifier-module-v0.md`, `extract-typechecker-module-v0.md`, `extract-semanticir-emitter-module-v0.md`, `extract-assembler-module-v0.md`, `compiler-orchestrator-v0.md`, `packageable-compiler-api-v0.md`, `compiler-package-boundary-v0.md`, `compiler-packaging-skeleton-v0.md`, `gem-native-package-boundary-specs-v0.md` | active_reference -> public_archive candidate | Line Up Summarizer + History Curator | Some of this is still useful for implementation archaeology. The live truth should be `lib/`, `agent-context.md`, and current compiler-profile tracks. Summarize before archiving. |
| Stage 2 TBackend descriptor bridge | `ledger-tbackend-adapter-descriptor-v0.md`, `ledger-tbackend-adapter-descriptor-package-plan-v0.md`, package-side `ledger-tbackend-adapter-descriptor-package-v0.md` | active_reference / external_archive for package-side doc | Bridge Agent + History Curator | Do not move package-side material from this slice. Fate note: descriptor is current as Gate 2 metadata evidence; runtime binding remains closed. |
| Stage 2 status curation maps | `stage2-round2-map-refresh-v0.md` through `stage2-round15-status-curation-v0.md` | public_archive | History Curator | These are per-round maps, now superseded by current-status, Stage 2 snapshot, and future Line Up. Keep public until link redirects exist. |
| Stage 3 R1-R7 Stage 2 carryover/parity tracks | `typed-emission-main-path-parity-v0.md`, `typed-emission-canonical-shape-v0.md`, `typed-emission-stage2-source-lowering-parity-v0.md`, `temporal-cache-key-proof-v0.md`, `orchestrator-emit-typed-switch-v0.md`, `proposal-lifecycle-index-sync-v0.md`, R6 spec sync tracks | active_reference for switch/spec sync; public_archive for stale parity blockers | Line Up Summarizer + History Curator | These are Stage 3 docs, but they are Stage 2 cleanup/carryover. The stale blocker tracks already have stale headers; summarize the switch story before moving. |
| Syntax/comprehension pressure around Stage 2 close | `human-agent-comprehension-synthesis-v0.md`, `future-syntax-pressure-formalization-v0.md`, syntax pressure fixtures and registries from early Stage 3 | active_reference / needs_canon_decision for any future syntax proposal claim | Compiler/Grammar Expert + Line Up Summarizer | Do not promote fixture syntax. Keep as pressure until routed to formal PROP/spec work. |
| Old pre-Gate-3 discussions | `temporal-fragment-and-cache-key-pressure-discussion-v0.md`, `temporal-manifest-and-cache-boundary-pressure-v0.md`, `temporal-igapp-runtime-boundary-pressure-v0.md`, `typed-emission-and-temporal-loader-pressure-v0.md`, `runtime-compatibility-and-typed-delta-pressure-v0.md`, `stage3-round8-pre-gate3-pressure-v0.md` | public_archive after summary | Line Up Summarizer, then History Curator | Discussion outputs are completed and routed. Current agents should read current specs/status, not these debates, unless tracing a decision. |
| Gate 3 pre-decision discussions | `gate3-prerequisite-package-pressure-v0.md`, `gate3-request-readiness-pressure-v0.md`, `gate3-request-safety-pressure-v0.md`, `gate3-request-revision-safety-pressure-v0.md` | active_reference -> public_archive after Line Up | Line Up Summarizer | These are not Stage 1/2, but they are the bridge from Stage 2 close to Gate 3. They need a compact "request revision and safety blockers" Line Up before they leave hot context. |
| R13-R22 Gate 3 discussion chain | `gate3-decision-safety-pressure-v0.md` through `phase1-e2e-and-content-address-pressure-v0.md` | public_archive candidate | History Curator | Already compressed by [History-S7](../archive/history/history-s7-gate3-stage3-rounds-13-22-compression-map.md). Movement can be planned after discussion links point to S7 and a Line Up exists. |
| Off-track role/process discussion | `agent-role-optimization-v0.md` | public_archive / needs_archaeology if role changes are disputed | Line Up Summarizer | Role index already carries current truth. Preserve as process archaeology, not current authority. |

---

## Documents Needing Line Up Summaries

Recommended first Line Up batch:

1. `stage1-stage2-close-baseline-lineup-v0`
   - Sources: Stage 1 close proof, Stage 2 close candidate, close snapshots,
     `META-EXPERT-007`, `META-EXPERT-009.1`.
   - Purpose: one compact answer to "what exactly closed and what stayed open?"

2. `stage2-proof-clusters-lineup-v0`
   - Sources: History/BiHistory, stream, OLAP, invariant, parser/OOF proof
     tracks.
   - Purpose: preserve proof outcomes and point agents to current spec/CSM
     instead of old proof documents.

3. `stage2-compiler-package-spine-lineup-v0`
   - Sources: module extraction, facade, CLI, package boundary, gem boundary.
   - Purpose: distinguish current compiler package facts from historical
     extraction steps.

4. `stage2-to-stage3-typed-switch-lineup-v0`
   - Sources: stale parity tracks, `orchestrator-emit-typed-switch-v0.md`,
     R5/R6 spec sync tracks, `parity-track-stale-header-sweep-v0.md`.
   - Purpose: prevent old parity blocker states from being read as current
     truth.

5. `old-discussions-pre-gate3-lineup-v0`
   - Sources: R2-R12 completed discussions.
   - Purpose: compress temporal/typed/Gate3-request debate into routed
     decisions and blockers closed by later rounds.

6. `gate3-r13-r22-discussions-lineup-v0`
   - Sources: R13-R22 completed discussions, linked to History-S7.
   - Purpose: let discussion files become public archive candidates without
     losing the safety-pressure story.

---

## Documents Needing History Curator Link / Movement Planning

| Movement packet | Sources | Prerequisite |
| --- | --- | --- |
| `tracks-stage2-proof-clusters-public-archive-v0` | Stage 2 proof clusters already present in Stage 2 close snapshot | Line Ups 1-2, then link redirects from tracks index |
| `tracks-stage2-status-curation-public-archive-v0` | `stage2-round*-map-refresh/status-curation` docs | Line Up 1, then decide whether one archive/history report is enough |
| `tracks-stage2-compiler-package-public-archive-v0` | compiler extraction/package/gem tracks | Line Up 3, verify implementation agents no longer rely on exact tracks by default |
| `tracks-stage3-r1-r7-stage2-carryover-public-archive-v0` | typed parity, switch, lifecycle sync, spec sync carryover | Line Up 4, preserve stale/superseded markers |
| `discussions-pre-gate3-public-archive-v0` | R2-R12 completed discussions | Line Up 5, discussion index redirect plan |
| `discussions-gate3-r13-r22-public-archive-v0` | R13-R22 completed discussions | Line Up 6 plus History-S7 pointer |
| `pre-crystallization-hot-track-dedup-v0` | Stage 1 pre-crystallization track copies still in hot docs/tracks | Verify coverage by History-S1/S8-S19 and produce missing value Line Ups |

No movement should happen until each packet has:

```text
source list -> Line Up summary -> link rewrite plan -> archive index row -> no-zombie check
```

---

## Canon / Archaeology Follow-Ups

Needs canon decision:

- Any claim from syntax/comprehension pressure docs that proposes `entrypoint`,
  `section`, `entity`, `metric`, `delegate`, or primitive sugar as language
  syntax. These remain pressure until Compiler/Grammar Expert routes a PROP.

Needs archaeology:

- Pre-crystallization hot track copies whose value is not already covered by
  History-S1/S8-S19 or `value-index.md`.
- Old role/process discussion details if the Architect wants a role-evolution
  history beyond current `roles/README.md`.

No current-status/spec update is required from this inventory. Required
follow-ups are Line Up summaries and History Curator movement/link planning.

---

## Handoff

```text
Card: S3-R37-C6-P2
Agent: [Igniter-Lang Archive/Form Expert]
Role: archive-form-expert
Track: igniter-lang/documentation-fate-inventory-stage1-stage2-v0
Status: done

[D] Stage 1/2 cleanup should preserve first: no delete candidates in this batch.
[D] Close decisions, snapshots, proposals, current-status, agent-context, and
    tracks/README are do-not-move anchors.
[S] Most completed Stage 2 proof tracks are snapshot-backed public archive
    candidates, but need Line Up summaries before movement.
[S] Old discussions should be compressed by Line Up before their index is
    redirected; R13-R22 already has History-S7 as the main compression anchor.
[R] Run Line Up batch first, then History Curator movement/link packets.
[Next] Line Up Summarizer: create the six recommended Line Ups above.
[Next] History Curator: plan movement packets after Line Ups land; do not move
       files from this inventory alone.
```
