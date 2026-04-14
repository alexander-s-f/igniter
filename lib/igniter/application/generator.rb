# frozen_string_literal: true

require "fileutils"

module Igniter
  class Application
    # Generates a new Igniter workspace scaffold.
    # Invoked via: igniter-server new my_app
    #
    # Creates:
    #   my_app/
    #   ├── apps/
    #   │   └── main/
    #   │       ├── app/
    #   │       │   ├── contracts/     — Contract subclasses
    #   │       │   ├── executors/     — Executor subclasses
    #   │       │   ├── tools/         — optional Tool subclasses
    #   │       │   ├── agents/        — optional Agent subclasses
    #   │       │   └── skills/        — optional Skill subclasses
    #   │       ├── spec/              — app-local specs
    #   │       ├── application.rb     — leaf Igniter::Application
    #   │       └── application.yml    — app-local server config
    #   ├── lib/<project>/shared/      — shared libraries / helpers
    #   ├── config/
    #   │   ├── topology.yml           — deployment roles + wiring
    #   │   ├── environments/          — environment overlays
    #   │   └── deploy/                — operational artifacts (Docker / Compose / etc.)
    #   ├── spec/                      — shared + integration + workspace-level specs
    #   ├── bin/
    #   │   ├── start                  — Launch a named app (default: main)
    #   │   └── demo                   — Run a quick demo (no server needed)
    #   ├── workspace.rb               — Workspace coordinator
    #   ├── workspace.yml              — Workspace metadata
    #   ├── Gemfile
    #   └── config.ru                  — Rack entry point (defaults to main)
    class Generator
      def initialize(name, minimal: false)
        @name    = name.to_s.strip
        @minimal = minimal
        raise ArgumentError, "App name cannot be blank" if @name.empty?

        @dir = @name
        @project_name = File.basename(@dir)
      end

      def generate # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        create_dir ""
        create_dir "apps/main/app/contracts"
        create_dir "apps/main/app/executors"
        create_dir "apps/main/app/tools"
        create_dir "apps/main/app/agents"
        create_dir "apps/main/app/skills"
        create_dir "apps/main/spec"
        create_dir "lib/#{namespace_path}/shared"
        create_dir "config/environments"
        create_dir "config/deploy"
        create_dir "spec"
        create_dir "bin"

        write "workspace.rb",                  workspace_rb
        write "workspace.yml",                 workspace_yml
        write "config/topology.yml",           topology_yml
        write "config/environments/development.yml", development_yml
        write "config/environments/production.yml",  production_yml
        write "config/deploy/.keep",           ""
        write "config/deploy/Procfile.dev",    procfile_dev
        write "Gemfile",                       gemfile
        write "config.ru",                     config_ru
        write "bin/start",                     bin_start
        write "bin/dev",                       bin_dev
        write "spec/spec_helper.rb",           root_spec_helper
        write "spec/workspace_spec.rb",        workspace_spec
        write "apps/main/spec/spec_helper.rb", main_spec_helper
        write "apps/main/application.rb",      main_application_rb
        write "apps/main/application.yml",     main_application_yml
        write "lib/#{namespace_path}/shared/.keep", ""

        if @minimal
          write "apps/main/app/executors/.keep", ""
          write "apps/main/app/contracts/.keep", ""
          write "apps/main/app/tools/.keep",     ""
          write "apps/main/app/agents/.keep",    ""
          write "apps/main/app/skills/.keep",    ""
          write "bin/demo",                      bin_demo_stub
        else
          write "bin/demo",                                     bin_demo
          write "apps/main/spec/main_app_spec.rb",              main_app_spec
          write "apps/main/app/executors/greeter.rb",           executor_greeter
          write "apps/main/app/contracts/greet_contract.rb",    contract_greet
          write "apps/main/app/tools/greet_tool.rb",            tool_greet
          write "apps/main/app/agents/host_agent.rb",           agent_host
          write "apps/main/app/skills/concierge_skill.rb",      skill_concierge
        end

        FileUtils.chmod(0o755, path("bin/start"))
        FileUtils.chmod(0o755, path("bin/dev"))
        FileUtils.chmod(0o755, path("bin/demo"))

        puts
        puts "  Done! Your #{module_name} workspace is ready."
        puts
        puts "  Next steps:"
        puts "    cd #{@name}"
        puts "    bundle install"
        unless @minimal
          puts "    ruby bin/demo      # ← see it work immediately"
        end
        puts "    bin/start          # ← launch apps/main"
        puts "    bin/dev            # ← launch the whole workspace locally"
        puts "    bin/start main     # ← explicit app selection"
        puts
        puts "  Production (Puma):"
        puts "    bundle add puma && bundle exec puma config.ru"
        puts
      end

      private

      def path(rel) = File.join(@dir, rel)

      def create_dir(rel)
        full = rel.empty? ? @dir : path(rel)
        FileUtils.mkdir_p(full)
        puts "  create  #{full}/"
      end

      def write(rel, content)
        full = path(rel)
        File.write(full, content)
        puts "  create  #{full}"
      end

      def module_name
        @project_name.split(/[^a-zA-Z0-9]+/).reject(&:empty?).map(&:capitalize).join
      end

      def namespace_path
        @project_name.strip.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
      end

      def workspace_class_name
        "#{module_name}::Workspace"
      end

      # ─── workspace.rb (workspace coordinator) ────────────────────────────────

      def workspace_rb
        <<~RUBY
          # frozen_string_literal: true

          require "igniter/workspace"
          require_relative "apps/main/application"

          module #{module_name}
            class Workspace < Igniter::Workspace
              root_dir __dir__
              shared_lib_path "lib"

              app :main, path: "apps/main", klass: #{module_name}::MainApp, default: true
            end
          end

          if $PROGRAM_NAME == __FILE__
            #{workspace_class_name}.start_cli(ARGV)
          end
        RUBY
      end

      # ─── workspace.yml (workspace metadata) ──────────────────────────────────

      def workspace_yml
        <<~YAML
          workspace:
            default_app: main
            shared_lib_paths:
              - lib

          persistence:
            data:
              adapter: memory   # memory | sqlite
              path: var/#{@project_name}_data.sqlite3
        YAML
      end

      def topology_yml
        <<~YAML
          workspace:
            name: #{@project_name}
            default_app: main

          topology:
            profile: local
            notes:
              - "apps/ define code roles; this file describes deployment roles and wiring"

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
              command: bundle exec ruby workspace.rb main

          shared:
            persistence:
              data:
                adapter: sqlite
                path: var/#{@project_name}_data.sqlite3
        YAML
      end

      def development_yml
        <<~YAML
          workspace:
            environment: development

          topology:
            profile: development
            apps:
              main:
                replicas: 1
        YAML
      end

      def production_yml
        <<~YAML
          workspace:
            environment: production

          topology:
            profile: production
            apps:
              main:
                replicas: 2
        YAML
      end

      # ─── apps/main/application.rb ───────────────────────────────────────────

      def main_application_rb
        <<~RUBY
          # frozen_string_literal: true

          require "igniter/app"
          require "igniter/core"

          module #{module_name}
            class MainApp < Igniter::Application
              root_dir __dir__
              config_file "application.yml"

              # Eagerly load app code in dependency order.
              tools_path     "app/tools"
              skills_path    "app/skills"
              executors_path "app/executors"
              contracts_path "app/contracts"
              agents_path    "app/agents"

              on_boot do
                register "GreetContract", #{module_name}::GreetContract
              end

              configure do |c|
                # c.server_host.port = ENV.fetch("PORT", 4567).to_i
                # c.store            = Igniter::Runtime::Stores::MemoryStore.new
              end

              # schedule :heartbeat, every: "30s" do
              #   puts "[heartbeat] \#{Time.now.strftime("%H:%M:%S")}"
              # end
            end
          end
        RUBY
      end

      # ─── apps/main/application.yml ──────────────────────────────────────────

      def main_application_yml
        <<~YAML
          server_host:
            port: 4567
            host: "0.0.0.0"
            log_format: text   # text | json
            drain_timeout: 30

          persistence:
            execution:
              adapter: memory   # memory | sqlite | redis
              path: var/main_executions.sqlite3
        YAML
      end

      # ─── Gemfile ─────────────────────────────────────────────────────────────

      def gemfile
        <<~RUBY
          # frozen_string_literal: true

          source "https://rubygems.org"

          gem "igniter"
          gem "sqlite3" # workspace-local data + execution stores

          group :development, :test do
            gem "rspec"
          end

          # Optional:
          # gem "puma"   # production HTTP server  →  bundle exec puma config.ru
        RUBY
      end

      # ─── config.ru ───────────────────────────────────────────────────────────

      def config_ru
        <<~RUBY
          # frozen_string_literal: true
          # Rack entry point — use with Puma or any Rack-compatible server.
          #   bundle exec puma config.ru

          require_relative "workspace"

          run #{workspace_class_name}.rack_app(ENV.fetch("IGNITER_APP", "main"))
        RUBY
      end

      # ─── bin/start ───────────────────────────────────────────────────────────

      def bin_start
        <<~BASH
          #!/usr/bin/env bash
          set -e
          cd "$(dirname "$0")/.."

          exec bundle exec ruby workspace.rb "$@"
        BASH
      end

      def bin_dev
        <<~BASH
          #!/usr/bin/env bash
          set -e
          cd "$(dirname "$0")/.."

          exec bundle exec ruby workspace.rb --dev "$@"
        BASH
      end

      # ─── bin/demo ────────────────────────────────────────────────────────────

      def bin_demo
        <<~RUBY
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          # Quick demo — no server needed. Run: ruby bin/demo

          root = File.expand_path("..", __dir__)
          $LOAD_PATH.unshift(File.join(root, "lib"))
          Dir.chdir(root)

          require "igniter"
          require "igniter/core"
          require_relative "../apps/main/application"

          %w[tools skills executors contracts agents].each do |dir|
            Dir[File.join(root, "apps/main/app/\#{dir}/**/*.rb")].sort.each { |f| require f }
          end

          hr = "─" * 48

          puts
          puts "  \#{hr}"
          puts "  #{module_name} Workspace  ·  apps/main powered by Igniter ⚡"
          puts "  \#{hr}"
          puts

          puts "1 · Contract — validated dependency graph"
          greeting = #{module_name}::GreetContract.new(name: "Alice").result.greeting
          puts "  ➜  \#{greeting[:message]}"
          puts "     resolved at \#{greeting[:greeted_at]}"
          puts

          puts "2 · Agent — stateful actor"
          ref = #{module_name}::HostAgent.start
          ref.call(:greet, { name: "Bob" })
          ref.call(:greet, { name: "Carol" })
          stats = ref.call(:stats)
          puts "  ➜  Greeted \#{stats.total} visitors: \#{stats.recent.map { |v| v[:name] }.join(", ")}"
          ref.stop
          puts

          puts "3 · Tool — LLM-callable (Anthropic / OpenAI compatible)"
          schema = #{module_name}::GreetTool.to_schema
          params = schema[:parameters]["properties"].keys.join(", ")
          puts "  ➜  \#{schema[:name]}(\#{params}) — \#{schema[:description]}"
          puts

          puts "4 · Skill — LLM reasoning loop (stub — add API key to activate)"
          puts "  ➜  See apps/main/app/skills/concierge_skill.rb"
          puts

          puts "  \#{hr}"
          puts "  Run  bin/start       →  start apps/main"
          puts "  Run  bin/dev         →  start the whole workspace locally"
          puts "  Run  bin/start main  →  explicit app selection"
          puts "  \#{hr}"
          puts
        RUBY
      end

      # ─── bin/demo stub (minimal mode) ────────────────────────────────────────

      def bin_demo_stub
        <<~RUBY
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          # Replace this stub with your own demo script.
          # See examples/companion/bin/demo for a full example.
          puts "#{module_name} workspace — add your demo code here."
          puts "Run  bin/start       →  start apps/main"
          puts "Run  bin/dev         →  start the whole workspace locally"
          puts "Run  bin/start main  →  explicit app selection"
        RUBY
      end

      def procfile_dev
        <<~TEXT
          main: IGNITER_APP=main PORT=4567 bundle exec ruby workspace.rb main
        TEXT
      end

      # ─── spec/spec_helper.rb ───────────────────────────────────────────────

      def root_spec_helper
        <<~RUBY
          # frozen_string_literal: true

          require "rspec"
          require_relative "../workspace"

          #{workspace_class_name}.setup_load_paths!

          RSpec.configure do |config|
            config.disable_monkey_patching!
            config.expect_with(:rspec) { |c| c.syntax = :expect }
          end
        RUBY
      end

      # ─── spec/workspace_spec.rb ────────────────────────────────────────────

      def workspace_spec
        <<~RUBY
          # frozen_string_literal: true

          require_relative "spec_helper"

          RSpec.describe #{workspace_class_name} do
            it "registers apps/main as the default app" do
              expect(described_class.default_app).to eq(:main)
              expect(described_class.application(:main)).to be(#{module_name}::MainApp)
            end
          end
        RUBY
      end

      # ─── apps/main/spec/spec_helper.rb ─────────────────────────────────────

      def main_spec_helper
        <<~RUBY
          # frozen_string_literal: true

          require_relative "../../../spec/spec_helper"

          #{module_name}::MainApp.send(:build!)
        RUBY
      end

      # ─── apps/main/spec/main_app_spec.rb ───────────────────────────────────

      def main_app_spec
        <<~RUBY
          # frozen_string_literal: true

          require_relative "spec_helper"

          RSpec.describe #{module_name}::MainApp do
            it "builds and registers the greet contract" do
              config = described_class.send(:build!)
              expect(config.registry.registered?("GreetContract")).to be(true)
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

      # ─── apps/main/app/executors/greeter.rb ────────────────────────────────

      def executor_greeter
        <<~RUBY
          # frozen_string_literal: true

          module #{module_name}
            # A pure function: given inputs, produce an output. No side effects.
            # Executors are the leaf nodes in a Contract dependency graph.
            class Greeter < Igniter::Executor
              def call(name:)
                { message: "Hello, \#{name}!", greeted_at: Time.now.iso8601 }
              end
            end
          end
        RUBY
      end

      # ─── apps/main/app/contracts/greet_contract.rb ─────────────────────────

      def contract_greet
        <<~RUBY
          # frozen_string_literal: true

          module #{module_name}
            # A Contract declares business logic as a validated dependency graph.
            # Igniter resolves execution order and validates edges at compile time.
            class GreetContract < Igniter::Contract
              define do
                input  :name
                compute :greeting, depends_on: :name, call: #{module_name}::Greeter
                output :greeting
              end
            end
          end
        RUBY
      end

      # ─── apps/main/app/tools/greet_tool.rb ─────────────────────────────────

      def tool_greet
        <<~RUBY
          # frozen_string_literal: true

          module #{module_name}
            # A Tool wraps an Executor with LLM-friendly metadata.
            # Any LLM (Anthropic, OpenAI) can call this via function-calling —
            # the schema is generated automatically from the param declarations.
            class GreetTool < Igniter::Tool
              description "Greet a person by name and return a welcome message"

              param :name, type: :string, required: true, desc: "The person's name"

              def call(name:)
                #{module_name}::GreetContract.new(name:).result.greeting
              end
            end
          end
        RUBY
      end

      # ─── apps/main/app/agents/host_agent.rb ────────────────────────────────

      def agent_host
        <<~RUBY
          # frozen_string_literal: true

          module #{module_name}
            # An Agent is a stateful actor — it holds state between messages and
            # processes them sequentially in its own thread.
            #
            # Handlers that return a Hash  → async state transition (no reply).
            # Handlers that return non-Hash → sync query, value sent back to caller.
            class HostAgent < Igniter::Agent
              Stats = Struct.new(:total, :recent, keyword_init: true)

              initial_state visitors: [], count: 0

              on :greet do |state:, payload:|
                name     = payload.fetch(:name, "stranger")
                greeting = #{module_name}::GreetContract.new(name:).result.greeting
                puts "  [HostAgent] \#{greeting[:message]}"

                state.merge(
                  visitors: (state[:visitors] + [{ name: name, at: Time.now.iso8601 }]).last(10),
                  count:    state[:count] + 1
                )
              end

              on :stats do |state:, **|
                Stats.new(total: state[:count], recent: state[:visitors].last(3))
              end
            end
          end
        RUBY
      end

      # ─── apps/main/app/skills/concierge_skill.rb ───────────────────────────

      def skill_concierge
        <<~RUBY
          # frozen_string_literal: true

          module #{module_name}
            # A Skill is a full LLM reasoning loop with access to your Tools.
            # Unlike a single Tool call, a Skill plans, reasons, and uses tools
            # iteratively until the task is complete.
            #
            # To activate:
            #   1. Add your API key: export ANTHROPIC_API_KEY=sk-ant-...
            #   2. Uncomment the code below.
            #   3. Add require "igniter/ai" to apps/main/application.rb.
            #
            # require "igniter/ai"
            #
            # class ConciergeSkill < Igniter::AI::Skill
            #   description "An AI concierge that greets visitors and answers questions"
            #
            #   param :request, type: :string, required: true, desc: "The visitor's request"
            #
            #   provider :anthropic           # or :openai, :ollama
            #   model    "claude-haiku-4-5-20251001"
            #   tools    #{module_name}::GreetTool
            #
            #   system_prompt <<~PROMPT
            #     You are a friendly concierge. Help visitors feel welcome.
            #     Use the greet_tool to greet people by name.
            #   PROMPT
            #
            #   def call(request:)
            #     complete(request)
            #   end
            # end
          end
        RUBY
      end
    end
  end
end
