# frozen_string_literal: true

module Igniter
  module Server
    module Handlers
      # GET /v1/live — Kubernetes liveness probe.
      #
      # Returns 200 as long as the process is running. This endpoint should
      # NEVER return a non-200 status unless the process is truly broken (e.g.
      # deadlocked). A failing liveness probe causes K8s to restart the pod.
      class LivenessHandler < Base
        private

        def handle(params:, body:) # rubocop:disable Lint/UnusedMethodArgument
          json_ok({ status: "alive", pid: Process.pid })
        end
      end
    end
  end
end
