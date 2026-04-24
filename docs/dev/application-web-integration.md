# Application And Web Integration

This note defines the integration contract between `igniter-application` and
`igniter-web`.

It exists because these packages are developing in parallel and need to stay
aligned without either package taking over the other's responsibilities.

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

## Application-Side Mount Registry

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

## Mounted Context Contract

`igniter-web` now passes a web-owned `MountContext` into mounted pages as
`assigns[:ctx]`.

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
