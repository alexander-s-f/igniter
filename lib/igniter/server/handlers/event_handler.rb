# frozen_string_literal: true

module Igniter
  module Server
    module Handlers
      class EventHandler < Base
        private

        def handle(params:, body:) # rubocop:disable Metrics/MethodLength
          contract_class = @registry.fetch(params[:name])
          event       = body["event"]&.to_sym
          correlation = symbolize_inputs(body["correlation"] || {})
          payload     = body["payload"] || {}

          raise Igniter::Error, "event name is required" unless event

          contract = contract_class.deliver_event(event,
                                                  correlation: correlation,
                                                  payload: payload,
                                                  store: @store)
          contract.resolve_all unless contract.success? || contract.failed?

          json_ok(serialize_execution(contract, contract_class))
        end
      end
    end
  end
end
