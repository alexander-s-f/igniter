# frozen_string_literal: true

require "time"

module Igniter
  module Cluster
    module Ownership
      class Claim
        attr_reader :entity_type, :entity_id, :owner, :metadata, :claimed_at, :updated_at

        def initialize(entity_type:, entity_id:, owner:, metadata: {}, claimed_at: nil, updated_at: nil)
          now = (updated_at || claimed_at || Time.now.utc).utc
          @entity_type = entity_type.to_s.freeze
          @entity_id = entity_id.to_s.freeze
          @owner = owner.to_s.freeze
          @metadata = stringify_keys(metadata).freeze
          @claimed_at = (claimed_at || now).utc.freeze
          @updated_at = now.freeze
          freeze
        end

        def key
          "#{entity_type}:#{entity_id}"
        end

        def with(owner: self.owner, metadata: self.metadata, updated_at: Time.now.utc)
          self.class.new(
            entity_type: entity_type,
            entity_id: entity_id,
            owner: owner,
            metadata: metadata,
            claimed_at: claimed_at,
            updated_at: updated_at
          )
        end

        private

        def stringify_keys(hash)
          hash.each_with_object({}) do |(key, value), memo|
            memo[key.to_s] = value
          end
        end
      end
    end
  end
end
