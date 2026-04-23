# frozen_string_literal: true

module Igniter
  module Runtime
    class AgentResultContract
      attr_reader :kind, :waiting_on, :source_node, :session_lifecycle_state, :phase,
                  :interaction_contract, :tool_runtime, :ownership, :owner_url,
                  :delivery_route, :interactive, :terminal, :continuable, :routed

      def self.from_result(result, kind:)
        session = result.session if result.respond_to?(:session)
        trace = result.agent_trace if result.respond_to?(:agent_trace)
        return nil unless session || trace

        new(
          kind: kind,
          waiting_on: result.waiting_on,
          source_node: result.source_node,
          session_lifecycle_state: session&.lifecycle_state,
          phase: session&.phase,
          interaction_contract: session&.interaction_contract&.to_h,
          tool_runtime: session&.tool_runtime,
          ownership: session&.ownership,
          owner_url: session&.owner_url,
          delivery_route: session&.delivery_route,
          interactive: session ? session.interactive? : false,
          terminal: session ? session.terminal? : false,
          continuable: session ? session.continuable? : false,
          routed: session ? session.routed? : trace_routed?(trace)
        )
      end

      def initialize(kind:, waiting_on:, source_node:, session_lifecycle_state:, phase:, # rubocop:disable Metrics/ParameterLists
                     interaction_contract:, tool_runtime:, ownership:, owner_url:,
                     delivery_route:, interactive:, terminal:, continuable:, routed:)
        @kind = kind&.to_sym
        @waiting_on = waiting_on&.to_sym
        @source_node = source_node&.to_sym
        @session_lifecycle_state = session_lifecycle_state&.to_sym
        @phase = phase&.to_sym
        @interaction_contract = interaction_contract&.dup&.freeze
        @tool_runtime = tool_runtime&.dup&.freeze
        @ownership = ownership&.to_sym
        @owner_url = owner_url&.to_s
        @delivery_route = delivery_route&.dup&.freeze
        @interactive = !!interactive
        @terminal = !!terminal
        @continuable = !!continuable
        @routed = !!routed
        freeze
      end

      def deferred?
        kind == :deferred
      end

      def stream?
        kind == :stream
      end

      def to_h
        {
          kind: kind,
          waiting_on: waiting_on,
          source_node: source_node,
          session_lifecycle_state: session_lifecycle_state,
          phase: phase,
          interaction_contract: interaction_contract,
          tool_runtime: tool_runtime,
          ownership: ownership,
          owner_url: owner_url,
          delivery_route: delivery_route,
          interactive: interactive,
          terminal: terminal,
          continuable: continuable,
          routed: routed
        }.compact.freeze
      end

      private

      def self.trace_routed?(trace)
        return false unless trace.is_a?(Hash)

        %i[node capability query pinned_to url peer_url].any? do |key|
          trace.key?(key) || trace.key?(key.to_s)
        end
      end
    end
  end
end
