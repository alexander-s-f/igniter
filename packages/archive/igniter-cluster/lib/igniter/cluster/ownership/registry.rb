# frozen_string_literal: true

module Igniter
  module Cluster
    module Ownership
      class Registry
        def initialize(store: nil, collection: "igniter_cluster_ownership_claims")
          @store = store
          @collection = collection.to_s
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
          write_claim(claim)
          claim
        end

        def lookup(entity_type, entity_id)
          key = claim_key(entity_type, entity_id)
          if persistent?
            payload = @store.get(collection: @collection, key: key)
            payload ? Claim.from_h(payload) : nil
          else
            @mutex.synchronize { @claims[key] }
          end
        end

        def owner_for(entity_type, entity_id)
          lookup(entity_type, entity_id)&.owner
        end

        def claimed?(entity_type, entity_id)
          !lookup(entity_type, entity_id).nil?
        end

        def release(entity_type, entity_id, owner: nil)
          key = claim_key(entity_type, entity_id)
          existing = lookup(entity_type, entity_id)
          return nil unless existing
          return nil if owner && existing.owner != owner.to_s

          if persistent?
            @store.delete(collection: @collection, key: key)
          else
            @mutex.synchronize { @claims.delete(key) }
          end
        end

        def claims_for_owner(owner)
          @mutex.synchronize do
            @claims.values.select { |claim| claim.owner == owner.to_s }
          end
        end

        def all
          if persistent?
            @store.all(collection: @collection).values.map { |payload| Claim.from_h(payload) }
          else
            @mutex.synchronize { @claims.values.dup }
          end
        end

        def clear
          if persistent?
            @store.clear(collection: @collection)
          else
            @mutex.synchronize { @claims.clear }
          end
        end

        private

        def persistent?
          !@store.nil?
        end

        def write_claim(claim)
          if persistent?
            @store.put(collection: @collection, key: claim.key, value: claim.to_h)
          else
            @mutex.synchronize { @claims[claim.key] = claim }
          end
        end

        def claim_key(entity_type, entity_id)
          "#{entity_type}:#{entity_id}"
        end
      end
    end
  end
end
