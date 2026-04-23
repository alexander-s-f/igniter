# frozen_string_literal: true

require "etc"
require "rbconfig"
require "socket"
require "time"

module Igniter
  module Tools
    class SystemDiscoveryTool < Igniter::Tool
      DEFAULT_UTILITY_CANDIDATES = %w[
        ruby
        bundle
        rake
        rspec
        git
        curl
        wget
        rg
        fd
        jq
        sqlite3
        redis-cli
        psql
        python3
        pip3
        node
        npm
        yarn
        pnpm
        docker
        docker-compose
        ffmpeg
        ollama
        pio
        arduino-cli
        esptool.py
        make
        gcc
        clang
      ].freeze

      SAFE_ENV_ALLOWLIST = %w[
        HOME
        USER
        SHELL
        LANG
        TERM
        PATH
        RUBY_ENGINE
        RUBY_VERSION
        BUNDLE_GEMFILE
        GEM_HOME
        GEM_PATH
        RBENV_VERSION
        ASDF_DIR
        NODENV_VERSION
        PYENV_VERSION
      ].freeze

      description "Inspect the current host environment and return a structured snapshot of the system, runtime, PATH, and available utilities."

      param :include_environment, type: :boolean, default: false,
                                  desc: "Include a filtered environment variable snapshot."
      param :environment_keys, type: :array, default: SAFE_ENV_ALLOWLIST,
                               desc: "Environment variable names to include when include_environment is true."
      param :utility_candidates, type: :array, default: DEFAULT_UTILITY_CANDIDATES,
                                 desc: "Specific utility names to probe in PATH."
      param :scan_path_entries, type: :boolean, default: true,
                                desc: "Whether to scan PATH directories and list executable names."
      param :path_entry_limit, type: :integer, default: 250,
                               desc: "Maximum number of discovered PATH executables to return."

      requires_capability :system_read

      def call(include_environment: false, environment_keys: SAFE_ENV_ALLOWLIST,
               utility_candidates: DEFAULT_UTILITY_CANDIDATES, scan_path_entries: true, path_entry_limit: 250)
        {
          generated_at: Time.now.utc.iso8601,
          host: host_snapshot,
          runtime: runtime_snapshot,
          paths: path_snapshot(
            utility_candidates: utility_candidates,
            scan_path_entries: scan_path_entries,
            path_entry_limit: path_entry_limit
          ),
          environment: include_environment ? environment_snapshot(environment_keys) : nil
        }.compact
      end

      private

      def host_snapshot
        {
          hostname: safe_hostname,
          platform: RUBY_PLATFORM,
          os: RbConfig::CONFIG["host_os"],
          cpu: RbConfig::CONFIG["host_cpu"],
          user: safe_user,
          home: ENV["HOME"],
          shell: ENV["SHELL"]
        }.compact
      end

      def runtime_snapshot
        {
          ruby: {
            version: RUBY_VERSION,
            engine: defined?(RUBY_ENGINE) ? RUBY_ENGINE : "ruby",
            platform: RUBY_PLATFORM,
            executable: RbConfig.ruby
          },
          process: {
            pid: Process.pid,
            cwd: Dir.pwd
          }
        }
      end

      def path_snapshot(utility_candidates:, scan_path_entries:, path_entry_limit:)
        entries = ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).reject(&:empty?)

        {
          path_entries: entries,
          utility_candidates: resolve_candidates(Array(utility_candidates)),
          discovered_executables: scan_path_entries ? scan_executables(entries, limit: path_entry_limit.to_i) : []
        }
      end

      def environment_snapshot(keys)
        Array(keys).each_with_object({}) do |key, memo|
          name = key.to_s
          next unless ENV.key?(name)

          memo[name] = ENV[name]
        end
      end

      def resolve_candidates(candidates)
        candidates.map do |name|
          {
            name: name.to_s,
            present: !find_executable(name).nil?,
            path: find_executable(name)
          }
        end
      end

      def scan_executables(path_entries, limit:)
        discovered = path_entries.each_with_object([]) do |entry, memo|
          break memo if memo.size >= limit
          next unless File.directory?(entry)

          Dir.children(entry).sort.each do |child|
            full = File.join(entry, child)
            next unless File.file?(full)
            next unless File.executable?(full)

            memo << child
            break if memo.size >= limit
          end
        rescue SystemCallError
          next
        end

        discovered.uniq.sort
      end

      def find_executable(name)
        target = name.to_s
        return nil if target.empty?

        ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).each do |entry|
          next if entry.to_s.empty?

          candidate = File.join(entry, target)
          return candidate if File.file?(candidate) && File.executable?(candidate)
        rescue SystemCallError
          next
        end

        nil
      end

      def safe_hostname
        Socket.gethostname
      rescue SocketError
        nil
      end

      def safe_user
        Etc.getlogin || Etc.passwd.name
      rescue StandardError
        ENV["USER"]
      end
    end
  end
end
