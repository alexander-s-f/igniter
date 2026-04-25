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

[Agent Application / Codex]
track: `docs/dev/application-web-poc-repeatability-synthesis-track.md`
status: landed
delta: repeated app seam: both POCs use `app.rb` as the composition boundary
  for `Igniter::Application.rack_app`, explicit service factories, opaque web
  mounts, small command endpoints, and `/events`.
delta: repeated service seam: both POCs keep mutable state, command methods,
  deterministic action facts, `CommandResult`, and detached snapshot objects
  inside the app-local service.
delta: repeated read seam: both POCs render `/events` from the same snapshot
  shape consumed by the web surface, with count fields plus recent action facts.
delta: repeated smoke seam: both POCs have a stable launcher, catalog entry,
  feedback redirects, command/refusal checks, action facts, and final state
  assertions.
delta: remain local: entity names, id fields, feedback codes, action kinds,
  snapshot class names, counters, and command parameters are still domain
  vocabulary (`task_id`/`signal_id`, `BoardSnapshot`/`SignalSnapshot`).
delta: recommendation: promote the shape to a guide-level convention now; do
  not open a package-level `CommandResult` or read snapshot API yet.
delta: future package experiment trigger: consider a narrow package experiment
  only if a third non-task POC repeats the same shape or if examples start
  duplicating enough mechanical code to obscure domain intent.
verify: `git diff --check` passed for docs-only synthesis.
ready: `[Agent Web / Codex]` can add web-side repeatability findings, then
  `[Architect Supervisor / Codex]` can choose guide update, package experiment,
  third POC, or pause.
block: none

[Agent Web / Codex]
track: `docs/dev/application-web-poc-repeatability-synthesis-track.md`
status: landed
delta: repeated web seam: both POCs use one mounted surface module that owns
  Arbre layout, local style helpers, feedback copy, status/activity labels, and
  marker naming while consuming app state through `MountContext`.
delta: repeated render seam: both surfaces take one app-owned snapshot at the
  top of render and use it for counters, cards, recent activity, and footer
  read-model hints.
delta: repeated marker seam: both surfaces expose stable markers for surface
  identity, counters, command forms, entity id/status, feedback code, recent
  activity surface, action kind, and activity status.
delta: repeated smoke seam: both launchers use those markers as the browser/
  smoke inspection contract instead of asserting presentation internals or
  introducing a component framework.
delta: remain local: entity marker names (`data-task-id` vs
  `data-signal-id`), command action names, feedback messages, status labels,
  severity/task styling, and activity label copy remain app vocabulary.
delta: guide-level convention: document "mounted surface consumes app snapshot
  and publishes stable inspection markers" as a copyable convention.
delta: package experiment trigger: consider `igniter-web` helpers only if a
  third distinct POC repeats enough mechanical marker/form/feedback code that
  local readability gets worse.
delta: recommendation: update/accept guide-level wording now; do not promote a
  UI kit, marker DSL, component DSL, live transport, generator, `interactive_app`,
  Line-Up tooling, or package-level snapshot/render API yet.
verify: `git diff --check` passed for docs-only synthesis.
ready: `[Architect Supervisor / Codex]` can choose guide update, package
  experiment, third POC, or pause.
block: none

## Supervisor Acceptance

[Architect Supervisor / Codex] Accepted after the cycle review.

Accepted:

- The task-board and signal-inbox POCs repeat the same app/web structure:
  `app.rb` composition, app-owned service boundary, local command result,
  deterministic action facts, detached read snapshot, `/events` parity, mounted
  web surface, stable markers, and catalog smoke launcher.
- This is enough for a guide-level convention.
- It is not enough for package-level `CommandResult`, snapshot API, marker DSL,
  UI kit, generator, live transport, or `interactive_app`.

Guide update:

- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)
  now includes the repeated convention and the "still app-local" boundary.

Decision:

- Pause new Application/Web POC implementation until the user or supervisor
  chooses one of:
  - third distinct POC
  - narrow guide polish
  - narrow package experiment after more evidence
  - return to Embed/Contracts pressure

Verification:

- `git diff --check` passed.
