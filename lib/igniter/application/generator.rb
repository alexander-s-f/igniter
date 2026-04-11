# frozen_string_literal: true

require "fileutils"

module Igniter
  class Application
    # Generates a new Igniter application scaffold.
    # Invoked via: igniter-server new my_app
    #
    # Creates:
    #   my_app/
    #   ├── app/
    #   │   ├── contracts/         — Contract subclasses (dependency graphs)
    #   │   ├── executors/         — Executor subclasses (pure functions)
    #   │   ├── tools/             — Tool subclasses (LLM-callable wrappers)
    #   │   ├── agents/            — Agent / Supervisor / ProactiveAgent subclasses
    #   │   └── skills/            — Skill subclasses (LLM reasoning loops)
    #   ├── lib/                   — Shared libraries and helpers
    #   ├── bin/
    #   │   ├── start              — Launch the HTTP server
    #   │   └── demo               — Run a quick demo (no server needed)
    #   ├── application.rb         — Application class (entry point)
    #   ├── application.yml        — Base server config
    #   ├── Gemfile
    #   └── config.ru              — Rack entry point (Puma / Unicorn)
    class Generator
      def initialize(name)
        @name = name.to_s.strip
        raise ArgumentError, "App name cannot be blank" if @name.empty?

        @dir = @name
      end

      def generate # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        create_dir ""
        create_dir "app/contracts"
        create_dir "app/executors"
        create_dir "app/tools"
        create_dir "app/agents"
        create_dir "app/skills"
        create_dir "lib"
        create_dir "bin"

        write "application.rb",              application_rb
        write "application.yml",             application_yml
        write "Gemfile",                     gemfile
        write "config.ru",                   config_ru
        write "bin/start",                   bin_start
        write "bin/demo",                    bin_demo
        write "lib/.keep",                   ""
        write "app/executors/greeter.rb",    executor_greeter
        write "app/contracts/greet_contract.rb", contract_greet
        write "app/tools/greet_tool.rb",     tool_greet
        write "app/agents/host_agent.rb",    agent_host
        write "app/skills/concierge_skill.rb", skill_concierge

        FileUtils.chmod(0o755, path("bin/start"))
        FileUtils.chmod(0o755, path("bin/demo"))

        puts
        puts "  Done! Your #{module_name}App is ready."
        puts
        puts "  Next steps:"
        puts "    cd #{@name}"
        puts "    bundle install"
        puts "    ruby bin/demo      # ← see it work immediately"
        puts "    bin/start          # ← launch the HTTP server"
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
        @name.split(/[-_\s]+/).map(&:capitalize).join
      end

      # ─── application.rb ──────────────────────────────────────────────────────

      def application_rb
        <<~RUBY
          # frozen_string_literal: true

          require "igniter"
          require "igniter/server"
          require "igniter/application"
          require "igniter/tool"
          require "igniter/integrations/agents"

          class #{module_name}App < Igniter::Application
            config_file File.join(__dir__, "application.yml")

            # Eagerly load app code in dependency order.
            executors_path "app/executors"
            contracts_path "app/contracts"
            tools_path     "app/tools"
            agents_path    "app/agents"
            skills_path    "app/skills"

            # on_boot runs after all paths are loaded — safe to reference autoloaded constants.
            on_boot do
              register "GreetContract", GreetContract
            end

            configure do |c|
              # c.port  = ENV.fetch("PORT", 4567).to_i
              # c.store = Igniter::Runtime::Stores::MemoryStore.new
            end

            # schedule :heartbeat, every: "30s" do
            #   puts "[heartbeat] \#{Time.now.strftime("%H:%M:%S")}"
            # end
          end

          #{module_name}App.start if $PROGRAM_NAME == __FILE__
        RUBY
      end

      # ─── application.yml ─────────────────────────────────────────────────────

      def application_yml
        <<~YAML
          server:
            port: 4567
            host: "0.0.0.0"
            log_format: text   # text | json  (json = Loki/ELK compatible)
            drain_timeout: 30  # seconds to wait for in-flight requests on shutdown
        YAML
      end

      # ─── Gemfile ─────────────────────────────────────────────────────────────

      def gemfile
        <<~RUBY
          # frozen_string_literal: true

          source "https://rubygems.org"

          gem "igniter"

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

          require_relative "application"

          run #{module_name}App.rack_app
        RUBY
      end

      # ─── bin/start ───────────────────────────────────────────────────────────

      def bin_start
        <<~BASH
          #!/usr/bin/env bash
          set -e
          cd "$(dirname "$0")/.."
          exec bundle exec ruby application.rb "$@"
        BASH
      end

      # ─── bin/demo ────────────────────────────────────────────────────────────

      def bin_demo
        <<~RUBY
          #!/usr/bin/env ruby
          # frozen_string_literal: true
          # Quick demo — no server needed.  Run: ruby bin/demo

          root = File.expand_path("..", __dir__)
          $LOAD_PATH.unshift(File.join(root, "lib"))
          Dir.chdir(root)

          require "igniter"
          require "igniter/tool"
          require "igniter/integrations/agents"

          # Load app code in dependency order
          %w[executors contracts tools agents].each do |dir|
            Dir[File.join(root, "app/\#{dir}/**/*.rb")].sort.each { |f| require f }
          end

          hr = "─" * 48

          puts
          puts "  \#{hr}"
          puts "  #{module_name}App  ·  Powered by Igniter ⚡"
          puts "  \#{hr}"
          puts

          # ── 1. Contract ─────────────────────────────────────────────────────
          puts "1 · Contract — validated dependency graph"
          result = GreetContract.new.resolve_all(name: "Alice")
          puts "  ➜  \#{result[:greeting][:message]}"
          puts "     resolved at \#{result[:greeting][:greeted_at]}"
          puts

          # ── 2. Agent ────────────────────────────────────────────────────────
          puts "2 · Agent — stateful actor"
          ref = HostAgent.start
          ref.call(:greet, { name: "Bob" })
          ref.call(:greet, { name: "Carol" })
          stats = ref.call(:stats)
          puts "  ➜  Greeted \#{stats[:total]} visitors: \#{stats[:recent].map { |v| v[:name] }.join(", ")}"
          ref.stop
          puts

          # ── 3. Tool ─────────────────────────────────────────────────────────
          puts "3 · Tool — LLM-callable (Anthropic / OpenAI compatible)"
          schema = GreetTool.to_schema
          params = schema[:parameters][:properties].keys.join(", ")
          puts "  ➜  \#{schema[:name]}(\#{params}) — \#{schema[:description]}"
          puts

          # ── 4. Skill ────────────────────────────────────────────────────────
          puts "4 · Skill — LLM reasoning loop (stub — add API key to activate)"
          puts "  ➜  See app/skills/concierge_skill.rb"
          puts

          puts "  \#{hr}"
          puts "  Run  bin/start  →  http://localhost:4567"
          puts "  \#{hr}"
          puts
        RUBY
      end

      # ─── app/executors/greeter.rb ─────────────────────────────────────────

      def executor_greeter
        <<~RUBY
          # frozen_string_literal: true

          # A pure function: given inputs, produce an output. No side effects.
          # Executors are the leaf nodes in a Contract dependency graph.
          class Greeter < Igniter::Executor
            def call(name:)
              { message: "Hello, \#{name}!", greeted_at: Time.now.iso8601 }
            end
          end
        RUBY
      end

      # ─── app/contracts/greet_contract.rb ─────────────────────────────────

      def contract_greet
        <<~RUBY
          # frozen_string_literal: true

          # A Contract declares business logic as a validated dependency graph.
          # Igniter resolves execution order and validates edges at compile time.
          class GreetContract < Igniter::Contract
            define do
              input  :name
              compute :greeting, depends_on: :name, call: Greeter
              output :greeting
            end
          end
        RUBY
      end

      # ─── app/tools/greet_tool.rb ─────────────────────────────────────────

      def tool_greet
        <<~RUBY
          # frozen_string_literal: true

          # A Tool wraps an Executor with LLM-friendly metadata.
          # Any LLM (Anthropic, OpenAI) can call this via function-calling —
          # the schema is generated automatically from the param declarations.
          class GreetTool < Igniter::Tool
            description "Greet a person by name and return a welcome message"

            param :name, type: :string, required: true, desc: "The person's name"

            def call(name:)
              GreetContract.new.resolve_all(name:)[:greeting]
            end
          end
        RUBY
      end

      # ─── app/agents/host_agent.rb ─────────────────────────────────────────

      def agent_host
        <<~RUBY
          # frozen_string_literal: true

          # An Agent is a stateful actor — it holds state between messages and
          # processes them sequentially in its own thread.
          #
          # Handlers that return a Hash → async state transition.
          # Handlers that return anything else → sync query, value sent back to caller.
          class HostAgent < Igniter::Agent
            initial_state visitors: [], count: 0

            on :greet do |state:, payload:|
              name   = payload.fetch(:name, "stranger")
              result = GreetContract.new.resolve_all(name:)
              puts "  [HostAgent] \#{result[:greeting][:message]}"

              state.merge(
                visitors: (state[:visitors] + [{ name: name, at: Time.now.iso8601 }]).last(10),
                count:    state[:count] + 1
              )
            end

            # Sync query — returns a plain value (not a Hash), so the caller receives it directly.
            on :stats do |state:, **|
              { total: state[:count], recent: state[:visitors].last(3) }
            end
          end
        RUBY
      end

      # ─── app/skills/concierge_skill.rb ───────────────────────────────────

      def skill_concierge
        <<~RUBY
          # frozen_string_literal: true

          # A Skill is a full LLM reasoning loop with access to your Tools.
          # Unlike a single Tool call, a Skill plans, reasons, and uses tools
          # iteratively until the task is complete.
          #
          # To activate:
          #   1. Add your API key: export ANTHROPIC_API_KEY=sk-ant-...
          #   2. Uncomment the code below.
          #   3. Add  require "igniter/integrations/llm"  to application.rb.
          #
          # require "igniter/integrations/llm"
          #
          # class ConciergeSkill < Igniter::Skill
          #   description "An AI concierge that greets visitors and answers questions"
          #
          #   param :request, type: :string, required: true, desc: "The visitor's request"
          #
          #   provider :anthropic           # or :openai, :ollama
          #   model    "claude-haiku-4-5-20251001"
          #   tools    GreetTool            # give the skill access to your tools
          #
          #   system_prompt <<~PROMPT
          #     You are a friendly concierge. Help visitors feel welcome.
          #     Use the greet_tool to greet people by name.
          #   PROMPT
          #
          #   def call(request:)
          #     complete(request)           # runs the LLM loop, returns final text
          #   end
          # end
        RUBY
      end
    end
  end
end
