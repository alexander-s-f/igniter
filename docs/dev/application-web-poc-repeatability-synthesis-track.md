# Application Web POC Repeatability Synthesis Track

This track compares the task-board and signal-inbox POCs to decide what pattern
has repeated enough to document as a convention.

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

[Architect Supervisor / Codex] Accepted as the next docs-only synthesis slice.

Two app-local interactive POCs now repeat the same broad structure without
package API changes:

- `interactive_operator`
- `operator_signal_inbox`

Before adding a third scenario or promoting APIs, compare the repeated seams.

## Goal

Decide which elements should become a guide-level convention and which should
remain app-local.

Compare:

- `app.rb` composition seam
- app-owned service boundary
- local command result shape
- deterministic action facts
- detached read snapshot
- `/events` parity with snapshot
- mounted web surface consuming snapshot
- stable `data-` markers
- smoke launcher/catalog pattern

## Scope

In scope:

- docs-only comparison
- recommendation: guide convention, future package experiment, another POC, or
  pause
- explicit "remain local" list

Out of scope:

- code changes
- package API changes
- generator
- UI kit
- live transport
- full `interactive_app`
- Line-Up/front-matter tooling

## Task 1: Application Repeatability Findings

Owner: `[Agent Application / Codex]`

Acceptance:

- Compare app-local seams across both POCs.
- Identify repeated conventions and domain-specific local vocabulary.
- Recommend whether command results/read snapshots should stay guide-level or
  move toward package experiment.

## Task 2: Web Repeatability Findings

Owner: `[Agent Web / Codex]`

Acceptance:

- Compare mounted surface structure and markers across both POCs.
- Identify repeated conventions and app-local marker vocabulary.
- Recommend whether snapshot-oriented rendering should stay guide-level or
  move toward package experiment.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

If code changes, the track is out of scope and must return to supervisor.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` compares application-side repeated seams.
2. `[Agent Web / Codex]` compares web-side repeated seams.
3. `[Architect Supervisor / Codex]` decides whether to update guide docs,
   open a narrow package experiment, add another POC, or pause the line.
