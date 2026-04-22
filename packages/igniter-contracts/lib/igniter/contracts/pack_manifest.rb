# frozen_string_literal: true

module Igniter
  module Contracts
    class PackManifest
      NodeContract = Struct.new(:kind, :requires_dsl, :requires_runtime, keyword_init: true) do
        def initialize(kind:, requires_dsl: true, requires_runtime: true)
          super(
            kind: kind.to_sym,
            requires_dsl: requires_dsl,
            requires_runtime: requires_runtime
          )
        end
      end

      class << self
        def node(kind, requires_dsl: true, requires_runtime: true)
          NodeContract.new(
            kind: kind,
            requires_dsl: requires_dsl,
            requires_runtime: requires_runtime
          )
        end
      end

      attr_reader :name, :node_contracts, :diagnostics, :metadata

      def initialize(name:, node_contracts: [], diagnostics: [], metadata: {})
        @name = name.to_sym
        @node_contracts = node_contracts.freeze
        @diagnostics = diagnostics.map(&:to_sym).freeze
        @metadata = metadata.freeze
        freeze
      end
    end
  end
end
