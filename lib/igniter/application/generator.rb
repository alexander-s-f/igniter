# frozen_string_literal: true

require "fileutils"

module Igniter
  class Application
    # Generates a new Igniter application scaffold.
    # Invoked via: igniter-server new my_app
    #
    # Creates:
    #   my_app/
    #   ├── application.rb     — Application class (entry point)
    #   ├── application.yml    — base config (port, log_format, etc.)
    #   ├── Gemfile
    #   ├── config.ru          — Rack entry point for Puma/Unicorn
    #   ├── bin/start          — convenience start script
    #   ├── contracts/         — Contract subclasses
    #   ├── executors/         — Executor subclasses
    #   └── agents/            — Agent, Supervisor, and ProactiveAgent subclasses
    class Generator
      def initialize(name)
        @name = name.to_s.strip
        raise ArgumentError, "App name cannot be blank" if @name.empty?

        @dir = @name
      end

      def generate # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        create_dir ""
        create_dir "contracts"
        create_dir "executors"
        create_dir "agents"
        create_dir "bin"

        write "application.rb",  application_rb
        write "application.yml", application_yml
        write "Gemfile",         gemfile
        write "config.ru",       config_ru
        write "bin/start",       bin_start
        write "contracts/.keep", ""
        write "executors/.keep", ""
        write "agents/.keep",    ""

        FileUtils.chmod(0o755, path("bin/start"))

        puts
        puts "Done! Next steps:"
        puts "  cd #{@name}"
        puts "  bundle install"
        puts "  bin/start"
        puts
        puts "To run with Puma:"
        puts "  bundle add puma"
        puts "  bundle exec puma config.ru"
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

      def application_rb
        <<~RUBY
          # frozen_string_literal: true

          $LOAD_PATH.unshift(File.join(__dir__, "../../lib")) if File.exist?("../../lib/igniter.rb")

          require "igniter"
          require "igniter/server"
          require "igniter/application"
          require "igniter/agents"

          class #{module_name}App < Igniter::Application
            config_file File.join(__dir__, "application.yml")

            # Eagerly load all .rb files from these directories on startup.
            executors_path "executors"
            contracts_path "contracts"
            agents_path    "agents"

            configure do |c|
              # Override YAML values here, e.g.:
              # c.port  = ENV.fetch("PORT", 4567).to_i
              # c.store = Igniter::Runtime::Stores::MemoryStore.new
            end

            # Register contracts for HTTP dispatch:
            # register "MyContract", MyContract

            # Recurring background jobs:
            # schedule :heartbeat, every: "30s" do
            #   puts "[heartbeat] \#{Time.now.strftime("%H:%M:%S")}"
            # end
          end

          #{module_name}App.start if $PROGRAM_NAME == __FILE__
        RUBY
      end

      def application_yml
        <<~YAML
          server:
            port: 4567
            host: "0.0.0.0"
            log_format: text   # text | json  (json = Loki/ELK compatible)
            drain_timeout: 30  # seconds to wait for in-flight requests on shutdown
        YAML
      end

      def gemfile
        <<~RUBY
          # frozen_string_literal: true

          source "https://rubygems.org"

          gem "igniter"
        RUBY
      end

      def config_ru
        <<~RUBY
          # frozen_string_literal: true
          # Rack entry point — use with Puma or any Rack-compatible server.
          #   bundle exec puma config.ru

          require_relative "application"

          run #{module_name}App.rack_app
        RUBY
      end

      def bin_start
        <<~BASH
          #!/usr/bin/env bash
          set -e
          cd "$(dirname "$0")/.."
          exec bundle exec ruby application.rb "$@"
        BASH
      end
    end
  end
end
