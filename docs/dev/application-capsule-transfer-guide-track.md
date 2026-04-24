# Application Capsule Transfer Guide Track

This track follows the accepted capsule handoff manifest cycle.

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

Igniter now has a coherent read-only chain for portable application capsules:

- capsule authoring
- capsule inspection
- capsule composition
- capsule assembly planning
- handoff manifests

The next step is not runtime activation. The next step is a concise public
transfer guide that explains how a human or agent reviews a capsule before
copying or wiring it into a host.

The guide should preserve the Igniter doctrine: capsules are portable because
they declare explicit metadata and dependencies, not because Igniter scans,
loads, packages, or mounts them automatically.

## Goal

Land the smallest public documentation pass for capsule transfer and host
wiring review:

- explain the capsule transfer workflow
- show where handoff manifests fit after inspection/composition/assembly
- clarify ready vs unresolved handoff states
- clarify suggested host wiring
- clarify optional web surface metadata as supplied metadata
- keep examples linked to the existing smoke scripts

The guide should answer: "How do I decide whether this capsule can move into a
new host, and what does the host need to provide?"

## Scope

In scope:

- user-facing guide updates in `docs/guide/`
- current-state alignment in `docs/current/` or `docs/dev/current-runtime-snapshot.md`
  when needed
- package README pointers only if they materially reduce discovery friction
- examples catalog alignment if output descriptions need refinement

Out of scope:

- archive/package creation
- filesystem copy automation
- discovery or autoloading
- boot/mount/runtime activation
- web routing/browser transport
- contract/service execution
- cluster placement
- private app-specific material

## Accepted Constraints

- The transfer story is metadata-first and explicit-input only.
- `ApplicationHandoffManifest` remains the read-only artifact for transfer
  review.
- Web remains optional. Web-owned helpers may produce surface metadata, but the
  application guide must not imply an application dependency on `igniter-web`.
- The guide must keep clean blueprint authoring and human capsule DSL as equal
  valid forms.

## Task 1: Public Transfer Guide

Owner: `[Agent Application / Codex]`

Suggested files:

- `docs/guide/application-capsules.md`
- `examples/README.md` if needed

Acceptance:

- Add a compact section that explains transfer/handoff review.
- Reference `ApplicationHandoffManifest` and
  `Igniter::Application.handoff_manifest(...)`.
- Show the relationship between capsule report, composition report, assembly
  plan, and handoff manifest.
- Explain `ready`, `unresolved_required_imports`, `missing_optional_imports`,
  and `suggested_host_wiring`.
- Link or mention `examples/application/capsule_handoff_manifest.rb`.
- Do not describe any automatic copying, package archive, discovery,
  activation, web mount, route, contract execution, or cluster placement.

## Task 2: Current State Alignment

Owner: `[Agent Application / Codex]`

Suggested files:

- `docs/current/app-structure.md`
- `docs/dev/current-runtime-snapshot.md`

Acceptance:

- Current docs mention read-only handoff manifests as the final transfer review
  artifact after assembly plans.
- The wording keeps app capsules as the portability boundary.
- The wording keeps transfer review separate from runtime activation.

## Task 3: Web Metadata Note

Owner: `[Agent Web / Codex]`

Acceptance:

- Confirm guide wording treats web as optional supplied surface metadata.
- Add a small package-local note only if the current web docs make the handoff
  path hard to discover.
- Do not add web-specific behavior to `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_handoff_manifest.rb
ruby examples/application/capsule_assembly_plan.rb
bundle exec rspec spec/current/example_scripts_spec.rb
```

If any package code changes, include the relevant package specs.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 as a docs-first
   transfer guide pass.
2. `[Agent Web / Codex]` performs Task 3 as a compatibility/narrative check.
3. Keep this cycle public and generic. Private SparkCRM or other host-specific
   details stay out of this track.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-transfer-guide-track.md`
Status: landed.
Changed:
- Added a public transfer and handoff review section to
  `docs/guide/application-capsules.md`.
- Aligned `docs/current/app-structure.md` with the read-only transfer chain:
  capsule report, composition report, assembly plan, and handoff manifest.
- Added composition, assembly, and handoff examples to the current capsule
  example pointers.
Accepted:
- `ApplicationHandoffManifest` is documented as the final read-only transfer
  review artifact.
- The guide explains `ready`, `unresolved_required_imports`,
  `missing_optional_imports`, and `suggested_host_wiring`.
- Web surface metadata remains optional supplied metadata; application still
  does not inspect web internals.
- Transfer review is explicitly separate from packaging, copy, discovery,
  loading, boot, mount, routing, execution, and cluster placement.
Needs:
- `[Agent Web / Codex]` can perform Task 3 wording review for optional web
  metadata discoverability.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-transfer-guide-track.md`
Status: landed.
Changed:
- Reviewed the public capsule transfer wording for optional web surface
  metadata.
- Updated `docs/guide/application-capsules.md` to name
  `Igniter::Web.surface_metadata(surface)` and
  `Igniter::Web.flow_surface_metadata(...)` as web-owned producers of supplied
  metadata for handoff manifests.
- Updated `packages/igniter-web/README.md` with a handoff manifest example that
  passes plain `surface_metadata` and mount intent metadata without binding or
  routing web.
Accepted:
- Transfer docs keep web optional and metadata-only.
- The handoff path does not imply `igniter-application` depends on
  `igniter-web` or inspects `SurfaceManifest`, screens, routes, Rack apps, or
  components.
Needs:
- `[Architect Supervisor / Codex]` review the transfer guide track for
  acceptance.
