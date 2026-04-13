# frozen_string_literal: true

module Igniter
  module Cluster
    module Ownership
      class Registry
        def initialize
          @claims = {}
          @mutex = Mutex.new
        end

        def claim(entity_type, entity_id, owner:, metadata: {})
          claim = Claim.new(
            entity_type: entity_type,
            entity_id: entity_id,
            owner: owner,
            metadata: metadata
          )
          @mutex.synchronize { @claims[claim.key] = claim }
          claim
        end

        def lookup(entity_type, entity_id)
          @mutex.synchronize { @claims[claim_key(entity_type, entity_id)] }
        end

        def owner_for(entity_type, entity_id)
          lookup(entity_type, entity_id)&.owner
        end

        def claimed?(entity_type, entity_id)
          !lookup(entity_type, entity_id).nil?
        end

        def release(entity_type, entity_id, owner: nil)
          @mutex.synchronize do
            key = claim_key(entity_type, entity_id)
            existing = @claims[key]
            return nil unless existing
            return nil if owner && existing.owner != owner.to_s

            @claims.delete(key)
          end
        end

        def claims_for_owner(owner)
          @mutex.synchronize do
            @claims.values.select { |claim| claim.owner == owner.to_s }
          end
        end

        def all
          @mutex.synchronize { @claims.values.dup }
        end

        def clear
          @mutex.synchronize { @claims.clear }
        end

        private

        def claim_key(entity_type, entity_id)
          "#{entity_type}:#{entity_id}"
        end
      end
    end
  end
end
