# frozen_string_literal: true

module Igniter
  module Extensions
    module Reactive
      class Matcher
        def initialize(reaction, event)
          @reaction = reaction
          @event = event
        end

        def match?
          return false unless @reaction.event_type == @event.type
          return true unless @reaction.path

          @reaction.path == @event.path
        end
      end
    end
  end
end
