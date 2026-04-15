# frozen_string_literal: true

require "pathname"

module Igniter
  class App
    module Generators
      class Playground
        def initialize(name, minimal: false)
          @name = name.to_s
          @minimal = minimal
          @base = Igniter::App::Generator.new(name, minimal: minimal)
        end

        def generate
          @base.generate
          expand_stack_shape
          expand_main_surface
          add_dashboard_app
          rewrite_gemfile_for_local_playground if local_monorepo_playground?
          write "README.md", playground_readme
        end

        private

        attr_reader :base

        def expand_stack_shape
          create_dir "lib/#{namespace_path}/main"
          create_dir "lib/#{namespace_path}/dashboard"
          create_dir "apps/dashboard/spec"
          create_dir "lib/#{namespace_path}/dashboard/views"
          write "stack.rb", stack_rb
          write "config/topology.yml", topology_yml
          write "config/environments/development.yml", development_yml
          write "config/environments/production.yml", production_yml
          write "config/deploy/Procfile.dev", procfile_dev
          write "spec/stack_spec.rb", stack_spec
          write "lib/#{namespace_path}/shared/stack_overview.rb", shared_stack_overview
        end

        def expand_main_surface
          write "apps/main/app.rb", main_app_rb
          write "apps/main/spec/main_app_spec.rb", main_app_spec
          write "lib/#{namespace_path}/main/status_handler.rb", main_status_handler
        end

        def add_dashboard_app
          write "apps/dashboard/app.rb", dashboard_app_rb
          write "apps/dashboard/app.yml", dashboard_app_yml
          write "apps/dashboard/spec/spec_helper.rb", dashboard_spec_helper
          write "apps/dashboard/spec/dashboard_app_spec.rb", dashboard_app_spec
          write "lib/#{namespace_path}/dashboard/home_handler.rb", dashboard_home_handler
          write "lib/#{namespace_path}/dashboard/overview_handler.rb", dashboard_overview_handler
          write "lib/#{namespace_path}/dashboard/views/home_page.rb", dashboard_home_page
        end

        def rewrite_gemfile_for_local_playground
          write "Gemfile", gemfile_with_local_path
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

        def generated_root
          Pathname.new(File.expand_path(@name, Dir.pwd))
        end

        def repo_root
          @repo_root ||= File.expand_path(Dir.pwd)
        end

        def local_monorepo_playground?
          File.directory?(File.join(repo_root, "lib", "igniter")) &&
            generated_root.to_s.start_with?(File.join(repo_root, "playgrounds") + "/")
        end

        def relative_path_to_repo_root
          Pathname.new(repo_root).relative_path_from(generated_root).to_s
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
              end
            end

            if $PROGRAM_NAME == __FILE__
              #{stack_class_name}.start_cli(ARGV)
            end
          RUBY
        end

        def topology_yml
          <<~YAML
            stack:
              name: #{project_name}
              default_app: main

            topology:
              profile: local
              notes:
                - "playground profile: main + dashboard proving slice"

            deploy:
              compose:
                context: .
                dockerfile: config/deploy/Dockerfile
                working_dir: /app
                volume_name: #{namespace_path}_var
                volume_target: /app/var

            apps:
              main:
                app: main
                role: api
                replicas: 1
                public: true
                http:
                  port: 4567
                command: bundle exec ruby stack.rb main

              dashboard:
                app: dashboard
                role: admin
                replicas: 1
                public: true
                http:
                  port: 4569
                command: bundle exec ruby stack.rb dashboard
                depends_on:
                  - main

            shared:
              persistence:
                data:
                  adapter: sqlite
                  path: var/#{project_name}_data.sqlite3
          YAML
        end

        def development_yml
          <<~YAML
            stack:
              environment: development

            topology:
              profile: development
              apps:
                main:
                  replicas: 1
                dashboard:
                  replicas: 1
          YAML
        end

        def production_yml
          <<~YAML
            stack:
              environment: production

            topology:
              profile: production
              apps:
                main:
                  replicas: 2
                dashboard:
                  replicas: 1
          YAML
        end

        def procfile_dev
          <<~TEXT
            main: IGNITER_APP=main PORT=4567 bundle exec ruby stack.rb main
            dashboard: IGNITER_APP=dashboard PORT=4569 bundle exec ruby stack.rb dashboard
          TEXT
        end

        def stack_spec
          <<~RUBY
            # frozen_string_literal: true

            require_relative "spec_helper"

            RSpec.describe #{stack_class_name} do
              it "registers main and dashboard apps with main as default" do
                expect(described_class.default_app).to eq(:main)
                expect(described_class.app(:main)).to be(#{module_name}::MainApp)
                expect(described_class.app(:dashboard)).to be(#{module_name}::DashboardApp)
                expect(described_class.app_for_role(:admin)).to eq(:dashboard)
              end
            end
          RUBY
        end

        def main_app_rb
          <<~RUBY
            # frozen_string_literal: true

            require "igniter/app"
            require "igniter/core"
            require_relative "../../lib/#{namespace_path}/main/status_handler"

            module #{module_name}
              class MainApp < Igniter::App
                root_dir __dir__
                config_file "app.yml"

                tools_path     "app/tools"
                skills_path    "app/skills"
                executors_path "app/executors"
                contracts_path "app/contracts"
                agents_path    "app/agents"

                route "GET", "/v1/home/status", with: #{module_name}::Main::StatusHandler

                on_boot do
                  register "GreetContract", #{module_name}::GreetContract
                end

                configure do |c|
                  c.app_host.host = "0.0.0.0"
                  c.app_host.port = ENV.fetch("PORT", "4567").to_i
                  c.app_host.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
                end
              end
            end
          RUBY
        end

        def main_app_spec
          <<~RUBY
            # frozen_string_literal: true

            require_relative "spec_helper"
            require "json"
            require "stringio"

            RSpec.describe #{module_name}::MainApp do
              it "builds and registers the greet contract" do
                config = described_class.send(:build!)
                expect(config.registry.registered?("GreetContract")).to be(true)
              end

              it "exposes a status endpoint for the stack snapshot" do
                app = described_class.rack_app

                status, headers, body = app.call(
                  "REQUEST_METHOD" => "GET",
                  "PATH_INFO" => "/v1/home/status",
                  "rack.input" => StringIO.new
                )

                payload = JSON.parse(body.each.to_a.join)

                expect(status).to eq(200)
                expect(headers["Content-Type"]).to include("application/json")
                expect(payload.dig("stack", "default_app")).to eq("main")
                expect(payload.dig("apps", "dashboard", "role")).to eq("admin")
              end
            end

            RSpec.describe #{module_name}::GreetContract do
              it "returns a greeting" do
                result = described_class.new(name: "Alice").result.greeting

                expect(result[:message]).to include("Alice")
                expect(result[:greeted_at]).to be_a(String)
              end
            end
          RUBY
        end

        def main_status_handler
          <<~RUBY
            # frozen_string_literal: true

            require "json"
            require "time"
            require_relative "../shared/stack_overview"

            module #{module_name}
              module Main
                module StatusHandler
                  module_function

                  def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
                    snapshot = #{module_name}::Shared::StackOverview.build

                    {
                      status: 200,
                      body: JSON.generate(
                        generated_at: snapshot.fetch(:generated_at),
                        stack: snapshot.fetch(:stack),
                        apps: snapshot.fetch(:apps)
                      ),
                      headers: { "Content-Type" => "application/json" }
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
            require_relative "../../lib/#{namespace_path}/dashboard/overview_handler"

            module #{module_name}
              class DashboardApp < Igniter::App
                root_dir __dir__
                config_file "app.yml"

                route "GET", "/", with: #{module_name}::Dashboard::HomeHandler
                route "GET", "/api/overview", with: #{module_name}::Dashboard::OverviewHandler

                configure do |c|
                  c.app_host.host = "0.0.0.0"
                  c.app_host.port = ENV.fetch("PORT", "4569").to_i
                  c.app_host.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
                end
              end
            end
          RUBY
        end

        def dashboard_app_yml
          <<~YAML
            app_host:
              port: 4569
              host: "0.0.0.0"
              log_format: text
              drain_timeout: 30

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
            require "json"
            require "stringio"

            RSpec.describe #{module_name}::DashboardApp do
              it "renders the overview endpoint" do
                app = described_class.rack_app

                status, headers, body = app.call(
                  "REQUEST_METHOD" => "GET",
                  "PATH_INFO" => "/api/overview",
                  "rack.input" => StringIO.new
                )

                payload = JSON.parse(body.each.to_a.join)

                expect(status).to eq(200)
                expect(headers["Content-Type"]).to include("application/json")
                expect(payload.dig("stack", "default_app")).to eq("main")
                expect(payload.dig("apps", "dashboard", "role")).to eq("admin")
              end
            end
          RUBY
        end

        def shared_stack_overview
          <<~RUBY
            # frozen_string_literal: true

            require "time"

            module #{module_name}
              module Shared
                module StackOverview
                  module_function

                  def build
                    deployment = #{stack_class_name}.deployment_snapshot

                    {
                      generated_at: Time.now.utc.iso8601,
                      stack: {
                        name: #{stack_class_name}.stack_settings.dig("stack", "name"),
                        default_app: deployment.dig("stack", "default_app"),
                        profile: deployment.dig("stack", "topology_profile"),
                        apps: #{stack_class_name}.app_names.map(&:to_s)
                      },
                      apps: deployment.fetch("apps").transform_values do |config|
                        {
                          role: config["role"],
                          public: config["public"],
                          replicas: config["replicas"],
                          port: config.dig("http", "port"),
                          command: config["command"],
                          depends_on: Array(config["depends_on"])
                        }
                      end
                    }
                  end
                end
              end
            end
          RUBY
        end

        def dashboard_home_handler
          <<~RUBY
            # frozen_string_literal: true

            require "igniter/plugins/view"
            require_relative "../shared/stack_overview"
            require_relative "views/home_page"

            module #{module_name}
              module Dashboard
                module HomeHandler
                  module_function

                  def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
                    snapshot = #{module_name}::Shared::StackOverview.build

                    Igniter::Plugins::View::Response.html(Views::HomePage.render(snapshot: snapshot))
                  end
                end
              end
            end
          RUBY
        end

        def dashboard_overview_handler
          <<~RUBY
            # frozen_string_literal: true

            require "json"
            require_relative "../shared/stack_overview"

            module #{module_name}
              module Dashboard
                module OverviewHandler
                  module_function

                  def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
                    {
                      status: 200,
                      body: JSON.generate(#{module_name}::Shared::StackOverview.build),
                      headers: { "Content-Type" => "application/json" }
                    }
                  end
                end
              end
            end
          RUBY
        end

        def dashboard_home_page
          <<~RUBY
            # frozen_string_literal: true

            require "igniter/plugins/view"

            module #{module_name}
              module Dashboard
                module Views
                  class HomePage < Igniter::Plugins::View::Page
                    def self.render(snapshot:)
                      new(snapshot: snapshot).render
                    end

                    def initialize(snapshot:)
                      @snapshot = snapshot
                    end

                    def call(view)
                      render_document(view, title: "#{module_name} Dashboard") do |body|
                        body.tag(:main, class: "shell") do |main|
                          render_hero(main)
                          render_apps(main)
                        end
                      end
                    end

                    private

                    attr_reader :snapshot

                    def yield_head(head)
                      head.tag(:style) { |style| style.raw(stylesheet) }
                    end

                    def render_hero(view)
                      view.tag(:section, class: "hero") do |hero|
                        hero.tag(:h1, "#{module_name} Dashboard")
                        hero.tag(:p, "Minimal multi-app operator surface generated by the playground profile.")
                        hero.tag(:div, class: "meta") do |meta|
                          meta.text("generated=\#{snapshot.fetch(:generated_at)} · ")
                          meta.text("default=\#{snapshot.dig(:stack, :default_app)} · ")
                          meta.text("profile=\#{snapshot.dig(:stack, :profile)}")
                        end
                        hero.tag(:p, class: "links") do |links|
                          links.tag(:a, "Overview API", href: "/api/overview")
                        end
                      end
                    end

                    def render_apps(view)
                      view.tag(:section, class: "grid") do |grid|
                        snapshot.fetch(:apps).each do |name, app|
                          grid.tag(:article, class: "card") do |card|
                            card.tag(:h2, name.to_s)
                            card.tag(:p, "role=\#{app.fetch(:role)}")
                            card.tag(:p, "port=\#{app.fetch(:port)} public=\#{app.fetch(:public)} replicas=\#{app.fetch(:replicas)}")
                            card.tag(:code, app.fetch(:command))
                            unless app.fetch(:depends_on).empty?
                              card.tag(:p, "depends_on=\#{app.fetch(:depends_on).join(", ")}")
                            end
                          end
                        end
                      end
                    end

                    def stylesheet
                      <<~CSS
                        :root {
                          color-scheme: light;
                          --bg: #f3efe6;
                          --ink: #1f2520;
                          --muted: #5a665d;
                          --card: #fffaf2;
                          --line: #d4c9b8;
                          --accent: #2f6c5b;
                        }

                        * { box-sizing: border-box; }
                        body {
                          margin: 0;
                          font-family: "Iowan Old Style", "Palatino Linotype", serif;
                          background:
                            radial-gradient(circle at top left, rgba(47, 108, 91, 0.12), transparent 28rem),
                            linear-gradient(180deg, #f8f4ec 0%, var(--bg) 100%);
                          color: var(--ink);
                        }

                        .shell {
                          width: min(980px, calc(100vw - 32px));
                          margin: 0 auto;
                          padding: 40px 0 64px;
                        }

                        .hero, .card {
                          background: var(--card);
                          border: 1px solid var(--line);
                          border-radius: 20px;
                          box-shadow: 0 18px 40px rgba(31, 37, 32, 0.08);
                        }

                        .hero {
                          padding: 28px;
                          margin-bottom: 24px;
                        }

                        .hero h1, .card h2 {
                          margin: 0 0 12px;
                        }

                        .meta, .links, .card p, .card code {
                          color: var(--muted);
                        }

                        .links a {
                          color: var(--accent);
                          text-decoration: none;
                        }

                        .grid {
                          display: grid;
                          grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
                          gap: 16px;
                        }

                        .card {
                          padding: 20px;
                        }

                        .card code {
                          display: block;
                          white-space: pre-wrap;
                          font-family: "SFMono-Regular", "Menlo", monospace;
                          font-size: 12px;
                        }
                      CSS
                    end
                  end
                end
              end
            end
          RUBY
        end

        def gemfile_with_local_path
          <<~RUBY
            # frozen_string_literal: true

            source "https://rubygems.org"

            gem "igniter", path: "#{relative_path_to_repo_root}"
            gem "sqlite3" # stack-local data + execution stores

            group :development, :test do
              gem "rspec"
            end

            # Optional:
            # gem "puma"   # production HTTP server  →  bundle exec puma config.ru
          RUBY
        end

        def playground_readme
          <<~MARKDOWN
            # #{module_name} Playground

            This scaffold was generated with the `playground` profile on top of the
            base Igniter stack generator.

            It intentionally starts with a small proving slice:

            - `main` as the API surface
            - `dashboard` as the operator surface
            - shared stack snapshot wiring between them

            ## Bootstrapping

            ```bash
            bundle install
            ruby bin/demo
            bin/start
            bin/start dashboard
            bin/dev
            ```

            Use this playground to evolve the stack in thin vertical slices rather than
            copying a whole production-shaped system up front.
          MARKDOWN
        end
      end
    end
  end
end
