# frozen_string_literal: true

module Igniter
  module Compiler
    module Validators
      class RemoteValidator
        def self.call(context)
          new(context).call
        end

        def initialize(context)
          @context = context
        end

        def call
          @context.runtime_nodes.each do |node|
            next unless node.kind == :remote

            validate_url!(node)
            validate_contract_name!(node)
            validate_dependencies!(node)
          end
        end

        private

        def validate_url!(node)
          return if node.routing_mode != :static

          return if node.node_url.start_with?("http://", "https://")

          raise @context.validation_error(
            node,
            "remote :#{node.name} has invalid node: URL '#{node.node_url}'. Must start with http:// or https://"
          )
        end

        def validate_contract_name!(node)
          return unless node.contract_name.strip.empty?

          raise @context.validation_error(
            node,
            "remote :#{node.name} requires a non-empty contract: name"
          )
        end

        def validate_dependencies!(node)
          node.dependencies.each do |dep_name|
            next if @context.dependency_resolvable?(dep_name)

            raise @context.validation_error(
              node,
              "remote :#{node.name} depends on '#{dep_name}' which is not defined in the graph"
            )
          end
        end
      end
    end
  end
end
