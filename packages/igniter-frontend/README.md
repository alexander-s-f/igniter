# igniter-frontend

`igniter-frontend` is a local monorepo gem for developer-facing app web surfaces on top of Igniter.

It groups high-level concerns that belong together in app development:

- route authoring
- handler/controller lifecycle
- request/response helpers
- mounted-app aware contexts
- Arbre page rendering
- semantic Arbre components

Schema-driven agent rendering intentionally lives outside this package. Use a
separate package for that lane so the human-first app surface stays simple.

The goal is not to re-create Rails.
The goal is to give Igniter apps a small, coherent, HTML-first framework for
building dashboards, chats, operator tools, decentralized personal apps, and
other rich mounted web surfaces.

Authoring guide:

- [Frontend Authoring](/Users/alex/dev/projects/igniter/docs/FRONTEND_AUTHORING.md)
- [Frontend Components](/Users/alex/dev/projects/igniter/docs/FRONTEND_COMPONENTS.md)

## First-cut API

```ruby
require "igniter/app"
require "igniter-frontend"

class WebApp < Igniter::App
  include Igniter::Frontend::App

  root_dir __dir__
  config_file "app.yml"

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

It is no longer just a facade over `lib/igniter/plugins/view`.
