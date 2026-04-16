# frozen_string_literal: true

module Igniter
  module Model
    # Represents a node that executes a contract on a remote igniter-stack node.
    # The result is the outputs hash returned by the remote contract.
    #
    # Three routing modes:
    #   :static     — node_url is a hard-coded URL (original behaviour)
    #   :capability — auto-select an alive peer via capability shorthand or query
    #   :pinned     — must use the specific named peer; IncidentError if down
    class RemoteNode < Node
      attr_reader :contract_name, :node_url, :input_mapping, :timeout,
                  :capability, :capability_query, :pinned_to

      def initialize(id:, name:, contract_name:, input_mapping:, # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
                     node_url: "", timeout: 30, path: nil, metadata: {},
                     capability: nil, capability_query: nil, pinned_to: nil)
        super(
          id: id,
          kind: :remote,
          name: name,
          path: path || name.to_s,
          dependencies: input_mapping.values.map(&:to_sym),
          metadata: metadata
        )
        @contract_name = contract_name.to_s
        @node_url      = node_url.to_s
        @input_mapping = input_mapping.transform_keys(&:to_sym).transform_values(&:to_sym).freeze
        @timeout       = Integer(timeout)
        @capability    = capability&.to_sym
        @capability_query = normalize_query(capability_query)
        @pinned_to     = pinned_to&.to_s
      end

      # Returns :static, :capability, or :pinned.
      def routing_mode
        return :pinned     if @pinned_to
        return :capability if @capability || @capability_query

        :static
      end

      private

      def normalize_query(query)
        case query
        when nil
          nil
        when Symbol, String
          { all_of: [query.to_sym] }.freeze
        when Array
          { all_of: query.map(&:to_sym).freeze }.freeze
        when Hash
          query.each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] =
              if value.is_a?(Array)
                value.map { |item| item.is_a?(String) || item.is_a?(Symbol) ? item.to_sym : item }.freeze
              elsif value.is_a?(String) || value.is_a?(Symbol)
                value.to_sym
              else
                value
              end
          end.freeze
        else
          query
        end
      end
    end
  end
end
