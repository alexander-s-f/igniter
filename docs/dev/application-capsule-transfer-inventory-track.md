# Application Capsule Transfer Inventory Track

This track follows the accepted capsule transfer guide cycle.

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

Igniter now has the metadata story for portable capsules:

- capsule reports explain one capsule
- composition reports explain import/export readiness
- assembly plans add host and mount intent metadata
- handoff manifests summarize the transfer review
- public docs explain the workflow

The next step is a read-only transfer inventory: a dry-run view of the capsule
material that would be considered for transfer. This is the bridge between
"the manifest says this capsule is portable" and a future package/copy tool.

This track is intentionally not packaging. It should help humans and agents
answer: "Which declared capsule paths/files are part of this portable unit,
what is missing, and what would need review before a real transfer?"

[Architect Supervisor / Codex] Accepted after the 2026-04-24 agent cycle.

Decision:

- `ApplicationTransferInventory` and
  `Igniter::Application.transfer_inventory(...)` are accepted as the
  application-owned read-only dry-run inventory surface.
- Clean blueprints and human capsule DSL objects through `to_blueprint` are
  accepted.
- Reporting roots, layout profile, active groups, expected sparse paths,
  existing paths, missing expected paths, optional file enumeration, summary
  counts, and supplied surface metadata is accepted.
- File enumeration constrained to explicit capsule roots and declared layout
  paths is accepted.
- Web path metadata remains supplied and opaque. `igniter-application` reports
  only the top-level application `:web` group and must not inspect
  `web/screens`, `web/pages`, routes, Rack apps, components, or browser
  transports as application-owned structure.

Verification:

```bash
ruby examples/application/capsule_transfer_inventory.rb
ruby examples/application/capsule_handoff_manifest.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
bundle exec rspec packages/igniter-web/spec/igniter/web/skeleton_spec.rb
bundle exec rubocop packages/igniter-application/lib/igniter/application/application_transfer_inventory.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_transfer_inventory.rb examples/catalog.rb
```

Result: all passed.

Next:

- Continue through
  [Application Capsule Transfer Readiness Track](./application-capsule-transfer-readiness-track.md).
- Keep the next slice as decision/reporting over handoff manifest and transfer
  inventory. Do not introduce packaging, copying, archive creation, loading,
  boot, mount, routing, execution, or cluster placement.

## Goal

Design and land the smallest read-only capsule transfer inventory:

- accept explicit capsule blueprints / capsule DSL objects
- report declared capsule roots and active layout groups
- report expected group paths from sparse structure plans
- optionally report actual materialized files under declared capsule roots
- mark missing expected groups without materializing them
- summarize optional web surface paths as metadata when supplied
- expose stable `to_h`

The inventory should complement `ApplicationHandoffManifest`, not replace it.

## Scope

In scope:

- application-owned read-only inventory value
- facade such as `Igniter::Application.transfer_inventory(...)`
- dry-run path/file summary under explicit capsule roots
- explicit constraints against loading constants or interpreting app code
- smoke example using existing application capsule examples
- web compatibility review for optional web-local path metadata

Out of scope:

- copying files
- creating archives or package artifacts
- deleting or moving files
- discovering unrelated directories outside declared capsule roots
- autoloading constants
- booting apps
- mounting web
- routing browser traffic
- contract/service execution
- cluster placement
- private app-specific material

## Accepted Constraints

- The inventory is read-only.
- Inputs are explicit capsules/blueprints; there is no project-wide discovery.
- If actual file enumeration is implemented, it must be limited to the
  explicit capsule root and declared layout paths.
- Missing paths are reported, not created.
- Web remains optional. Web-owned metadata can name web-local paths, but
  `igniter-application` must not inspect screens, routes, Rack apps,
  components, or browser transports.
- The result should be serializable and compact enough for agent handoff.

## Task 1: Transfer Inventory Shape

Owner: `[Agent Application / Codex]`

Acceptance:

- Add the smallest application-owned value, for example
  `ApplicationTransferInventory`.
- Add a public facade, for example
  `Igniter::Application.transfer_inventory(...)`.
- Accept clean blueprints and human capsule DSL objects through `to_blueprint`.
- Include capsule name, root, layout profile, active groups, expected paths,
  existing paths/files when safely enumerable, missing expected paths, and
  summary counts.
- Expose stable `to_h`.
- Do not copy, archive, create, delete, load, boot, mount, route, execute, or
  coordinate clusters.

## Task 2: Smoke Example

Owner: `[Agent Application / Codex]`

Suggested file:

- `examples/application/capsule_transfer_inventory.rb`

Acceptance:

- Build a transfer inventory for at least one capsule.
- Print compact smoke keys for capsule names, expected paths, missing paths,
  and total files or explicit `files=not_enumerated` if enumeration is deferred.
- Keep the example deterministic and safe for clean checkouts.

Suggested smoke keys:

```text
application_capsule_transfer_inventory_capsules=...
application_capsule_transfer_inventory_expected=...
application_capsule_transfer_inventory_missing=...
application_capsule_transfer_inventory_files=...
application_capsule_transfer_inventory_ready=...
```

## Task 3: Web Metadata Compatibility

Owner: `[Agent Web / Codex]`

Acceptance:

- Verify optional web path/surface metadata can be represented as supplied
  metadata without application inspecting web internals.
- Add a package README note only if the transfer inventory path is otherwise
  hard to discover.
- Do not add web-specific inventory behavior to `igniter-application`.

## Verification Gate

Before supervisor acceptance:

```bash
ruby examples/application/capsule_transfer_inventory.rb
ruby examples/application/capsule_handoff_manifest.rb
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb
```

If web package code or docs examples change, include the relevant
`packages/igniter-web/spec` slice.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 with a narrow
   read-only inventory.
2. `[Agent Web / Codex]` performs Task 3 as a boundary check only.
3. Keep this as dry-run inventory. Do not turn it into transfer packaging,
   copying, discovery, loading, activation, routing, execution, or cluster
   placement.

[Agent Application / Codex]
Track: `docs/dev/application-capsule-transfer-inventory-track.md`
Status: landed.
Changed:
- Added application-owned `ApplicationTransferInventory`.
- Added `Igniter::Application.transfer_inventory(...)`.
- Added `examples/application/capsule_transfer_inventory.rb` and registered it
  in the active examples catalog.
- Updated public/current docs to position transfer inventory after handoff
  review as a dry-run material inventory.
Accepted:
- Inventories accept clean blueprints and human capsule DSL objects through
  `to_blueprint`.
- The inventory reports capsule names, roots, layout profile, active groups,
  expected sparse layout paths, existing paths, missing expected paths, optional
  file enumeration, summary counts, and supplied surface metadata.
- File enumeration is constrained to explicit capsule roots and declared layout
  paths; paths outside the capsule root are skipped rather than inspected.
- The surface path story remains supplied metadata only. Application does not
  inspect web screens, routes, Rack apps, components, or browser transports.
- The slice remains read-only: no copy, archive, create, delete, discovery,
  loading, boot, mount, routing, execution, or cluster placement.
Verification:
- `ruby examples/application/capsule_transfer_inventory.rb` passed.
- `ruby examples/application/capsule_handoff_manifest.rb` passed.
- `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb spec/current/example_scripts_spec.rb`
  passed with 99 examples, 0 failures.
- `bundle exec rubocop packages/igniter-application/lib/igniter/application/application_transfer_inventory.rb packages/igniter-application/lib/igniter/application.rb packages/igniter-application/spec/igniter/application/environment_spec.rb examples/application/capsule_transfer_inventory.rb examples/catalog.rb`
  passed with no offenses.
Needs:
- `[Agent Web / Codex]` can perform Task 3 wording/boundary review for optional
  web path metadata in transfer inventories.

[Agent Web / Codex]
Track: `docs/dev/application-capsule-transfer-inventory-track.md`
Status: landed.
Changed:
- Reviewed `ApplicationTransferInventory` against web-owned path/surface
  metadata.
- Updated `examples/application/capsule_transfer_inventory.rb` so web-local
  path metadata comes from `Igniter::Web.surface_structure(blueprint)` and is
  passed into `Igniter::Application.transfer_inventory(...)` as supplied plain
  metadata.
- Updated `docs/guide/application-capsules.md`,
  `packages/igniter-web/README.md`, and the examples catalog with the
  transfer-inventory web path metadata boundary.
Accepted:
- Transfer inventory keeps web path metadata supplied and opaque.
- Application reports the top-level `:web` layout group but does not inspect
  `web/screens`, `web/pages`, Rack apps, routes, components, or browser
  transports as application-owned structure.
- No web-specific inventory behavior is needed in `igniter-application`.
Needs:
- `[Architect Supervisor / Codex]` review the transfer inventory track for
  acceptance.
