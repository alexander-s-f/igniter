# frozen_string_literal: true

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
        end

        def call(event)
          reactions.each do |reaction|
            next unless Matcher.new(reaction, event).match?

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
      end
    end
  end
end
