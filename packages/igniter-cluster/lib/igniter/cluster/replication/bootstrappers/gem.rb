# frozen_string_literal: true

require "shellwords"

module Igniter
  module Cluster
    module Replication
    module Bootstrappers
      # Deploys by installing the igniter gem from RubyGems on the remote host.
      #
      # Optionally pins a specific gem version. The startup script defaults to
      # the +igniter-stack+ executable installed with the gem.
      class Gem < Bootstrapper
        def initialize(version: nil, startup_script: nil)
          super()
          @version        = version
          @startup_script = startup_script
        end

        def install(session:, manifest:, env: {}, target_path: "/opt/igniter") # rubocop:disable Lint/UnusedMethodArgument
          ver_flag = @version ? " -v #{@version}" : ""
          session.exec!("gem install igniter#{ver_flag} --no-document")
          session.exec!("mkdir -p #{target_path}")
          write_env_file(session: session, env: env, path: "#{target_path}/.env")
        end

        def start(session:, manifest:, target_path: "/opt/igniter") # rubocop:disable Lint/UnusedMethodArgument
          log_path = "#{target_path}/igniter.log"
          pid_path = "#{target_path}/igniter.pid"
          script   = @startup_script || "igniter-stack"
          session.exec!(
            "sh -lc 'nohup #{script} >> #{Shellwords.escape(log_path)} 2>&1 & echo $! > #{Shellwords.escape(pid_path)}'"
          )
        end
      end
    end
    end
  end
end
