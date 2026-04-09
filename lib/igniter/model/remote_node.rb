# frozen_string_literal: true

module Igniter
  module Model
    # Represents a node that executes a contract on a remote igniter-server node.
    # The result is the outputs hash returned by the remote contract.
    class RemoteNode < Node
      attr_reader :contract_name, :node_url, :input_mapping, :timeout

      def initialize(id:, name:, contract_name:, node_url:, input_mapping:, timeout: 30, path: nil, metadata: {})
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
      end
    end
  end
end
