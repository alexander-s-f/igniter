# frozen_string_literal: true

# Standard library of ready-made Igniter agents.
#
# Usage:
#   require "igniter/agents"
#
# Provides production-grade agents per domain:
#
#   Reliability   — Igniter::Agents::RetryAgent
#   Pipeline      — Igniter::Agents::BatchProcessorAgent
#   Scheduling    — Igniter::Agents::CronAgent
#   AI/LLM        — Igniter::Agents::RouterAgent
#                   Igniter::Agents::CriticAgent
#                   Igniter::Agents::PlannerAgent
#                   Igniter::Agents::ChainAgent
#                   Igniter::Agents::SelfReflectionAgent
#                   Igniter::Agents::ObserverAgent
#                   Igniter::Agents::EvaluatorAgent
#                   Igniter::Agents::EvolutionAgent
#   Proactive     — Igniter::Agents::ProactiveAgent  (base)
#                   Igniter::Agents::AlertAgent
#                   Igniter::Agents::HealthCheckAgent
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
require_relative "agents/ai/self_reflection_agent"
require_relative "agents/ai/observer_agent"
require_relative "agents/ai/evaluator_agent"
require_relative "agents/ai/evolution_agent"
require_relative "agents/proactive_agent"
require_relative "agents/ai/alert_agent"
require_relative "agents/ai/health_check_agent"
require_relative "agents/observability/metrics_agent"

module Igniter
  module Agents
    # Convenience method — list all registered stdlib agents.
    #
    # @return [Array<Class>]
    def self.all
      [RetryAgent, BatchProcessorAgent, CronAgent,
       RouterAgent, CriticAgent, PlannerAgent, ChainAgent,
       SelfReflectionAgent, ObserverAgent, EvaluatorAgent, EvolutionAgent,
       AlertAgent, HealthCheckAgent,
       MetricsAgent]
    end
  end
end
