# frozen_string_literal: true

module Igniter
  module Runtime
    class JobWorker
      def initialize(contract_class, store: Igniter.execution_store)
        @contract_class = contract_class
        @store = store
      end

      def resume(execution_id:, token:, value:)
        contract = @contract_class.restore_from_store(execution_id, store: @store)
        contract.execution.resume_by_token(token, value: value)
        contract
      end
    end
  end
end
