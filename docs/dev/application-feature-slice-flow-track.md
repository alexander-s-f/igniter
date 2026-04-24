# Application Feature Slice And Flow Declaration Track

This track starts the next broad cycle after the Embed Human Sugar DSL surface
stabilized.

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

Igniter now has enough lower-level shape to move one layer up:

- contracts and class contracts are usable from host code
- embed has a human-friendly host DSL for Rails/application pressure
- application capsules have layout profiles, exports/imports, and sparse
  structure plans
- web surfaces can expose portable manifests and interaction metadata
- agent-native flow snapshots, pending state, and explicit resume/status updates
  exist without a flow engine

The next broad question is how an application explains its functional slices and
agent-native flows without becoming Rails-style global buckets or a hidden
workflow runtime.

## Goal

Design and land the smallest inspectable model for:

- optional feature-slice reporting
- flow declaration metadata
- the relationship between app capsules, web surfaces, contracts, and pending
  interaction state

This must improve app comprehension, portability, and agent handoff. It must
not make `features/` mandatory or turn flow snapshots into a state machine.

## Scope

In scope:

- feature-slice discovery/reporting as metadata
- app-owned flow declaration metadata
- linking flow declarations to app exports/imports, contracts, services, and
  optional web surfaces
- examples proving a non-web and web-capable app can use the same vocabulary
- current-doc alignment if the model is stable enough

Out of scope:

- mandatory `features/` directory
- automatic contract execution from flow events
- browser submit/resume transport
- real agent runtime
- cluster routing or distributed flow sessions
- replacing `FlowSessionSnapshot` with a workflow engine
- moving web screen knowledge into `igniter-application`

## Accepted Constraints

- Feature slices are optional reporting/organization metadata, not a required
  runtime boundary.
- Flow declarations are metadata that can help start or inspect a flow; active
  runtime state remains `FlowSessionSnapshot`.
- `SurfaceManifest#interactions` remains candidate metadata. Active pending
  state is still selected explicitly at `Environment#start_flow` or
  `Environment#resume_flow`.
- Web may project flow-related metadata from screens and surfaces, but
  application must not inspect web screen graphs.
- App capsules remain the portability boundary.
- All new public shapes need stable `to_h` output.

## Task 1: Feature-Slice Reporting

Owner: `[Agent Application / Codex]`

Acceptance:

- application can report optional feature slices present in a capsule or
  blueprint without requiring a `features/` directory
- report includes slice name, owned layout groups or paths, exports/imports, and
  related contracts/services when available
- sparse app structures without feature slices still report cleanly
- no loader magic, autoloading, or contract execution is introduced
- specs prove non-web and web-capable capsules produce serializable reports

## Task 2: Flow Declaration Metadata

Owner: `[Agent Application / Codex]`

Acceptance:

- add the smallest app-owned flow declaration shape, or justify using plain
  manifest metadata if a class is premature
- declaration can describe name, purpose/status defaults, candidate pending
  inputs/actions, artifacts, related contracts/services/interfaces, and related
  surfaces by metadata
- declaration can be serialized with `to_h`
- starting/resuming a flow remains explicit and does not infer execution from
  the declaration
- status validation remains intentionally small or open with documented
  rationale

## Task 3: Web Projection And Adapter Check

Owner: `[Agent Web / Codex]`

Acceptance:

- web can expose flow-related surface metadata without application loading web
- `Igniter::Web.flow_pending_state(...)` remains a bridge from candidate web
  metadata to explicit application pending state
- no browser route or form transport is added
- examples show web-owned metadata and application-owned active state remain
  separate

## Task 4: Smoke Example

Owner: shared.

Primary: `[Agent Application / Codex]`

Support: `[Agent Web / Codex]`

Suggested file:

- `examples/application/feature_flow_report.rb`

Acceptance:

- builds an app capsule or blueprint with at least one optional feature slice
- includes exports/imports metadata
- includes one flow declaration or equivalent manifest metadata
- starts a flow session from explicit pending state
- optionally includes a web surface manifest as a related surface
- prints smoke flags for feature slices, flow declaration, pending state, and
  exports/imports
- does not require browser, cluster, real agent runtime, or contract execution

Suggested smoke keys:

```text
application_feature_flow_slices=...
application_feature_flow_exports=...
application_feature_flow_imports=...
application_feature_flow_declarations=...
application_feature_flow_pending_inputs=...
application_feature_flow_pending_actions=...
application_feature_flow_status=...
```

## Verification Gate

Before supervisor acceptance:

```bash
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
ruby examples/application/feature_flow_report.rb
```

If a new package-local spec is added for feature reporting or flow declarations,
include it in the handoff.

## Current Handoff

[Architect Supervisor / Codex] Next:

1. `[Agent Application / Codex]` starts Task 1 and Task 2 in the smallest
   implementation slice.
2. `[Agent Web / Codex]` stays in support mode until application exposes the
   app-owned reporting/declaration shape.
3. Keep feature slices optional and flow declarations metadata-only.
