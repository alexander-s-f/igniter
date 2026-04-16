# frozen_string_literal: true

module Igniter
  module Cluster
    module Replication
      # Immutable snapshot of a node's observable runtime traits.
      #
      # Profiles bridge host discovery and cluster replication: a node can inspect
      # its environment, derive capability coordinates, and advertise which
      # capability queries it can currently satisfy.
      class NodeProfile
        DEFAULT_CAPABILITY_MAP = {
          "ruby" => :ruby,
          "bundle" => :ruby,
          "rake" => :ruby,
          "rspec" => :ruby,
          "git" => :source_control,
          "curl" => :http_client,
          "wget" => :http_client,
          "jq" => :json_cli,
          "sqlite3" => :data_store,
          "psql" => :data_store,
          "redis-cli" => :data_store,
          "python3" => :python,
          "pip3" => :python,
          "node" => :javascript,
          "npm" => :javascript,
          "yarn" => :javascript,
          "pnpm" => :javascript,
          "docker" => :container_runtime,
          "docker-compose" => :container_runtime,
          "ffmpeg" => :media_processing,
          "ollama" => :local_llm,
          "pio" => :embedded,
          "arduino-cli" => :embedded,
          "esptool.py" => :embedded,
          "make" => :native_build,
          "gcc" => :native_build,
          "clang" => :native_build
        }.freeze

        attr_reader :hostname, :platform, :os, :cpu, :utilities,
                    :capabilities, :tags, :metadata

        def self.from_discovery(snapshot, capabilities: [], tags: [],
                                capability_map: DEFAULT_CAPABILITY_MAP)
          utility_candidates = Array(snapshot.dig(:paths, :utility_candidates))
          discovered = utility_candidates.filter_map do |entry|
            next unless entry[:present]

            entry[:name].to_s
          end

          discovered |= Array(snapshot.dig(:paths, :discovered_executables)).map(&:to_s)
          derived_capabilities = discovered.flat_map { |name| Array(capability_map[name]) }

          new(
            hostname:     snapshot.dig(:host, :hostname),
            platform:     snapshot.dig(:host, :platform),
            os:           snapshot.dig(:host, :os),
            cpu:          snapshot.dig(:host, :cpu),
            utilities:    discovered,
            capabilities: derived_capabilities + Array(capabilities),
            tags:         inferred_tags(snapshot) + Array(tags),
            metadata:     { generated_at: snapshot[:generated_at] }
          )
        end

        def self.inferred_tags(snapshot)
          tags = []
          os   = snapshot.dig(:host, :os).to_s.downcase
          cpu  = snapshot.dig(:host, :cpu).to_s

          tags << :darwin if os.include?("darwin")
          tags << :linux if os.include?("linux")
          tags << cpu.tr("-", "_").to_sym unless cpu.empty?

          ruby_engine = snapshot.dig(:runtime, :ruby, :engine).to_s
          tags << ruby_engine.to_sym unless ruby_engine.empty?
          tags
        end

        def initialize(hostname: nil, platform: nil, os: nil, cpu: nil,
                       utilities: [], capabilities: [], tags: [], metadata: {})
          @hostname     = hostname&.to_s
          @platform     = platform&.to_s
          @os           = os&.to_s
          @cpu          = cpu&.to_s
          @utilities    = Array(utilities).map(&:to_s).uniq.sort.freeze
          @capabilities = Array(capabilities).map(&:to_sym).uniq.sort.freeze
          @tags         = Array(tags).map(&:to_sym).uniq.sort.freeze
          @metadata     = Hash(metadata).transform_keys(&:to_sym).freeze
          freeze
        end

        def capability?(capability)
          @capabilities.include?(capability.to_sym)
        end

        def tag?(tag)
          @tags.include?(tag.to_sym)
        end

        def to_h
          {
            hostname: @hostname,
            platform: @platform,
            os: @os,
            cpu: @cpu,
            utilities: @utilities,
            capabilities: @capabilities,
            tags: @tags,
            metadata: @metadata
          }
        end
      end
    end
  end
end
