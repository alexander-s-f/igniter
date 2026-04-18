# frozen_string_literal: true

module Igniter
  module Cluster
    module Replication
    module Bootstrappers
      # Deploys by cloning a git repository on the remote host.
      #
      # Requires git to be installed on the remote. After cloning, installs
      # bundler and runs bundle install.
      class Git < Bootstrapper
        DEFAULT_BRANCH         = "main"
        DEFAULT_BUNDLE_OPTIONS = "--without development test"

        def initialize(repo_url:, branch: DEFAULT_BRANCH, bundle_options: DEFAULT_BUNDLE_OPTIONS)
          super()
          @repo_url       = repo_url
          @branch         = branch
          @bundle_options = bundle_options
        end

        def install(session:, manifest:, env: {}, target_path: "/opt/igniter") # rubocop:disable Lint/UnusedMethodArgument
          app_path = "#{target_path}/app"
          session.exec!("mkdir -p #{target_path}")
          session.exec!("git clone --branch #{@branch} --depth 1 #{@repo_url} #{app_path}")
          session.exec!("cd #{app_path} && gem install bundler --no-document")
          session.exec!("cd #{app_path} && bundle install #{@bundle_options}")
          write_env_file(session: session, env: env, path: "#{target_path}/.env")
        end

        def start(session:, manifest:, target_path: "/opt/igniter")
          app_path = "#{target_path}/app"
          log_path = "#{target_path}/igniter.log"
          cmd      = manifest.startup_command
          session.exec!("cd #{app_path} && nohup ruby #{cmd} >> #{log_path} 2>&1 &")
        end
      end
    end
    end
  end
end
