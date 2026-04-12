# frozen_string_literal: true

require "securerandom"
require_relative "replication_agent"
require_relative "network_topology"
require_relative "expansion_plan"
require_relative "expansion_planner"
require_relative "role_registry"

module Igniter
  module Cluster
    module Replication
    # ReplicationAgent extended with episodic memory, self-reflection, and
    # topology-aware network expansion.
    #
    # == Additional message types
    #
    #   :assess_network  — run ExpansionPlanner; execute replicate_role/retire_node actions
    #   :reflect         — run a ReflectionCycle over recent episodes; store summary in state
    #   :register_node   — register a remote node in the local NetworkTopology
    #   :node_heartbeat  — update last_seen_at for a known node
    #   :signal_scale    — emit a :scale_signal episode (e.g. from load monitors)
    #
    # == State keys (in addition to inherited :events)
    #
    #   :topology        — NetworkTopology instance (created lazily on first access)
    #   :host_pool       — Array<String> of candidate hosts
    #   :required_roles  — Array<Symbol> of roles that must always be present
    #   :last_plan       — Hash from the most recent ExpansionPlan
    #   :last_reflection — String summary from the most recent reflection cycle
    #
    # == Memory
    #
    # Call +enable_class_memory+ in the class body to activate episodic memory.
    # Memory is class-level (shared across handler invocations on this class).
    #
    # == Auto-assessment
    #
    # Call +auto_assess(every: N)+ to schedule periodic topology assessment.
    #
    # @example
    #   RoleRegistry.define(:worker, env_overrides: { "POOL" => "4" })
    #
    #   class MyAgent < ReflectiveReplicationAgent
    #     enable_class_memory
    #     auto_assess every: 60
    #   end
    #
    #   ref = MyAgent.start(initial_state: {
    #     topology:       NetworkTopology.new,
    #     required_roles: [:worker],
    #     host_pool:      ["10.0.0.2", "10.0.0.3"]
    #   })
    #   ref.call(:assess_network)
    class ReflectiveReplicationAgent < ReplicationAgent
      initial_state topology: nil, host_pool: [], required_roles: [],
                    last_plan: nil, last_reflection: nil

      # ── Class-level memory ─────────────────────────────────────────────────────

      class << self
        # Activate episodic memory for this class.
        #
        # @param store [Memory::Store, nil] backing store; defaults to global default
        # @return [void]
        def enable_class_memory(store: nil)
          require "igniter/core/memory"
          @class_memory_store   = store || Igniter::Memory.default_store
          @class_memory_enabled = true
        end

        # Returns true when class-level memory has been activated.
        #
        # @return [Boolean]
        def class_memory_enabled?
          @class_memory_enabled || false
        end

        # Returns the AgentMemory facade bound to this class, or nil when disabled.
        #
        # @return [Memory::AgentMemory, nil]
        def class_memory
          return nil unless class_memory_enabled?

          @class_memory ||= Igniter::Memory::AgentMemory.new(
            store:    @class_memory_store,
            agent_id: name.to_s
          )
        end

        # Reset class-level memory state. Intended for use in tests.
        #
        # @return [void]
        def reset_class_memory!
          @class_memory         = nil
          @class_memory_store   = nil
          @class_memory_enabled = false
        end

        # Register a recurring topology assessment.
        #
        # @param every [Numeric] interval in seconds
        # @return [void]
        def auto_assess(every:)
          schedule(:auto_assessment, every: every) do |state:|
            agent = new
            agent.send(:run_assess_network, state, {})
          end
        end
      end

      # ── deliver: intercept lifecycle events into memory ────────────────────────

      # Override the no-op deliver from ReplicationAgent to record events.
      # Subclasses can call +super+ and then add their own routing.
      #
      # @param type    [Symbol]
      # @param payload [Hash]
      def deliver(type, payload = {})
        self.class.class_memory&.record(
          type:       :replication_event,
          content:    "#{type}: #{payload.inspect}",
          outcome:    type == :replication_failed ? "failure" : "success",
          importance: 0.6
        )
      end

      # ── Handlers ───────────────────────────────────────────────────────────────

      # Re-define :replicate (parent's handler is cleared by Agent.inherited).
      on :replicate do |state:, payload:, **|
        agent = new
        agent.send(:run_replicate, payload)
        state
      end

      on :assess_network do |state:, payload:, **|
        agent = new
        agent.send(:run_assess_network, state, payload)
      end

      on :reflect do |state:, payload:, **|
        next state unless class_memory_enabled?

        rec = class_memory.reflect
        class_memory.record(
          type:       :reflection,
          content:    rec.summary,
          outcome:    "success",
          importance: 0.8
        )
        state.merge(last_reflection: rec.summary)
      end

      on :register_node do |state:, payload:, **|
        topology = state[:topology] || NetworkTopology.new
        topology.register(
          node_id: payload.fetch(:node_id),
          host:    payload.fetch(:host),
          role:    payload[:role]
        )
        state.merge(topology: topology)
      end

      on :node_heartbeat do |state:, payload:, **|
        state[:topology]&.touch(node_id: payload.fetch(:node_id))
        state
      end

      on :signal_scale do |state:, payload:, **|
        role = payload.fetch(:role)
        class_memory&.record(
          type:    :scale_signal,
          content: "scale_out:#{role}",
          outcome: nil
        )
        state
      end

      private

      # Assess the network topology and execute the resulting plan.
      # Returns the updated state hash.
      #
      # @param state   [Hash]
      # @param payload [Hash]
      # @return [Hash]
      def run_assess_network(state, payload)
        topology = state[:topology] || NetworkTopology.new
        planner  = ExpansionPlanner.new(
          topology:       topology,
          memory:         self.class.class_memory,
          required_roles: Array(payload[:required_roles] || state[:required_roles]),
          host_pool:      Array(payload[:host_pool]      || state[:host_pool])
        )

        plan = planner.plan

        plan.actions.each do |action|
          case action[:action]
          when :replicate_role
            run_replicate_role(action, topology)
          when :retire_node
            topology.remove(node_id: action[:node_id])
            deliver(:node_retired, node_id: action[:node_id], host: action[:host])
          end
        end

        self.class.class_memory&.record(
          type:    :assessment,
          content: plan.rationale.to_s,
          outcome: "success"
        )

        state.merge(topology: topology, last_plan: plan.to_h)
      end

      # Execute a :replicate_role action: call run_replicate + register in topology.
      #
      # @param action   [Hash]
      # @param topology [NetworkTopology]
      def run_replicate_role(action, topology)
        role_obj = RoleRegistry.registered?(action[:role]) ? RoleRegistry.fetch(action[:role]) : nil
        env      = role_obj&.env_overrides || {}

        run_replicate(
          host:                 action.fetch(:host),
          user:                 action.fetch(:user, "deploy"),
          strategy:             action.fetch(:strategy, :git),
          env:                  env,
          bootstrapper_options: action.fetch(:bootstrapper_options, {})
        )

        topology.register(node_id: SecureRandom.uuid, host: action[:host], role: action[:role])
        deliver(:role_replicated, host: action[:host], role: action[:role])
      end
    end
    end
  end
end
