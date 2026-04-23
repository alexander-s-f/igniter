# frozen_string_literal: true

require "set"

module Igniter
  module Extensions
    module Reactive
      class Engine
        attr_reader :execution, :contract, :reactions, :errors

        def initialize(execution:, contract:, reactions:)
          @execution = execution
          @contract = contract
          @reactions = reactions
          @errors = []
          @fired_reactions = Set.new
        end

        def call(event)
          reactions.each do |reaction|
            next unless Matcher.new(reaction, event).match?
            next if already_fired?(reaction, event)

            mark_fired(reaction, event)
            call_action(
              reaction.action,
              event: event,
              contract: contract,
              execution: execution,
              value: value_for(event)
            )
          rescue StandardError => e
            @errors << {
              event: event,
              reaction: reaction,
              error: e
            }
          end
        end

        private

        def call_action(action, **kwargs)
          parameters = action.parameters
          accepts_any_keywords = parameters.any? { |kind, _name| kind == :keyrest }

          if accepts_any_keywords
            action.call(**kwargs)
            return
          end

          accepted_keywords = parameters.select { |kind, _name| %i[key keyreq].include?(kind) }.map(&:last)
          filtered_kwargs = kwargs.slice(*accepted_keywords)
          action.call(**filtered_kwargs)
        end

        def value_for(event)
          return nil unless %i[node_succeeded node_resumed node_pending].include?(event.type)
          return nil unless event.node_name

          state = execution.cache.fetch(event.node_name)
          state&.value
        end

        def already_fired?(reaction, event)
          return false unless reaction.once_per_execution

          @fired_reactions.include?(reaction_key(reaction, event))
        end

        def mark_fired(reaction, event)
          return unless reaction.once_per_execution

          @fired_reactions << reaction_key(reaction, event)
        end

        def reaction_key(reaction, event)
          [reaction.object_id, event.execution_id]
        end
      end
    end
  end
end
