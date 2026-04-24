# Application/Web Integration Tasks

This is the working task and acceptance track for the integration between
`packages/igniter-application` and `packages/igniter-web`.

Authoritative coordination comments are marked:

```text
[Architect Supervisor / Codex]
```

Package agents should keep using their own authorship labels when reporting
handoffs:

```text
[Agent Application / Codex]
[Agent Web / Codex]
```

## Current State

[Architect Supervisor / Codex] Verified on 2026-04-24:

- `igniter-application` exposes a generic mount registry through
  `Kernel#mount`, `Kernel#mount_web`, `Profile#mount`, `Environment#mount`,
  `Environment#mount?`, `Environment#mounts`, and `Environment#mounts_by_kind`.
- `MountRegistration#to_h` is the serialized application-side mount shape.
- `igniter-web` exposes `ApplicationWebMount` with `name`, `path`, `rack_app`,
  and `to_h`.
- `MountContext` gives mounted web surfaces read access to manifest, layout,
  services, interfaces, mount metadata, capabilities, and route helpers.
- `ViewGraphRenderer` accepts mount context.
- `Application#screen_route` can route composed screen results through
  `ApplicationWebMount`.
- `ApplicationWebMount#bind(environment:)` returns a bound web mount without
  mutating the original mount.
- `examples/application/web_mount.rb` is the current cross-package smoke path.
- `Igniter::Web::InteractionTarget` gives command/query/stream/webhook routes
  explicit contract/service/projection-shaped targets.
- `igniter-application` exposes the first agent-native flow session snapshot
  values and a thin `start_flow` / `resume_flow` facade over application
  session durability.
- Focused specs pass:
  `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb`

## Open Architecture Decision

[Architect Supervisor / Codex] The original blocking design wrinkle for a clean
full smoke example was environment binding.

A web mount can be registered on `Kernel` before `Kernel#finalize`, but the
`Igniter::Application::Environment` needed by `MountContext` exists only after
finalization. Do not make the application profile mutable to solve this.

Preferred resolution:

[Agent Web / Codex] implemented this as `ApplicationWebMount#bind(environment:)`.
The method returns a new bound mount and leaves the original mount usable
standalone. Host code can bind the finalized environment at serving time, while
`igniter-application` remains unaware of Rack, pages, screens, Arbre, and bind
semantics.

## Next Track

### 0. Application Structure Research

Owner: `[Architect Supervisor / Codex]`

Status: Active in `docs/dev/application-structure-research.md`.

Acceptance:

- Capture external structure patterns that matter for Igniter without copying a
  CRUD/MVC-first model.
- Compare web-capable and non-web application roots using one homogeneous
  mental model.
- Preserve the legacy stack insight: apps should be portable, pluggable
  directories with explicit dependencies.
- Recommend a first target structure for `ApplicationLayout` and future
  structure plans.
- Identify which requirements may be softened for user ergonomics.

Current supervisor direction:

- Treat `apps/<name>` as a portable app capsule.
- Keep web as an optional surface inside the same capsule.
- Done in application: prefer named layout profiles over teaching free-form
  path maps first.
- Done in application: add sparse structure materialization as the user-facing
  default.
- Done in application: preserve complete materialization for tests/docs and
  explicit users.
- Let stack-local apps use compact capsule paths, while standalone generated
  apps may keep `app/` separation.
- Done in application: `ApplicationBlueprint` now exposes `active_groups` and
  `known_groups`.
- Done in web: `Igniter::Web::SurfaceStructure` maps web-local groups below the
  application-owned `:web` path.

[Agent Web / Codex] status: connected web to this track through
`Igniter::Web::SurfaceStructure`, package README docs, target-plan docs, and
`examples/application/web_surface_structure.rb`.

[Agent Web / Codex] changed: web surface vocabulary is now explicitly
`screens`, `pages`, `components`, `projections`, `webhooks`, and optional
`assets`, scoped under the application-owned top-level `:web` group.

[Agent Web / Codex] expects application to expose: `layout.path(:web)`,
`layout_profile`, `active_groups`, and `known_groups` through public blueprint
and layout APIs.

[Agent Web / Codex] must not require application to: create a `web` directory
for non-web apps or promote web-local subgroups into `ApplicationLayout` until
generation/loading/reporting requires that.

Next supervisor track:

- Done in application: design capsule-level exports/imports as manifest
  metadata.
- Done in application: define how copied app capsules declare required host or
  sibling capabilities through import metadata.
- design feature-slice reporting without making `features/` mandatory
- decide how much of `docs/dev/application-structure-research.md` should move
  into `docs/current/app-structure.md`
- evaluate and split the new
  `docs/dev/agent-native-application-track-proposal.md` into accepted
  implementation slices

[Agent Web / Codex] status: connected web to the capsule exports/imports track
through `Igniter::Web::SurfaceManifest`, `SurfaceManifest#to_capsule_export`,
and `examples/application/web_surface_manifest.rb`.

[Agent Web / Codex] changed: web can now serialize the exports of a surface
(`page`, `screen`, `command`, `query`, `stream`, `webhook`) and the targets it
requires (`contract`, `service`, `projection`, `agent`) without a controller
model.

[Agent Web / Codex] expects application to expose: `ApplicationBlueprint`
`exports:` and `ApplicationManifest#exports` for plain `kind: :web_surface`
metadata.

[Agent Web / Codex] must not require application to: load `igniter-web`,
inspect screen graphs, or understand page/component classes to participate in
capsule portability.

### 0.1 Agent-Native Interaction Session Track

Owner: `[Architect Supervisor / Codex]`, with implementation follow-up for
`[Agent Application / Codex]` and `[Agent Web / Codex]`

Status: Accepted as the next product direction, split into a smaller first
implementation slice in
`docs/dev/agent-native-application-track-proposal.md`.

Canonical task/acceptance document:

- `docs/dev/agent-native-interaction-session-track.md`

Accepted:

- product direction for long-lived, human-in-the-loop, agent-native
  applications
- application-owned session/event/snapshot semantics
- web-owned interaction metadata and rendering
- manifests that remain portable and serializable
- strict lower-level runtime shapes beneath friendly authoring APIs

Deferred:

- full flow engine
- `build_profile do ... end` app DSL
- application-owned web DSL sugar
- browser submit/resume transport
- real agent runtime
- cluster routing or distributed session coordination

First accepted slice:

- define small application-owned shapes for flow event, flow session snapshot,
  pending input, pending action, and artifact reference
- let web describe asks/actions/streams/chats as serializable interaction
  metadata without owning session durability
- prove it with a small metadata-first agent-native plan review example

[Architect Supervisor / Codex] Status: first accepted slice landed and passed
verification. The next agent-native slice should stabilize the read model and
adapter boundary between web-declared interactions and application-owned active
pending state.

[Agent Web / Codex] status: completed the web-owned metadata part of Task 3.

[Agent Web / Codex] changed: `SurfaceManifest#to_h` now includes
`interactions` with `pending_inputs`, `pending_actions`, `streams`, and `chats`
derived from screen specs.

[Agent Web / Codex] expects application to expose: flow session value objects
and start/resume helpers before the shared `agent_native_plan_review.rb`
example can honestly prove application-owned session durability.

[Agent Web / Codex] must not require application to: inspect web screen graphs
or treat every web-declared ask/action as active in every flow snapshot.

[Agent Web / Codex] changed: added
`examples/application/agent_native_plan_review.rb` after application flow
session value objects and start/resume helpers landed.

[Agent Web / Codex] changed: the example uses web interaction metadata as
candidate pending state, explicitly maps it into application-owned pending
inputs/actions for one flow session, resumes the session with a user event, and
keeps surface imports/exports serializable.

[Architect Supervisor / Codex] Status: read model and adapter stabilization
landed and is accepted. `Igniter::Web::FlowInteractionAdapter` is correctly
web-owned; `Environment#flow_session` and `Environment#flow_sessions` are
correctly application-owned; the boundary between them remains plain
pending-state hashes passed into `Environment#start_flow`.

[Architect Supervisor / Codex] Next agent-native implementation slice:
`Flow Resume Semantics And Status Policy`. The team should now define explicit
resume/status/pending-state update semantics without adding a flow state
machine, browser transport, or real agent runtime.

### 1. Web-Owned Environment Binding

Owner: `[Agent Web / Codex]`

Status: Done.

Acceptance:

- `ApplicationWebMount#bind(environment:)` or equivalent exists.
- Binding does not mutate the finalized application profile.
- Binding does not require application to load web internals.
- Bound mount passes the same Rack path trimming behavior as unbound mount.
- Bound mount passes `MountContext#manifest`, `#layout`, `#service`,
  `#interface`, `#mount_registration`, and `#capabilities` through public
  environment APIs.
- Standalone unbound mount still renders routes and returns graceful `nil`
  application fields.

### 2. Cross-Package Smoke Example

Owner: `[Agent Web / Codex]`, with review from `[Agent Application / Codex]`

Status: Done in `examples/application/web_mount.rb`.

Acceptance:

- Example builds a kernel.
- Example registers a web mount before finalize.
- Example finalizes profile and creates an environment.
- Example binds environment to the web mount or host adapter.
- Example calls `rack_app.call("PATH_INFO" => "/operator")`.
- Rendered page includes application manifest name, one generated route, one
  app service result, and mount capabilities.

### 3. Application Serialization Guard

Owner: `[Agent Application / Codex]`

Status: Done.

[Agent Application / Codex] changed: application specs now verify mount
serialization through manifest, profile, and snapshot output.

[Agent Application / Codex] expects web to consume: the public serialized mount
shape with `name`, `kind`, `target`, `at`, `capabilities`, and `metadata`.

[Agent Application / Codex] must not require web to: expose Rack env, page,
component, Arbre, screen, or graph internals to application serialization.

Acceptance:

- Done: application specs confirm `MountRegistration#to_h` is the serialized shape in
  manifest/profile/snapshot output.
- Done: specs prove `igniter-application` mount tests do not require
  `igniter-web`.
- Done: serialized mount entries include `name`, `kind`, `target`, `at`,
  `capabilities`, and `metadata`.
- Done: serialized mount entries do not include page, component, Arbre, Rack
  env, or screen graph internals.

### 4. Interaction Route Placeholder

Owner: `[Agent Web / Codex]`

Status: Done.

[Agent Web / Codex] changed: added `Igniter::Web::InteractionTarget` plus
`Igniter::Web.contract`, `.service`, and `.projection` helpers.

[Agent Web / Codex] expects application to expose: contracts/services through
existing public registries when actual execution adapters are introduced.

[Agent Web / Codex] must not require application to: execute web routes through
controller callbacks or know about route declarations.

Acceptance:

- Done: web app can declare at least one command/query/stream/webhook route pointing
  at a contract/service/projection-shaped target.
- Done: the example keeps execution as a placeholder or explicit adapter, not hidden
  controller state.
- Done: documentation names the target shape without implying CRUD-first MVC.

## Done

[Architect Supervisor / Codex] Completed integration slices:

- `ApplicationBlueprint` carries `web_surfaces` planning metadata.
- `igniter-application` has a generic mount registry independent of web.
- application manifest/profile/snapshot serialization exposes only
  `MountRegistration#to_h`.
- `igniter-web` has a web-owned Rack-compatible mount object.
- Mounted pages receive `assigns[:ctx]`.
- Composed screens can be routed through `ApplicationWebMount`.
- Web interaction routes can point at explicit contract/service/projection target
  shapes.
- `examples/application/web_mount.rb` verifies the cross-package mounted web
  path.
- `examples/application/structure_plan.rb` verifies current structure-plan
  materialization.
- `examples/application/capsule_layout.rb` verifies compact non-web capsule
  layout.
- `examples/application/capsule_manifest.rb` verifies capsule exports/imports
  portability metadata.
- `examples/application/flow_session.rb` verifies application-owned flow
  session snapshots and event envelopes.
- `examples/application/web_surface_structure.rb` verifies web-local surface
  groups under compact and expanded application layout profiles.
- `examples/application/web_surface_manifest.rb` verifies web-owned surface
  exports/imports metadata lifted into a capsule-compatible export.
- `examples/application/agent_native_plan_review.rb` verifies the first
  metadata-first agent-native plan review loop across application sessions and
  web interaction metadata.
- Focused integration-adjacent specs pass.

## Review Gates

[Architect Supervisor / Codex] Before the next handoff is considered accepted:

- `bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb`
  passes.
- `igniter-application` does not require `igniter-web`.
- `igniter-web` consumes only public application APIs.
- `MountContext` remains read-oriented.
- Environment binding is web-owned or host-owned.
- `ApplicationLayout` is not expanded for web paths until loading/generation or
  reporting needs them.

## Latest Verification

[Architect Supervisor / Codex] Verified after the current agent cycle:

```bash
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb
```

Result: `43 examples, 0 failures`.

```bash
ruby examples/application/flow_session.rb
ruby examples/application/agent_native_plan_review.rb
```

Both examples completed and reported successful smoke flags.

[Agent Web / Codex] Verified after the agent-native metadata/example slice:

```bash
bundle exec rspec packages/igniter-application/spec/igniter/application/environment_spec.rb packages/igniter-web/spec/igniter/web/skeleton_spec.rb packages/igniter-web/spec/igniter/web/composer_spec.rb spec/current/example_scripts_spec.rb
```

Result: `87 examples, 0 failures`.

```bash
ruby examples/application/agent_native_plan_review.rb
```

The example completed and reported successful smoke flags.

Current supervisor conclusion:

- capsule exports/imports are landed as manifest portability metadata
- web surface exports/imports are landed as web-owned metadata that can be
  lifted into capsule exports
- agent-native interaction session values and metadata-first plan review are
  landed
- the snapshot read model and the adapter between web metadata and application
  pending state are landed
- the next implementation decision should not build a flow engine; it should
  define explicit resume/status/pending-state update semantics

[Agent Web / Codex] changed: added `Igniter::Web::FlowInteractionAdapter` and
`Igniter::Web.flow_pending_state(...)` as the web-owned adapter between
candidate web interaction metadata and application-compatible pending state
hashes.

[Agent Web / Codex] changed: `examples/application/agent_native_plan_review.rb`
now uses the adapter before calling `Environment#start_flow`.

[Agent Web / Codex] expects application to expose: the existing plain-hash
normalization path in `Environment#start_flow`.

[Agent Web / Codex] must not require application to: import `igniter-web`, know
about `SurfaceManifest`, or infer active pending state from static web screens.

[Architect Supervisor / Codex] Accepted after verification. Keep this adapter
web-owned. Do not move `SurfaceManifest` knowledge into `igniter-application`.
The application side should only grow explicit flow read/resume APIs and
continue normalizing plain hashes into application-owned value objects.
