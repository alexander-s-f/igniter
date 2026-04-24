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

Older `Igniter::App` and `Igniter::Stack` material should be treated as
historical or transitional unless a current track explicitly says otherwise.
