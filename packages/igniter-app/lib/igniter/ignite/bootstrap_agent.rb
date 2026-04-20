# frozen_string_literal: true

require "yaml"
require "shellwords"
require "igniter/agent"
require "igniter/cluster/replication"

module Igniter
  module Ignite
    class BootstrapAgent < Igniter::Agent
      DEFAULT_REMOTE_STRATEGY = :tarball
      DEFAULT_TARGET_PATH = "/opt/igniter"
      BootstrapResult = Data.define(
        :status,
        :action,
        :admission,
        :join,
        :bootstrap,
        :bootstrap_error,
        :host,
        :port
      )
      DecommissionResult = Data.define(
        :status,
        :action,
        :transport,
        :acknowledged,
        :error
      )

      on :bootstrap do |payload:, **|
        intent = payload.fetch(:intent)
        root_dir = File.expand_path(payload.fetch(:root_dir))
        session_factory = payload[:session_factory]
        bootstrapper_factory = payload[:bootstrapper_factory]

        raise ArgumentError, "bootstrap requires an Igniter::Ignite::DeploymentIntent" unless intent.is_a?(DeploymentIntent)
        raise ArgumentError, "bootstrap only supports ssh_server targets" unless intent.ssh_server?

        config_path = resolve_config_path(root_dir, intent.target.locator.fetch("config_path"))
        target_config = load_target_config(config_path)
        session = build_session(target_config, session_factory)
        raise Igniter::Cluster::Replication::SSHSession::SSHError, "SSH connectivity test failed" unless session.test_connection

        strategy = normalize_strategy(target_config, intent)
        bootstrapper = build_bootstrapper(strategy, target_config, bootstrapper_factory)
        target_path = target_config["target_path"] || DEFAULT_TARGET_PATH
        manifest = Igniter::Cluster::Replication::Manifest.current
        environment = build_remote_environment(intent, target_config)

        bootstrapper.install(
          session: session,
          manifest: manifest,
          env: environment,
          target_path: target_path
        )
        bootstrapper.start(
          session: session,
          manifest: manifest,
          target_path: target_path
        )

        verified = bootstrapper.verify(session: session, target_path: target_path)
        raise Igniter::Cluster::Replication::Bootstrapper::BootstrapError, "remote bootstrap verification failed" unless verified

        BootstrapResult.new(
          status: :bootstrapped,
          action: :await_remote_join,
          bootstrap: {
            strategy: strategy,
            target_path: target_path,
            host: target_config.fetch("host"),
            user: target_config.fetch("user"),
            port: target_config.fetch("port", 22),
            config_path: config_path,
            verified: verified
          },
          host: target_config.fetch("host"),
          port: target_config.fetch("port", 22),
          admission: nil,
          join: {
            required: true,
            status: :awaiting_join
          },
          bootstrap_error: nil
        )
      rescue Igniter::Cluster::Replication::SSHSession::SSHError,
             Igniter::Cluster::Replication::Bootstrapper::BootstrapError,
             ArgumentError,
             Errno::ENOENT,
             Psych::SyntaxError => e
        BootstrapResult.new(
          status: :blocked,
          action: :remote_bootstrap_failed,
          admission: {
            required: true,
            status: :blocked
          },
          join: {
            required: true,
            status: :blocked
          },
          bootstrap_error: "#{e.class}: #{e.message}",
          bootstrap: nil,
          host: nil,
          port: nil
        )
      end

      on :detach do |payload:, **|
        decommission(payload, mode: :detach)
      end

      on :teardown do |payload:, **|
        decommission(payload, mode: :teardown)
      end

      class << self
        private

        def decommission(payload, mode:)
          entry = Hash(payload.fetch(:entry))
          root_dir = payload[:root_dir] && File.expand_path(payload[:root_dir])
          session_factory = payload[:session_factory]

          raise ArgumentError, "#{mode} only supports ssh_server targets" unless entry.fetch(:kind).to_sym == :ssh_server

          config_path = resolve_target_config_path(entry, root_dir)
          target_config = load_target_config(config_path)
          session = build_session(target_config, session_factory)
          raise Igniter::Cluster::Replication::SSHSession::SSHError, "SSH connectivity test failed" unless session.test_connection

          target_path = entry.dig(:bootstrap, :target_path) || target_config["target_path"] || DEFAULT_TARGET_PATH
          drain_command = decommission_drain_command(mode, target_path, target_config)
          command = decommission_command(mode, target_path, target_config)
          verification_command = decommission_verification_command(target_path, target_config)
          run_drain!(session, drain_command) if drain_command
          session.exec!(command)
          acknowledged = wait_for_shutdown_ack!(
            session,
            verification_command,
            timeout: target_config.fetch("shutdown_timeout", 10),
            poll_interval: target_config.fetch("shutdown_poll_interval", 0.5)
          )

          DecommissionResult.new(
            status: mode == :detach ? :detached : :torn_down,
            action: mode == :detach ? :remote_detached : :remote_torn_down,
            transport: {
              host: target_config.fetch("host"),
              port: target_config.fetch("port", 22),
              config_path: config_path,
              target_path: target_path,
              drain_command: drain_command,
              command: command,
              verification_command: verification_command,
              verified_shutdown: acknowledged
            },
            acknowledged: acknowledged,
            error: nil
          )
        rescue Igniter::Cluster::Replication::SSHSession::SSHError,
               ArgumentError,
               Errno::ENOENT,
               Psych::SyntaxError => e
          DecommissionResult.new(
            status: :blocked,
            action: mode == :detach ? :remote_detach_failed : :remote_teardown_failed,
            transport: nil,
            acknowledged: false,
            error: "#{e.class}: #{e.message}"
          )
        end

        def resolve_config_path(root_dir, config_path)
          candidate = File.expand_path(config_path.to_s, root_dir)
          return candidate if File.exist?(candidate)

          raise Errno::ENOENT, candidate
        end

        def resolve_target_config_path(entry, root_dir)
          bootstrap_path = entry.dig(:bootstrap, :config_path)
          return bootstrap_path if bootstrap_path && File.exist?(bootstrap_path)

          locator_path = entry.dig(:locator, "config_path") || entry.dig(:locator, :config_path)
          raise ArgumentError, "remote ignition target does not have a config_path" unless locator_path
          raise ArgumentError, "remote ignition target requires root_dir to resolve config_path" unless root_dir

          resolve_config_path(root_dir, locator_path)
        end

        def load_target_config(path)
          config = YAML.safe_load_file(path, permitted_classes: [], aliases: false) || {}
          hash = Hash(config)

          {
            "host" => hash.fetch("host"),
            "user" => hash.fetch("user"),
            "port" => hash.fetch("port", 22),
            "key" => hash["key"],
            "strategy" => hash["strategy"],
            "target_path" => hash["target_path"],
            "detach_command" => hash["detach_command"],
            "teardown_command" => hash["teardown_command"],
            "drain_command" => hash["drain_command"],
            "shutdown_check_command" => hash["shutdown_check_command"],
            "shutdown_timeout" => hash["shutdown_timeout"],
            "shutdown_poll_interval" => hash["shutdown_poll_interval"],
            "env" => Hash(hash["env"] || {}),
            "bootstrapper_options" => Hash(hash["bootstrapper_options"] || {})
          }
        end

        def build_session(target_config, session_factory)
          factory = session_factory || method(:default_session_factory)
          factory.call(
            host: target_config.fetch("host"),
            user: target_config.fetch("user"),
            key: target_config["key"],
            port: target_config.fetch("port", 22)
          )
        end

        def default_session_factory(host:, user:, key:, port:)
          Igniter::Cluster::Replication::SSHSession.new(
            host: host,
            user: user,
            key: key,
            port: port
          )
        end

        def normalize_strategy(target_config, intent)
          (target_config["strategy"] ||
            intent.target.bootstrap_requirements["strategy"] ||
            DEFAULT_REMOTE_STRATEGY).to_sym
        end

        def build_bootstrapper(strategy, target_config, bootstrapper_factory)
          factory = bootstrapper_factory || method(:default_bootstrapper_factory)
          factory.call(strategy, **Hash(target_config["bootstrapper_options"] || {}))
        end

        def default_bootstrapper_factory(strategy, **options)
          Igniter::Cluster::Replication.bootstrapper_for(strategy, **options)
        end

        def build_remote_environment(intent, target_config)
          env = Hash(target_config["env"] || {}).each_with_object({}) do |(key, value), result|
            result[key.to_s] = value.to_s
          end

          env["IGNITER_IGNITE_TARGET"] = intent.target.id
          env["IGNITER_IGNITE_INTENT"] = intent.id
          env["IGNITER_IGNITE_MODE"] = intent.ignite_mode.to_s
          env["IGNITER_ENV"] ||= intent.requested_from["environment"].to_s unless intent.requested_from["environment"].to_s.empty?
          env["PORT"] ||= intent.target.base_server["port"].to_s if intent.target.base_server["port"]

          seed_host = intent.seed_node["host"]
          seed_port = intent.seed_node["port"]
          if seed_host && seed_port
            env["IGNITER_CLUSTER_SEED_URL"] ||= "http://#{seed_host}:#{seed_port}"
          end

          env
        end

        def decommission_command(mode, target_path, target_config)
          configured =
            case mode
            when :detach
              target_config["detach_command"]
            when :teardown
              target_config["teardown_command"]
            end
          return configured if configured && !configured.to_s.empty?

          pid_path = Shellwords.escape("#{target_path}/igniter.pid")
          escaped_target = Shellwords.escape(target_path)
          stop_clause = "if [ -f #{pid_path} ]; then kill $(cat #{pid_path}) 2>/dev/null || true; rm -f #{pid_path}; else pkill -f #{escaped_target} 2>/dev/null || pkill -f \"igniter-stack|ruby stack.rb\" 2>/dev/null || true; fi"

          case mode
          when :detach
            "sh -lc '#{stop_clause}'"
          when :teardown
            "sh -lc '#{stop_clause}; rm -rf #{escaped_target}'"
          else
            raise ArgumentError, "unsupported decommission mode #{mode.inspect}"
          end
        end

        def decommission_drain_command(_mode, _target_path, target_config)
          configured = target_config["drain_command"]
          return nil unless configured && !configured.to_s.empty?

          configured
        end

        def decommission_verification_command(target_path, target_config)
          configured = target_config["shutdown_check_command"]
          return configured if configured && !configured.to_s.empty?

          pid_path = Shellwords.escape("#{target_path}/igniter.pid")
          escaped_target = Shellwords.escape(target_path)
          "sh -lc 'if [ -f #{pid_path} ]; then pid=$(cat #{pid_path} 2>/dev/null || true); if [ -n \"$pid\" ] && kill -0 \"$pid\" 2>/dev/null; then exit 1; fi; fi; pgrep -f #{escaped_target} >/dev/null 2>&1 && exit 1; exit 0'"
        end

        def run_drain!(session, command)
          session.exec!(command)
        end

        def wait_for_shutdown_ack!(session, verification_command, timeout:, poll_interval:)
          deadline = Time.now + timeout.to_f
          interval = [poll_interval.to_f, 0.01].max

          loop do
            result =
              if session.respond_to?(:exec)
                session.exec(verification_command)
              else
                { success: true, stdout: "", stderr: "", exit_code: 0 }
              end

            return true if result[:success]
            raise Igniter::Cluster::Replication::SSHSession::SSHError, "remote shutdown verification failed: #{result[:stderr]}".strip if Time.now >= deadline

            sleep interval
          end
        end
      end
    end
  end
end
