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
