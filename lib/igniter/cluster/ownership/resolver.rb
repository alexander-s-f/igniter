# frozen_string_literal: true

module Igniter
  module Cluster
    module Ownership
      class Resolver
        def initialize(registry:, mesh_router: nil)
          @registry = registry
          @mesh_router = mesh_router
        end

        def resolve(entity_type, entity_id, fallback_capability: nil, deferred_result: nil)
          claim = @registry.lookup(entity_type, entity_id)
          if claim
            return {
              mode: :owner,
              owner: claim.owner,
              claim: claim,
              url: mesh_router.resolve_pinned(claim.owner)
            }
          end

          if fallback_capability
            return {
              mode: :capability,
              owner: nil,
              claim: nil,
              url: mesh_router.find_peer_for(fallback_capability, deferred_result)
            }
          end

          raise NoOwnerError.new(entity_type, entity_id)
        end

        def resolve_url(entity_type, entity_id, fallback_capability: nil, deferred_result: nil)
          resolve(
            entity_type,
            entity_id,
            fallback_capability: fallback_capability,
            deferred_result: deferred_result
          ).fetch(:url)
        end

        private

        def mesh_router
          @mesh_router ||= Igniter::Cluster::Mesh.router
        end
      end
    end
  end
end
