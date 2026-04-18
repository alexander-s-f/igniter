# frozen_string_literal: true

require "stringio"
require "spec_helper"
require_relative "../../packages/igniter-frontend/lib/igniter-frontend"

RSpec.describe "igniter-frontend local gem facade" do
  it "provides mounted-aware page rendering through frontend handlers" do
    page_class = Class.new do
      def self.render(context:, **)
        "<h1>#{context.fetch(:title)}</h1><p>#{context.route("/notes")}</p>"
      end
    end

    context_class = Class.new(Igniter::Frontend::Context)

    handler_class = Class.new(Igniter::Frontend::Handler) do
      define_method(:call) do
        render(page_class, context: build_context(context_class, title: "Frontend Home"))
      end
    end

    app_class = Class.new(Igniter::App) do
      include Igniter::Frontend::App

      root_dir Dir.pwd
      get "/", to: handler_class
    end

    status, headers, body = app_class.rack_app.call(
      "REQUEST_METHOD" => "GET",
      "SCRIPT_NAME" => "/dashboard",
      "PATH_INFO" => "/",
      "rack.input" => StringIO.new
    )

    html = body.each.to_a.join

    expect(status).to eq(200)
    expect(headers["Content-Type"]).to include("text/html")
    expect(html).to include("Frontend Home")
    expect(html).to include("/dashboard/notes")
  end

  it "adds scoped route helpers and request/response wrappers" do
    handler_class = Class.new(Igniter::Frontend::Handler) do
      define_method(:call) do
        json(
          {
            "path" => request.path,
            "query" => request.query_params,
            "params" => request.params,
            "stack" => app_access.stack
          }
        )
      end
    end

    app_class = Class.new(Igniter::App) do
      include Igniter::Frontend::App

      root_dir Dir.pwd

      scope "/notes" do
        post "/search", to: handler_class
      end
    end

    status, headers, body = app_class.rack_app.call(
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/notes/search",
      "QUERY_STRING" => "q=router",
      "CONTENT_TYPE" => "application/x-www-form-urlencoded",
      "rack.input" => StringIO.new("page=2")
    )

    payload = JSON.parse(body.each.to_a.join)

    expect(status).to eq(200)
    expect(headers["Content-Type"]).to include("application/json")
    expect(payload.fetch("path")).to eq("/notes/search")
    expect(payload.fetch("query")).to eq({ "q" => "router" })
    expect(payload.fetch("params")).to include("q" => "router", "page" => "2")
    expect(payload.fetch("stack")).to eq({})
  end

  it "re-exports the current page and component lanes" do
    expect(Igniter::Frontend::ArbrePage).to eq(Igniter::Plugins::View::ArbrePage)
    expect(Igniter::Frontend::SchemaPage).to eq(Igniter::Plugins::View::SchemaPage)
    expect(Igniter::Frontend::Components).to eq(Igniter::Plugins::View::Arbre::Components)
  end
end
