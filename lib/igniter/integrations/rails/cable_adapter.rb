# frozen_string_literal: true

module Igniter
  module Rails
    # ActionCable channel mixin for streaming contract execution events.
    #
    # Usage:
    #   class OrderChannel < ApplicationCable::Channel
    #     include Igniter::Rails::CableAdapter
    #
    #     subscribed do
    #       stream_contract(OrderContract, execution_id: params[:execution_id])
    #     end
    #   end
    #
    # Broadcasts events as:
    #   { type: "node_succeeded", node: "payment", status: "succeeded", payload: { ... } }
    module CableAdapter
      def stream_contract(contract_class, execution_id:, store: nil)
        resolved_store = store || Igniter.execution_store
        snapshot = resolved_store.fetch(execution_id)
        instance = contract_class.restore(snapshot)

        instance.subscribe do |event|
          broadcast_igniter_event(event, execution_id)
        end

        @_igniter_executions ||= []
        @_igniter_executions << instance
      rescue Igniter::ResolutionError => e
        transmit({ type: "error", message: e.message })
      end

      private

      def broadcast_igniter_event(event, execution_id)
        transmit({
          type: event.type.to_s,
          execution_id: execution_id,
          node: event.node_name,
          path: event.path,
          status: event.status,
          payload: event.payload,
          timestamp: event.timestamp&.iso8601
        }.compact)
      end
    end
  end
end
