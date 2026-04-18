# Frontend Authoring

This guide shows the current developer-facing authoring shape for
`Igniter::Frontend`.

It is based on the active `playgrounds/home-lab` implementation, not on an old
prototype. If you want the shortest path to "how do I build a page today?",
start here.

## Mental Model

The current frontend lane is intentionally split into four small roles:

1. `Handler`
   reads the request, assembles data, chooses the page
2. `Context`
   holds the page-ready snapshot and route helpers
3. `ArbrePage`
   defines template root, layout, and locals
4. `.arb` templates
   compose semantic UI blocks such as `page_header`, `panel`, `metric_grid`,
   `resource_list`, and `tabs`

That keeps request handling, state shaping, and UI authoring separate.

## Canonical Shape

### 1. Build a page context

Use a plain Ruby object to expose page-ready data instead of passing a raw hash
everywhere.

Real example:
[home_page_context.rb](/Users/alex/dev/projects/igniter/playgrounds/home-lab/lib/home_lab/dashboard/views/home_page_context.rb:1)

```ruby
module HomeLab
  module Dashboard
    module Views
      class HomePageContext
        def self.build(snapshot:, base_path:, chat_error: nil, note_error: nil, demo: nil)
          new(
            snapshot: snapshot,
            base_path: base_path,
            chat_error: chat_error,
            note_error: note_error,
            demo: demo
          )
        end

        def route(suffix)
          [base_path.to_s.sub(%r{/+\z}, ""), suffix].join
        end
      end
    end
  end
end
```

Good context objects usually do three things:

- expose named readers like `counts`, `devices`, `routing`
- hide snapshot nesting with small methods like `topology_health`
- provide mounted-safe route helpers like `route("/chat")`

### 2. Keep handlers thin

The handler should gather data and render a page, not build HTML.

```ruby
class HomeHandler < Igniter::Frontend::Handler
  def call
    snapshot = build_snapshot

    render Views::HumanHomePage,
           context: Views::HomePageContext.build(
             snapshot: snapshot,
             base_path: env["SCRIPT_NAME"].to_s
           )
  end
end
```

### 3. Define a page object

Use `Igniter::Frontend::ArbrePage` as the stable page entrypoint.

Real example:
[human_home_page.rb](/Users/alex/dev/projects/igniter/playgrounds/home-lab/lib/home_lab/dashboard/views/human_home_page.rb:1)

```ruby
class HumanHomePage < Igniter::Frontend::ArbrePage
  template_root __dir__
  template "home_page"
  layout "layout"

  def initialize(context:)
    @context = context
  end

  def template_locals
    { page_context: @context }
  end
end
```

Use `page_context`, not `context`, inside `.arb` locals. In real Arbre runtime,
`context` is too overloaded and becomes confusing quickly.

### 4. Keep layout in `.arb`

Use a dedicated layout template for document shell concerns like `html`, `head`,
`body`, inline CSS, and scripts.

Real example:
[layout.arb](/Users/alex/dev/projects/igniter/playgrounds/home-lab/lib/home_lab/dashboard/views/layout.arb:1)

```ruby
html lang: "en" do
  head do
    meta charset: "utf-8"
    title "HomeLab Dashboard"
    style { raw_text stylesheet }
  end

  body do
    main do
      render_template_content
    end
  end
end
```

### 5. Keep page composition in `.arb`

Use `.arb` for the high-level screen outline.

Real example:
[home_page.arb](/Users/alex/dev/projects/igniter/playgrounds/home-lab/lib/home_lab/dashboard/views/home_page.arb:1)

```ruby
page_header(
  eyebrow: "Operator Surface",
  title: "HomeLab Dashboard",
  description: "Живой dashboard для сценариев home-lab."
) do
  metric_grid do
    metric "Apps", page_context.counts.fetch(:apps)
    metric "Nodes", page_context.counts.fetch(:nodes)
  end
end

section class: "grid" do |grid|
  render_chat_panel(grid, messages: page_context.chat_messages, prompts: page_context.chat_suggested_prompts, pending_action: page_context.pending_chat_action)
  render_notes_panel(grid, notes: page_context.notes)
  render_cluster_state_panel(grid, routing: page_context.routing, peers: page_context.discovered_peers, current_node: page_context.current_node)
end
```

The important part is the reading experience:
the template should read like an outline of the page, not like low-level HTML
assembly.

## What To Put Where

### Put in `.arb`

- top-level page structure
- sequencing of panels/sections
- simple local composition of already-meaningful blocks

### Put in the page class

- helper methods that render a domain block
- reusable route-aware forms
- small bits of UI policy that would clutter the template

In `home-lab`, methods like
[render_chat_panel](/Users/alex/dev/projects/igniter/playgrounds/home-lab/lib/home_lab/dashboard/views/human_home_page.rb:25)
and
[render_topology_health_panel](/Users/alex/dev/projects/igniter/playgrounds/home-lab/lib/home_lab/dashboard/views/human_home_page.rb:140)
are a good example of the current sweet spot.

### Put in components

- repeated semantics that should feel like vocabulary
- blocks reused across pages or apps
- UI primitives whose internal HTML should stop leaking into pages

Current useful primitives already available in `Igniter::Frontend::Arbre`:

- `page_header`
- `panel`
- `badge`
- `action_group`
- `metric_grid`
- `key_value_list`
- `resource_list`
- `event_list`
- `conversation_panel`
- `scenario_card`
- `json_panel`
- `tabs`

## Recommended Flow

When building a new page:

1. Start with a `Context` object.
2. Add a thin `Handler`.
3. Add an `ArbrePage` class with `template_root`, `template`, and `layout`.
4. Sketch the screen in `.arb` using semantic blocks.
5. Only then extract repeated parts into helper methods or new components.

That order keeps us from over-engineering abstractions too early.

## Human vs Schema Lanes

Use `Igniter::Frontend` when a developer is authoring the page directly.

Use `Igniter::SchemaRendering` when the page definition is persisted, patched,
machine-authored, or needs a generic runtime path.

They can share the same app and the same data context shape, but they are
different authoring lanes on purpose.

## Related Docs

- [igniter-frontend README](/Users/alex/dev/projects/igniter/packages/igniter-frontend/README.md)
- [Frontend Components](./FRONTEND_COMPONENTS.md)
- [Schema Rendering Authoring](./SCHEMA_RENDERING_AUTHORING.md)
- [Frontend Packages Idea](./FRONTEND_PACKAGES_IDEA.md)
