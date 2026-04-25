# Application Web POC Guide Consolidation Track

This track promotes the repeated app/web POC convention from dev notes into a
compact user-facing guide.

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

- [Documentation Compression Doctrine](./documentation-compression-doctrine.md)
- [Application Web POC Pattern Guide](./application-web-poc-pattern-guide.md)

## Decision

[Architect Supervisor / Codex] Accepted as the next docs-only slice.

The repeatability synthesis accepted the pattern as guide-level convention, not
package API. The next useful step is to publish a short user-facing guide that
points to the two working examples.

## Goal

Add a compact guide for copyable interactive app structure with
Igniter Application + Igniter Web.

The guide should explain:

- `app.rb` as composition boundary
- app-owned services as state/command/read boundary
- local command result and snapshot convention
- `/events` parity with the same snapshot used by web rendering
- mounted web surface consuming snapshots through `MountContext`
- stable `data-` markers for smoke/browser checks
- why this is still guide convention, not package API

## Scope

In scope:

- one user-facing guide page under `docs/guide/`
- guide index links
- short references to `interactive_operator` and `operator_signal_inbox`
- no large code copies

Out of scope:

- code changes
- package API changes
- generator
- UI kit
- live transport
- full `interactive_app`
- Line-Up/front-matter tooling

## Task 1: Application Guide Section

Owner: `[Agent Application / Codex]`

Acceptance:

- Document the app-local structure in user-facing language.
- Reference existing files instead of copying large snippets.
- Keep command result and snapshot as guide-level conventions only.

## Task 2: Web Guide Section

Owner: `[Agent Web / Codex]`

Acceptance:

- Document mounted surface consumption of app-owned snapshots.
- Document stable `data-` markers as the current inspection seam.
- Avoid UI kit/component DSL language.

## Verification Gate

Before supervisor acceptance:

```bash
git diff --check
```

If code changes, the track is out of scope and must return to supervisor.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` drafts the app structure section.
2. `[Agent Web / Codex]` drafts the web surface and marker section.
3. Keep the guide compact and explicitly non-API.

[Agent Application / Codex]
track: `docs/dev/application-web-poc-guide-consolidation-track.md`
status: landed
delta: `docs/guide/interactive-app-structure.md` adds the user-facing
  app-local structure section for `app.rb`, app-owned services, local command
  results, detached snapshots, `/events` parity, and still-local vocabulary.
delta: `docs/guide/interactive-app-structure.md` references the two runnable
  examples instead of copying large code blocks and leaves the web section for
  `[Agent Web / Codex]`.
delta: `docs/guide/README.md` and `docs/guide/app.md` link the new guide.
verify: `git diff --check` passed for docs-only change.
ready: `[Agent Web / Codex]` can add the web surface and marker section.
block: none
