# frozen_string_literal: true

module Igniter
  module Cluster
    module Diagnostics
      module IdentityContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            return report unless defined?(Igniter::Cluster::Mesh)

            config = Igniter::Cluster::Mesh.config
            local_identity = config.identity || safe_generated_identity(config)
            peers = summarize_peers(config.peer_registry.all)

            report[:cluster_identity] = {
              local: local_identity ? summarize_identity(local_identity) : nil,
              trust_store: config.trust_store.to_h,
              peers: peers,
              counts: {
                peers: peers.size,
                trusted: peers.count { |peer| peer.dig(:trust, :status) == :trusted },
                unknown: peers.count { |peer| peer.dig(:trust, :status) == :unknown },
                attested: peers.count { |peer| !peer[:capabilities_attestation].nil? },
                attested_trusted: peers.count { |peer| peer.dig(:capabilities_attestation, :trust, :status) == :trusted },
                invalid: peers.count do |peer|
                  %i[invalid_signature key_mismatch missing_identity missing_signature].include?(peer.dig(:trust, :status))
                end
              }
            }

            report
          end

          def append_text(report:, lines:)
            summary = report[:cluster_identity]
            return unless summary

            counts = summary[:counts]
            lines << "Cluster Identity: local=#{summary.dig(:local, :node_id) || 'none'} fingerprint=#{summary.dig(:local, :fingerprint) || 'none'} peers=#{counts[:peers]} trusted=#{counts[:trusted]} unknown=#{counts[:unknown]} attested=#{counts[:attested]} attested_trusted=#{counts[:attested_trusted]} invalid=#{counts[:invalid]}"
          end

          def append_markdown_summary(report:, lines:)
            summary = report[:cluster_identity]
            return unless summary

            counts = summary[:counts]
            lines << "- Cluster Identity: local=`#{summary.dig(:local, :node_id) || 'none'}` peers=#{counts[:peers]} trusted=#{counts[:trusted]} unknown=#{counts[:unknown]} attested=#{counts[:attested]} attested_trusted=#{counts[:attested_trusted]} invalid=#{counts[:invalid]}"
          end

          def append_markdown_sections(report:, lines:)
            summary = report[:cluster_identity]
            return unless summary

            lines << ""
            lines << "## Cluster Identity"
            lines << "- Local: node_id=`#{summary.dig(:local, :node_id) || 'none'}` fingerprint=`#{summary.dig(:local, :fingerprint) || 'none'}`"
            lines << "- Trust Store: known=#{summary.dig(:trust_store, :size)}"

            summary[:peers].each do |peer|
              lines << "- `#{peer[:name]}` node_id=`#{peer.dig(:identity, :node_id) || 'unknown'}` trust=`#{peer.dig(:trust, :status) || 'unknown'}` attestation=`#{peer.dig(:capabilities_attestation, :trust, :status) || 'none'}` fingerprint=`#{peer.dig(:identity, :fingerprint) || 'none'}`"
            end
          end

          private

          def summarize_identity(identity)
            {
              node_id: identity.node_id,
              algorithm: identity.algorithm,
              fingerprint: identity.fingerprint,
              created_at: identity.created_at
            }
          end

          def summarize_peers(peers)
            peers.map do |peer|
              {
                name: peer.name,
                url: peer.url,
                identity: peer.metadata[:mesh_identity],
                trust: peer.metadata[:mesh_trust],
                capabilities_attestation: peer.metadata[:mesh_capabilities]
              }
            end.sort_by { |peer| peer[:name].to_s }
          end

          def safe_generated_identity(config)
            return nil unless config.peer_name

            config.ensure_identity!
          rescue StandardError
            nil
          end
        end
      end
    end
  end
end
