# igniter-frontend

`igniter-frontend` is a local monorepo gem for developer-facing app web surfaces on top of Igniter.

It now ships with `arbre` as a standard dependency. The intent is simple:

- `Igniter Frontend` should feel as simple and powerful for Ruby-authored app UI
  as `ActiveAdmin` feels for admin UI
- Arbre is no longer a side adapter you add by hand later
- Arbre is part of the default developer-authoring lane for `igniter-frontend`

It groups high-level concerns that belong together in app development:

- route authoring
- handler/controller lifecycle
- request/response helpers
- mounted-app aware contexts
- Arbre page rendering
- semantic Arbre components
- optional JavaScript runtime and app-owned entrypoints

Schema-driven agent rendering intentionally lives outside this package. Use a
separate package for that lane so the human-first app surface stays simple.

The goal is not to re-create Rails.
The goal is to give Igniter apps a small, coherent, HTML-first framework for
building dashboards, chats, operator tools, decentralized personal apps, and
other rich mounted web surfaces.

The frontend direction is now explicitly:

- Arbre for developer-authored page composition
- Tailwind surfaces for shared UI language
- stronger UX/UI semantics on top of that Arbre lane over time

That “stronger semantics” line now includes richer Arbre primitives such as:

- `badge` with inferred status tone and compact sizing
- `card#line` with `as: :badge` / `as: :code`
- placeholder-aware schema rows and nested `subcard` composition
- `table_with` for logs, events, history, and other collection-heavy operator views
- `viz` for raw hashes, arrays, objects, and runtime payload inspection
- `filters` for mounted-safe search and narrowing lanes above tables and feeds
- `pagination` for mounted-safe browsing lanes across notes, history, logs, and other long collections

Authoring guide:

- [Frontend Authoring](../../docs/guide/frontend-authoring.md)
- [Frontend Components](../../docs/guide/frontend-components.md)
- [Guide](../../docs/guide/README.md)
- [Dev](../../docs/dev/README.md)

## First-cut API

```ruby
require "igniter/app"
require "igniter-frontend"

class WebApp < Igniter::App
  include Igniter::Frontend::App

  root_dir __dir__
  config_file "app.yml"
  frontend_assets path: "frontend"

  get "/", to: Web::Handlers::HomeHandler

  scope "/notes" do
    post "/", to: Web::Handlers::NotesCreateHandler
  end
end
```

```ruby
module Web
  module Handlers
    class HomeHandler < Igniter::Frontend::Handler
      def call
        render Views::HomePage,
               context: build_context(Contexts::HomeContext, title: "Home")
      end
    end
  end
end
```

```ruby
module Web
  module Views
    class HomePage < Igniter::Frontend::ArbrePage
      template_root __dir__
      template "home"
      layout "layout"

      def initialize(context:)
        @context = context
      end

      def template_locals
        { page_context: @context }
      end
    end
  end
end
```

## Status

This package now owns the human-facing web surface directly inside the monorepo:

- route DSL and handler lifecycle
- HTML builder/page abstractions
- Arbre page pipeline
- Tailwind shell and semantic UI components
- optional frontend JavaScript runtime with app-owned assets under `frontend/`

It is no longer just a facade over `lib/igniter/plugins/view`.

## Optional JavaScript

Use `frontend_assets` when the app wants a small built-in runtime plus its own
JavaScript entrypoints.

```ruby
class DashboardApp < Igniter::App
  include Igniter::Frontend::App

  root_dir __dir__
  frontend_assets path: "frontend"
end
```

App structure:

```text
apps/dashboard/
  app.rb
  frontend/
    application.js
    controllers/
```

Layout usage:

```ruby
body do
  render_template_content
  render_frontend_javascript "application"
end
```

This serves:

- built-in runtime at `/__frontend/runtime.js`
- app entrypoints like `/__frontend/assets/application.js`

Both URLs stay mounted-app aware when rendered through `ArbrePage` helpers.

Built-in controllers currently include:

- `tabs` for semantic tab panels
- `stream` for `EventSource` lifecycle, JSON parsing, and app-level hooks

Example stream wiring:

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

For repeated updates, prefer marking DOM zones with `data-ig-stream-target` and
using the small helpers exposed by `stream`:

- `setTextTarget(name, value)`
- `setHtmlTarget(name, html)`
- `setJsonTarget(name, payload)`
- `prependHtmlTarget(name, html, { limit: ... })`

In Arbre pages and components, prefer the helper:

```ruby
span current_value, **stream_target(:generated_at, id: "generated-at")
```

That keeps `data-ig-*` details out of app templates.

The same applies to controller values:

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

Use `controller_value(:tabs, :active_id, "routing")` when you need the generic
form outside the `stream` lane.

For the controller name itself, prefer `stream_scope` or the generic
`controller_scope(:stream, :operator_panel)` over raw `data-ig-controller`
strings.
