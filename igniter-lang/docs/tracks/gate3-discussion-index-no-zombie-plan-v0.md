# Gate 3 Discussion Index No-Zombie Plan v0

Card: S3-R41-C3-P1
Agent: [Igniter-Lang History Curator]
Role: history-curator
Track: igniter-lang/gate3-discussion-index-no-zombie-plan-v0
Status: movement/link plan only
Date: 2026-05-12

Route: STALE_REFRESH
Previous known card: S3-R37-C7-P2
Latest observed round: Stage 3 Round 41
Same-role newer work: documentation movement ledger exists; Line Up and
Archive/Form neighbors landed P-55/P-56 closure and R41 hardening work.
Gate/status changes: P-55 and P-56 are closed in R40, but current-status still
records that no movement, deletion, or discussion-index redirect has happened.

---

## Scope

Plan discussion-index movement/link readiness for pre-Gate3 and Gate3
discussion clusters after P-55/P-56 closure.

This card does not move files, delete files, or rewrite links. It defines the
no-zombie checks and future redirect/index plan only.

## Read Set

- `docs/lineups/old-discussions-pre-gate3-spine.md`
- `docs/lineups/gate3-r13-r22-discussions-spine.md`
- `docs/tracks/gate3-r13-r22-lineup-authority-verification-v0.md`
- `docs/tracks/pre-gate3-lineup-rq1-rq2-revision-v0.md`
- `docs/tracks/gate3-r13-r22-lineup-historical-blockers-hardening-v0.md`
- `docs/discussions/README.md`
- `docs/current-status.md`
- `docs/gates/README.md`
- role onboarding and `handoff/INSTANCE_ROUTING.md`

## Source Cluster List

| Cluster | Source files | Current compact memory | Current status |
| --- | --- | --- | --- |
| R2-R8 pre-Gate3 runtime pressure | `temporal-fragment-and-cache-key-pressure-discussion-v0.md`; `temporal-manifest-and-cache-boundary-pressure-v0.md`; `temporal-igapp-runtime-boundary-pressure-v0.md`; `typed-emission-and-temporal-loader-pressure-v0.md`; `runtime-compatibility-and-typed-delta-pressure-v0.md`; `stage3-round8-pre-gate3-pressure-v0.md` | `lineups/old-discussions-pre-gate3-spine.md` | Complete and routed; not current authority |
| R9-R12 Gate3 request pressure | `gate3-prerequisite-package-pressure-v0.md`; `gate3-request-readiness-pressure-v0.md`; `gate3-request-safety-pressure-v0.md`; `gate3-request-revision-safety-pressure-v0.md` | `lineups/old-discussions-pre-gate3-spine.md` | Complete and routed; P-56 closed by revision |
| R13-R22 Gate3 decision/live-read pressure | `gate3-decision-safety-pressure-v0.md`; `gate3-decision-safety-pressure-v0-agent-v2-cross-test.md`; `phase1-implementation-prep-safety-pressure-v0.md`; `runtime-temporal-executor-lib-prep-safety-pressure-v0.md`; `live-read-addendum-draft-safety-pressure-v0.md`; `gate3-live-read-addendum-pre-signature-pressure-v0.md`; `gate3-post-signature-runtime-pressure-v0.md`; `phase1-post-signature-audit-registry-pressure-v0.md`; `phase1-e2e-and-content-address-pressure-v0.md` | `lineups/gate3-r13-r22-discussions-spine.md` plus `archive/history/history-s7-gate3-stage3-rounds-13-22-compression-map.md` | Complete and routed; P-55 closed; R41 historical-blocker hardening landed |

## Proposed Discussion Index Grouping

Keep every source discussion row reachable, but add group rows before any
future row collapsing.

| Proposed group | Placement in `docs/discussions/README.md` | Target | Notes |
| --- | --- | --- | --- |
| Pre-Gate3 pressure spine, R2-R12 | Before the first R2 discussion row or as a compact subsection above the index | `../lineups/old-discussions-pre-gate3-spine.md` | Use as the first read for completed R2-R12 pressure. Do not claim it is canon. |
| Gate3 decision/live-read pressure spine, R13-R22 | Before `gate3-decision-safety-pressure-v0.md` row or as a compact subsection above the R13 rows | `../lineups/gate3-r13-r22-discussions-spine.md` and `../archive/history/history-s7-gate3-stage3-rounds-13-22-compression-map.md` | Use as the first read for R13-R22 pressure. History-S7 remains the timeline/compression map. |
| Current Gate3 authority pointer | In a short note near the Gate3 group rows | `../gates/README.md`, `../current-status.md`, `../agent-context.md` | Prevents Line Ups from becoming authority by accident. |

## Redirect Candidate Rows

These are future index candidates only. Do not apply them until the checklist
below passes.

| Candidate source row(s) | Future README status wording | Primary memory target | Direct source link stays? | Authority note |
| --- | --- | --- | --- | --- |
| R2-R8 temporal/runtime pressure rows | `complete - routed; summarized in Pre-Gate3 Line Up` | `lineups/old-discussions-pre-gate3-spine.md` | Yes | Current runtime/gate authority remains status/spec/gates, not discussion rows. |
| R9-R12 Gate3 request rows | `complete - routed; summarized in Pre-Gate3 Line Up; superseded by R13 decision where applicable` | `lineups/old-discussions-pre-gate3-spine.md` | Yes | R11 HOLD and R12 proceed are historical request-readiness states, not current Gate3 state. |
| `gate3-decision-safety-pressure-v0.md` and cross-test row | `complete - routed; summarized in Gate3 R13-R22 Line Up and History-S7` | `lineups/gate3-r13-r22-discussions-spine.md`; `archive/history/history-s7-gate3-stage3-rounds-13-22-compression-map.md` | Yes | `gates/README.md` and `gate3-decision-record-v0.md` remain decision authority. |
| R14-R19 prep/addendum pressure rows | `complete - routed; summarized in Gate3 R13-R22 Line Up` | `lineups/gate3-r13-r22-discussions-spine.md` | Yes | Draft/addendum wording is historical until current gate docs say otherwise. |
| R20-R22 post-signature/audit/content-address rows | `complete - routed; summarized in Gate3 R13-R22 Line Up; current rollout state in gates/status` | `lineups/gate3-r13-r22-discussions-spine.md` | Yes | Audit-ready, registry, and content-address language must not imply durable audit or production signing authority. |

## Authority Checks

| Check | Required result before redirect/index rewrite | Current observation |
| --- | --- | --- |
| P-56 closure for R2-R12 | Pre-Gate3 Line Up has RQ-1/RQ-2/RQ-3 hardening, exact source paths, and exact proof-log anchor | PASS by `pre-gate3-lineup-rq1-rq2-revision-v0.md` |
| P-55 closure for R13-R22 | Gate3 Line Up verified against current authority and not-promoted surfaces | PASS by `gate3-r13-r22-lineup-authority-verification-v0.md` |
| Historical blocker hardening | R13-R22 blocker table cannot be read as current R40/R41 state | PASS by `gate3-r13-r22-lineup-historical-blockers-hardening-v0.md` |
| Current authority not lost | Redirect landing pages point to `agent-context`, `current-status`, `gates/README`, and signed addendum/gate decision where needed | PASS in Line Ups; must be preserved in future index wording |
| Source evidence reachable | Every original discussion remains linked from either direct rows or a source list | PASS now; must remain true after any grouping |
| No broad authority promotion | Discussion rows remain process records, not canon/spec/proposal acceptance | PASS now; must be preserved in wording |

## Files That Must Remain Directly Linked

Do not replace these with only a group-level link in the first rewrite batch:

- `docs/discussions/gate3-request-safety-pressure-v0.md`
- `docs/discussions/gate3-request-revision-safety-pressure-v0.md`
- `docs/discussions/gate3-decision-safety-pressure-v0.md`
- `docs/discussions/gate3-decision-safety-pressure-v0-agent-v2-cross-test.md`
- `docs/discussions/gate3-live-read-addendum-pre-signature-pressure-v0.md`
- `docs/discussions/gate3-post-signature-runtime-pressure-v0.md`
- `docs/discussions/phase1-post-signature-audit-registry-pressure-v0.md`
- `docs/discussions/phase1-e2e-and-content-address-pressure-v0.md`
- `docs/lineups/old-discussions-pre-gate3-spine.md`
- `docs/lineups/gate3-r13-r22-discussions-spine.md`
- `docs/archive/history/history-s7-gate3-stage3-rounds-13-22-compression-map.md`
- `docs/gates/README.md`
- `docs/gates/gate3-decision-record-v0.md`
- `docs/gates/gate3-live-read-decision-addendum-v0.md`
- `docs/current-status.md`
- `docs/agent-context.md`

Reason: these files carry request HOLD/proceed transitions, final Gate3 decision
authority, signed-addendum scope, audit/registry/content-address exclusions, or
the compact memory targets themselves.

## No-Zombie Checklist

Before any discussion-index rewrite or movement:

1. Confirm `docs/discussions/README.md` still links every source discussion file.
2. Confirm each group row links to the appropriate Line Up and does not remove
   the direct source row in the first batch.
3. Confirm Gate3 authority links point to `docs/gates/README.md`,
   `docs/gates/gate3-decision-record-v0.md`,
   `docs/gates/gate3-live-read-decision-addendum-v0.md`,
   `docs/current-status.md`, and `docs/agent-context.md`.
4. Confirm no row says or implies that discussions authorize implementation,
   live runtime, Ledger, BiHistory, stream/OLAP, cache, writes, replay, compact,
   subscribe, production durable audit, registry, signing, or broad
   RuntimeMachine binding.
5. Confirm `source remains authoritative for exact proof logs.` remains in both
   Line Ups.
6. Confirm R11/R12 request-readiness language is historical and superseded by
   the R13 decision where applicable.
7. Confirm the R13-R22 Line Up keeps `Historical R22 Remaining Blockers` wording
   and current-state pointers.
8. Confirm `rg` for each source filename returns at least the source file, the
   discussion README row, and one compact memory target or history map.
9. Confirm no `current-status`, `agent-context`, `gates`, `spec`, or proposal
   document is edited as part of the index rewrite unless a separate card
   explicitly assigns it.
10. Confirm no file movement/deletion is attempted without explicit Architect
    approval.

## Blockers Before Actual Movement Or Link Rewrite

- Architect or supervisor approval is still required for any move/delete.
- A separate index-rewrite card should be assigned before editing
  `docs/discussions/README.md`.
- First rewrite should be additive: add group rows and authority notes, keep all
  direct rows.
- Broad row-collapsing should wait for a second pass after `rg` no-zombie
  checks prove no important inbound references depend on exact README rows.
- No cold/archive movement should happen while current-status still uses these
  discussions as route archaeology for Gate3 and durable-audit context.

## Stage-Close Handoff

Compact claim:

- P-55/P-56 closure makes the two Line Ups safe as redirect candidates, not as
  replacements for source evidence or current authority. The first safe
  discussion-index step is additive grouping with direct source links preserved.

Categories applied:

- `active_memory_card`
- `public_archive_candidate`
- `direct_link_required`
- `authority_anchor`
- `no_zombie_check_required`
- `movement_approval_required`

Changed files:

- `docs/tracks/gate3-discussion-index-no-zombie-plan-v0.md`

Next recommended slice:

- Assign a narrow discussion-index additive grouping card for
  `docs/discussions/README.md` after supervisor approval. It should add group
  rows and authority notes only; no row deletion, no source movement, no broad
  redirect collapse.
