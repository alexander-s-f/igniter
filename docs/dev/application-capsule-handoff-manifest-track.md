# Application Capsule Handoff Manifest Track

This track follows the accepted capsule assembly plan cycle.

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

Igniter now has enough read-only pieces to explain and transfer a capsule or a
small set of capsules:

- capsule blueprint / DSL authoring
- capsule inspection reports
- composition readiness reports
- assembly plans
- optional web surface metadata

The next step is a compact handoff manifest: a serializable artifact a human or
agent can read before copying, reviewing, or wiring capsules into a host.

This must stay descriptive. It must not discover files, package archives, boot
apps, mount web, or execute contracts.

[Architect Supervisor / Codex] Accepted after the 2026-04-24 agent cycle.

Decision:

- `ApplicationHandoffManifest` and
  `Igniter::Application.handoff_manifest(...)` are accepted as the
  application-owned read-only handoff surface.
- Building from explicit capsules or an existing `ApplicationAssemblyPlan` is
  accepted.
- Summaries for capsule identities, exports/imports, readiness, unresolved
  requirements, suggested host wiring, mount intents, surface metadata, and
  nested assembly metadata are accepted.
- Web metadata remains caller-supplied plain hashes. The example may use
  `igniter-web` to produce those hashes, but `igniter-application` must not
  inspect web screens, routes, components, Rack apps, or mount internals.

Verification:

```bash
ruby examples/application/capsule_handoff_manifest.rb
ruby examples/application/capsule_assembly_plan.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb
```

Result: all passed.

Next:

- Continue through
  [Application Capsule Transfer Guide Track](./application-capsule-transfer-guide-track.md).
- Keep the next slice documentation-first. Do not turn handoff manifests into
  packaging, copy, discovery, loading, boot, mount, route, execution, or
  cluster placement.

## Goal

Design and land the smallest handoff manifest for portable application
capsules:

- identify the handoff subject
- include selected capsule identities
- include capsule inspection summaries
- include composition readiness
- include assembly plan metadata
- include unresolved requirements and suggested host wiring
- include optional surface metadata summaries
- expose stable `to_h`

The manifest should answer: "What am I moving, what does it need, and what must
the receiving host provide?"

## Scope

In scope:

- application-owned read-only handoff manifest value
- manifest builder over explicit blueprints/capsules and optional existing
  reports/plans
- compact summary over capsule reports, composition report, and assembly plan
- unresolved/required/optional dependency summaries
- smoke example for a ready handoff and a handoff with a missing host export
- guide note only if needed

Out of scope:

- archive/package creation
- filesystem copy or discovery
- autoloading
- boot/mount/runtime activation
- contract/service execution
- cluster placement
- web route/browser transport
- private app-specific material

## Accepted Constraints

- Handoff manifest is metadata, not packaging.
- Inputs are explicit; no scanning directories or resolving constants.
- It may compose existing reports but should not duplicate matching logic.
- Web surface metadata remains opaque plain hashes supplied by the caller.
- The manifest should work for a single capsule and multiple-capsule assembly.

## Task 1: Handoff Manifest Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned value, for example
  `ApplicationHandoffManifest`.
- Accept capsules/blueprints and optional assembly/composition/report inputs,
  or build the read-only reports internally from explicit inputs.
- Include capsule names, roots, exports/imports summary, readiness,
  unresolved required imports, missing optional imports, mount intents, and
  supplied surface metadata summary.
- Expose stable `to_h`.
- Do not discover, copy, load, boot, mount, route, or execute anything.

## Task 2: Smoke Examples

Owner: `[Agent Application / Codex]`

Suggested file:

- `examples/application/capsule_handoff_manifest.rb`

Acceptance:

- Build at least one ready handoff manifest.
- Build or show one unresolved/missing-host-export signal.
- Print compact smoke keys.
- No filesystem copy, archive creation, runtime boot, web mount, cluster
  behavior, or contract execution.

Suggested smoke keys:

```text
application_capsule_handoff_subject=...
application_capsule_handoff_capsules=...
application_capsule_handoff_ready=...
application_capsule_handoff_required=...
application_capsule_handoff_unresolved=...
application_capsule_handoff_mounts=...
application_capsule_handoff_surfaces=...
```

## Task 3: Web Compatibility Review

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify web surface metadata can be included in the manifest as supplied plain
  hashes.
- Do not require application handoff manifests to inspect `SurfaceManifest`,
  screens, routes, components, Rack apps, or mounts.
- Add docs/example notes only if needed.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_handoff_manifest.rb
ruby examples/application/capsule_assembly_plan.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web examples/specs change, include the relevant `packages/igniter-web/spec`
slice in the handoff.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 with a read-only handoff
   manifest over explicit capsule/assembly metadata.
2. `[Agent Web / Codex]` stays in compatibility-review mode unless web surface
   metadata needs a package-local note.
3. Keep this as manifest/description. Do not turn it into packaging, copy,
   discovery, boot, mount, route, execute, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-handoff-manifest-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationHandoffManifest` and
  `Igniter::Application.handoff_manifest(...)`.
- The manifest can build from explicit capsules or an existing
  `ApplicationAssemblyPlan`.
- Added `examples/application/capsule_handoff_manifest.rb`.
Accepted:
- The manifest summarizes capsule identities, exports/imports, readiness,
  unresolved required imports, missing optional imports, suggested host wiring,
  mount intents, supplied surface metadata, and nested assembly metadata.
- It remains descriptive metadata only: no packaging, copying, discovery,
  loading, booting, mounting, routing, execution, or cluster placement.
Needs:
- `[Agent Web / Codex]` can verify supplied web surface metadata remains opaque
  plain hashes in handoff manifests.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-handoff-manifest-track.md`
Status: landed.
Changed:
- Reviewed `ApplicationHandoffManifest` against web-owned surface metadata.
- Updated `examples/application/capsule_handoff_manifest.rb` so a web-owned
  `Igniter::Web.application`, `SurfaceManifest`, and `ApplicationWebMount`
  provide only explicit plain metadata/path inputs to
  `Igniter::Application.handoff_manifest(...)`.
- Updated the examples catalog with web surface kind and web mount smoke flags.
Accepted:
- Web surface metadata remains an opaque supplied hash in handoff manifests.
- Handoff manifests do not inspect `SurfaceManifest`, screens, routes,
  components, Rack apps, or mounts.
- No web-specific handoff behavior is needed in `igniter-application`.
Needs:
- `[Architect Supervisor / Codex]` review the handoff manifest track for
  acceptance.
