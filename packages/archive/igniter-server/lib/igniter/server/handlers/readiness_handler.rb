# frozen_string_literal: true

module Igniter
  module Server
    module Handlers
      # GET /v1/ready — Kubernetes readiness probe.
      #
      # Returns 200 when the server is ready to accept traffic:
      #   - Store is reachable (list_pending does not raise)
      #   - At least one contract is registered
      #
      # Returns 503 when the server should be removed from the load balancer
      # rotation but NOT restarted. A failing readiness probe causes K8s to
      # stop routing traffic to the pod without killing it.
      class ReadinessHandler < Base
        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument,Metrics/MethodLength
          checks = {}

          # Store connectivity check
          checks[:store] = check_store

          # Contract registration check
          checks[:contracts] = @registry.names.any? ? "ok" : "no_contracts_registered"

          if checks.values.all? { |v| v == "ok" }
            json_ok({ status: "ready", checks: checks })
          else
            service_unavailable({ status: "not_ready", checks: checks })
          end
        end

        def check_store
          @store.list_pending(graph: nil)
          "ok"
        rescue StandardError => e
          "error: #{e.message}"
        end

        def service_unavailable(data)
          { status: 503, body: JSON.generate(data), headers: { "Content-Type" => "application/json" } }
        end
      end
    end
  end
end
