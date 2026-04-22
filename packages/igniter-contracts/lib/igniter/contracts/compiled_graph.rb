# frozen_string_literal: true

module Igniter
  module Contracts
    CompiledGraph = Struct.new(:operations, :profile_fingerprint, keyword_init: true) do
      def initialize(operations:, profile_fingerprint:)
        frozen_operations = operations.map { |operation| operation.dup.freeze }.freeze
        super(operations: frozen_operations, profile_fingerprint: profile_fingerprint)
      end
    end
  end
end
