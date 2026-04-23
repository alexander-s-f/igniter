# frozen_string_literal: true

require "time"
require_relative "assistant_runtime"

module Companion
  module Main
    module Support
      class AssistantAdapter < Igniter::Runtime::AgentAdapter
        def call(node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
          runtime = Companion::Main::Support::AssistantRuntime.overview

          {
            status: :pending,
            payload: {
              requester: inputs.fetch(:requester).to_s.strip,
              request: inputs.fetch(:request).to_s.strip,
              requested_at: Time.now.utc.iso8601,
              runtime: runtime.fetch(:status)
            },
            agent_trace: {
              adapter: :companion_assistant,
              via: node.agent_name,
              message: node.message_name,
              routing_mode: node.routing_mode,
              session_policy: node.session_policy,
              outcome: :manual_followup_required,
              reason: runtime.dig(:status, :reason),
              mode: runtime.dig(:config, :mode),
              provider: runtime.dig(:config, :provider),
              model: runtime.dig(:config, :model)
            }
          }
        end
      end
    end
  end
end
