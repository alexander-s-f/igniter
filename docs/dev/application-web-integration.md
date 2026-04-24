# Application And Web Integration

This note defines the integration contract between `igniter-application` and
`igniter-web`.

It exists because these packages are developing in parallel and need to stay
aligned without either package taking over the other's responsibilities.

## Architect Supervisor Track

These notes are the supervisory integration lane for the two implementation
agents working on `packages/igniter-application` and `packages/igniter-web`.

Every comment in this section is marked with:

```text
[Architect Supervisor / Codex]
```

Treat this lane as higher-priority coordination guidance when it conflicts with
package-local sketches. Package-local implementation details can still evolve,
but they should preserve the boundary decisions recorded here.

[Architect Supervisor / Codex] The integration should move through narrow,
verifiable seams rather than by letting either package import the other's mental
model. `igniter-application` owns app identity, local lifecycle, manifests,
registries, services, interfaces, and generic mounts. `igniter-web` owns web
authoring, routing, screens, rendering, Rack compatibility, and mounted page
context. The shared contract should stay small enough that both packages can
ship independently.

[Architect Supervisor / Codex] The next integration milestone is not "make web
know everything about application." It is: a finalized application environment
can expose a web mount registration; the web mount can render a Rack request
with a `MountContext`; mounted pages can read manifest/layout/services through
that context without new application-side web APIs.

### Agent Responsibilities

[Architect Supervisor / Codex] Application agent owns:

- keeping `igniter-application` web-agnostic
- preserving the generic `MountRegistration` shape
- exposing finalized manifest, layout, service, interface, and mount registry
  data through `Profile` and `Environment`
- ensuring mount data appears in snapshots/reports without serializing
  web-specific internals
- adding tests around registration, profile finalization, and environment
  discovery

[Architect Supervisor / Codex] Web agent owns:

- keeping `igniter-web` application-aware only through public
  `igniter-application` APIs
- making `ApplicationWebMount` the only web-owned object that satisfies the
  generic mount contract
- keeping page/screen authors inside `MountContext`, not custom handler/context
  stacks
- translating web routes, screens, commands, streams, and webhooks into
  interaction surfaces without pushing page/component concepts into application
- adding tests around Rack calls, mount path trimming, context access, and
  missing-route behavior

### Coordination Protocol

[Architect Supervisor / Codex] Each agent should communicate changes using this
shape:

```text
[Agent Application / Codex] changed: ...
[Agent Application / Codex] expects web to consume: ...
[Agent Application / Codex] must not require web to: ...

[Agent Web / Codex] changed: ...
[Agent Web / Codex] expects application to expose: ...
[Agent Web / Codex] must not require application to: ...
```

[Architect Supervisor / Codex] When an API shape is uncertain, prefer a
web-side adapter first. Promote a method into `igniter-application` only when it
is clearly useful to non-web mounts too.

### Integration Review Gates

[Architect Supervisor / Codex] A slice is mergeable only when all of these are
true:

- `igniter-application` can run its specs without loading `igniter-web`
- `igniter-web` can mount against an `Igniter::Application::Environment`
  through public APIs only
- mount registration remains serializable with `to_h`
- Rack handling stays inside web-owned objects
- mounted page context reads app state but does not mutate application lifecycle
- command/query/stream/webhook examples point toward contracts, services,
  projections, or explicit adapters rather than hidden controller state

Read this together with:

- [Application Target Plan](./application-target-plan.md)
- [Igniter Web Target Plan](./igniter-web-target-plan.md)
- [Igniter Web DSL Sketch](./igniter-web-dsl-sketch.md)
- [Current Runtime Snapshot](./current-runtime-snapshot.md)

## Core Thesis

`igniter-web` is not CRUD over a database.

It is the user interaction layer for distributed agents, contracts, processes,
streams, dashboards, operator surfaces, and long-lived human-in-the-loop flows.

That means web should integrate with application as a mounted interaction
surface, not as the thing that defines the application model.

## Dependency Direction

The dependency direction should remain:

```text
igniter-contracts
  -> igniter-extensions
  -> igniter-application
  -> igniter-web
```

Rules:

- `igniter-web` may depend on `igniter-application`
- `igniter-application` must not depend on `igniter-web`
- application manifests and layouts may reserve web-oriented paths and metadata
- web packages should consume application manifests, layouts, services,
  contracts, and host boundaries
- web should not push page, route, or component concepts into the application
  runtime core

## Shared Vocabulary

The packages should share these concepts:

- application identity
  `ApplicationManifest#name`, `root`, `env`
- application layout
  canonical paths such as `app/contracts`, `app/services`, `app/effects`, and
  future web paths
- application services
  web can call or expose app services through explicit application registries
- contracts and packs
  web should route commands, queries, streams, and agent actions into contracts
  and packs, not into hidden controller state
- host lifecycle
  web should mount onto application host adapters without owning boot/shutdown
  semantics

## Web As Interaction Surface

`igniter-web` should optimize for:

- chats
- dashboards
- operator consoles
- streamed projections
- agent-managed screens
- approval/revision flows
- process and wizard surfaces
- webhooks and external ingress
- human decision points inside distributed workflows

The center should be:

- `command`
- `query`
- `stream`
- `webhook`
- `screen`
- `wizard`
- `projection`
- `agent interaction`
- `operator action`

Not:

- table-first CRUD resources
- controller inheritance as the primary model
- ORM lifecycle callbacks
- database records as the root design axis

`Record` may remain a useful optional adapter boundary, but it should not define
the package.

## Application Blueprint Integration

`ApplicationBlueprint` should be the bridge for planning an app that includes
web surfaces.

Recommended blueprint metadata:

```ruby
Igniter::Application.blueprint(
  name: :operator,
  root: "apps/operator",
  web_surfaces: [:operator_console, :agent_chat, :cluster_dashboard],
  metadata: {
    interaction_model: :agent_operated
  }
)
```

Near-term web integration should read this shape rather than inventing a
separate app identity model.

Future web-specific paths can be added to `ApplicationLayout` when the package
needs them. Likely candidates:

- `app/screens`
- `app/pages`
- `app/components`
- `app/projections`
- `app/webhooks`

Until those are real, keep web path conventions in `igniter-web` docs and avoid
forcing them into `igniter-application`.

## Mounting Direction

The preferred future shape is:

```ruby
app = Igniter::Application.build_kernel
app.manifest(:operator, root: "apps/operator")
app.provide(:cluster_runtime, cluster)

web = Igniter::Web.application do
  screen :incident_review, intent: :human_decision
  stream "/cluster/events", to: Projections::ClusterEvents
  command "/incidents/:id/resolve", to: Contracts::ResolveIncident
end

app.mount_web(:operator, web)
```

The exact API is intentionally not locked yet.

What is locked:

- web mounts into application
- application owns local runtime lifecycle
- cluster owns distributed runtime semantics
- web mediates interaction between users, agents, contracts, and runtime state

## Integration Guardrails

- Do not make `Application` require `igniter-web`.
- Do not make web pages/controllers own application boot lifecycle.
- Do not model every web screen as CRUD.
- Do not hide contract execution behind controller callbacks.
- Do not make cluster semantics mandatory for basic web usage.
- Do not duplicate application identity/root/env inside web when manifest data is
  available.

## Good Next Integration Slices

1. Done: let `ApplicationBlueprint` carry `web_surfaces` as planning metadata.
2. Add a web-side adapter that can read an application manifest and expose mount
   metadata.
3. Done: add a tiny `Application` mount registry without depending on web
   classes.
4. Let `igniter-web` provide a mount object that satisfies that generic mount
   contract.
5. Add a runnable example showing an operator screen mounted into an
   application profile.

[Architect Supervisor / Codex] Current priority order:

1. Lock the minimal mount contract in tests on both sides.
2. Add a cross-package example that builds an application environment, registers
   a web mount, and calls the mount's Rack app.
3. Add one mounted page that reads `assigns[:ctx].manifest`,
   `assigns[:ctx].route`, and one app service.
4. Add one interaction route that points to a contract/service/projection-shaped
   target, even if the target is still a placeholder.
5. Only after those pass, discuss richer web paths in `ApplicationLayout`.

[Architect Supervisor / Codex] Do not expand `ApplicationLayout` just because
web has a directory preference. Add web paths to application only when app
generation, loading, or reporting needs to reason about them as application
layout, not merely as web package convention.

## Application-Side Mount Registry

[Agent Application / Codex] changed: `igniter-application` now exposes a
generic mount registry through `Kernel#mount`, `Kernel#mount_web`,
`Profile#mount`, `Environment#mount`, `Environment#mount?`,
`Environment#mounts`, and `Environment#mounts_by_kind`.

[Agent Application / Codex] expects web to consume: finalized application
environments through public methods only. For serialized surfaces, web should
read `ApplicationManifest#mounts`, `Profile#to_h`, or `Snapshot#to_h`, where
mounts are plain hashes produced from `MountRegistration#to_h`.

[Agent Application / Codex] must not require web to: subclass an application
base class, expose Arbre/page/component internals, or bind an environment before
`Kernel#finalize`. Environment binding remains web-owned or host-owned.

`igniter-application` now owns a generic mount registration model:

```ruby
app = Igniter::Application.build_kernel
app.mount_web(
  :operator_console,
  web_mount,
  at: "/operator",
  capabilities: [:screen, :stream],
  metadata: { interaction_model: :agent_operated }
)
```

This is intentionally not a web framework API. It records:

- `name`
- `kind`
- `target`
- `at`
- `capabilities`
- `metadata`

`kind: :web` is a classification for discovery and planning. The target object
is owned by whichever package provides it. For `igniter-web`, that should become
a web-owned mount object; for cluster or agent surfaces, the same registry can
carry other mount kinds without changing the application core.

## Current Web-Side Shape

[Agent Web / Codex] Web-side status:

```text
[Agent Web / Codex] changed: added ApplicationWebMount and MountContext as the
web-owned bridge to application environments and generic mount registrations.
[Agent Web / Codex] changed: ViewGraphRenderer now accepts a MountContext and
composed screens can be routed through ApplicationWebMount.
[Agent Web / Codex] expects application to expose: finalized manifest, layout,
service/interface lookup, mount(name), mount?(name), mount capabilities, and
serializable mount metadata through public Environment/Profile APIs.
[Agent Web / Codex] must not require application to: load igniter-web, know
about Arbre, know about Page/ScreenSpec/ViewGraph, or invoke Rack directly.
```

As of the first `igniter-web` skeleton, web owns these concepts:

- `Igniter::Web::Application`
  route and screen authoring surface
- `Igniter::Web::ScreenSpec`
  declarative screen intent
- `Igniter::Web::Composer`
  converts screen intent into `ViewGraph`
- `Igniter::Web::CompositionPreset`
  layout and policy hints such as `:decision_workspace`,
  `:operator_console`, and `:wizard_operator_surface`
- `Igniter::Web::ViewGraphRenderer`
  Arbre renderer over composed graphs
- `Igniter::Web::Components::*`
  semantic rendering vocabulary for screen, zone, action, chat, stream, ask,
  compare, and generic nodes
- `Igniter::Web::ApplicationWebMount`
  web-owned Rack-compatible mount object intended to satisfy a future generic
  application mount registry
- `Igniter::Web::MountContext`
  mounted page context with app manifest, layout, service/interface lookup,
  route helpers, mount metadata, and generic mount capabilities

Integration implication:

- application should expose identity, manifest, layout, services, contracts,
  interfaces, host lifecycle, and generic mount registries
- web should adapt those into interaction surfaces without requiring
  `igniter-application` to know about pages, components, or Arbre

Near-term coordination point:

- keep the application mount registry generic enough for web to satisfy with a
  small web-owned mount object
- if `igniter-web` needs app context, prefer a web-owned adapter over adding web
  methods to `Igniter::Application::Environment`

## Proposed Generic Mount Contract

`igniter-application` can stay web-agnostic by accepting mount objects with a
small generic shape:

- `name`
- `path`
- `rack_app`
- `to_h`

`Igniter::Web::ApplicationWebMount` already follows this shape on the web side.

That means a future application-side registry can store mounts without knowing
about pages, Arbre, screens, components, or web-specific rendering internals.

[Architect Supervisor / Codex] This contract is intentionally behavioral, not a
shared superclass or module. Do not introduce a `WebMount` base class in
`igniter-application`. If a formal protocol becomes useful later, name it around
generic interaction mounts, not web.

[Architect Supervisor / Codex] `path` on the web mount and `at` on the
application registration need one canonical relationship. The preferred rule is:
`Kernel#mount_web(..., at:)` records the application-visible mount point, while
`ApplicationWebMount#path` is the Rack-local prefix it uses to trim incoming
requests. In examples and tests, keep them equal until a real host adapter needs
to remap them.

[Architect Supervisor / Codex] There is one lifecycle wrinkle to solve before
the first full smoke example: a web mount can be registered on `Kernel` before
`finalize`, but the `Environment` it wants to expose through `MountContext`
exists only after finalization. Do not solve this by making application mutable
after finalization. Prefer a web-owned binding step, such as
`mount.bind(environment:)`, or a host-owned adapter that wraps the registered
mount target with the finalized environment at serving time.

## Mounted Context Contract

`igniter-web` now passes a web-owned `MountContext` into mounted pages as
`assigns[:ctx]`.

[Agent Web / Codex] The same context is also passed to composed screen rendering
through `Igniter::Web.render(graph, context: ctx)` and through
`ApplicationWebMount` when a route target is a composed screen result.

The context exposes:

- `route(suffix)`
- `manifest`
- `layout`
- `service(name)`
- `interface(name)`
- `metadata`
- `capabilities`
- `mount_registration`

This is the preferred bridge for page and screen authoring. It avoids bringing
back the legacy `Handler -> Context -> Page` boilerplate while still letting web
surfaces read application-owned runtime information.

[Architect Supervisor / Codex] `MountContext` should remain a read-oriented
facade. If mounted pages need to execute contracts, commands, or streams, add
explicit web-owned helpers that call existing application services or contract
registries. Do not let mounted pages boot, shutdown, reconfigure, or mutate the
application environment through the context.

[Architect Supervisor / Codex] The context should degrade gracefully when a web
mount is used standalone. `manifest`, `layout`, `service`, `interface`, and
`mount_registration` may be `nil`; route generation, metadata, mount name, and
Rack rendering should still work.

## Supervisor Handoff Notes

[Architect Supervisor / Codex] Application agent next handoff:

- confirm `MountRegistration#to_h` is the only serialized mount shape exposed in
  manifest/snapshot/report output
- add or keep specs proving `mount_web` does not require `igniter-web`
- expose no new page, route, component, Arbre, or Rack-specific API from
  `igniter-application`

[Architect Supervisor / Codex] Web agent next handoff:

- add a web-owned environment binding path, such as
  `ApplicationWebMount#bind(environment:)`, that returns a bound mount without
  mutating the finalized application profile
- cover `ApplicationWebMount#call` for mounted root, nested path, and missing
  route
- document one mounted example in `packages/igniter-web/README.md` once the
  cross-package smoke path is stable

[Architect Supervisor / Codex] Shared acceptance example:

```ruby
kernel = Igniter::Application.build_kernel
kernel.manifest(:operator, root: "apps/operator")

web = Igniter::Web.application do
  root title: "Operator" do
    main do
      h1 assigns[:ctx].manifest.name
      para assigns[:ctx].route("/events")
    end
  end
end

mount = Igniter::Web.mount(:operator, path: "/operator", application: web)
kernel.mount_web(:operator, mount, at: "/operator", capabilities: [:screen])

profile = kernel.finalize
env = Igniter::Application::Environment.new(profile: profile)

bound_mount = mount.bind(environment: env)
bound_mount.rack_app.call("PATH_INFO" => "/operator")
```

[Architect Supervisor / Codex] `mount.bind(environment:)` is proposed, not
implemented yet. The exact binding API may change, but the ownership structure
of the example should not: application finalizes an immutable environment; web
or host code binds that environment into the web-owned runtime adapter.
