# Application Chronicle Scoping Track

This track scopes Chronicle as the second product/app pressure test after Lense.
It must decide whether Chronicle is worth implementing as a bounded one-process
POC and what the smallest useful slice should be.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

Constraints:

- `:interactive_poc_guardrails` from [Constraint Sets](./constraints.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)
- [Application Showcase Synthesis Track](./application-showcase-synthesis-track.md)
- [Application Proposals](../experts/application-proposals.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting app/web showcase
synthesis.

Chronicle is selected for scoping because it can stress a different enterprise
application shape without leaving the current guardrails:

- local Markdown decision/proposal records
- deterministic proposal and conflict scanning
- explicit decision/sign-off commands
- linked decision/read-model snapshots
- receipt-shaped decision records
- Web inspection with stable markers and `/events` parity

This is not yet approval to implement Chronicle.

## Goal

Define a compact Chronicle POC slice that is useful to an end user and sharp
enough to test Igniter application structure.

The result must answer:

- what local files/data Chronicle reads and writes, if any
- what app-owned services exist
- what the first contracts graph should validate or compute
- what commands exist and what their local result shape looks like
- what snapshot/read model the Web surface consumes
- what receipt/report artifact Chronicle produces
- what stable Web markers and smoke assertions prove
- what is explicitly out of scope for the first slice
- whether the next cycle should implement Chronicle or choose another pressure
  line

## Scope

In scope:

- docs/design scoping only
- local deterministic data model
- app-local service boundaries
- candidate contract graph shape
- command/result/snapshot shape
- receipt-shaped output shape
- one mounted Web surface sketch
- smoke-test acceptance sketch

Out of scope:

- implementation
- public `Igniter.interactive_app` facade
- generic decision/workflow framework
- UI kit, graph/canvas renderer, SVG map, or component library
- LLM provider integration
- network/search/connectors
- scheduler/file watcher
- persistence database
- auth, users, teams, or production server concerns
- mutating external repositories or external systems

## Task 1: Chronicle Application Scoping

Owner: `[Agent Application / Codex]`

Acceptance:

- Propose the smallest local Chronicle domain model using Markdown or plain
  files as the backing store.
- Define app-owned services, command names, command result shape, action facts,
  snapshot shape, and refusal paths.
- Propose the first useful contract graph, keeping it deterministic and
  runnable offline.
- Define a receipt/report shape that proves provenance, conflicts, and sign-off
  state without becoming a generic report framework.
- Identify which pieces must stay app-local and which repeated conventions
  should be observed for future graduation.

## Task 2: Chronicle Web Scoping

Owner: `[Agent Web / Codex]`

Acceptance:

- Propose one mounted Web surface for Chronicle using app-owned snapshots.
- Define page sections, forms/actions, feedback codes, `/events` parity, and
  stable `data-` markers.
- Prefer inspectable nested HTML for linked decisions/conflicts; do not propose
  graph/canvas/SVG tooling in the first slice.
- Define smoke assertions for initial render, command success, refusal path,
  receipt/report marker, and `/events` parity.
- Identify which Web pieces stay app-local and which repeated boilerplate
  should merely be observed.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- Chronicle must feel like a real enterprise workflow, not a toy ADR viewer.
- The first slice should center on "proposal meets existing decisions":
  conflict evidence, explicit sign-off, and a durable decision receipt.
- A tiny file store is allowed if it stays transparent and deterministic.
- Do not use Chronicle to smuggle in a public app DSL, production workflow
  engine, or UI framework.
- The useful output of this track is a scoped implementation decision.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

Implementation belongs to a later track.

## Chronicle Application Scoping

[Agent Application / Codex] Proposed first slice:

Chronicle should center on one useful workflow:

```text
proposal meets existing decisions -> conflicts are explained -> human signs off
or refuses -> durable decision receipt is emitted
```

Local data model:

- Seed decision library:
  `examples/application/chronicle/data/decisions/*.md`.
- Seed proposals:
  `examples/application/chronicle/data/proposals/*.md`.
- Runtime workdir:
  `ENV["CHRONICLE_WORKDIR"] || "/tmp/igniter_chronicle_poc"`.
- Runtime writes:
  `sessions/*.json`, `actions/*.jsonl`, and `receipts/*.md`.
- Repo fixtures stay read-only during smoke runs; only the workdir mutates.

Markdown decision shape:

```text
id: DR-041
title: PostgreSQL as primary store
status: accepted
date: 2024-11-12
tags: data, consistency, billing
owners: platform
signoffs: alex,sarah
supersedes:
related: DR-067

## Decision
...

## Context
...

## Constraints
...

## Rejected Options
- MongoDB: transaction and consistency limitations.
```

Markdown proposal shape:

```text
id: PR-001
title: Move user profile storage to MongoDB
author: alex
tags: data, pii, consistency
requires_signoff: platform,security

## Proposal
...

## Rationale
...
```

App-owned services:

- `DecisionStore`: loads and parses decision Markdown from the seed library.
- `ProposalStore`: loads proposal Markdown and exposes explicit proposal ids.
- `DecisionConflictScanner`: deterministic token/tag/rule scanner that returns
  conflict evidence without LLM, network, or embeddings.
- `DecisionSessionStore`: owns scan sessions, sign-off state, refusal state,
  action facts, and receipt emission in the runtime workdir.
- `ChronicleApp`: app composition boundary that wires services, commands, Rack
  routes, and the mounted surface.

Command names:

- `scan_proposal(proposal_id:)`: creates or refreshes a deterministic scan
  session for a seed proposal.
- `sign_off(session_id:, signer:)`: records required sign-off when a conflict
  scan exists.
- `refuse_signoff(session_id:, signer:, reason:)`: records explicit refusal;
  blank reason is a refusal path, not an exception.
- `acknowledge_conflict(session_id:, decision_id:)`: marks a conflict as
  acknowledged without pretending it is resolved.
- `emit_receipt(session_id:)`: writes a receipt only when the session has a
  proposal, conflict evidence, and either enough sign-offs or a refusal record.

Local command result shape:

```ruby
CommandResult = Data.define(
  :kind,
  :feedback_code,
  :session_id,
  :proposal_id,
  :decision_id,
  :receipt_id,
  :action
)
```

Expected result kinds and feedback codes:

- `:ok`, `chronicle_scan_created`
- `:ok`, `chronicle_conflict_acknowledged`
- `:ok`, `chronicle_signoff_recorded`
- `:ok`, `chronicle_signoff_refused`
- `:ok`, `chronicle_receipt_emitted`
- `:refused`, `chronicle_unknown_proposal`
- `:refused`, `chronicle_unknown_session`
- `:refused`, `chronicle_blank_signer`
- `:refused`, `chronicle_blank_reason`
- `:refused`, `chronicle_receipt_not_ready`

Action facts:

- `proposal_scanned`
- `conflict_detected`
- `conflict_acknowledged`
- `signoff_recorded`
- `signoff_refused`
- `receipt_emitted`
- `command_refused`

Snapshot shape:

```ruby
ChronicleSnapshot = Data.define(
  :proposal_id,
  :proposal_title,
  :session_id,
  :status,
  :conflict_count,
  :open_conflict_count,
  :required_signoffs,
  :signed_by,
  :refused_by,
  :top_conflicts,
  :related_decisions,
  :receipt_id,
  :action_count,
  :recent_events
)
```

First useful contract graph:

- `proposal`: input parsed proposal metadata/body.
- `decision_library`: input parsed decisions.
- `tag_matches`: lookup/project decisions sharing proposal tags.
- `text_matches`: deterministic keyword overlap from title, constraints, and
  rejected options.
- `policy_matches`: rule check for sensitive tags such as `pii`,
  `consistency`, and `billing`.
- `conflict_evidence`: composition of matched decisions with evidence refs.
- `required_signoffs`: project proposal `requires_signoff`.
- `readiness`: aggregate sign-off/refusal state into `ready`, `blocked`, or
  `needs_review`.
- `chronicle_receipt_payload`: output with proposal, conflicts, provenance,
  sign-off state, skipped/deferred notes, and validity.

This graph should be deterministic and offline. It should not call an LLM,
perform semantic search, write files, or invent decisions.

Receipt/report shape:

- `receipt_id`: stable id derived from session id and timestamp.
- `proposal`: id, title, author, source file.
- `conflicts`: decision id, title, evidence kind, evidence excerpt, source
  section, acknowledged flag.
- `signoffs`: required signers, signed signers, refused signers with reason.
- `decision_state`: `accepted`, `blocked`, or `needs_review`.
- `provenance`: decision/proposal file paths and scan contract version.
- `actions`: compact action ledger slice.
- `deferred`: explicit note that no PR, Slack, Confluence, or repo mutation was
  performed.
- `validity`: whether the receipt is complete enough for the POC.

Keep app-local for this slice:

- Markdown schema and parser.
- Conflict rules and thresholds.
- Command result class.
- Snapshot class and fields.
- Action fact schema.
- Receipt writer and receipt Markdown shape.
- Sign-off vocabulary and readiness states.

Observe for future graduation only:

- App-owned `CommandResult`, action fact, snapshot, and receipt conventions.
- Deterministic file-backed fixture plus runtime workdir pattern.
- Contract-backed receipt payload shape.
- In-process smoke helpers if Chronicle repeats the existing boilerplate.

Application recommendation:

- Implement Chronicle next if Web scoping agrees that one nested HTML surface
  can prove proposal/conflict/sign-off/receipt flows without graph tooling.
- Do not implement Scout, a second Lense slice, or a public facade in the next
  cycle.
- Keep the first Chronicle slice offline, deterministic, one-process, and
  useful enough that an engineer can see which existing decisions conflict with
  a proposal and what sign-off state exists.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` scopes Chronicle's app-local model and first
   contract-backed workflow.
2. `[Agent Web / Codex]` scopes Chronicle's mounted surface and smoke evidence.
3. `[Architect Supervisor / Codex]` decides whether to implement Chronicle or
   choose another pressure line.

[Agent Application / Codex]
track: `docs/dev/application-chronicle-scoping-track.md`
status: landed
delta: scoped Chronicle's smallest app-local slice around proposal scans,
  conflict evidence, explicit sign-off/refusal commands, and durable decision
  receipts.
delta: proposed read-only Markdown fixtures plus a deterministic runtime
  workdir so smoke runs do not mutate repository fixtures.
delta: defined app-owned services, command names, local command result shape,
  action facts, snapshot fields, refusal paths, first contract graph, and
  receipt/report evidence shape.
delta: kept Markdown parsing, conflict rules, snapshots, command results,
  receipt writer, sign-off vocabulary, and readiness states app-local; only
  repeated conventions should be observed for future graduation.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can scope the Chronicle mounted surface and smoke
  evidence; `[Architect Supervisor / Codex]` can decide implementation after
  Web scoping lands.
block: none
