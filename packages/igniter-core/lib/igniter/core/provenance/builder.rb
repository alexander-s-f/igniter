# frozen_string_literal: true

module Igniter
  module Provenance
    # Builds a Lineage object for a named output by traversing the compiled
    # graph and reading resolved values from the execution cache.
    #
    # The builder memoises each NodeTrace so that shared dependencies
    # (diamond patterns) point to the same object rather than being duplicated.
    class Builder
      class << self
        # Build lineage for +output_name+ from a resolved +execution+.
        def build(output_name, execution)
          new(execution).build(output_name)
        end
      end

      def initialize(execution)
        @graph = execution.compiled_graph
        @cache = execution.cache
      end

      def build(output_name) # rubocop:disable Metrics/MethodLength
        sym = output_name.to_sym

        raise ProvenanceError, "No output named '#{sym}' in #{@graph.name}" unless @graph.output?(sym)

        output_node = @graph.fetch_output(sym)
        source_name = output_node.source_root

        source_node = begin
          @graph.fetch_node(source_name)
        rescue KeyError
          raise ProvenanceError, "Source node '#{source_name}' for output '#{sym}' not found in graph"
        end

        trace = build_trace(source_node, {})
        Lineage.new(trace)
      end

      private

      # Recursively build a NodeTrace for +node+.
      # +memo+ prevents re-processing the same node in diamond-dependency graphs.
      def build_trace(node, memo) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        return memo[node.name] if memo.key?(node.name)

        # Reserve the slot to handle (unlikely) circular edge during traversal
        memo[node.name] = nil

        state = @cache.fetch(node.name)
        value = extract_value(state)

        contributing = {}
        node.dependencies.each do |dep_name|
          dep_node = safe_fetch_node(dep_name)
          next unless dep_node

          contributing[dep_name] = build_trace(dep_node, memo)
        end

        trace = NodeTrace.new(
          name: node.name,
          kind: node.kind,
          value: value,
          contributing: contributing
        )
        memo[node.name] = trace
        trace
      end

      def safe_fetch_node(name)
        @graph.fetch_node(name)
      rescue KeyError
        nil
      end

      # Extract a display-friendly value from a NodeState.
      # Composition/Collection results are summarised as hashes.
      def extract_value(state) # rubocop:disable Metrics/MethodLength
        return nil unless state

        if state.failed?
          return {
            failed: true,
            error: {
              type: state.error.class.name,
              message: state.error.message,
              context: state.error.respond_to?(:context) ? state.error.context : {}
            }
          }
        end

        val = state.value
        case val
        when Runtime::Result
          val.to_h
        when Runtime::CollectionResult
          val.summary
        when Runtime::DeferredResult
          {
            pending: true,
            event: val.waiting_on,
            payload: val.payload,
            routing_trace: val.routing_trace,
            agent_trace: val.agent_trace
          }.compact
        else
          val
        end
      end
    end
  end
end
