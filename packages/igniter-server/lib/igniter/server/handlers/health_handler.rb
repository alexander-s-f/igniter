# frozen_string_literal: true

module Igniter
  module Server
    module Handlers
      class HealthHandler < Base
        def initialize(registry, store, node_url: nil)
          super(registry, store)
          @node_url = node_url
        end

        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument,Metrics/MethodLength
          pending_count = begin
            @store.list_pending.size
          rescue StandardError
            0
          end

          json_ok({
                    status: "ok",
                    node: @node_url,
                    contracts: @registry.names,
                    store: @store.class.name.split("::").last,
                    pending: pending_count
                  })
        end
      end
    end
  end
end
