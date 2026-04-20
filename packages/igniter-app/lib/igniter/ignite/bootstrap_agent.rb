# frozen_string_literal: true

require "yaml"
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

      class << self
        private

        def resolve_config_path(root_dir, config_path)
          candidate = File.expand_path(config_path.to_s, root_dir)
          return candidate if File.exist?(candidate)

          raise Errno::ENOENT, candidate
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
      end
    end
  end
end
