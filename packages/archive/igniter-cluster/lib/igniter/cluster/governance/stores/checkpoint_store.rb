# frozen_string_literal: true

require "fileutils"
require "json"

module Igniter
  module Cluster
    module Governance
      module Stores
        # File-backed store for a single signed Governance::Checkpoint.
        #
        # Saves the latest checkpoint as JSON. On load, deserializes and
        # optionally verifies the RSA/ECDSA signature before returning.
        #
        # Typical usage:
        #   store  = CheckpointStore.new(path: "var/governance/checkpoint.json")
        #   record = Mesh.compact_governance!(identity: identity, peer_name: "node-a")
        #   store.save(record.checkpoint)
        #
        #   # On restart:
        #   cp = store.load_verified   # nil if missing or tampered
        class CheckpointStore
          attr_reader :path

          def initialize(path:)
            @path = path.to_s
            FileUtils.mkdir_p(File.dirname(@path))
          end

          # Persist a Checkpoint to disk (overwrites any previous checkpoint).
          #
          # @param checkpoint [Checkpoint]
          # @return [self]
          def save(checkpoint)
            File.write(@path, JSON.generate(checkpoint.to_h))
            self
          end

          # Load the most recently saved Checkpoint, or nil if none exists.
          #
          # @return [Checkpoint, nil]
          def load
            return nil unless File.exist?(@path)

            Checkpoint.from_h(deep_symbolize(JSON.parse(File.read(@path))))
          rescue JSON::ParserError
            nil
          end

          # Load and verify the Checkpoint's signature.
          # Returns nil if the file is missing, malformed, or the signature is invalid.
          #
          # @return [Checkpoint, nil]
          def load_verified
            cp = load
            return nil unless cp&.verify_signature

            cp
          end

          # Remove the persisted checkpoint.
          #
          # @return [self]
          def clear!
            FileUtils.rm_f(@path)
            self
          end

          def exists?
            File.exist?(@path)
          end

          private

          def deep_symbolize(value)
            case value
            when Hash
              value.each_with_object({}) { |(k, v), h| h[k.to_sym] = deep_symbolize(v) }
            when Array
              value.map { |v| deep_symbolize(v) }
            else
              value
            end
          end
        end
      end
    end
  end
end
