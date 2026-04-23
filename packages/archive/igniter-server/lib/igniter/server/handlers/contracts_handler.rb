# frozen_string_literal: true

module Igniter
  module Server
    module Handlers
      class ContractsHandler < Base
        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument
          json_ok(@registry.introspect)
        end
      end
    end
  end
end
