# Igniter Web DSL Sketch

This note captures the current authoring-first direction for `igniter-web`.

It complements:

- [Igniter Web Target Plan](./igniter-web-target-plan.md)

## DSL Thesis

Design `igniter-web` from the shape we want users to write, not from the
internal routing primitives first.

The package should feel:

- compact
- expressive
- low-boilerplate
- pleasant to scan
- friendly to long-lived, stream-heavy, non-CRUD web surfaces

## Current Preferred Feel

The intended tone is closer to:

- Sinatra for compactness
- Rails for pleasant conventions
- Igniter for contracts/process/stream semantics

Not:

- a controller-heavy ceremony-first framework
- an ORM-centered CRUD shell

## Initial Authoring Shape

The first DSL pass should make examples like this feel natural:

```ruby
app = Igniter::Web.application do
  root title: "Operator" do
    main class: "shell" do
      h1 "Operator"
      para "Cluster is healthy"
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

This is intentionally more compact than:

- explicit controller classes
- explicit template file wiring for every first page
- multiple ceremony objects before the screen can exist

## DSL Priorities

Prioritize these authoring wins early:

- `root` and `page` as first-class route + page sugar
- inline page blocks
- easy promotion path from inline page to dedicated page class
- Arbre-backed HTML authoring
- simple layout defaults
- compact route declarations for `command`, `query`, `stream`, and `webhook`

## Promotion Path

The DSL should support growth from tiny apps to richer apps without punishing
the simple case.

Start small:

```ruby
page "/chat", title: "Chat" do
  h1 "Chat"
end
```

Promote later:

```ruby
class ChatPage < Igniter::Web::Page
  title "Chat"

  body do
    main do
      h1 "Chat"
    end
  end
end

page "/chat", to: ChatPage
```

That gives the package a useful spectrum:

- inline for small surfaces
- classes for reusable or larger surfaces

## First-Class Authoring Objects

The current DSL lane should revolve around:

- `Application`
- `Page`
- `Component`
- `Api`
- `Record`

The shape is intentionally:

- `Application` for route drawing and web composition
- `Page` for full-screen HTML surfaces
- `Component` for reusable UI vocabulary
- `Api` for contracts-first transport declarations
- `Record` for optional persistence convenience

## Working Rule

If a proposed API makes small web surfaces longer, noisier, or more ceremonial
without buying a real capability, it is probably the wrong default DSL.
