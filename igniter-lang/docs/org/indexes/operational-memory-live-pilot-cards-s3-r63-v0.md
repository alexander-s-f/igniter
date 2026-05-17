# Operational Memory Live Pilot Cards S3 R63 v0

Status: ready-to-dispatch
Owner: [Org Architect Supervisor]
Date: 2026-05-17
Authority ref: `igniter-lang/docs/org/reports/operational-memory-pilot-architect-approval-v0.md`
Result baseline: `igniter-lang/docs/org/reports/operational-contract-memory-two-role-pilot-result-v0.md`

---

## Purpose

Run the next operational-contract memory check on real role-shaped work while
staying inside the approved org-sidecar boundary.

This is not a main `docs/cards/S3` compiler/profile round. These are internal
org pilot cards.

---

## Launch Pattern

```text
ORG-R63 = [C1-P1, C2-P1] -> C3-S
```

- `C1-P1` and `C2-P1` can run in parallel.
- `C3-S` runs after both pilot reports land.
- No role profile, gate, proposal, spec, current-status, archive movement, or
  implementation changes are authorized.

---

## Card C1

```text
Card: ORG-S3-R63-C1-P1
Agent: [Igniter-Lang Line Up Summarizer]
Role: line-up-summarizer
Track: operational-memory-lineup-live-card-pilot-v0

Route: UPDATE
Mode: org-sidecar-pilot
Authority ref:
- igniter-lang/docs/org/reports/operational-memory-pilot-architect-approval-v0.md

Operational Memory:
- Read igniter-lang/docs/org/memory-contracts/line-up-summarizer-operational-memory-pilot-v0.md
  after your role profile and before source review.
- Treat memory as optional non-authority handoff supplement.
- If memory conflicts with role profile, card, current-status, gates, or
  proposals, authority docs win and memory is stale.

Goal:
Use the Line Up Summarizer operational memory on a small real QA-shaped slice,
then report whether it helped.

Scope:
- Read:
  - igniter-lang/AGENTS.md
  - igniter-lang/roles/line-up-summarizer.md
  - igniter-lang/docs/org/memory-contracts/line-up-summarizer-operational-memory-pilot-v0.md
  - igniter-lang/docs/lineups/README.md
  - igniter-lang/docs/lineups/stage2-compiler-package-spine.md
  - igniter-lang/docs/lineups/stage2-to-stage3-typed-switch-spine.md
- Check only whether the pilot memory helps you catch:
  - standalone QA anchor hazard;
  - no-canon boundary;
  - no-movement boundary;
  - public/private risk routing;
  - narrow read discipline.
- Do not edit the Line Up files in this pilot.
- Do not decide archive movement or canon status.
- Do not update role profiles, current-status, gates, proposals, spec, or
  active cards.

Deliver:
- Compact pilot report in igniter-lang/docs/org/reports/
- Answer:
  1. Did memory reduce startup rereads?
  2. Did it catch a role-specific hazard?
  3. Did it stay subordinate to authority docs?
  4. Was stale-memory behavior clear?
  5. Was it compact enough for handoff?
- Recommendation: standardize / iterate / reject / keep optional
```

---

## Card C2

```text
Card: ORG-S3-R63-C2-P1
Agent: [Igniter-Lang History Curator]
Role: history-curator
Track: operational-memory-history-curator-live-card-pilot-v0

Route: UPDATE
Mode: org-sidecar-pilot
Authority ref:
- igniter-lang/docs/org/reports/operational-memory-pilot-architect-approval-v0.md

Operational Memory:
- Read igniter-lang/docs/org/memory-contracts/history-curator-operational-memory-pilot-v0.md
  after your role profile and before source review.
- Treat memory as optional non-authority handoff supplement.
- If memory conflicts with role profile, card, current-status, gates, or
  proposals, authority docs win and memory is stale.

Goal:
Use the History Curator operational memory on a small real movement-planning
slice, then report whether it helped.

Scope:
- Read:
  - igniter-lang/AGENTS.md
  - igniter-lang/roles/history-curator.md
  - igniter-lang/roles/archive-form-expert.md
  - igniter-lang/docs/org/memory-contracts/history-curator-operational-memory-pilot-v0.md
  - igniter-lang/docs/dev/documentation-metabolism.md
  - igniter-lang/docs/tracks/documentation-movement-link-ledger-stage1-stage2-v0.md
- Check only whether the pilot memory helps you catch:
  - bounded-source-set discipline;
  - no-move/no-delete default;
  - canon-vs-history confusion;
  - Line Up before redirect;
  - stale refresh triggers.
- Do not move, delete, archive, or rewrite source documents.
- Do not update role profiles, current-status, gates, proposals, spec, or
  active cards.

Deliver:
- Compact pilot report in igniter-lang/docs/org/reports/
- Answer:
  1. Did memory reduce startup rereads?
  2. Did it catch a role-specific hazard?
  3. Did it stay subordinate to authority docs?
  4. Was stale-memory behavior clear?
  5. Was it compact enough for handoff?
- Recommendation: standardize / iterate / reject / keep optional
```

---

## Card C3

```text
Card: ORG-S3-R63-C3-S
Agent: [Org Architect Supervisor]
Role: org-architect-supervisor
Track: operational-memory-live-pilot-synthesis-v0

Route: UPDATE
Mode: org-sidecar-synthesis
Depends on:
- ORG-S3-R63-C1-P1
- ORG-S3-R63-C2-P1

Goal:
Synthesize the Line Up Summarizer and History Curator live pilot reports and
prepare a short return summary for Architect Supervisor.

Scope:
- Read both C1/C2 pilot reports.
- Compare against:
  - igniter-lang/docs/org/reports/operational-contract-memory-two-role-pilot-result-v0.md
  - igniter-lang/docs/org/reports/operational-memory-pilot-architect-approval-v0.md
- Decide recommendation:
  - standardize;
  - iterate;
  - reject;
  - keep optional.
- Preserve that no broad standardization is authorized.

Deliver:
- Synthesis report in igniter-lang/docs/org/reports/
- Updated compact pilot index if needed
- Short return summary for Architect Supervisor
```
