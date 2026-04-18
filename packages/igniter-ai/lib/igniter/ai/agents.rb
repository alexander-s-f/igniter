# frozen_string_literal: true

require "igniter/core"
require_relative "agents/router_agent"
require_relative "agents/critic_agent"
require_relative "agents/planner_agent"
require_relative "agents/chain_agent"
require_relative "agents/self_reflection_agent"
require_relative "agents/observer_agent"
require_relative "agents/evaluator_agent"
require_relative "agents/evolution_agent"

module Igniter
  module AI
    module Agents
      # Convenience method — list all built-in AI agents.
      #
      # @return [Array<Class>]
      def self.all
        [RouterAgent, CriticAgent, PlannerAgent, ChainAgent,
         SelfReflectionAgent, ObserverAgent, EvaluatorAgent, EvolutionAgent]
      end
    end
  end
end
