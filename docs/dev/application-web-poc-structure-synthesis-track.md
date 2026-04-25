# Application Web POC Structure Synthesis Track

This track extracts structure lessons from the interactive operator POC.

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
- [Documentation Compression Doctrine](./documentation-compression-doctrine.md)

## Decision

[Architect Supervisor / Codex] Accepted as the next compact docs-only slice.

The POC now has enough live pressure data: task commands, feedback, action
ledger, command results, read snapshot, `/events`, and web rendering all work
together. Before adding another feature, capture what this teaches about
organic app structure.

## Goal

Summarize the app/web structure that proved useful in the POC.

The result should help decide whether the next implementation should be:

- another POC feature
- a reusable application pattern
- a guide update
- a package-level API experiment
- a stop/pause point

## Scope

In scope:

- app-local structure: `app.rb`, `services/`, command results, read snapshots
- web-local structure: mounted surface, feedback, data markers, snapshot
  rendering
- what should remain app-local for now
- what might later graduate into package API
- one compact supervisor-ready recommendation

Out of scope:

- code changes
- package API changes
- front-matter rollout
- compression tooling
- UI redesign
- live transport
- full `interactive_app`

## Task 1: Application Structure Findings

Owner: `[Agent Application / Codex]`

Acceptance:

- Summarize the useful app-local seams from the POC.
- Call out which seams should remain local and why.
- Call out any candidate seams for future package graduation.
- Keep the handoff compact and factual.

## Task 2: Web Structure Findings

Owner: `[Agent Web / Codex]`

Acceptance:

- Summarize the useful web-local seams from the POC.
- Call out which rendering/marker choices should remain local and why.
- Call out any candidate seams for future package graduation.
- Keep the handoff compact and factual.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

If code changes, the track is out of scope and must return to supervisor.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` reports application structure findings.
2. `[Agent Web / Codex]` reports web structure findings.
3. `[Architect Supervisor / Codex]` decides whether the next step is another
   POC feature, guide update, reusable pattern, package experiment, or pause.

[Agent Application / Codex]
track: `docs/dev/application-web-poc-structure-synthesis-track.md`
status: landed
delta: app-local structure finding: `app.rb` works best as the composition
  seam; it owns service factories, explicit web mounts, and small Rack command
  endpoints without hiding routes behind a larger facade.
delta: app-local structure finding: `services/task_board.rb` works best as the
  state/command/read boundary; `CommandResult`, action facts, and
  `BoardSnapshot` stayed readable because they remained local to the app.
delta: remain local: command result codes, action kinds, task ids, and board
  snapshot fields are domain vocabulary, not framework contracts yet.
delta: possible graduation: `Application.rack_app` is already the reusable seam;
  future package experiments could explore a generic app-owned command result
  or read snapshot convention only after at least one more non-task POC repeats
  the same shape.
delta: recommendation: next best step is a guide/pattern note for copyable
  interactive app structure before adding another runtime feature.
verify: `git diff --check` passed for docs-only change.
ready: `[Agent Web / Codex]` can add web-local structure findings, then
  `[Architect Supervisor / Codex]` can choose the next compact slice.
block: none

[Agent Web / Codex]
track: `docs/dev/application-web-poc-structure-synthesis-track.md`
status: landed
delta: web-local structure finding: `web/operator_board.rb` works best as one
  mounted surface module that owns presentation helpers, feedback copy,
  data-marker naming, and Arbre layout while treating application state as an
  app-owned snapshot.
delta: web-local structure finding: stable `data-` markers proved more useful
  than a component framework for this POC; they keep smoke tests, operator
  inspection, and future browser checks aligned without adding UI kit ceremony.
delta: remain local: feedback codes, activity labels, task-card styling, and
  form actions should stay inside the app surface until another non-task POC
  repeats the same vocabulary.
delta: possible graduation: `MountContext` plus snapshot-oriented rendering is
  the candidate seam; a future package experiment could document a
  "surface consumes app read model" convention before introducing helpers.
delta: recommendation: publish a short guide/pattern note for copyable
  app-local web surfaces before adding another runtime feature or package API.
verify: `git diff --check` passed for docs-only change.
ready: `[Architect Supervisor / Codex]` can decide whether the next compact
  slice is a guide update, another non-task POC, reusable pattern note, or
  pause.
block: none
