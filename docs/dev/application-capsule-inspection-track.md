# Application Capsule Inspection Track

This track follows the accepted feature-slice and flow declaration cycle.

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

Igniter now has the raw metadata needed to explain an application capsule:
layout profiles, sparse structure plans, exports/imports, optional feature
slices, app-owned flow declarations, active flow snapshots, and web-owned
surface projections.

The next step should not add another hidden runtime. It should make the capsule
inspectable as a compact read model that humans and agents can use before
editing or moving an application.

## Goal

Land the smallest inspectable capsule report that can answer:

- what this app capsule owns
- what it exports and imports
- which optional feature slices exist
- which flow declarations are available
- which surfaces are related by metadata
- which paths would be materialized in sparse and complete layouts

The report should work for both non-web and web-capable apps and should be
serializable with stable `to_h` output.

## Scope

In scope:

- application-owned capsule inspection/reporting value object or equivalent
  read model
- aggregation of existing manifest, structure plan, feature-slice report, and
  flow declaration metadata
- stable smoke example that prints compact flags for non-web and web-capable
  capsules
- optional web-side projection summary when a caller supplies web surface
  manifests
- documentation alignment for the current public application structure model

Out of scope:

- mandatory feature directories
- automatic loading or discovery
- contract execution
- browser route/form transport
- workflow/state-machine semantics
- cluster/distributed placement semantics
- making `igniter-application` depend on `igniter-web`

## Accepted Constraints

- The capsule remains the portability boundary.
- The report is read-only and derived from explicit inputs.
- Application may accept plain surface metadata supplied by callers, but must
  not inspect web screen graphs or require `igniter-web`.
- Web may provide helper projection reports, but application owns the capsule
  inspection vocabulary.
- Missing optional sections should serialize as empty arrays/hashes, not
  failures.

## Task 1: Application Capsule Report

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned capsule inspection shape, for example
  `ApplicationCapsuleReport`, or justify reusing an existing report shape.
- A blueprint can produce the report without materializing files.
- Report includes app identity, layout profile, active/known groups,
  sparse/complete planned paths or enough path metadata to compare them,
  exports/imports, feature slices, flow declarations, services/contracts, and
  supplied surface metadata when present.
- Report works for sparse apps with no features, flows, or web surfaces.
- Report is immutable enough for current package conventions and exposes stable
  `to_h`.
- No loader magic, contract execution, web dependency, or flow execution is
  introduced.

## Task 2: Web Projection Summary

Owner: `[Agent Web / Codex]`

Acceptance:

- Web can supply plain surface manifest/projection hashes that fit into the
  application-owned capsule report.
- Existing `Igniter::Web.flow_surface_projection(...)` remains a helper, not a
  runtime bridge.
- Web does not require application to inspect screens, routes, or components.
- Add mismatch/attention coverage only if it materially improves the report;
  do not expand into browser transport.

## Task 3: Smoke Examples

Owner: shared.

Primary: `[Agent Application / Codex]`

Support: `[Agent Web / Codex]`

Suggested files:

- `examples/application/capsule_inspection.rb`

Acceptance:

- Shows a non-web capsule and a web-capable capsule using the same report
  vocabulary.
- Prints compact smoke keys for identity, groups, planned paths,
  exports/imports, feature slices, flow declarations, and surface projection
  status when present.
- Does not require browser, cluster, real agent runtime, file materialization,
  or contract execution.

Suggested smoke keys:

```text
application_capsule_report_name=...
application_capsule_report_groups=...
application_capsule_report_sparse_paths=...
application_capsule_report_exports=...
application_capsule_report_imports=...
application_capsule_report_features=...
application_capsule_report_flows=...
application_capsule_report_surfaces=...
application_capsule_report_web_projection=...
```

## Task 4: Documentation Alignment

Owner: `[Architect Supervisor / Codex]` after agent handoff, or agents may
propose changes.

Acceptance:

- `docs/dev/tracks.md` and `docs/dev/current-runtime-snapshot.md` stay aligned.
- `docs/dev/application-structure-research.md` marks feature-slice reporting as
  landed and records whether a user-facing/current structure doc should be
  updated next.
- Public docs describe generic architecture only; private app specifics remain
  outside the repository.

## Verification Gate

Before supervisor acceptance:

```bash
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb spec/current/example_scripts_spec.rb
ruby examples/application/capsule_inspection.rb
```

If the implementation adds narrower package specs, include those in the
handoff.

## Current Handoff

[Architect Supervisor / Codex] Accepted after the 2026-04-24 agent cycle.

Decision:

- Task 1 accepted: `ApplicationCapsuleReport` is the application-owned capsule
  inspection read model.
- `ApplicationBlueprint#capsule_report(surface_metadata:, metadata:)` is the
  right authoring entrypoint for now because it keeps inspection derived from
  explicit blueprint state.
- Task 2 accepted: web-owned surface metadata envelopes may carry `kind`,
  summary `status`, related `flows`, related `features`, and nested
  `projections`.
- The surface envelope is intentionally opaque to `igniter-application` beyond
  shallow key normalization. Application reports supplied surface metadata; web
  owns screen/surface inspection and projection semantics.
- Task 3 accepted: `examples/application/capsule_inspection.rb` proves non-web
  and web-capable capsules share the same report vocabulary.

Verification:

```bash
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb spec/current/example_scripts_spec.rb
# 103 examples, 0 failures

ruby examples/application/capsule_inspection.rb
# successful smoke flags including web_projection=aligned
```

Next:

- Continue through [Application Capsule Guide Track](./application-capsule-guide-track.md).
- Do not expand capsule inspection into loading, discovery, execution, routing,
  workflow orchestration, or cluster placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-inspection-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationCapsuleReport` as a read-only aggregate
  over blueprint identity, layout groups, sparse/complete structure plans,
  exports/imports, feature slices, flow declarations, contracts/services, and
  supplied surface metadata.
- Added `ApplicationBlueprint#capsule_report(surface_metadata:, metadata:)`.
- Added `examples/application/capsule_inspection.rb` smoke proof for non-web
  and web-capable capsules using the same report vocabulary.
Accepted:
- The report is derived from explicit blueprint/surface inputs and does not
  materialize files, load code, execute contracts, start flows, or require web.
Needs:
- `[Agent Web / Codex]` may supply richer web-owned projection hashes through
  `surface_metadata` if the current plain `status: :aligned` smoke is too thin.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-inspection-track.md`
Status: landed.
Changed:
- Added web-owned surface metadata envelopes over `SurfaceManifest` so
  `ApplicationCapsuleReport#surfaces` can receive plain hashes with
  `kind: :web_surface`, summary `status`, related `flows` / `features`, and
  nested projection hashes.
- Added `Igniter::Web.surface_metadata(...)` and
  `Igniter::Web.flow_surface_metadata(...)` as convenience helpers around the
  existing `Igniter::Web.flow_surface_projection(...)` report.
- Updated `examples/application/capsule_inspection.rb` to pass enriched web
  surface metadata into the application-owned capsule report.
Accepted:
- Web still owns screen/surface inspection; application receives only explicit
  serializable surface metadata and does not load web internals.
Needs:
- `[Architect Supervisor / Codex]` review whether the envelope fields
  (`status`, `flows`, `features`, `projections`) are sufficient for capsule
  report alignment.
