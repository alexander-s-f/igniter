# frozen_string_literal: true

require_relative "node_identity_catalog"

module Companion
  module Shared
    module CapabilityProfile
      module_function

      DEFAULT_SERVICE = "seed"
      DEFAULT_PORT = 4667
      DEFAULTS = {
        "seed" => {
          role: "seed",
          port: 4667,
          declared_capabilities: %i[mesh_seed notes_api routing],
          mocked_capabilities: [:notifications],
          tags: %i[local seed],
          seeds: []
        },
        "edge" => {
          role: "edge",
          port: 4668,
          declared_capabilities: %i[notes_api speech_io],
          mocked_capabilities: %i[piper_tts whisper_asr],
          tags: %i[audio edge local],
          seeds: ["http://127.0.0.1:4667"]
        },
        "analyst" => {
          role: "analyst",
          port: 4669,
          declared_capabilities: %i[assistant_orchestration notes_api],
          mocked_capabilities: %i[local_llm rag],
          tags: %i[analyst local reasoning],
          seeds: ["http://127.0.0.1:4667"]
        }
      }.freeze

      def current(env = ENV)
        service_name = string(env["IGNITER_SERVICE"], default: DEFAULT_SERVICE)
        defaults = DEFAULTS.fetch(service_name, {})
        node_name = string(env["COMPANION_NODE_NAME"], default: "companion-#{service_name}")
        node_role = string(env["COMPANION_NODE_ROLE"], default: defaults.fetch(:role, service_name))
        port = integer(env["PORT"], default: defaults.fetch(:port, DEFAULT_PORT))
        local_url = string(env["COMPANION_NODE_URL"], default: "http://127.0.0.1:#{port}")

        declared = csv(env["COMPANION_LOCAL_CAPABILITIES"], default: defaults.fetch(:declared_capabilities, []))
        mocked = csv(env["COMPANION_MOCK_CAPABILITIES"], default: defaults.fetch(:mocked_capabilities, []))
        tags = csv(env["COMPANION_NODE_TAGS"], default: defaults.fetch(:tags, []))
        seeds = csv_strings(env["COMPANION_SEEDS"], default: defaults.fetch(:seeds, []))

        {
          service_name: service_name,
          node_name: node_name,
          node_role: node_role,
          port: port,
          local_url: local_url,
          declared_capabilities: declared,
          mocked_capabilities: mocked,
          effective_capabilities: (declared + mocked).uniq.sort,
          tags: tags,
          seeds: seeds,
          start_discovery: truthy?(env["COMPANION_START_DISCOVERY"]),
          auto_self_heal: truthy?(env["COMPANION_AUTO_SELF_HEAL"]),
          self_heal_interval: integer(env["COMPANION_SELF_HEAL_INTERVAL"], default: 15),
          auto_announce: !falsy?(env["COMPANION_AUTO_ANNOUNCE"]),
          identity: NodeIdentityCatalog.identity_for(node_name),
          trust_store: NodeIdentityCatalog.trust_store,
          metadata: {
            companion: {
              service: service_name,
              role: node_role,
              declared_capabilities: declared,
              mocked_capabilities: mocked
            }
          }
        }
      end

      def discovery_snapshot(env = ENV)
        profile = current(env)

        {
          node: {
            name: profile[:node_name],
            service: profile[:service_name],
            role: profile[:node_role],
            port: profile[:port],
            url: profile[:local_url]
          },
          identity: {
            node_id: profile[:identity].node_id,
            fingerprint: profile[:identity].fingerprint,
            algorithm: profile[:identity].algorithm
          },
          trust: {
            known_peers: profile[:trust_store].size,
            entries: profile[:trust_store].to_h[:entries]
          },
          governance: {
            trail: Igniter::Cluster::Mesh.config.governance_trail.snapshot(limit: 5),
            checkpoint: governance_checkpoint_snapshot
          },
          capabilities: {
            declared: profile[:declared_capabilities],
            mocked: profile[:mocked_capabilities],
            effective: profile[:effective_capabilities]
          },
          tags: profile[:tags],
          seeds: profile[:seeds],
          discovery: {
            start: profile[:start_discovery],
            auto_announce: profile[:auto_announce],
            auto_self_heal: profile[:auto_self_heal],
            self_heal_interval: profile[:self_heal_interval]
          }
        }
      end

      def discovered_peers
        return [] unless defined?(Igniter::Cluster::Mesh)

        Igniter::Cluster::Mesh.config.peer_registry.all.map do |peer|
          {
            name: peer.name,
            url: peer.url,
            capabilities: peer.capabilities,
            tags: peer.tags,
            metadata: peer.metadata,
            identity: peer.metadata[:mesh_identity],
            trust: peer.metadata[:mesh_trust]
          }
        end.sort_by { |peer| peer.fetch(:name) }
      rescue StandardError
        []
      end

      def configure_cluster!(config, env = ENV)
        profile = current(env)

        config.peer_name = profile[:node_name]
        config.local_capabilities = profile[:effective_capabilities]
        config.local_tags = profile[:tags]
        config.local_metadata = profile[:metadata]
        config.seeds = profile[:seeds]
        config.local_url = profile[:local_url]
        config.start_discovery = profile[:start_discovery]
        config.auto_announce = profile[:auto_announce]
        config.auto_self_heal = profile[:auto_self_heal]
        config.self_heal_interval = profile[:self_heal_interval]
        config.identity = profile[:identity]
        config.trust_store = profile[:trust_store]
      end

      def governance_checkpoint_snapshot
        checkpoint = Igniter::Cluster::Mesh.config.governance_checkpoint(limit: 5)
        assessment = Igniter::Cluster::Trust::Verifier.assess_governance_checkpoint(
          checkpoint,
          trust_store: Igniter::Cluster::Mesh.config.trust_store
        )

        {
          node_id: checkpoint.node_id,
          fingerprint: checkpoint.fingerprint,
          crest_digest: checkpoint.crest_digest,
          checkpointed_at: checkpoint.checkpointed_at,
          trust: assessment.to_h
        }
      rescue StandardError
        nil
      end

      def csv(value, default: [])
        text = value.to_s.strip
        items = if text.empty?
                  Array(default)
                else
                  text.split(",")
                end

        items.map { |entry| entry.to_s.strip }.reject(&:empty?).map(&:to_sym).uniq.sort
      end

      def csv_strings(value, default: [])
        text = value.to_s.strip
        items = if text.empty?
                  Array(default)
                else
                  text.split(",")
                end

        items.map { |entry| entry.to_s.strip }.reject(&:empty?).uniq.sort
      end

      def truthy?(value)
        %w[1 true yes on].include?(value.to_s.strip.downcase)
      end

      def falsy?(value)
        %w[0 false no off].include?(value.to_s.strip.downcase)
      end

      def string(value, default:)
        text = value.to_s.strip
        text.empty? ? default.to_s : text
      end

      def integer(value, default:)
        text = value.to_s.strip
        text.empty? ? default.to_i : Integer(text)
      end
    end
  end
end
