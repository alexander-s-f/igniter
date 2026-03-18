# frozen_string_literal: true

module Igniter
  module Extensions
    module Reactive
      class Reaction
        attr_reader :event_type, :path, :action, :once_per_execution

        def initialize(event_type:, path: nil, action:, once_per_execution: false)
          @event_type = event_type.to_sym
          @path = path&.to_s
          @action = action
          @once_per_execution = once_per_execution
        end
      end
    end
  end
end
