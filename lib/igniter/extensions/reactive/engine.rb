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

            reaction.action.call(
              event: event,
              contract: contract,
              execution: execution
            )
          rescue StandardError => e
            @errors << {
              event: event,
              reaction: reaction,
              error: e
            }
          end
        end
      end
    end
  end
end
