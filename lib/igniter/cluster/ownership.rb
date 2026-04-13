# frozen_string_literal: true

require_relative "ownership/errors"
require_relative "ownership/claim"
require_relative "ownership/registry"
require_relative "ownership/resolver"
require_relative "ownership/owner_client"

module Igniter
  module Cluster
    module Ownership
      class << self
        attr_reader :store

        def registry
          @registry ||= Registry.new(store: @store)
        end

        def resolver
          @resolver ||= Resolver.new(registry: registry)
        end

        def client
          @client ||= OwnerClient.new(resolver: resolver)
        end

        def configure
          yield self
        end

        def store=(store)
          @store = store
          @registry = nil
          @resolver = nil
          @client = nil
        end

        def claim(entity_type, entity_id, owner:, metadata: {})
          registry.claim(entity_type, entity_id, owner: owner, metadata: metadata)
        end

        def lookup(entity_type, entity_id)
          registry.lookup(entity_type, entity_id)
        end

        def owner_for(entity_type, entity_id)
          registry.owner_for(entity_type, entity_id)
        end

        def claimed?(entity_type, entity_id)
          registry.claimed?(entity_type, entity_id)
        end

        def release(entity_type, entity_id, owner: nil)
          registry.release(entity_type, entity_id, owner: owner)
        end

        def claims_for_owner(owner)
          registry.claims_for_owner(owner)
        end

        def resolve_url(entity_type, entity_id, fallback_capability: nil, deferred_result: nil)
          resolver.resolve_url(
            entity_type,
            entity_id,
            fallback_capability: fallback_capability,
            deferred_result: deferred_result
          )
        end

        def reset!
          @registry = nil
          @resolver = nil
          @client = nil
          @store = nil
        end
      end
    end
  end
end
