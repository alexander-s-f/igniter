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
