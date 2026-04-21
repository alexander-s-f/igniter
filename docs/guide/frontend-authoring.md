# Frontend Authoring

This guide shows the current developer-facing authoring shape for
`Igniter::Frontend`.

It is based on the active `playgrounds/home-lab` implementation, not on an old
prototype. If you want the shortest path to "how do I build a page today?",
start here.

`igniter-frontend` now ships with `arbre` as part of the standard authoring
lane. The intended experience is: Ruby-authored app UI should feel as simple
and powerful as working with `ActiveAdmin`, but for Igniter apps and operator
surfaces.

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

The current semantic primitive lane is intentionally small, but it is getting
more expressive. For example:

- `badge` can infer a tone from values like `:active`, `false`, or `"pending"`
- `card#line` can render values as `:badge` or `:code`
- `card#subcard` lets a page nest compact schema sections without dropping back
  to raw layout markup
- `table_with` gives collection-heavy screens a first-class Arbre path for
  events, history, logs, and operator records
- `viz` gives raw structured payloads a first-class path for snapshots,
  diagnostics, and debug-oriented operator surfaces
- `filters` gives collection-heavy pages a semantic GET-form lane for search,
  select narrowing, and reset/apply actions
- `pagination` gives long lists a mounted-safe browsing lane without dropping
  back to ad-hoc link markup
- `sidebar_shell` gives operator/admin apps a reusable left-nav shell without
  moving layout chrome back into custom template plumbing

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
`body`, inline CSS, and script includes.

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

    render_frontend_javascript "application"
  end
end
```

### 5. Add JavaScript as an optional layer

`igniter-frontend` stays HTML-first, but it now has an optional JavaScript lane
for progressive enhancement and app-owned behavior.

Configure it in the app:

```ruby
class DashboardApp < Igniter::App
  include Igniter::Frontend::App

  root_dir __dir__
  frontend_assets path: "frontend"
end
```

Put app-owned code here:

```text
apps/dashboard/
  frontend/
    application.js
    controllers/
```

This gives the page:

- the built-in runtime at `/__frontend/runtime.js`
- your entrypoint at `/__frontend/assets/application.js`

When the app is mounted under a sub-path, `render_frontend_javascript` emits the
correct mounted URLs automatically.

The built-in runtime already includes a few small controllers. Right now the
most useful ones are:

- `tabs`
- `stream`

`stream` is the first good example of the intended split:

- the framework owns `EventSource`, connection lifecycle, and JSON parsing
- the app owns only the rendering hook

Example:

```ruby
main(
  "data-ig-controller": "stream",
  "data-ig-stream-url-value": page_context.route("/api/overview/stream"),
  "data-ig-stream-events-value": "[\"overview\",\"activity\"]",
  "data-ig-stream-hook-value": "homeLabOverviewStream"
) do
  render_template_content
end
```

```js
window.homeLabOverviewStream = {
  overview({ controller, payload }) {
    controller.setTextTarget("generatedAt", payload.generated_at);
  }
};
```

When a page has repeated live-update zones, mark them with
`data-ig-stream-target` and prefer the small helper methods that the built-in
`stream` controller exposes:

- `setTextTarget`
- `setHtmlTarget`
- `setJsonTarget`
- `prependHtmlTarget`

In Arbre templates and components, avoid writing the raw attribute by hand.
Prefer:

```ruby
span page_context.generated_at, **stream_target(:generated_at, id: "generated-at")
```

That keeps the template at the semantic level instead of leaking `data-ig-*`
strings into every page.

Do the same for controller values:

```ruby
main(
  **stream_scope,
  **stream_value(:url, page_context.route("/api/overview/stream")),
  **stream_value(:events, %w[overview activity]),
  **stream_value(:hook, "homeLabOverviewStream")
) do
  render_template_content
end
```

`stream_value` is just the focused version of `controller_value`, so use
`controller_value(:tabs, :active_id, "routing")` when you need the generic form.
Likewise, use `stream_scope` or `controller_scope(:stream, :operator_panel)` for
the controller name instead of raw `data-ig-controller` strings.

### 6. Keep page composition in `.arb`

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
[render_cluster_state_panel](/Users/alex/dev/projects/igniter/playgrounds/home-lab/lib/home_lab/dashboard/views/human_home_page.rb:188)
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
