# frozen_string_literal: true

require "igniter/agent"
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
