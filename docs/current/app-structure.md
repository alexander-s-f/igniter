# App Structure

This note records the current public structure direction for contracts-native
Igniter applications. It supersedes older `Igniter::App`/stack-first structure
notes for new application design.

For the practical user-facing path, start with
[Application Capsules](../guide/application-capsules.md).

## Core Thesis

An application should be portable.

In current Igniter vocabulary, that portable unit is an application capsule.
A capsule owns app-local code and metadata, and can be inspected before it is
loaded, mounted, copied, or connected to a host.

That means:

- app-local code lives inside the capsule
- web is an optional surface inside the capsule
- dependencies on a host or sibling app are explicit imports
- capabilities offered by the capsule are explicit exports
- feature slices are optional reporting metadata for scale
- flow declarations are app-owned metadata, not workflow execution
- capsule reports are read-only inspection output for humans and agents

## Sparse-First Structure

The default user-facing structure is sparse. Materialize only the paths the
capsule actually owns.

Compact capsule shape:

```text
apps/<app>/
  contracts/
  services/
  support/
  spec/
  igniter.rb
```

Web-capable capsule shape:

```text
apps/<app>/
  contracts/
  services/
  web/
  support/
  spec/
  igniter.rb
```

These are examples, not mandatory scaffolds. `ApplicationBlueprint` and
`ApplicationLayout` use logical groups such as `contracts`, `services`, `web`,
`support`, `spec`, and `config`. Sparse structure plans include only active
groups; complete plans are available for explicit inspection or materialization.

## Layout Profiles

Use named layout profiles instead of ad hoc path doctrine.

Current profiles:

- `:capsule` for compact portable app capsules
- `:standalone` for expanded standalone app roots
- `:expanded_capsule` when a capsule wants standalone-style paths

A layout profile is a named path vocabulary. It is not a requirement to create
every possible directory.

## Exports And Imports

Capsules should not depend on hidden sibling constants or stack-global helper
files.

Use exports to describe what a capsule offers:

```ruby
exports: [
  { name: :resolve_incident, kind: :contract, target: "Contracts::ResolveIncident" }
]
```

Use imports to describe what a capsule needs:

```ruby
imports: [
  { name: :incident_runtime, kind: :service, from: :host, capabilities: [:incidents] }
]
```

This is portability metadata first. Host, stack, web, and cluster layers can
inspect it later without the capsule reaching into sibling internals.

## Feature Slices

Small apps should stay flat and obvious. Larger apps may add optional feature
slice metadata:

```ruby
features: [
  {
    name: :incidents,
    groups: %i[contracts services web],
    contracts: ["Contracts::ResolveIncident"],
    services: [:incident_queue],
    exports: [:resolve_incident],
    imports: [:incident_runtime],
    flows: [:incident_review],
    surfaces: [:operator_console]
  }
]
```

Feature slices are reporting/organization metadata. They do not require a
`features/` directory and do not create a runtime boundary.

## Flow Declarations

Flow declarations describe available human-in-the-loop or agent-native flows:

```ruby
flows: [
  {
    name: :incident_review,
    initial_status: :waiting_for_user,
    pending_inputs: [
      { name: :clarification, input_type: :textarea, target: :review_plan }
    ],
    pending_actions: [
      { name: :approve_plan, action_type: :contract, target: "Contracts::ResolveIncident" }
    ],
    surfaces: [:operator_console]
  }
]
```

They are metadata. Active runtime state remains explicit
`FlowSessionSnapshot` state created through `Environment#start_flow` and
updated through `Environment#resume_flow`.

## Web As Optional Surface

`web/` is optional. A non-web capsule and a web-capable capsule use the same
application vocabulary.

Surface packages such as `igniter-web` can provide plain surface metadata for
inspection reports. `igniter-application` must not inspect screen graphs,
browser routes, or component trees.

For `igniter-web`, the current bridge is:

- `SurfaceManifest` for web-owned exports/imports and candidate interactions
- `flow_surface_projection` for checking a web surface against app-owned flow
  and feature metadata
- `flow_surface_metadata` for passing a plain surface envelope into
  `ApplicationBlueprint#capsule_report(surface_metadata:)`

These are inspection aids. They do not create browser transport, execute
contracts, or make web a required dependency of application capsules.

## Capsule Reports

`ApplicationBlueprint#capsule_report` is the current read model for capsule
inspection.

It reports:

- identity and layout profile
- active and known groups
- sparse and complete planned paths
- exports/imports
- feature slices
- flow declarations
- contracts/services/interfaces
- supplied surface metadata

The report is read-only. It does not load code, materialize files, execute
contracts, start flows, submit browser forms, or coordinate clusters.

## Transfer Review

The current transfer chain is read-only:

- `ApplicationBlueprint#capsule_report` inspects one capsule
- `Igniter::Application.compose_capsules` checks sibling and host import/export
  readiness
- `Igniter::Application.assemble_capsules` records intended mounts as metadata
  over composition readiness
- `Igniter::Application.handoff_manifest` produces the final transfer review
  artifact for humans and agents
- `Igniter::Application.transfer_inventory` dry-runs declared capsule material
  under explicit capsule roots
- `Igniter::Application.transfer_readiness` produces the decision report over
  handoff and inventory artifacts
- `Igniter::Application.transfer_bundle_plan` describes what a future bundle
  operation would include, exclude, and still block
- `Igniter::Application.write_transfer_bundle` writes an explicit directory
  artifact from an accepted bundle plan
- `Igniter::Application.verify_transfer_bundle` reads back a written artifact
  and reports metadata/file mismatches

`ApplicationHandoffManifest` is the current answer to "what is moving, is it
ready, and what must the receiving host provide?" It summarizes readiness,
unresolved required imports, missing optional imports, suggested host wiring,
mount intents, and supplied surface metadata.

`ApplicationTransferInventory` is the current dry-run view of declared capsule
material. It reports explicit capsule roots, active groups, expected sparse
layout paths, existing paths/files under declared layout paths, missing expected
paths, and supplied surface path metadata.

`ApplicationTransferReadiness` is the current decision surface before any
future transfer/package tooling. It reports one readiness boolean, blockers,
warnings, source counts, and the nested handoff manifest and inventory.

`ApplicationTransferBundlePlan` is the current plan surface before any future
bundle/package tooling. It summarizes included files already enumerated by the
inventory, missing paths, supplied surfaces, blockers, warnings, and whether a
future bundle step would be allowed by policy.

`ApplicationTransferBundleArtifact` is the current explicit writer from an
accepted plan. It writes only to a caller-provided output path, refuses existing
output by default, includes only planned files, and embeds serialized review
metadata.

`ApplicationTransferBundleVerification` is the current read-only artifact
readback surface. It reads `igniter-transfer-bundle.json`, compares planned
files with actual files under `files/`, reports missing, extra, or malformed
entries, and counts supplied surfaces without interpreting web internals.

`ApplicationTransferIntakePlan` is the current read-only receiving-side review
surface. Given a verified artifact and an explicit destination root, it reports
planned paths, destination conflicts, blockers, required host wiring, warnings,
and supplied surface metadata without copying or installing anything.

`ApplicationTransferApplyPlan` is the current read-only operation review
surface. Given accepted intake data, it reports whether a future apply would be
executable, lists ordered `ensure_directory`, `copy_file`, and
`manual_host_wiring` operations, and preserves blockers/warnings without
creating directories, copying files, or applying host wiring.

`ApplicationTransferApplyResult` is the current dry-run-first execution report
for reviewed transfer apply plans. It defaults to reporting what would be
applied; with `commit: true` it preflights the reviewed operations and may
create only reviewed directories and copy only reviewed files. It refuses
non-executable plans, unsafe paths, missing artifact sources, unsupported
operations, and destination overwrites; manual host wiring remains review-only.

This remains separate from runtime activation and broad transfer automation. It
does not discover project directories, auto-select destinations, install or
extract bundles, load, boot, mount, route, execute, or place capsules on a
cluster.

## Placement Rules

Code that exists for one capsule belongs inside that capsule.

Good app-local candidates:

- contracts
- services
- providers
- effects
- agents
- tools
- skills
- optional web surfaces
- app-private support code

Stack-level `lib/<project>/shared` should mean genuinely shared stack-level
code, not a convenient place to put app-local behavior.

## Current Anti-Patterns

Avoid:

- app-local code in stack-level `lib/<project>/shared`
- implicit sibling coupling through direct constant reach-in
- hardcoded HTML strings as the recommended UI authoring style
- mandatory `features/` directories for small apps
- mandatory `web/` directories for non-web apps
- flow declarations that imply contract execution or browser transport

## Examples

Runnable examples for the current model:

- [`examples/application/capsule_manifest.rb`](../../examples/application/capsule_manifest.rb)
- [`examples/application/feature_flow_report.rb`](../../examples/application/feature_flow_report.rb)
- [`examples/application/capsule_inspection.rb`](../../examples/application/capsule_inspection.rb)
- [`examples/application/capsule_composition.rb`](../../examples/application/capsule_composition.rb)
- [`examples/application/capsule_assembly_plan.rb`](../../examples/application/capsule_assembly_plan.rb)
- [`examples/application/capsule_handoff_manifest.rb`](../../examples/application/capsule_handoff_manifest.rb)
- [`examples/application/capsule_transfer_inventory.rb`](../../examples/application/capsule_transfer_inventory.rb)
- [`examples/application/capsule_transfer_readiness.rb`](../../examples/application/capsule_transfer_readiness.rb)
- [`examples/application/capsule_transfer_bundle_plan.rb`](../../examples/application/capsule_transfer_bundle_plan.rb)
- [`examples/application/capsule_transfer_bundle_artifact.rb`](../../examples/application/capsule_transfer_bundle_artifact.rb)
- [`examples/application/capsule_transfer_bundle_verification.rb`](../../examples/application/capsule_transfer_bundle_verification.rb)
- [`examples/application/capsule_transfer_intake_plan.rb`](../../examples/application/capsule_transfer_intake_plan.rb)
- [`examples/application/capsule_transfer_apply_plan.rb`](../../examples/application/capsule_transfer_apply_plan.rb)
- [`examples/application/capsule_transfer_apply_execution.rb`](../../examples/application/capsule_transfer_apply_execution.rb)

Older `Igniter::App` and `Igniter::Stack` material should be treated as
historical or transitional unless a current track explicitly says otherwise.
