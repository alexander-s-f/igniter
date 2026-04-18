# frozen_string_literal: true

module Igniter
  module Server
    # HTTP/mesh transport adapter for Runtime remote nodes.
    class RemoteAdapter < Igniter::Runtime::RemoteAdapter
      def call(node:, inputs:, execution: nil) # rubocop:disable Lint/UnusedMethodArgument
        url = resolve_url(node)
        Client.new(url, timeout: node.timeout).execute(node.contract_name, inputs: inputs)
      rescue Client::ConnectionError => e
        raise ResolutionError, "Cannot reach #{url}: #{e.message}"
      end

      private

      def resolve_url(node)
        case node.routing_mode
        when :static
          node.node_url
        else
          raise ResolutionError,
                "remote :#{node.name} uses #{node.routing_mode} routing — add `require 'igniter/cluster'`"
        end
      end
    end
  end
end
