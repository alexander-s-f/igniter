# frozen_string_literal: true

module Igniter
  class App
    module Generators
      class Dashboard
        def initialize(name, minimal: false)
          @name = name.to_s
          @minimal = minimal
          @base = Igniter::App::Generator.new(name, minimal: minimal)
        end

        def generate
          @base.generate
          expand_stack_shape
          add_dashboard_app
          write "README.md", dashboard_readme
        end

        private

        attr_reader :base

        def expand_stack_shape
          create_dir "apps/dashboard/spec"
          create_dir "lib/#{namespace_path}/dashboard"
          create_dir "lib/#{namespace_path}/shared"
          write "stack.rb", stack_rb
          write "spec/stack_spec.rb", stack_spec
          write "lib/#{namespace_path}/shared/stack_overview.rb", shared_stack_overview
        end

        def add_dashboard_app
          write "apps/dashboard/app.rb", dashboard_app_rb
          write "apps/dashboard/app.yml", dashboard_app_yml
          write "apps/dashboard/spec/spec_helper.rb", dashboard_spec_helper
          write "apps/dashboard/spec/dashboard_app_spec.rb", dashboard_app_spec
          write "lib/#{namespace_path}/dashboard/home_handler.rb", dashboard_home_handler
        end

        def path(rel)
          File.join(@name, rel)
        end

        def write(rel, content)
          File.write(path(rel), content)
        end

        def create_dir(rel)
          FileUtils.mkdir_p(path(rel))
        end

        def module_name
          project_name.split(/[^a-zA-Z0-9]+/).reject(&:empty?).map(&:capitalize).join
        end

        def namespace_path
          project_name.strip.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
        end

        def project_name
          File.basename(@name)
        end

        def stack_class_name
          "#{module_name}::Stack"
        end

        def stack_rb
          <<~RUBY
            # frozen_string_literal: true

            require "igniter/stack"
            require_relative "apps/main/app"
            require_relative "apps/dashboard/app"

            module #{module_name}
              class Stack < Igniter::Stack
                root_dir __dir__
                shared_lib_path "lib"

                app :main, path: "apps/main", klass: #{module_name}::MainApp, default: true
                app :dashboard, path: "apps/dashboard", klass: #{module_name}::DashboardApp

                mount :dashboard, at: "/dashboard"
              end
            end

            if $PROGRAM_NAME == __FILE__
              #{stack_class_name}.start_cli(ARGV)
            end
          RUBY
        end

        def stack_spec
          <<~RUBY
            # frozen_string_literal: true

            require_relative "spec_helper"

            RSpec.describe #{stack_class_name} do
              it "registers a mounted dashboard app" do
                expect(described_class.root_app).to eq(:main)
                expect(described_class.default_node).to eq(:main)
                expect(described_class.app(:main)).to be(#{module_name}::MainApp)
                expect(described_class.app(:dashboard)).to be(#{module_name}::DashboardApp)
                expect(described_class.mounts).to eq(dashboard: "/dashboard")
                expect(described_class.node_names).to eq([:main])
              end
            end
          RUBY
        end

        def shared_stack_overview
          <<~RUBY
            # frozen_string_literal: true

            module #{module_name}
              module Shared
                module StackOverview
                  module_function

                  def build
                    snapshot = #{stack_class_name}.deployment_snapshot
                    current_node = ENV["IGNITER_NODE"].to_s

                    {
                      stack: snapshot.fetch("stack"),
                      apps: snapshot.fetch("apps"),
                      nodes: snapshot.fetch("nodes"),
                      current_node: current_node.empty? ? snapshot.dig("stack", "default_node") : current_node
                    }
                  end
                end
              end
            end
          RUBY
        end

        def dashboard_app_rb
          <<~RUBY
            # frozen_string_literal: true

            require "igniter/app"
            require "igniter/core"
            require_relative "../../lib/#{namespace_path}/dashboard/home_handler"

            module #{module_name}
              class DashboardApp < Igniter::App
                root_dir __dir__
                config_file "app.yml"
                mount_operator_surface

                route "GET", "/", with: #{module_name}::Dashboard::HomeHandler
              end
            end
          RUBY
        end

        def dashboard_app_yml
          <<~YAML
            persistence:
              execution:
                adapter: memory
                path: var/dashboard_executions.sqlite3
          YAML
        end

        def dashboard_spec_helper
          <<~RUBY
            # frozen_string_literal: true

            require_relative "../../../spec/spec_helper"

            #{module_name}::DashboardApp.send(:build!)
          RUBY
        end

        def dashboard_app_spec
          <<~RUBY
            # frozen_string_literal: true

            require_relative "spec_helper"
            require "stringio"

            RSpec.describe #{module_name}::DashboardApp do
              it "renders the canonical operator endpoint" do
                app = described_class.rack_app

                status, headers, body = app.call(
                  "REQUEST_METHOD" => "GET",
                  "PATH_INFO" => "/api/operator",
                  "rack.input" => StringIO.new
                )

                payload = JSON.parse(body.each.to_a.join)

                expect(status).to eq(200)
                expect(headers["Content-Type"]).to include("application/json")
                expect(payload["app"]).to eq("#{module_name}::DashboardApp")
                expect(payload["scope"]).to eq("mode" => "app")
                expect(payload.dig("summary", "total")).to eq(0)
              end

              it "renders the built-in operator console" do
                app = described_class.rack_app

                status, headers, body = app.call(
                  "REQUEST_METHOD" => "GET",
                  "PATH_INFO" => "/operator",
                  "rack.input" => StringIO.new
                )

                html = body.each.to_a.join

                expect(status).to eq(200)
                expect(headers["Content-Type"]).to include("text/html")
                expect(html).to include("Operator Console")
                expect(html).to include("/api/operator")
              end

              it "renders the mounted dashboard home page" do
                app = described_class.rack_app

                status, headers, body = app.call(
                  "REQUEST_METHOD" => "GET",
                  "PATH_INFO" => "/",
                  "rack.input" => StringIO.new
                )

                html = body.each.to_a.join

                expect(status).to eq(200)
                expect(headers["Content-Type"]).to include("text/html")
                expect(html).to include("#{module_name} Dashboard")
                expect(html).to include("/dashboard")
                expect(html).to include("/api/operator")
                expect(html).to include("Mounted Apps")
              end
            end
          RUBY
        end

        def dashboard_home_handler
          <<~RUBY
            # frozen_string_literal: true

            require "cgi"
            require "json"
            require "igniter-frontend"
            require_relative "../shared/stack_overview"

            module #{module_name}
              module Dashboard
                module HomeHandler
                  module_function

                  def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
                    snapshot = #{module_name}::Shared::StackOverview.build

                    Igniter::Frontend::Response.html(render_page(snapshot: snapshot, base_path: env["SCRIPT_NAME"].to_s))
                  end

                  def render_page(snapshot:, base_path:)
                    stack = snapshot.fetch(:stack)
                    apps = snapshot.fetch(:apps)
                    nodes = snapshot.fetch(:nodes)
                    mounted_apps = stack.fetch("mounts", {})

                    <<~HTML
                      <!doctype html>
                      <html lang="en">
                        <head>
                          <meta charset="utf-8">
                          <meta name="viewport" content="width=device-width, initial-scale=1">
                          <title>#{module_name} Dashboard</title>
                          <style>
                            :root { color-scheme: light; }
                            body { font-family: ui-sans-serif, system-ui, sans-serif; margin: 0; background: #f5f1e8; color: #1c1b18; }
                            main { max-width: 960px; margin: 0 auto; padding: 32px 20px 48px; }
                            .hero { background: linear-gradient(135deg, #fdf8ef, #efe0c8); border: 1px solid #d7c3a2; border-radius: 20px; padding: 24px; }
                            .meta, .card pre { color: #5a5145; }
                            .grid { display: grid; gap: 16px; margin-top: 20px; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); }
                            .card { background: white; border: 1px solid #ded4c4; border-radius: 16px; padding: 18px; box-shadow: 0 8px 24px rgba(40, 24, 8, 0.06); }
                            code, pre { font-family: ui-monospace, SFMono-Regular, monospace; }
                            pre { white-space: pre-wrap; font-size: 13px; }
                            a { color: #0b5f56; }
                          </style>
                        </head>
                        <body>
                          <main>
                            <section class="hero">
                              <h1>#{module_name} Dashboard</h1>
                              <p>Mounted stack overview generated by the <code>dashboard</code> scaffold profile.</p>
                              <p class="meta">
                                root_app=\#{h(stack["root_app"])} ·
                                default_node=\#{h(stack["default_node"])} ·
                                current_node=\#{h(snapshot[:current_node])}
                              </p>
                              <p><a href="\#{route(base_path, "/")}">Refresh</a> · <a href="\#{route(base_path, "/operator")}">Operator Console</a> · <a href="\#{route(base_path, "/api/operator")}">Operator API</a></p>
                            </section>

                            <section class="grid">
                              <article class="card">
                                <h2>Mounted Apps</h2>
                                <pre>\#{h(JSON.pretty_generate(apps))}</pre>
                              </article>
                              <article class="card">
                                <h2>Mounts</h2>
                                <pre>\#{h(JSON.pretty_generate(mounted_apps))}</pre>
                              </article>
                              <article class="card">
                                <h2>Nodes</h2>
                                <pre>\#{h(JSON.pretty_generate(nodes))}</pre>
                              </article>
                            </section>
                          </main>
                        </body>
                      </html>
                    HTML
                  end

                  def route(base_path, suffix)
                    [base_path.to_s.sub(%r{/+\z}, ""), suffix].join
                  end

                  def h(value)
                    CGI.escapeHTML(value.to_s)
                  end
                end
              end
            end
          RUBY
        end

        def dashboard_readme
          <<~MARKDOWN
            # #{module_name}

            This stack was generated with the `dashboard` scaffold profile.

            The intended reading order is simple:

            1. `stack.rb`
            2. `stack.yml`
            3. `apps/dashboard/app.rb`

            ## What This Profile Adds

            - a mounted `dashboard` app at `/dashboard`
            - a small HTML overview page for the current stack shape
            - a second app that still lives under the same stack runtime

            ## Boot

            ```bash
            bundle install
            ruby bin/demo
            bin/start
            bin/console --node main
            bin/dev
            ```

            Then open:

            - `http://127.0.0.1:4567/`
            - `http://127.0.0.1:4567/dashboard`

            `bin/dev` also writes per-node logs to `var/log/dev/*.log`.
          MARKDOWN
        end
      end
    end
  end
end
