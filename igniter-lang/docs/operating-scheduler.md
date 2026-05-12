# Igniter-Lang Operating Scheduler

Status: active scheduler/checklist
Owner: `[Architect Supervisor / Codex]`
Last updated: 2026-05-12

---

## Purpose

This document defines recurring operating tasks for Igniter-Lang agent work.

The operating model says how work moves. This scheduler says what should repeat
per round, per stage, and when onboarding cards must be refreshed.

The goal is to keep agents starting from a compact current map, not from broad
archaeology or stale memory.

---

## Cadence Summary

| Cadence | Owner | Output | Rule |
|---------|-------|--------|------|
| Per round start | Architect Supervisor | cards / stage packets | Assign only current-role reads and bounded source sets |
| Per round close | Meta Expert in Status Curator mode | status/map updates | Update current maps from landed evidence only |
| Per round close | Architect Supervisor | inbox triage | Route or archive new inbox material; no zombie docs |
| Per round close | Compiler/Grammar Expert when assigned | spec-lag notes | Flag spec drift caused by accepted proof/proposal changes |
| Per round close | Architect Supervisor | next routing | Accept, hold, redirect, or open next round |
| Per stage open | Architect Supervisor + Meta Expert | stage fixed point | Refresh current context and role launch docs |
| Per stage close | Meta Expert + History Curator | snapshot / compression | Freeze evidence, hoist values, archive or compress old docs |
| Per role refresh | Architect Supervisor | onboarding card | Keep launch capsule current for fast new-agent initialization |
| Documentation metabolism batch | Archive/Form + History Curator + Line Up Summarizer | fate/movement/summary | Classify source fate, plan movement/linking, write compact Line Ups |

---

## Per Round Start

Before assigning cards:

- confirm the current stage and gate state in `docs/agent-context.md`;
- decide whether the round is proof, implementation, docs, discussion, or gate
  review;
- assign one role per card;
- include `Card`, `Agent`, `Role`, `Track`, and mode when needed;
- name exact source files when older tracks, archives, or package docs are
  required;
- avoid asking every agent to reread broad history.

Round cards should prefer:

```text
current map -> assigned role profile -> assigned source set -> deliverable
```

not:

```text
read the whole project -> reconstruct context -> guess the useful slice
```

---

## Per Round Close

After agents finish a round:

1. Read landed track handoffs and proof summaries.
2. Separate:
   - landed evidence;
   - proposal-only signals;
   - discussion pressure;
   - request/pending decision artifacts;
   - implementation authorization.
3. Update only the living maps that are explicitly assigned:
   - `docs/current-status.md`
   - `docs/tracks/README.md`
   - `docs/agent-context.md`
   - `docs/value-index.md` only for durable signals
4. Keep gates explicit:
   - request drafted is not approval;
   - proof-local behavior is not production enforcement;
   - report-only metadata is not runtime authority.
5. Write next routing as a short list.
6. Check `docs/inbox/README.md`:
   - every new item must be triaged;
   - every processed item must link to a destination;
   - active inbox items must name their next owning card/track.

Do not run broad expensive suites just to curate maps. Use proof results from
the owning tracks unless a contradiction appears.

---

## Per Stage Open

At the start of a stage:

- establish the stage fixed point in `docs/current-status.md`;
- refresh `docs/agent-context.md` as the compact capsule;
- confirm active roles in `roles/README.md`;
- refresh relevant onboarding cards in `handoff/`;
- route any old stage material to History Curator if it is valuable but bulky;
- decide which gates are open, closed, pending request, or held.

Stage open should make a new agent able to start from:

```text
AGENTS.md -> roles/README.md -> role profile -> onboarding card -> agent-context.md
```

without reading old tracks by default.

---

## Per Stage Close

At stage close:

- freeze the close evidence and decision;
- snapshot or archive the documentation state if useful;
- hoist durable ideas into `docs/value-index.md`;
- ask History Curator to compress bulky historical areas into compact reports;
- mark superseded docs as historical through links or archive indexes;
- clear or archive processed inbox items that no longer feed active work;
- update onboarding cards so new agents do not inherit stale stage assumptions.

Stage close is not just "status update". It is memory hygiene.

---

## Onboarding Cards

Onboarding cards are launch capsules for quickly initializing a fresh agent
instance.

They should live in `igniter-lang/handoff/` and follow the template:

```text
handoff/ONBOARDING_CARD_TEMPLATE.md
```

Recommended naming:

```text
handoff/onboarding-<role-id>-v0.md
```

Each onboarding card should include:

- Agent name and role id;
- instance route check using `handoff/INSTANCE_ROUTING.md`;
- required read order;
- current entry state;
- owned surfaces;
- closed gates and active gates relevant to the role;
- first recommended slices or stage packet;
- quality bar;
- handoff format;
- "do not read" and "do not implement" boundaries.

Refresh onboarding cards:

- at every stage open;
- at every stage close;
- whenever a role is added or substantially changed;
- whenever a gate/request changes the role's allowed work;
- whenever `current-status.md` says a card's "open surfaces" are stale.

Onboarding cards are not canon. If an onboarding card disagrees with
`agent-context.md`, `current-status.md`, or the role profile, the current maps
win and the card should be refreshed.

Agents should state one of these routes before doing work:

```text
INIT / UPDATE / IN_FLIGHT_REFRESH / STALE_REFRESH / DISCUSSION / STAGE_LOOP
```

Use `INIT` for a fresh chat, `UPDATE` for an existing agent receiving a new
card, `STALE_REFRESH` when the previous card is older than the current round or
same-role agents may have landed newer work, and `IN_FLIGHT_REFRESH` for a
minimal mid-slice state check.

---

## Stage-Level Roles

Some roles work better as long-cycle agents than per-round card agents.

Current stage-level candidates:

- `[Igniter-Lang History Curator]`: archive compression and value preservation;
- `[Igniter-Lang Applied Pressure Agent]`: longer real-system pressure cycles;
- `[Igniter-Lang Line Up Summarizer]`: compact memory-card batches for bulky
  docs after Archive/Form or History Curator assigns a source set;
- future durable reviewers or benchmark agents if created.

Stage-level roles still need bounded source sets and stage-close handoffs. They
do not get broader write authority just because the cycle is longer.

---

## Drift Signals

Refresh maps or onboarding cards when agents start saying:

- "docs say one thing, code says another";
- "I need to run everything to reconstruct the current state";
- "the spec seems stale but I am not sure";
- "this role does not exist for the work I was asked to do";
- "the card asks for implementation but the gate is closed";
- "the onboarding card says proof open, but status says landed";
- "I had to read old tracks not named by the card".

These are process bugs, not agent bugs.

---

## Minimal Scheduler Checklist

```text
Round start:
  [ ] cards include Agent + Role + Track + scope
  [ ] no broad archive reads unless assigned
  [ ] gate state visible

Round close:
  [ ] landed evidence summarized
  [ ] inbox items triaged / routed / archived
  [ ] current-status updated if assigned
  [ ] tracks index updated if assigned
  [ ] agent-context next movement refreshed if assigned
  [ ] value-index updated only for durable signals
  [ ] next routing clear

Stage open/close:
  [ ] role index current
  [ ] onboarding cards refreshed
  [ ] archive/history compression routed
  [ ] stale docs marked or linked
  [ ] gates/request state explicit
```
