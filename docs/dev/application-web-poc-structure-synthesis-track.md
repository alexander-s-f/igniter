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
