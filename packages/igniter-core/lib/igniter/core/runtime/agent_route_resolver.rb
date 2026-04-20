# frozen_string_literal: true

require_relative "agent_route"

module Igniter
  module Runtime
    # Resolves an agent node into a concrete delivery route.
    class AgentRouteResolver
      def resolve(node:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        case node.routing_mode
        when :local
          AgentRoute.local(via: node.agent_name, message: node.message_name)
        when :static
          AgentRoute.static(
            via: node.agent_name,
            message: node.message_name,
            url: node.node_url
          )
        else
          raise ResolutionError,
                "agent :#{node.name} uses #{node.routing_mode} routing — add `require 'igniter/cluster'`"
        end
      end
    end
  end
end
