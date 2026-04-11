# frozen_string_literal: true

# Standard library of ready-made Igniter agents.
#
# Usage:
#   require "igniter/agents"
#
# Provides one production-grade agent per domain:
#
#   Reliability   — Igniter::Agents::RetryAgent
#   Pipeline      — Igniter::Agents::BatchProcessorAgent
#   Scheduling    — Igniter::Agents::CronAgent
#   AI/LLM        — Igniter::Agents::RouterAgent
#                   Igniter::Agents::CriticAgent
#                   Igniter::Agents::PlannerAgent
#                   Igniter::Agents::ChainAgent
#   Observability — Igniter::Agents::MetricsAgent
#
require_relative "integrations/agents"
require_relative "agents/reliability/retry_agent"
require_relative "agents/pipeline/batch_processor_agent"
require_relative "agents/scheduling/cron_agent"
require_relative "agents/ai/router_agent"
require_relative "agents/ai/critic_agent"
require_relative "agents/ai/planner_agent"
require_relative "agents/ai/chain_agent"
require_relative "agents/observability/metrics_agent"

module Igniter
  module Agents
    # Convenience method — list all registered stdlib agents.
    #
    # @return [Array<Class>]
    def self.all
      [RetryAgent, BatchProcessorAgent, CronAgent,
       RouterAgent, CriticAgent, PlannerAgent, ChainAgent,
       MetricsAgent]
    end
  end
end
