# frozen_string_literal: true

module Igniter
  module Cluster
    module Ownership
      class Error < Igniter::Error; end

      class NoOwnerError < Error
        attr_reader :entity_type, :entity_id

        def initialize(entity_type, entity_id)
          @entity_type = entity_type.to_s
          @entity_id = entity_id.to_s
          super("No owner registered for #{entity_type}:#{entity_id}")
        end
      end
    end
  end
end
