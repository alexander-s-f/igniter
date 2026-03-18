# frozen_string_literal: true

module Igniter
  module Extensions
    module Reactive
      class Reaction
        attr_reader :event_type, :path, :action

        def initialize(event_type:, path: nil, action:)
          @event_type = event_type.to_sym
          @path = path&.to_s
          @action = action
        end
      end
    end
  end
end
