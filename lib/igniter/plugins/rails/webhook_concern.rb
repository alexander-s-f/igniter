# frozen_string_literal: true

module Igniter
  module Rails
    # Controller mixin for delivering external events to running contracts.
    #
    # Usage:
    #   class WebhooksController < ApplicationController
    #     include Igniter::Rails::WebhookHandler
    #
    #     def stripe
    #       deliver_event_for(
    #         OrderContract,
    #         event:            :stripe_payment_succeeded,
    #         correlation_from: { order_id: params[:metadata][:order_id] },
    #         payload:          params.to_unsafe_h
    #       )
    #     end
    #   end
    module WebhookHandler
      def deliver_event_for(contract_class, event:, correlation_from:, payload: nil, store: nil) # rubocop:disable Metrics/MethodLength
        payload_data = payload || (respond_to?(:params) ? params.to_unsafe_h : {})
        correlation = extract_correlation(correlation_from)

        contract_class.deliver_event(
          event,
          correlation: correlation,
          payload: payload_data,
          store: store || Igniter.execution_store
        )

        head :ok
      rescue Igniter::ResolutionError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def extract_correlation(source)
        case source
        when Hash then source.transform_keys(&:to_sym)
        when Symbol then { source => params[source] }
        when Array then source.each_with_object({}) { |k, h| h[k.to_sym] = params[k] }
        else source.to_h.transform_keys(&:to_sym)
        end
      end
    end
  end
end
