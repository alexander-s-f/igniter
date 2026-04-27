# Application Showcase Evidence And Smoke Design Track

This track designs the smallest useful convention for showcase evidence and
smoke proof after Lense, Chronicle, and Scout proved the pattern.

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
- [Application Showcase Portfolio Update Track](./application-showcase-portfolio-update-track.md)
- [Application Showcase Convention Consolidation Track](./application-showcase-convention-consolidation-track.md)
- [Interactive App Structure](../guide/interactive-app-structure.md)

## Decision

[Architect Supervisor / Codex] Opened after accepting the updated showcase
portfolio.

The team may design a tiny evidence/smoke convention. This is not approval to
implement a helper, runtime API, app DSL, UI kit, marker DSL, or shared receipt
class.

## Goal

Define compact guidance that makes the next showcase cheaper and more
consistent without turning local app vocabulary into framework surface.

The result should answer:

- what a showcase evidence artifact should prove
- what smoke output should prove
- what `/events`, `/report`, and `/receipt` checks should demonstrate
- what mutation-boundary proof means
- whether any script-local helper deserves a later implementation track
- what remains app-local and Web-local
- whether Dispatch scoping should open next

## Scope

In scope:

- docs/design only
- evidence artifact checklist
- smoke proof checklist
- mutation-boundary proof vocabulary
- manual browser review checklist refinement, if needed
- optional future helper shape, limited to examples/specs
- next-track recommendation

Out of scope:

- implementation
- production/runtime APIs
- public `Igniter.interactive_app` facade
- shared `CommandResult`, snapshot, action ledger, or receipt/report classes
- route DSL, marker DSL, UI kit, screen compiler, generic report viewer
- browser automation requirement
- live transport, persistence, scheduler, auth, production server
- LLM/provider integration or connectors
- changing existing showcase behavior

## Task 1: Evidence Artifact Design

Owner: `[Agent Application / Codex]`

Acceptance:

- Define a compact evidence artifact checklist based on Lense, Chronicle, and
  Scout.
- Cover receipt/report ids, kind, validity, subject identity, provenance,
  evidence refs, action facts, deferred scope, metadata, and mutation boundary.
- Explicitly keep payload keys, validity rules, rendering, classes, and domain
  vocabularies app-local.
- Recommend whether this belongs in the public guide, dev docs, or both.
- Recommend whether Dispatch scoping should open next from the app side.

## Task 2: Smoke Proof Design

Owner: `[Agent Web / Codex]`

Acceptance:

- Define a compact smoke proof checklist based on Lense, Chronicle, and Scout.
- Cover initial render, one success path, one refusal path, final state,
  feedback markers, action markers, `/events` parity, report/receipt endpoint,
  catalog fragments, manual server review, and mutation-boundary proof.
- Decide whether a future helper should remain script-local and examples/specs
  scoped; reject runtime API, marker DSL, route DSL, UI kit, and browser
  automation as defaults.
- Recommend whether this belongs in the public guide, dev docs, or both.
- Recommend whether Dispatch scoping should open next from the Web side.

## Supervisor Guardrails

[Architect Supervisor / Codex] Notes:

- Prefer strengthening existing docs over creating a large new architecture
  document.
- The design should reduce future agent context and prevent showcase drift.
- The strongest acceptable future implementation is a tiny script-local smoke
  helper. Do not design a framework.
- Dispatch can come next only if the first slice is offline, fixture-backed,
  and receipt-oriented.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

Implementation belongs to a later track.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` designs the evidence artifact convention and
   app-side proof boundaries.
2. `[Agent Web / Codex]` designs the smoke proof convention and Web/manual
   review boundaries.
3. `[Architect Supervisor / Codex]` decides whether to open Dispatch scoping, a
   tiny helper implementation track, or return to Embed/Contracts.

## Evidence Artifact Design

[Agent Application / Codex] Recommendation:

- Strengthen the existing public guide instead of creating a new architecture
  document. The convention belongs in
  `docs/guide/interactive-app-structure.md` for app authors, while this dev
  track keeps the design rationale and next-track recommendation.
- Treat receipt/report artifacts as app-local evidence artifacts, not shared
  framework objects. Lense, Chronicle, and Scout repeat the checklist, but not
  the payload schema.
- A richer showcase artifact should prove: stable id, kind, validity,
  generated timestamp, subject identity, readiness/validity basis, deterministic
  contract or app-local analysis provenance, evidence refs, relevant action
  facts, deferred scope, caller/inspection metadata, and mutation boundary.
- Keep these app-local: class names, payload keys, nested shapes, Markdown/hash
  rendering, validity rules, evidence reference format, deferred vocabulary,
  runtime workdir layout, command/result/snapshot shape, and domain nouns.
- Mutation-boundary proof should be explicit enough for smoke and manual
  review: compare read-only fixture or target signatures when useful, count
  runtime files in the workdir when useful, and emit boring stable markers such
  as `*_no_mutation=true` or `*_fixture_no_mutation=true`.
- If a future helper is approved, start in examples/specs and keep it limited
  to checklist vocabulary or small proof utilities. Do not introduce a shared
  receipt/report class, runtime API, command result, snapshot type, route DSL,
  marker DSL, UI kit, persistence, or `Igniter.interactive_app`.

Dispatch recommendation from Application:

- Open Dispatch scoping next after Web's smoke proof design lands, unless the
  supervisor chooses a tiny script-local helper design first.
- Dispatch's first slice should stay offline and fixture-backed:
  incoming operational events -> deterministic triage/assignment evidence ->
  escalation or handoff checkpoint -> dispatch receipt.
- Dispatch should pressure event intake, routing decisions, assignment state,
  handoff provenance, and operator-facing receipt evidence without introducing
  live transport, scheduler, queue runtime, connectors, auth, production server,
  database persistence, or cluster placement.

[Agent Application / Codex]
track: `docs/dev/application-showcase-evidence-smoke-design-track.md`
status: landed
delta: updated `docs/guide/interactive-app-structure.md` receipt/report
  convention with an evidence artifact checklist covering id, kind, validity,
  subject identity, readiness basis, provenance, evidence refs, action facts,
  deferred scope, metadata, and mutation boundary.
delta: added explicit mutation-boundary proof guidance to the guide validation
  section while keeping hashing strategy, filenames, markers, and workdir
  layout app-local.
delta: recorded app-side design rationale and Dispatch recommendation in this
  track; no runtime/helper/API behavior was added.
verify: `git diff --check` passed.
ready: `[Agent Web / Codex]` can add smoke proof/manual review design; then
  `[Architect Supervisor / Codex]` can choose Dispatch, tiny helper, or
  Embed/Contracts next.
block: none

## Smoke Proof Design

[Agent Web / Codex] Recommendation:

- Strengthen `docs/guide/interactive-app-structure.md` instead of creating a
  new architecture document. The smoke proof checklist belongs in the public
  guide because future showcase authors need it while writing examples.
- Keep this dev track as rationale: three showcase apps now repeat enough
  smoke mechanics to document proof expectations, but not enough to create
  runtime APIs, route DSL, marker DSL, UI kit, screen compiler, browser
  automation requirement, or generic report viewer.
- A showcase smoke should prove: initial mounted surface render, one success
  path, one refusal path, final state, feedback markers, command/action
  markers, domain record/counter markers, recent activity, `/events` parity,
  report/receipt endpoint when present, deterministic catalog fragments, manual
  server command availability, and mutation-boundary markers.
- `/events` checks should demonstrate that the text endpoint and HTML surface
  consume the same app-owned snapshot shape. `/report` and `/receipt` checks
  should demonstrate app-owned artifact availability, not standardize payload
  schemas.
- A future helper may be worth implementing, but it should be script-local
  first and scoped to examples/specs: Rack env construction, form encoding,
  redirect-following, response status checks, marker assertions, endpoint
  parity checks, and deterministic output helpers.
- Keep these Web-local: marker names, `data-action` values, feedback code
  strings, selected success/refusal paths, endpoint names, smoke output labels,
  catalog fragments, and whether a manual review uses browser tooling.

Dispatch recommendation from Web:

- Open Dispatch scoping next unless the supervisor prefers a tiny script-local
  helper implementation first.
- Dispatch's first Web slice should stay offline and fixture-backed:
  event inbox -> deterministic triage/assignment evidence -> escalation or
  handoff checkpoint -> dispatch receipt.
- Web should pressure different presentation seams from Lense, Chronicle, and
  Scout: queue/inbox state, routing rationale, assignee/escalation markers,
  handoff provenance, action ledger, `/events` parity, and receipt evidence.
- Keep live transport, background scheduler, queue runtime, connectors,
  database persistence, auth, production server, cluster placement, and LLM
  triage explicitly out of the first Dispatch slice.

[Agent Web / Codex]
track: `docs/dev/application-showcase-evidence-smoke-design-track.md`
status: landed
delta: updated `docs/guide/interactive-app-structure.md` with a smoke proof
  checklist covering initial render, success/refusal paths, feedback/action
  markers, domain markers, recent activity, `/events` parity, report/receipt
  endpoints, catalog fragments, and mutation-boundary proof.
delta: recorded Web-side design rationale that any future helper should remain
  script-local and examples/specs scoped; runtime API, marker DSL, route DSL,
  UI kit, browser automation default, and generic report viewer remain
  rejected.
delta: recommended Dispatch scoping next from the Web side, limited to an
  offline fixture-backed inbox/triage/handoff receipt slice.
verify: `git diff --check` passed.
ready: `[Architect Supervisor / Codex]` can choose Dispatch scoping, tiny
  helper implementation, or Embed/Contracts next.
block: none
