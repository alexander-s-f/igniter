# Application Capsule Composition Track

This track follows the accepted capsule authoring DSL cycle.

Authoritative supervisor notes are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should report with:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

## Decision

[Architect Supervisor / Codex] Accepted as the next broad track.

Igniter now has portable application capsules, exports/imports, inspection
reports, and a compact human authoring DSL. The next portability question is
how a host, stack, or agent can look at several capsules and understand whether
their declared dependencies can be satisfied.

This should start as a read-only composition report, not as a runtime
orchestrator.

## Goal

Design and land the smallest application-owned composition/readiness report for
multiple capsules:

- which capsules are present
- which exports they provide
- which imports they require
- which imports can be satisfied by sibling capsule exports
- which imports are expected from the host
- which required imports remain unresolved
- which optional imports are missing but acceptable

The report should support both clean `ApplicationBlueprint` instances and
human-authored capsule DSL objects via `to_blueprint`.

## Scope

In scope:

- application-owned read-only composition report/planner over explicit
  blueprints
- import/export matching by declared `name`, `kind`, and available metadata
- host-supplied capabilities/exports as explicit input
- serializable `to_h` output
- smoke example with two capsules and one host-provided dependency
- guide/docs update only if it clarifies plug-and-play capsule portability

Out of scope:

- automatic constant resolution
- autoloading/discovery
- executing contracts or services
- booting/mounting apps
- cluster placement or distributed routing
- browser/web transport
- replacing existing stack runtime
- making web define application composition semantics

## Accepted Constraints

- Composition is inspection first.
- A capsule import is not satisfied just because a constant exists somewhere.
- Matching should use explicit exports/imports and explicit host input.
- Required and optional imports must stay distinguishable.
- Web surfaces may appear as `kind: :web_surface` exports or supplied surface
  metadata, but web route/screen details stay web-owned.
- The report should accept plain hashes where reasonable, but the canonical app
  input remains `ApplicationBlueprint`-like objects.

## Task 1: Composition Report Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned report shape, for example
  `ApplicationCompositionReport`.
- Accept a list of blueprints or capsule DSL objects that respond to
  `to_blueprint`.
- Accept explicit host exports/capabilities input.
- Report capsule identities, exports, imports, satisfied imports, unresolved
  required imports, missing optional imports, and host-satisfied imports.
- Expose stable `to_h`.
- Do not execute, boot, load, mount, or materialize anything.

## Task 2: Matching Policy

Owner: `[Agent Application / Codex]`

Acceptance:

- Start with conservative exact matching by import/export `name` and `kind`.
- Preserve enough metadata for later richer matching without implementing a
  rules engine now.
- Do not silently satisfy imports through fuzzy constants, paths, web routes, or
  contract class names.
- Specs cover sibling-satisfied, host-satisfied, unresolved required, and
  missing optional imports.

## Task 3: Smoke Example

Owner: `[Agent Application / Codex]`

Support: `[Agent Web / Codex]` only if web surface exports are used.

Suggested file:

- `examples/application/capsule_composition.rb`

Acceptance:

- Use at least two capsules, preferably one clean blueprint and one DSL-built
  capsule.
- Include one sibling-satisfied import, one host-satisfied import, and one
  optional missing import.
- Print compact smoke keys.
- No runtime boot, web transport, cluster behavior, or contract execution.

Suggested smoke keys:

```text
application_capsule_composition_capsules=...
application_capsule_composition_exports=...
application_capsule_composition_satisfied=...
application_capsule_composition_host_satisfied=...
application_capsule_composition_unresolved=...
application_capsule_composition_optional_missing=...
application_capsule_composition_ready=...
```

## Task 4: Web Compatibility Review

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify that web surface exports/imports can remain plain metadata in the
  composition report.
- Do not require application composition to inspect `SurfaceManifest`,
  screens, routes, or components.
- Add docs/example notes only if needed.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_composition.rb
ruby examples/application/capsule_authoring_dsl.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web examples/specs change, include the relevant `packages/igniter-web/spec`
slice in the handoff.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 with a read-only
   composition report.
2. `[Agent Web / Codex]` stays in compatibility-review mode unless web surface
   metadata creates a concrete issue.
3. Keep this as explicit metadata matching. Do not turn it into boot, mount,
   discovery, cluster routing, or service execution.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-composition-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationCompositionReport` and
  `Igniter::Application.compose_capsules(...)`.
- The report accepts clean blueprints and capsule DSL objects via
  `to_blueprint`, plus explicit host exports and host capabilities.
- Matching starts conservatively with exact import/export `name` and `kind`.
- Added `examples/application/capsule_composition.rb`.
Accepted:
- Reports capsule identities, exports, imports, sibling-satisfied imports,
  host-satisfied imports, unresolved required imports, missing optional imports,
  and readiness.
- The report is read-only and does not load, boot, mount, materialize, execute,
  discover, or inspect web internals.
Needs:
- `[Agent Web / Codex]` can verify that web surface exports/imports remain
  plain metadata in composition reports.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-composition-track.md`
Status: landed.
Changed:
- Reviewed the application-owned composition report against web surface
  metadata.
- Updated `examples/application/capsule_composition.rb` so a web-owned
  `SurfaceManifest` is exported as `kind: :web_surface` plain metadata and
  satisfied by another capsule import through exact `name` / `kind` matching.
- Updated the examples catalog with web surface export/satisfaction smoke
  flags.
Accepted:
- Web surface exports/imports fit the composition report without application
  inspecting `SurfaceManifest`, screens, routes, or components.
- No web-specific composition semantics are needed in `igniter-application`.
Needs:
- `[Architect Supervisor / Codex]` review the composition track for
  acceptance.
