# frozen_string_literal: true

module Igniter
  module Cluster
    module Trust
      class AdmissionRunner
        def initialize(config:)
          @config = config
        end

        def run(plan, approve: false)
          applied = []
          blocked = []

          plan.actions.each do |action|
            if action[:requires_approval] && !approve
              blocked_entry = {
                id: action[:id],
                action: action[:action],
                status: :blocked,
                reason: :approval_required,
                params: action[:params]
              }
              blocked << blocked_entry
              record(
                :trust_admission_blocked,
                action: action,
                payload: {
                  peer_name: action.dig(:params, :peer_name),
                  node_id: action.dig(:params, :node_id),
                  reason: :approval_required
                }
              )
              next
            end

            applied << execute(action)
          end

          AdmissionResult.new(
            applied: applied,
            blocked: blocked,
            summary: {
              status: applied.any? ? :applied : :blocked,
              source_status: plan.summary[:status],
              applied: applied.size,
              blocked: blocked.size
            }
          )
        end

        private

        def execute(action)
          case action[:action]
          when :admit_trusted_peer
            params = action[:params]
            @config.trust_store.add(
              params.fetch(:node_id),
              public_key: params.fetch(:public_key),
              label: params[:label]
            )
            refresh_peer_trust!(params[:peer_name])

            record(
              :trust_admission_applied,
              action: action,
              payload: {
                peer_name: params[:peer_name],
                node_id: params[:node_id],
                label: params[:label],
                scope: action[:scope]
              }
            )

            {
              id: action[:id],
              action: action[:action],
              status: :applied,
              scope: action[:scope],
              params: params
            }
          else
            raise ArgumentError, "Unsupported trust admission action #{action[:action].inspect}"
          end
        end

        def refresh_peer_trust!(peer_name)
          peer = @config.peer_registry.peer_named(peer_name)
          return unless peer

          manifest = peer.metadata.dig(:mesh_identity, :manifest)
          return unless manifest.is_a?(Hash)

          attributes = Igniter::Cluster::Mesh::PeerIdentityEnvelope.build(
            source: manifest,
            trust_store: @config.trust_store
          )

          @config.peer_registry.register(
            Igniter::Cluster::Mesh::Peer.new(
              name: attributes[:name],
              url: attributes[:url],
              capabilities: attributes[:capabilities],
              tags: attributes[:tags],
              metadata: attributes[:metadata]
            )
          )
        end

        def record(type, action:, payload:)
          @config.governance_trail&.record(
            type,
            source: :trust_admission_runner,
            payload: {
              action: action[:action],
              requires_approval: action[:requires_approval],
              automated: action[:automated]
            }.merge(payload)
          )
        end
      end
    end
  end
end
