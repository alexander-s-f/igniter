# igniter-web

Contracts-first web package for Igniter.

Primary entrypoints:

- `require "igniter-web"`
- `require "igniter/web"`

Current package shape:

- `Igniter::Web::Api`
- `Igniter::Web::Application`
- `Igniter::Web::ScreenSpec`
- `Igniter::Web::Composer`
- `Igniter::Web::CompositionPreset`
- `Igniter::Web::ViewGraph`
- `Igniter::Web::ViewGraphRenderer`
- `Igniter::Web::SurfaceStructure`
- `Igniter::Web::SurfaceManifest`
- `Igniter::Web::FlowInteractionAdapter`
- `Igniter::Web::FlowSurfaceProjection`
- `Igniter::Web::Page`
- `Igniter::Web::Component`
- `Igniter::Web::Record`

## Direction

`igniter-web` is the active rebuild target for Igniter's web authoring and
transport surface.

It is intentionally not a generic CRUD-first MVC framework.
The package should optimize for the shapes Igniter actually cares about:

- dashboards
- chats
- streams
- automations
- webhooks
- operator surfaces
- agent-driven and environment-driven flows
- long-lived wizard/process UIs

Current design notes live in:

- [docs/dev/igniter-web-target-plan.md](../../docs/dev/igniter-web-target-plan.md)
- [docs/dev/igniter-web-dsl-sketch.md](../../docs/dev/igniter-web-dsl-sketch.md)

## Current Status

This package currently ships only a skeleton:

- package facade
- namespace entrypoints
- route/endpoint declaration objects
- Arbre-backed `Page` and `Component` base classes
- compact `root` / `page` authoring DSL
- initial screen composition objects for agent-managed views and flows
- first Arbre renderer for composed view graphs
- semantic Arbre components for screen, zone, and node rendering
- specialized Arbre components for action, chat, stream, ask, and compare nodes
- web-side `ApplicationWebMount` for future `igniter-application` integration
- `MountContext` for mounted pages to access routes, app manifest, services,
  interfaces, and mount metadata without custom handler/context classes
- `SurfaceStructure` for web-owned surface groups inside application layout
  profiles
- `SurfaceManifest` for web-owned exports/imports metadata that can be lifted
  into application capsule exports
- flow pending-state/projection helpers for inspection and explicit
  application flow handoff
- an adapter-oriented `Record` placeholder

That gives the rebuild a real package boundary now, while leaving room to shape
the full web runtime and authoring DSL incrementally.

## Current DSL Sketch

```ruby
app = Igniter::Web.application do
  root title: "Operator" do
    main class: "shell" do
      h1 "Operator"
      para "Everything is healthy"
    end
  end

  page "/projects/:id", title: "Project" do
    main do
      h1 assigns[:project_name]
      para assigns[:status]
    end
  end

  command "/projects/:id/advance", to: Contracts::AdvanceProject
  stream "/projects/:id/events", to: Projections::ProjectEvents
end
```

Composition starts from screen intent:

```ruby
result = Igniter::Web.compose(name: :plan_review, intent: :human_decision) do
  title "Plan review"

  show :plan_summary
  show :risk_panel
  compare :current_plan, :proposed_plan

  action :approve, run: Contracts::ApprovePlan
  chat with: Agents::ProjectLead

  compose with: :decision_workspace
end

result.success?
result.graph.zone(:footer)
Igniter::Web.render(result.graph, context: assigns[:ctx])
```

Web applications can also be wrapped as a web-owned mount object:

```ruby
web = Igniter::Web.application do
  root title: "Operator" do
    main { h1 "Operator" }
  end
end

mount = Igniter::Web.mount(:operator, path: "/operator", application: web)
bound_mount = mount.bind(environment: app_environment)
bound_mount.rack_app.call("PATH_INFO" => "/operator")
```

Mounted pages receive `assigns[:ctx]`:

```ruby
root title: "Operator" do
  main do
    h1 assigns[:ctx].manifest.name
    para assigns[:ctx].route("/events")
    para assigns[:ctx].service(:cluster_status).call
  end
end

command "/incidents/:id/resolve", to: Igniter::Web.contract("Contracts::ResolveIncident")
stream "/events", to: Igniter::Web.projection("Projections::ClusterEvents")
```

## Application Capsule Structure

`igniter-web` treats web as an optional surface inside an
`igniter-application` capsule, not as the application itself.

If you are starting from application structure, read the user-facing
[Application Capsules guide](../../docs/guide/application-capsules.md) first.
This README explains the web-owned half of that boundary.

Application layout owns only the top-level `:web` group:

- compact capsule profile: `web`
- standalone / expanded profile: `app/web`

Inside that root, `igniter-web` owns this initial surface vocabulary:

- `screens` - composed screen specs and agent-managed flows
- `pages` - routeable page templates
- `components` - reusable Arbre-backed view components
- `projections` - read-model and stream targets for live surfaces
- `webhooks` - external ingress endpoints
- `assets` - optional web-local static or generated assets

This vocabulary is deliberately web-local. Non-web applications remain
first-class and do not need a `web` directory.

```ruby
blueprint = Igniter::Application.blueprint(
  name: :operator,
  root: "apps/operator",
  layout_profile: :capsule,
  web_surfaces: [:operator_console]
)

structure = Igniter::Web.surface_structure(blueprint)
structure.web_root      # => "web"
structure.path(:screens) # => "web/screens"
```

## Surface Exports And Imports

`igniter-web` can describe a mounted web surface without asking
`igniter-application` to understand pages, Arbre, or screen graphs.

```ruby
web = Igniter::Web.application do
  command "/incidents/:id/resolve",
          to: Igniter::Web.contract("Contracts::ResolveIncident")

  stream "/events",
         to: Igniter::Web.projection("Projections::ClusterEvents")
end

surface = Igniter::Web.surface_manifest(web, name: :operator_console, path: "/operator")
surface.exports # route/api/screen surface exported by the mount
surface.imports # contract/service/projection/agent targets required by it
surface.to_h.fetch(:interactions) # pending asks/actions plus streams/chats
Igniter::Web.flow_pending_state(surface, current_step: :review)
surface.to_capsule_export # compatible with ApplicationBlueprint exports:
```

This is intentionally web-owned metadata. The application capsule can export
the whole web surface as `kind: :web_surface`, while the detailed route/screen
imports stay nested until a host decides which targets are local and which are
external requirements.

For agent-native flows, `SurfaceManifest` also extracts interaction metadata
from screen specs:

- `pending_inputs` from `ask`
- `pending_actions` from `action`
- `streams` from `stream`
- `chats` from `chat`

This remains metadata only. Application-owned flow sessions decide which
interactions are active for a concrete snapshot.

When an application wants to start a flow from a web surface, use
`Igniter::Web.flow_pending_state(...)` as an explicit boundary adapter. It
returns plain `pending_inputs` and `pending_actions` hashes suitable for
`Environment#start_flow`, while preserving the original web interaction under
metadata for inspection.

`Igniter::Web.flow_surface_projection(...)` can also compare a surface manifest
with application-owned flow declaration and feature-slice metadata. Use it for
inspection/reporting, not for starting flows or mutating sessions.

For application capsule reports, use `Igniter::Web.flow_surface_metadata(...)`
or `surface.to_surface_metadata(projections: ...)` to pass a plain web-owned
surface hash into `ApplicationBlueprint#capsule_report(surface_metadata:)`.
The envelope keeps `kind: :web_surface`, summary `status`, related `flows` /
`features`, and nested projection hashes on the web side.

The same plain surface metadata can be carried into application transfer
artifacts:

```ruby
surface_metadata = Igniter::Web.surface_metadata(surface)

Igniter::Application.handoff_manifest(
  subject: :operator_bundle,
  capsules: [operator],
  mount_intents: [
    {
      capsule: :operator,
      kind: :web,
      at: "/operator",
      metadata: { surface: surface.name }
    }
  ],
  surface_metadata: [surface_metadata]
)
```

This is still a read-only handoff manifest. It does not bind the web mount, call
Rack, route browser traffic, or make `igniter-application` inspect
`SurfaceManifest`, screens, pages, or components.

For dry-run transfer inventories, keep web-local paths as supplied metadata too:

```ruby
structure = Igniter::Web.surface_structure(operator)

Igniter::Application.transfer_inventory(
  operator,
  surface_metadata: [
    {
      name: :operator_console,
      kind: :web_surface,
      path: structure.web_root,
      screens_path: structure.path(:screens)
    }
  ]
)
```

The inventory may report that the top-level application `web` group is missing,
but it should not inspect `web/screens`, `web/pages`, or other web-local
subgroups as application-owned structure.

For the final read-only decision report before any future transfer/package
tool, pass the same supplied metadata into transfer readiness:

```ruby
readiness = Igniter::Application.transfer_readiness(
  operator,
  surface_metadata: [
    {
      name: :operator_console,
      kind: :web_surface,
      path: structure.web_root,
      screens_path: structure.path(:screens)
    }
  ]
)
```

Readiness may count supplied web surfaces and warn when a declared surface has
no supplied metadata. It still treats the metadata as an opaque hash and does
not load `igniter-web`, inspect screen graphs, bind mounts, or route browser
traffic.

Bundle plans reuse the same boundary. A future package writer can inspect the
read-only plan's `surfaces` count and metadata, but the plan still contains only
supplied hashes:

```ruby
bundle_plan = Igniter::Application.transfer_bundle_plan(
  operator,
  surface_metadata: [
    {
      name: :operator_console,
      kind: :web_surface,
      path: structure.web_root,
      screens_path: structure.path(:screens)
    }
  ]
)
```

This is planning metadata, not an archive writer, mount binder, route
activation step, or web screen/component inspection pass.

If an application writes an explicit transfer bundle artifact from that plan,
the artifact metadata manifest preserves the same supplied surface hashes inside
the serialized plan:

```ruby
result = Igniter::Application.write_transfer_bundle(
  bundle_plan,
  output: "tmp/operator_bundle"
)
```

The writer copies only files already listed by the plan and writes
`igniter-transfer-bundle.json`. Web metadata is embedded for review; it is not
used to discover web-local files, load `SurfaceManifest`, bind mounts, or
activate routes.
