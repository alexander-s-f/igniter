# frozen_string_literal: true

# Standard library of ready-made non-AI Igniter agents.
#
# Usage:
#   require "igniter/agents"
#
# Provides production-grade generic agents:
#
#   Reliability   — Igniter::Agents::RetryAgent
#   Pipeline      — Igniter::Agents::BatchProcessorAgent
#   Scheduling    — Igniter::Agents::CronAgent
#   Proactive     — Igniter::Agents::ProactiveAgent  (base)
#                   Igniter::Agents::AlertAgent
#                   Igniter::Agents::HealthCheckAgent
#   Observability — Igniter::Agents::MetricsAgent
#
# AI-oriented agents live under:
#   require "igniter/sdk/ai/agents"
#   Igniter::AI::Agents::*
#
require_relative "core"
require_relative "agents/reliability/retry_agent"
require_relative "agents/pipeline/batch_processor_agent"
require_relative "agents/scheduling/cron_agent"
require_relative "agents/proactive_agent"
require_relative "agents/proactive/alert_agent"
require_relative "agents/proactive/health_check_agent"
require_relative "agents/observability/metrics_agent"

module Igniter
  module Agents
    # Convenience method — list all registered generic stdlib agents.
    #
    # @return [Array<Class>]
    def self.all
      [RetryAgent, BatchProcessorAgent, CronAgent,
       ProactiveAgent, AlertAgent, HealthCheckAgent,
       MetricsAgent]
    end
  end
end
