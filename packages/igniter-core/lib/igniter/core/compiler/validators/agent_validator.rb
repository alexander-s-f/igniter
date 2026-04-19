# frozen_string_literal: true

module Igniter
  module Compiler
    module Validators
      class AgentValidator
        def self.call(context)
          new(context).call
        end

        def initialize(context)
          @context = context
        end

        def call
          @context.runtime_nodes.each do |node|
            next unless node.kind == :agent

            validate_agent_name!(node)
            validate_message_name!(node)
            validate_timeout!(node)
            validate_mode!(node)
          end
        end

        private

        def validate_agent_name!(node)
          return unless node.agent_name.to_s.strip.empty?

          raise @context.validation_error(
            node,
            "agent :#{node.name} requires a non-empty via:"
          )
        end

        def validate_message_name!(node)
          return unless node.message_name.to_s.strip.empty?

          raise @context.validation_error(
            node,
            "agent :#{node.name} requires a non-empty message:"
          )
        end

        def validate_timeout!(node)
          return if node.timeout.positive?

          raise @context.validation_error(
            node,
            "agent :#{node.name} timeout must be positive"
          )
        end

        def validate_mode!(node)
          return if %i[call cast].include?(node.mode)

          raise @context.validation_error(
            node,
            "agent :#{node.name} mode must be :call or :cast"
          )
        end
      end
    end
  end
end
