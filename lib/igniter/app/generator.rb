# frozen_string_literal: true

require "fileutils"

module Igniter
  class App
    # Generates a new Igniter stack scaffold.
    # Invoked via: igniter-stack new my_app
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
    #   │       ├── app.rb             — leaf Igniter::App
    #   │       └── app.yml            — app-local runtime defaults
    #   ├── lib/<project>/shared/      — shared libraries / helpers
    #   ├── config/
    #   │   └── deploy/                — optional generated operational artifacts
    #   ├── spec/                      — shared + integration + stack-level specs
    #   ├── bin/
    #   │   ├── start                  — Launch a named app (default: main)
    #   │   ├── console                — Interactive stack console
    #   │   └── demo                   — Run a quick demo (no server needed)
    #   ├── stack.rb                   — Stack coordinator
    #   ├── stack.yml                  — Stack metadata
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
        create_dir "config/deploy"
        create_dir "spec"
        create_dir "bin"

        write "stack.rb",                      stack_rb
        write "stack.yml",                     stack_yml
        write "config/deploy/.keep",           ""
        write "Gemfile",                       gemfile
        write "config.ru",                     config_ru
        write "bin/start",                     bin_start
        write "bin/dev",                       bin_dev
        write "bin/console",                   bin_console
        write "spec/spec_helper.rb",           root_spec_helper
        write "spec/stack_spec.rb",            stack_spec
        write "apps/main/spec/spec_helper.rb", main_spec_helper
        write "apps/main/app.rb",              main_app_rb
        write "apps/main/app.yml",             main_app_yml
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
        FileUtils.chmod(0o755, path("bin/console"))
        FileUtils.chmod(0o755, path("bin/demo"))

        puts
        puts "  Done! Your #{module_name} stack is ready."
        puts
        puts "  Next steps:"
        puts "    cd #{@name}"
        puts "    bundle install"
        unless @minimal
        puts "    ruby bin/demo      # ← see it work immediately"
        end
        puts "    bin/start          # ← launch the mounted stack"
        puts "    bin/console        # ← open the igniter console"
        puts "    bin/dev            # ← launch the whole stack locally (+ var/log/dev/*.log)"
        puts "    bin/start --node main      # ← explicit node selection"
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

      def stack_class_name
        "#{module_name}::Stack"
      end

      # ─── stack.rb (stack coordinator) ────────────────────────────────────────

      def stack_rb
        <<~RUBY
          # frozen_string_literal: true

          require "igniter/stack"
          require_relative "apps/main/app"

          module #{module_name}
            class Stack < Igniter::Stack
              root_dir __dir__
              shared_lib_path "lib"

              app :main, path: "apps/main", klass: #{module_name}::MainApp, default: true
            end
          end

          if $PROGRAM_NAME == __FILE__
            #{stack_class_name}.start_cli(ARGV)
          end
        RUBY
      end

      # ─── stack.yml (stack metadata) ──────────────────────────────────────────

      def stack_yml
        <<~YAML
          stack:
            name: #{@project_name}
            root_app: main
            default_node: main
            shared_lib_paths:
              - lib

          server:
            host: 0.0.0.0

          nodes:
            main:
              role: app
              port: 4567

          persistence:
            data:
              adapter: memory   # memory | sqlite
              path: var/#{@project_name}_data.sqlite3
        YAML
      end

      # ─── apps/main/app.rb ───────────────────────────────────────────────────

      def main_app_rb
        <<~RUBY
          # frozen_string_literal: true

          require "igniter/app"
          require "igniter/core"

          module #{module_name}
            class MainApp < Igniter::App
              root_dir __dir__
              config_file "app.yml"

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
                # c.store         = Igniter::Runtime::Stores::MemoryStore.new
              end

              # schedule :heartbeat, every: "30s" do
              #   puts "[heartbeat] \#{Time.now.strftime("%H:%M:%S")}"
              # end
            end
          end
        RUBY
      end

      # ─── apps/main/app.yml ──────────────────────────────────────────────────

      def main_app_yml
        <<~YAML
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
          gem "sqlite3" # stack-local data + execution stores

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

          require_relative "stack"

          node = ENV["IGNITER_NODE"]
          run #{stack_class_name}.rack_node(node)
        RUBY
      end

      # ─── bin/start ───────────────────────────────────────────────────────────

      def bin_start
        <<~BASH
          #!/usr/bin/env bash
          set -e
          cd "$(dirname "$0")/.."

          exec bundle exec ruby stack.rb "$@"
        BASH
      end

      def bin_dev
        <<~BASH
          #!/usr/bin/env bash
          set -e
          cd "$(dirname "$0")/.."

          exec bundle exec ruby stack.rb --dev "$@"
        BASH
      end

      def bin_console
        <<~BASH
          #!/usr/bin/env bash
          set -e
          cd "$(dirname "$0")/.."

          exec bundle exec ruby stack.rb --console "$@"
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
          require_relative "../apps/main/app"

          %w[tools skills executors contracts agents].each do |dir|
            Dir[File.join(root, "apps/main/app/\#{dir}/**/*.rb")].sort.each { |f| require f }
          end

          hr = "─" * 48

          puts
          puts "  \#{hr}"
          puts "  #{module_name} Stack  ·  apps/main powered by Igniter ⚡"
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
          puts "  Run  bin/start       →  start the mounted stack"
          puts "  Run  bin/console     →  open the igniter console"
          puts "  Run  bin/dev         →  start the whole stack locally (+ var/log/dev/*.log)"
          puts "  Run  bin/start --node main     →  explicit node selection"
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
          puts "#{module_name} stack — add your demo code here."
          puts "Run  bin/start       →  start the mounted stack"
          puts "Run  bin/console     →  open the igniter console"
          puts "Run  bin/dev         →  start the whole stack locally (+ var/log/dev/*.log)"
          puts "Run  bin/start --node main     →  explicit node selection"
        RUBY
      end

      # ─── spec/spec_helper.rb ───────────────────────────────────────────────

      def root_spec_helper
        <<~RUBY
          # frozen_string_literal: true

          require "rspec"
          require_relative "../stack"

          #{stack_class_name}.setup_load_paths!

          RSpec.configure do |config|
            config.disable_monkey_patching!
            config.expect_with(:rspec) { |c| c.syntax = :expect }
          end
        RUBY
      end

      # ─── spec/stack_spec.rb ────────────────────────────────────────────────

      def stack_spec
        <<~RUBY
          # frozen_string_literal: true

          require_relative "spec_helper"

          RSpec.describe #{stack_class_name} do
            it "registers apps/main as the root app and default node" do
              expect(described_class.root_app).to eq(:main)
              expect(described_class.default_node).to eq(:main)
              expect(described_class.node_names).to eq([:main])
              expect(described_class.app(:main)).to be(#{module_name}::MainApp)
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
            #   3. Add require "igniter/sdk/ai" to apps/main/app.rb.
            #
            # require "igniter/sdk/ai"
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
