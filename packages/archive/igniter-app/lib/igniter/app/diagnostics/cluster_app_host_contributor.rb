# frozen_string_literal: true

module Igniter
  class App
    module Diagnostics
      module ClusterAppHostContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            app = report[:app]
            return report unless app
            return report unless app[:host] == :cluster_app

            cluster_settings = Hash(app.dig(:host_settings, :cluster_app) || {})
            server_settings = Hash(app.dig(:host_settings, :app) || {})

            report[:cluster_app_host] = {
              adapter: :cluster_app,
              peer_name: cluster_settings[:peer_name],
              local_capabilities: Array(cluster_settings[:local_capabilities]).map(&:to_sym).sort,
              local_tags: Array(cluster_settings[:local_tags]).map(&:to_sym).sort,
              local_metadata: Hash(cluster_settings[:local_metadata] || {}),
              local_metadata_keys: Hash(cluster_settings[:local_metadata] || {}).keys.map(&:to_s).sort,
              seeds: Array(cluster_settings[:seeds]),
              seed_count: Array(cluster_settings[:seeds]).size,
              static_peers: Array(cluster_settings[:peers]).map { |peer| serialize_peer(peer) },
              static_peer_count: Array(cluster_settings[:peers]).size,
              discovery_interval: cluster_settings[:discovery_interval],
              auto_announce: cluster_settings[:auto_announce],
              local_url: cluster_settings[:local_url],
              gossip_fanout: cluster_settings[:gossip_fanout],
              start_discovery: cluster_settings[:start_discovery],
              server: {
                host: server_settings[:host],
                port: server_settings[:port],
                log_format: server_settings[:log_format],
                drain_timeout: server_settings[:drain_timeout]
              }
            }
            report
          end

          def append_text(report:, lines:)
            cluster_host = report[:cluster_app_host]
            return unless cluster_host

            lines << "Cluster Host: #{summary(cluster_host)}"
          end

          def append_markdown_summary(report:, lines:)
            cluster_host = report[:cluster_app_host]
            return unless cluster_host

            lines << "- Cluster Host: #{summary(cluster_host)}"
          end

          def append_markdown_sections(report:, lines:)
            cluster_host = report[:cluster_app_host]
            return unless cluster_host

            lines << ""
            lines << "## Cluster App Host"
            lines << "- Peer: name=`#{cluster_host[:peer_name] || "anonymous"}` local_url=`#{cluster_host[:local_url] || "n/a"}`"
            lines << "- Capabilities: total=#{cluster_host[:local_capabilities].size}, names=#{cluster_host[:local_capabilities].join(", ")}"
            lines << "- Tags: total=#{cluster_host[:local_tags].size}, names=#{cluster_host[:local_tags].join(", ")}"
            lines << "- Mesh: seeds=#{cluster_host[:seed_count]}, static_peers=#{cluster_host[:static_peer_count]}, discovery_interval=#{cluster_host[:discovery_interval]}, auto_announce=#{cluster_host[:auto_announce]}, start_discovery=#{cluster_host[:start_discovery]}, gossip_fanout=#{cluster_host[:gossip_fanout]}"
            lines << "- Server: host=`#{cluster_host.dig(:server, :host)}` port=`#{cluster_host.dig(:server, :port)}` log_format=`#{cluster_host.dig(:server, :log_format)}`"
          end

          private

          def serialize_peer(peer)
            normalized = Hash(peer || {})
            {
              name: normalized[:name],
              url: normalized[:url],
              capabilities: Array(normalized[:capabilities]).map(&:to_sym).sort,
              tags: Array(normalized[:tags]).map(&:to_sym).sort,
              metadata_keys: Hash(normalized[:metadata] || {}).keys.map(&:to_s).sort
            }
          end

          def summary(cluster_host)
            [
              "peer=#{cluster_host[:peer_name] || "anonymous"}",
              "capabilities=#{cluster_host[:local_capabilities].size}",
              "tags=#{cluster_host[:local_tags].size}",
              "seeds=#{cluster_host[:seed_count]}",
              "static_peers=#{cluster_host[:static_peer_count]}",
              "auto_announce=#{cluster_host[:auto_announce]}",
              "start_discovery=#{cluster_host[:start_discovery]}"
            ].join(", ")
          end
        end
      end
    end
  end
end
