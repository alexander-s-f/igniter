# frozen_string_literal: true

module Igniter
  module Saga
    # Immutable record of a single compensation that was attempted.
    class CompensationRecord
      attr_reader :node_name, :error

      def initialize(node_name:, success:, error: nil)
        @node_name = node_name
        @success = success
        @error = error
        freeze
      end

      def success? = @success
      def failed?  = !@success
    end
  end
end
