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
          write "stack.yml", stack_yml
          write "spec/stack_spec.rb", stack_spec
          write "lib/#{namespace_path}/shared/stack_overview.rb", shared_stack_overview
          write "lib/#{namespace_path}/shared/note_store.rb", shared_note_store
        end

        def expand_main_surface
          write "apps/main/app.rb", main_app_rb
          write "apps/main/spec/main_app_spec.rb", main_app_spec
          write "lib/#{namespace_path}/main/status_handler.rb", main_status_handler
          write "lib/#{namespace_path}/main/notes_list_handler.rb", main_notes_list_handler
          write "lib/#{namespace_path}/main/notes_create_handler.rb", main_notes_create_handler
        end

        def add_dashboard_app
          write "apps/dashboard/app.rb", dashboard_app_rb
          write "apps/dashboard/app.yml", dashboard_app_yml
          write "apps/dashboard/spec/spec_helper.rb", dashboard_spec_helper
          write "apps/dashboard/spec/dashboard_app_spec.rb", dashboard_app_spec
          write "lib/#{namespace_path}/dashboard/home_handler.rb", dashboard_home_handler
          write "lib/#{namespace_path}/dashboard/notes_create_handler.rb", dashboard_notes_create_handler
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

        def project_label
          project_name.split(/[^a-zA-Z0-9]+/).reject(&:empty?).map(&:capitalize).join(" ")
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
              mount :dashboard, at: "/dashboard"
            end
          end

            if $PROGRAM_NAME == __FILE__
              #{stack_class_name}.start_cli(ARGV)
            end
          RUBY
        end

        def stack_yml
          <<~YAML
            stack:
              name: #{project_name}
              root_app: main
              default_node: main
              shared_lib_paths:
                - lib

            server:
              host: 0.0.0.0

            nodes:
              main:
                role: playground
                port: 4567
                public: true
            persistence:
              data:
                adapter: sqlite
                path: var/#{project_name}_data.sqlite3
          YAML
        end

        def stack_spec
          <<~RUBY
            # frozen_string_literal: true

            require_relative "spec_helper"

            RSpec.describe #{stack_class_name} do
              it "registers main and dashboard apps with a mounted stack runtime" do
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

        def main_app_rb
          <<~RUBY
            # frozen_string_literal: true

            require "igniter/app"
            require "igniter/core"
            require_relative "../../lib/#{namespace_path}/main/status_handler"
            require_relative "../../lib/#{namespace_path}/main/notes_list_handler"
            require_relative "../../lib/#{namespace_path}/main/notes_create_handler"

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
                route "GET", "/v1/notes", with: #{module_name}::Main::NotesListHandler
                route "POST", "/v1/notes", with: #{module_name}::Main::NotesCreateHandler

                on_boot do
                  register "GreetContract", #{module_name}::GreetContract
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
              before do
                #{module_name}::Shared::NoteStore.reset!
              end

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
                expect(payload.dig("stack", "root_app")).to eq("main")
                expect(payload.dig("stack", "default_node")).to eq("main")
                expect(payload.dig("nodes", "main", "mounts", "dashboard")).to eq("/dashboard")
                expect(payload.dig("counts", "notes")).to eq(0)
              end

              it "creates and lists shared notes" do
                app = described_class.rack_app

                create_status, create_headers, create_body = app.call(
                  "REQUEST_METHOD" => "POST",
                  "PATH_INFO" => "/v1/notes",
                  "CONTENT_TYPE" => "application/json",
                  "rack.input" => StringIO.new(JSON.generate(text: "Check UPS battery"))
                )

                created = JSON.parse(create_body.each.to_a.join)

                list_status, list_headers, list_body = app.call(
                  "REQUEST_METHOD" => "GET",
                  "PATH_INFO" => "/v1/notes",
                  "rack.input" => StringIO.new
                )

                listed = JSON.parse(list_body.each.to_a.join)

                expect(create_status).to eq(201)
                expect(create_headers["Content-Type"]).to include("application/json")
                expect(created.dig("note", "text")).to eq("Check UPS battery")
                expect(created["count"]).to eq(1)
                expect(list_status).to eq(200)
                expect(list_headers["Content-Type"]).to include("application/json")
                expect(listed["count"]).to eq(1)
                expect(listed.dig("notes", 0, "text")).to eq("Check UPS battery")
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
                        apps: snapshot.fetch(:apps),
                        nodes: snapshot.fetch(:nodes),
                        counts: snapshot.fetch(:counts),
                        notes: snapshot.fetch(:notes)
                      ),
                      headers: { "Content-Type" => "application/json" }
                    }
                  end
                end
              end
            end
          RUBY
        end

        def main_notes_list_handler
          <<~RUBY
            # frozen_string_literal: true

            require "json"
            require_relative "../shared/note_store"

            module #{module_name}
              module Main
                module NotesListHandler
                  module_function

                  def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
                    notes = #{module_name}::Shared::NoteStore.all

                    {
                      status: 200,
                      body: JSON.generate(
                        count: notes.size,
                        notes: notes
                      ),
                      headers: { "Content-Type" => "application/json" }
                    }
                  end
                end
              end
            end
          RUBY
        end

        def main_notes_create_handler
          <<~RUBY
            # frozen_string_literal: true

            require "json"
            require_relative "../shared/note_store"

            module #{module_name}
              module Main
                module NotesCreateHandler
                  module_function

                  def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
                    text = body.fetch("text", body.fetch("note", "")).to_s.strip

                    if text.empty?
                      return {
                        status: 422,
                        body: JSON.generate(error: "text is required"),
                        headers: { "Content-Type" => "application/json" }
                      }
                    end

                    note = #{module_name}::Shared::NoteStore.add(text, source: "main")

                    {
                      status: 201,
                      body: JSON.generate(
                        ok: true,
                        note: note,
                        count: #{module_name}::Shared::NoteStore.count
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
            require_relative "../../lib/#{namespace_path}/dashboard/notes_create_handler"

            module #{module_name}
              class DashboardApp < Igniter::App
                root_dir __dir__
                config_file "app.yml"

                route "GET", "/", with: #{module_name}::Dashboard::HomeHandler
                route "GET", "/api/overview", with: #{module_name}::Dashboard::OverviewHandler
                route "POST", "/notes", with: #{module_name}::Dashboard::NotesCreateHandler
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
            require "json"
            require "stringio"
            require "uri"

            RSpec.describe #{module_name}::DashboardApp do
              before do
                #{module_name}::Shared::NoteStore.reset!
              end

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
                expect(payload.dig("stack", "root_app")).to eq("main")
                expect(payload.dig("stack", "default_node")).to eq("main")
                expect(payload.dig("nodes", "main", "mounts", "dashboard")).to eq("/dashboard")
                expect(payload.dig("counts", "notes")).to eq(0)
              end

              it "renders the home page" do
                app = described_class.rack_app

                status, headers, body = app.call(
                  "REQUEST_METHOD" => "GET",
                  "PATH_INFO" => "/",
                  "rack.input" => StringIO.new
                )

                html = body.each.to_a.join

                expect(status).to eq(200)
                expect(headers["Content-Type"]).to include("text/html")
                expect(html).to include("#{project_label} Dashboard")
                expect(html).to include("Overview API")
                expect(html).to include('action="/notes"')
                expect(html).to include("Shared Notes")
              end

              it "creates a note from the dashboard form and exposes it in the overview" do
                app = described_class.rack_app

                create_status, create_headers, = app.call(
                  "REQUEST_METHOD" => "POST",
                  "PATH_INFO" => "/notes",
                  "CONTENT_TYPE" => "application/x-www-form-urlencoded",
                  "rack.input" => StringIO.new(URI.encode_www_form("text" => "Top off the UPS rack"))
                )

                overview_status, overview_headers, overview_body = app.call(
                  "REQUEST_METHOD" => "GET",
                  "PATH_INFO" => "/api/overview",
                  "rack.input" => StringIO.new
                )

                payload = JSON.parse(overview_body.each.to_a.join)

                expect(create_status).to eq(303)
                expect(create_headers["Location"]).to eq("/?note_created=1")
                expect(overview_status).to eq(200)
                expect(overview_headers["Content-Type"]).to include("application/json")
                expect(payload.dig("counts", "notes")).to eq(1)
                expect(payload.dig("notes", 0, "text")).to eq("Top off the UPS rack")
              end
            end
          RUBY
        end

        def shared_stack_overview
          <<~RUBY
            # frozen_string_literal: true

            require "time"
            require_relative "note_store"

            module #{module_name}
              module Shared
                module StackOverview
                  module_function

                  def build
                    deployment = #{stack_class_name}.deployment_snapshot
                    notes = #{module_name}::Shared::NoteStore.all
                    nodes = deployment.fetch("nodes").transform_values do |config|
                      {
                        role: config["role"],
                        public: config["public"],
                        port: config["port"],
                        host: config["host"],
                        command: config["command"],
                        mounts: config.fetch("mounts", {})
                      }
                    end

                    {
                      generated_at: Time.now.utc.iso8601,
                      stack: {
                        name: #{stack_class_name}.stack_settings.dig("stack", "name"),
                        root_app: deployment.dig("stack", "root_app"),
                        default_node: deployment.dig("stack", "default_node"),
                        mounts: deployment.dig("stack", "mounts"),
                        apps: #{stack_class_name}.app_names.map(&:to_s)
                      },
                      counts: {
                        apps: #{stack_class_name}.app_names.size,
                        nodes: nodes.size,
                        notes: notes.size
                      },
                      notes: notes.first(8),
                      nodes: nodes,
                      apps: deployment.fetch("apps").transform_values do |config|
                        {
                          path: config["path"],
                          class_name: config["class_name"],
                          default: config["default"]
                        }
                      end
                    }
                  end
                end
              end
            end
          RUBY
        end

        def shared_note_store
          <<~RUBY
            # frozen_string_literal: true

            require "igniter/sdk/data"
            require "time"

            module #{module_name}
              module Shared
                module NoteStore
                  COLLECTION = "#{namespace_path}_notes"

                  class << self
                    def add(text, source: "operator")
                      entry = {
                        "id" => "#{namespace_path}-\#{Time.now.utc.strftime("%Y%m%d%H%M%S%6N")}",
                        "text" => text.to_s.strip,
                        "source" => source.to_s,
                        "created_at" => Time.now.utc.iso8601
                      }

                      store.put(collection: COLLECTION, key: entry.fetch("id"), value: entry)
                      entry
                    end

                    def all
                      store
                        .all(collection: COLLECTION)
                        .values
                        .sort_by { |entry| entry.fetch("created_at", "") }
                        .reverse
                    end

                    def count
                      all.size
                    end

                    def reset!
                      store.clear(collection: COLLECTION)
                    end

                    private

                    def store
                      @store ||= Igniter::Data::Stores::File.new(path: File.expand_path("../../../var/notes.json", __dir__))
                    end
                  end
                end
              end
            end
          RUBY
        end

        def dashboard_home_handler
          <<~RUBY
            # frozen_string_literal: true

            require "igniter-frontend"
            require_relative "../shared/stack_overview"
            require_relative "views/home_page"

            module #{module_name}
              module Dashboard
                module HomeHandler
                  module_function

                  def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
                    snapshot = #{module_name}::Shared::StackOverview.build

                    Igniter::Frontend::Response.html(
                      Views::HomePage.render(
                        snapshot: snapshot,
                        base_path: base_path_for(env)
                      )
                    )
                  end

                  def base_path_for(env)
                    env["SCRIPT_NAME"].to_s.sub(%r{/+\z}, "")
                  end
                end
              end
            end
          RUBY
        end

        def dashboard_notes_create_handler
          <<~RUBY
            # frozen_string_literal: true

            require "igniter-frontend"
            require_relative "../shared/note_store"
            require_relative "../shared/stack_overview"
            require_relative "views/home_page"

            module #{module_name}
              module Dashboard
                module NotesCreateHandler
                  module_function

                  def call(params:, body:, headers:, env:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
                    text = body.fetch("text", body.fetch("note", "")).to_s.strip
                    base_path = base_path_for(env)

                    if text.empty?
                      snapshot = #{module_name}::Shared::StackOverview.build
                      html = Views::HomePage.render(
                        snapshot: snapshot,
                        error_message: "Note text cannot be blank.",
                        form_values: body,
                        base_path: base_path
                      )
                      return Igniter::Frontend::Response.html(html, status: 422)
                    end

                    #{module_name}::Shared::NoteStore.add(text, source: "dashboard")
                    location = [base_path, ""].reject(&:empty?).join("/") + "/?note_created=1"

                    {
                      status: 303,
                      body: "",
                      headers: { "Location" => location }
                    }
                  end

                  def base_path_for(env)
                    env["SCRIPT_NAME"].to_s.sub(%r{/+\z}, "")
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

            require "igniter-frontend"

            module #{module_name}
              module Dashboard
                module Views
                  class HomePage < Igniter::Frontend::Page
                    def self.render(snapshot:, error_message: nil, form_values: {}, base_path: "")
                      new(
                        snapshot: snapshot,
                        error_message: error_message,
                        form_values: form_values,
                        base_path: base_path
                      ).render
                    end

                    def initialize(snapshot:, error_message:, form_values:, base_path:)
                      @snapshot = snapshot
                      @error_message = error_message
                      @form_values = form_values
                      @base_path = base_path
                    end

                    def call(view)
                      render_document(view, title: "#{project_label} Dashboard") do |body|
                        body.tag(:main, class: "shell") do |main|
                          render_hero(main)
                          render_metrics(main)
                          render_notes(main)
                          render_apps(main)
                        end
                      end
                    end

                    private

                    attr_reader :snapshot
                    attr_reader :error_message
                    attr_reader :form_values
                    attr_reader :base_path

                    def yield_head(head)
                      head.tag(:style) { |style| style.raw(stylesheet) }
                    end

                    def render_hero(view)
                      view.tag(:section, class: "hero") do |hero|
                        hero.tag(:h1, "#{project_label} Dashboard")
                        hero.tag(:p, "Fresh proving ground for the rebuilt Igniter stack model.")
                        hero.tag(:div, class: "meta") do |meta|
                          meta.text("generated=\#{snapshot.fetch(:generated_at)} · ")
                          meta.text("root=\#{snapshot.dig(:stack, :root_app)} · ")
                          meta.text("node=\#{snapshot.dig(:stack, :default_node)}")
                        end
                        hero.tag(:p, class: "links") do |links|
                          links.tag(:a, "Overview API", href: route("/api/overview"))
                          links.text(" · ")
                          links.tag(:a, "Main status", href: "/v1/home/status")
                        end
                      end
                    end

                    def render_metrics(view)
                      counts = snapshot.fetch(:counts)

                      view.tag(:section, class: "metrics") do |section|
                        section.tag(:article, class: "metric-card") do |card|
                          card.tag(:span, "Apps", class: "metric-label")
                          card.tag(:strong, snapshot.dig(:stack, :apps).size.to_s, class: "metric-value")
                        end

                        section.tag(:article, class: "metric-card") do |card|
                          card.tag(:span, "Nodes", class: "metric-label")
                          card.tag(:strong, counts.fetch(:nodes).to_s, class: "metric-value")
                        end

                        section.tag(:article, class: "metric-card") do |card|
                          card.tag(:span, "Notes", class: "metric-label")
                          card.tag(:strong, counts.fetch(:notes).to_s, class: "metric-value")
                        end
                      end
                    end

                    def render_notes(view)
                      notes = snapshot.fetch(:notes)

                      view.tag(:section, class: "notes-panel") do |section|
                        section.tag(:div, class: "panel-head") do |head|
                          head.tag(:h2, "Shared Notes")
                          head.tag(:p, "Simple cross-app proving slice shared by main and dashboard.")
                        end

                        if error_message
                          section.tag(:p, error_message, class: "error-banner")
                        end

                        section.form(action: route("/notes"), method: "post", class: "stacked-form") do |form|
                          form.label("note-text", "Add note")
                          form.textarea("text",
                                        id: "note-text",
                                        rows: 3,
                                        placeholder: "Capture a lab observation or operator todo",
                                        value: form_values.fetch("text", ""))
                          form.submit("Save Note")
                        end

                        if notes.empty?
                          section.tag(:p, "No notes saved yet.", class: "empty-state")
                        else
                          section.tag(:ul, class: "notes-list") do |list|
                            notes.each do |note|
                              list.tag(:li) do |item|
                                item.tag(:strong, note.fetch("text"))
                                item.tag(:div, class: "note-meta") do |meta|
                                  meta.text("source=\#{note.fetch("source")} · created=\#{note.fetch("created_at")}")
                                end
                              end
                            end
                          end
                        end
                      end
                    end

                    def render_apps(view)
                      view.tag(:section, class: "grid") do |grid|
                        snapshot.fetch(:nodes).each do |name, service|
                          grid.tag(:article, class: "card") do |card|
                            card.tag(:h2, name.to_s)
                            card.tag(:p, "role=\#{service.fetch(:role)}")
                            card.tag(:p, "host=\#{service.fetch(:host)} port=\#{service.fetch(:port)} public=\#{service.fetch(:public)}")
                            mounts = service.fetch(:mounts)
                            unless mounts.empty?
                              card.tag(:p, "mounts=\#{mounts.map { |app, mount| "\#{app}: \#{mount}" }.join(", ")}")
                            end
                            card.tag(:code, service.fetch(:command))
                          end
                        end
                      end
                    end

                    def route(path)
                      prefix = base_path.to_s
                      return path if prefix.empty?

                      [prefix, path.sub(%r{\\A/}, "")].join("/")
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

                        .hero, .card, .notes-panel, .metric-card {
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

                        .meta, .links, .card p, .card code, .panel-head p, .note-meta, .metric-label {
                          color: var(--muted);
                        }

                        .links a {
                          color: var(--accent);
                          text-decoration: none;
                        }

                        .metrics {
                          display: grid;
                          grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                          gap: 16px;
                          margin-bottom: 24px;
                        }

                        .metric-card {
                          padding: 20px;
                        }

                        .metric-label, .metric-value {
                          display: block;
                        }

                        .metric-value {
                          margin-top: 8px;
                          font-size: 32px;
                        }

                        .notes-panel {
                          padding: 24px;
                          margin-bottom: 24px;
                        }

                        .panel-head h2, .panel-head p {
                          margin: 0 0 10px;
                        }

                        .stacked-form label,
                        .stacked-form textarea,
                        .stacked-form button {
                          display: block;
                          width: 100%;
                        }

                        .stacked-form label {
                          margin-bottom: 8px;
                        }

                        .stacked-form textarea {
                          min-height: 96px;
                          margin-bottom: 12px;
                          padding: 12px;
                          border-radius: 12px;
                          border: 1px solid var(--line);
                          background: #fffdf8;
                          font: inherit;
                          color: inherit;
                        }

                        .stacked-form button {
                          max-width: 220px;
                          padding: 12px 16px;
                          border: 0;
                          border-radius: 999px;
                          background: var(--accent);
                          color: white;
                          cursor: pointer;
                          font: inherit;
                        }

                        .error-banner {
                          margin: 0 0 16px;
                          padding: 12px 14px;
                          border-radius: 12px;
                          background: #fff0e8;
                          color: #8a3d1f;
                        }

                        .empty-state {
                          margin: 16px 0 0;
                        }

                        .notes-list {
                          margin: 18px 0 0;
                          padding-left: 20px;
                        }

                        .notes-list li + li {
                          margin-top: 12px;
                        }

                        .note-meta {
                          margin-top: 4px;
                          font-size: 14px;
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
            gem "igniter-core", path: "#{relative_path_to_repo_root}/packages/igniter-core"
            gem "igniter-sdk", path: "#{relative_path_to_repo_root}/packages/igniter-sdk"
            gem "igniter-app", path: "#{relative_path_to_repo_root}/packages/igniter-app"
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
            # #{project_label} Playground

            `#{@name}` was generated with the `playground` profile on top of the
            base Igniter stack generator.

            It starts with a small proving slice:

            - `main` as the operator-facing API surface
            - `dashboard` as the minimal admin surface
            - one shared stack snapshot feeding both apps
            - one shared notes flow proving simple cross-app persistence

            ## Bootstrapping

            ```bash
            cd #{@name}
            bundle install
            ruby bin/demo
            bin/console
            bin/start
            bin/start --node main
            bin/dev
            ```

            `bin/dev` also writes per-node logs to `var/log/dev/*.log`.

            Then open:

            - API status: `http://127.0.0.1:4567/v1/home/status`
            - dashboard: `http://127.0.0.1:4567/dashboard`

            ## Current Direction

            Use this playground to evolve the stack in thin vertical slices rather than
            copying a whole production-shaped system up front.

            A good next move is to port one real capability at a time from a legacy
            playground or experiment:

            1. one mounted app flow
            2. one device or channel edge
            3. one operator/dashboard surface
            4. one cluster-facing capability
          MARKDOWN
        end
      end
    end
  end
end
