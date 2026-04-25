# Application Web POC Pattern Guide Track

This track turns the accepted interactive operator POC findings into a compact
copyable pattern guide.

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

[Architect Supervisor / Codex] Accepted as the next docs-only slice.

The structure synthesis recommends documenting the copyable app-local pattern
before adding another runtime feature or package API.

## Goal

Add a short guide/pattern note for building a small interactive app with
Igniter Application + Igniter Web.

The guide should cover:

- `app.rb` as the composition seam
- `services/` as the app-owned state/command/read boundary
- app-local `CommandResult`
- app-local read snapshot
- mounted web surface consuming the snapshot
- stable `data-` markers for smoke/browser checks
- what should remain local until repeated by another POC

## Scope

In scope:

- one compact guide or dev pattern note
- links from the dev index if needed
- examples that point to the existing `examples/application/interactive_operator`
  skeleton instead of copying large code blocks

Out of scope:

- code changes
- package API changes
- generators
- UI kit
- live transport
- full `interactive_app`
- Line-Up/front-matter tooling

## Task 1: Application Pattern Note

Owner: `[Agent Application / Codex]`

Acceptance:

- Document the app-local structure and why it stayed local.
- Keep examples short and reference existing files.
- Do not propose package API unless labeled as future candidate.

## Task 2: Web Pattern Note

Owner: `[Agent Web / Codex]`

Acceptance:

- Document the mounted surface and snapshot rendering pattern.
- Document stable `data-` markers as the current testing/inspection seam.
- Do not introduce a UI kit or web abstraction.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

If code changes, the track is out of scope and must return to supervisor.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` drafts the app-local pattern section.
2. `[Agent Web / Codex]` drafts the web-local pattern section.
3. Keep the guide compact; link existing files instead of reproducing code.

[Agent Application / Codex]
track: `docs/dev/application-web-poc-pattern-guide-track.md`
status: landed
delta: `docs/dev/application-web-poc-pattern-guide.md` adds a compact
  app-local pattern section covering `app.rb` as composition seam, `services/`
  as state/command/read boundary, local `CommandResult`, detached read
  snapshots, and future graduation criteria.
delta: `docs/dev/application-web-poc-pattern-guide.md` references the existing
  interactive operator files instead of copying code and leaves the web section
  for `[Agent Web / Codex]`.
delta: `docs/dev/README.md` links the new pattern guide from the dev index.
verify: `git diff --check` passed for docs-only change.
ready: `[Agent Web / Codex]` can fill the web-local pattern section.
block: none

[Agent Web / Codex]
track: `docs/dev/application-web-poc-pattern-guide-track.md`
status: landed
delta: `docs/dev/application-web-poc-pattern-guide.md` fills the web-local
  pattern section with the mounted surface, app snapshot rendering, stable
  `data-` marker seam, and local-vocabulary boundaries.
delta: the guide keeps examples as file references and does not introduce a UI
  kit, web abstraction, package API, live transport, generator, or Line-Up
  tooling.
verify: `git diff --check` passed for docs-only change.
ready: `[Architect Supervisor / Codex]` can review/accept the completed pattern
  guide slice.
block: none

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after the cycle review.

Accepted:

- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)
  captures the copyable app-local and web-local structure proven by the POC.
- The guide references existing files instead of copying large code blocks.
- It keeps `CommandResult`, action facts, snapshot fields, feedback codes, and
  web marker vocabulary app-local for now.
- It identifies `Igniter::Application.rack_app` and `MountContext` plus
  app-owned snapshot rendering as the current reusable seams.
- It does not introduce package APIs, UI kit, live transport, generator,
  `interactive_app`, Line-Up tooling, or front-matter tooling.

Verification:

- `git diff --check` passed.

Next:

- Open [Application Web POC Second Scenario Track](./application-web-poc-second-scenario-track.md)
  to choose a second non-task scenario before deciding whether any pattern
  deserves broader documentation or package-level experimentation.
