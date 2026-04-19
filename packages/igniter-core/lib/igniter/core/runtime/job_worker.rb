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

      def resume_agent_session(execution_id:, session:, node_name: nil, value: Execution::UNDEFINED_RESUME_VALUE)
        contract = @contract_class.restore_from_store(execution_id, store: @store)
        contract.execution.resume_agent_session(session, node_name: node_name, value: value)
        contract
      end

      def continue_agent_session(execution_id:, session:, payload:, trace: nil, token: nil, waiting_on: nil, request: nil, reply: nil, phase: nil)
        contract = @contract_class.restore_from_store(execution_id, store: @store)
        contract.execution.continue_agent_session(
          session,
          payload: payload,
          trace: trace,
          token: token,
          waiting_on: waiting_on,
          request: request,
          reply: reply,
          phase: phase
        )
        @contract_class.restore_from_store(execution_id, store: @store)
      end
    end
  end
end
