# frozen_string_literal: true

require_relative "../agent"

module Igniter
  module Replication
    # Agent that handles :replicate messages to deploy Igniter to remote servers.
    #
    # In production, start via ReplicationAgent.start and send messages through
    # the Ref. In tests, instantiate directly and call handle_message/1.
    #
    # Message payload keys:
    #   host:                  [String]  (required) remote hostname or IP
    #   user:                  [String]  (required) SSH username
    #   key:                   [String]  path to SSH private key (optional)
    #   port:                  [Integer] SSH port (default: 22)
    #   env:                   [Hash]    environment variables for remote (default: {})
    #   strategy:              [Symbol]  :git, :gem, or :tarball (default: :git)
    #   target_path:           [String]  installation path on remote (default: /opt/igniter)
    #   bootstrapper_options:  [Hash]    forwarded to the bootstrapper constructor
    #
    class ReplicationAgent < Igniter::Agent
      MAX_REPLICAS = 10

      initial_state events: []

      # Class-level handler for the agent mailbox runtime.
      # Instantiates a temporary agent to run the replication so that
      # deliver/1 can be overridden in subclasses.
      on :replicate do |state:, payload:, **|
        agent = new
        agent.send(:run_replicate, payload)
        state
      end

      # Emit a named lifecycle event. Override or stub in tests.
      #
      # @param type    [Symbol] event name (e.g. :replication_started)
      # @param payload [Hash]   associated data
      def deliver(type, payload = {})
        # Base implementation: no-op. Override in subclasses for real routing.
      end

      # Process a raw message hash synchronously (used in tests and internal tooling).
      #
      # @param message [Hash] must have :type key; optional :payload key
      def handle_message(message)
        type    = message.fetch(:type).to_sym
        payload = message.fetch(:payload, {})
        return unless type == :replicate

        run_replicate(payload)
      end

      private

      def run_replicate(payload) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        host        = payload[:host]        || raise(ArgumentError, "host is required")
        user        = payload[:user]        || raise(ArgumentError, "user is required")
        key         = payload[:key]
        port        = payload.fetch(:port, 22)
        env         = payload.fetch(:env, {})
        strategy    = payload.fetch(:strategy, :git).to_sym
        target_path = payload.fetch(:target_path, "/opt/igniter")
        bs_options  = payload.fetch(:bootstrapper_options, {})

        session      = SSHSession.new(host: host, user: user, key: key, port: port)
        bootstrapper = Replication.bootstrapper_for(strategy, **bs_options)
        manifest     = Manifest.current

        deliver(:replication_started, host: host, instance_id: manifest.instance_id)

        bootstrapper.install(session: session, manifest: manifest,
                             env: env, target_path: target_path)
        bootstrapper.start(session: session, manifest: manifest, target_path: target_path)
        verified = bootstrapper.verify(session: session, target_path: target_path)

        deliver(:replication_completed,
                host: host, instance_id: manifest.instance_id, verified: verified)
      rescue SSHSession::SSHError => e
        deliver(:replication_failed, host: host, error: e.message)
      rescue ArgumentError => e
        deliver(:replication_failed, host: payload[:host], error: e.message)
      end
    end
  end
end
