# frozen_string_literal: true

module Igniter
  module Model
    class AwaitNode < Node
      attr_reader :event_name

      def initialize(id:, name:, event_name:, path: nil, metadata: {})
        super(
          id: id,
          kind: :await,
          name: name,
          path: path || name.to_s,
          dependencies: [],
          metadata: metadata
        )
        @event_name = event_name.to_sym
      end
    end
  end
end
