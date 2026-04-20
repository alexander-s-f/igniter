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
            validate_reply_mode!(node)
            validate_finalizer!(node)
            validate_tool_loop_policy!(node)
            validate_session_policy!(node)
            validate_routing!(node)
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
          return if Model::AgentInteractionContract::MODES.include?(node.mode)

          raise @context.validation_error(
            node,
            "agent :#{node.name} mode must be :call or :cast"
          )
        end

        def validate_reply_mode!(node)
          unless Model::AgentInteractionContract::REPLY_MODES.include?(node.reply_mode)
            raise @context.validation_error(
              node,
              "agent :#{node.name} reply must be :single, :deferred, :stream, or :none"
            )
          end

          return unless node.mode == :cast && node.reply_mode != :none

          raise @context.validation_error(
            node,
            "agent :#{node.name} mode :cast only supports reply: :none"
          )
        end

        def validate_finalizer!(node)
          return if node.finalizer.nil?
          return if node.reply_mode == :stream

          raise @context.validation_error(
            node,
            "agent :#{node.name} finalizer requires reply: :stream"
          )
        end

        def validate_tool_loop_policy!(node)
          return if node.tool_loop_policy.nil?

          unless Model::AgentInteractionContract::TOOL_LOOP_POLICIES.include?(node.tool_loop_policy)
            raise @context.validation_error(
              node,
              "agent :#{node.name} tool_loop_policy must be :ignore, :resolved, or :complete"
            )
          end

          return if node.reply_mode == :stream

          raise @context.validation_error(
            node,
            "agent :#{node.name} tool_loop_policy requires reply: :stream"
          )
        end

        def validate_session_policy!(node)
          return if node.session_policy.nil?

          unless Model::AgentInteractionContract::SESSION_POLICIES.include?(node.session_policy)
            raise @context.validation_error(
              node,
              "agent :#{node.name} session_policy must be :interactive, :single_turn, or :manual"
            )
          end

          return if node.reply_mode == :stream

          raise @context.validation_error(
            node,
            "agent :#{node.name} session_policy requires reply: :stream"
          )
        end

        def validate_routing!(node)
          return if Model::AgentInteractionContract::ROUTING_MODES.include?(node.routing_mode)

          raise @context.validation_error(
            node,
            "agent :#{node.name} routing mode must be :local, :static, :capability, or :pinned"
          )
        end
      end
    end
  end
end
