# frozen_string_literal: true

require "base64"
require "json"
require "openssl"
require "time"

module Igniter
  module Cluster
    module Governance
      class Checkpoint
        attr_reader :peer_name, :node_id, :algorithm, :public_key, :crest,
                    :checkpointed_at, :signature, :previous_digest

        def self.build(identity:, peer_name:, trail:, limit: 10, checkpointed_at: Time.now.utc.iso8601, previous: nil)
          crest = trail.snapshot(limit: limit)
          payload = {
            peer_name: peer_name.to_s,
            node_id: identity.node_id,
            algorithm: identity.algorithm,
            public_key: identity.public_key_pem,
            crest: crest_payload(crest),
            checkpointed_at: checkpointed_at.to_s
          }
          payload[:previous_digest] = previous.crest_digest if previous

          new(payload.merge(signature: identity.sign(payload)))
        end

        def self.from_h(hash)
          new(hash)
        end

        def self.crest_payload(crest)
          normalized = symbolize_keys(crest || {})
          {
            total: normalized[:total].to_i,
            latest_type: normalized[:latest_type]&.to_sym,
            latest_at: normalized[:latest_at],
            by_type: symbolize_keys(normalized[:by_type] || {}),
            persistence: symbolize_keys(normalized[:persistence] || {}),
            events: Array(normalized[:events]).map { |event| normalize_event(event) }
          }
        end

        def initialize(hash)
          source = self.class.send(:symbolize_keys, hash || {})
          @peer_name = source[:peer_name].to_s.freeze
          @node_id = source[:node_id].to_s.freeze
          @algorithm = source[:algorithm].to_s.freeze
          @public_key = source[:public_key].to_s.freeze
          @crest = self.class.crest_payload(source[:crest]).freeze
          @checkpointed_at = source[:checkpointed_at].to_s.freeze
          @signature = source[:signature].to_s.freeze
          @previous_digest = source[:previous_digest]&.to_s&.freeze
          freeze
        end

        def payload
          base = {
            peer_name: peer_name,
            node_id: node_id,
            algorithm: algorithm,
            public_key: public_key,
            crest: crest,
            checkpointed_at: checkpointed_at
          }
          base[:previous_digest] = previous_digest if previous_digest
          base
        end

        def chained?
          !previous_digest.nil?
        end

        def verify_signature
          return false if public_key.empty? || signature.empty?

          key = OpenSSL::PKey.read(public_key)
          key.verify(OpenSSL::Digest::SHA256.new, Base64.strict_decode64(signature), canonical_json(payload))
        rescue OpenSSL::PKey::PKeyError, ArgumentError
          false
        end

        def fingerprint
          return nil if public_key.empty?

          OpenSSL::Digest::SHA256.hexdigest(OpenSSL::PKey.read(public_key).to_der)[0, 24]
        rescue OpenSSL::PKey::PKeyError
          nil
        end

        def crest_digest
          OpenSSL::Digest::SHA256.hexdigest(canonical_json(crest))[0, 24]
        end

        def to_h
          payload.merge(signature: signature)
        end

        private

        def canonical_json(value)
          JSON.generate(deep_sort(value))
        end

        def deep_sort(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, nested), memo|
              memo[key.to_s] = deep_sort(nested)
            end.sort.to_h
          when Array
            value.map { |item| deep_sort(item) }
          when Symbol
            value.to_s
          else
            value
          end
        end

        class << self
          private

          def symbolize_keys(hash)
            hash.each_with_object({}) do |(key, value), memo|
              memo[key.to_sym] = value
            end
          end

          def normalize_event(event)
            source = symbolize_keys(event || {})
            source[:type] = source[:type]&.to_sym
            source[:source] = source[:source]&.to_sym
            source
          end
        end
      end
    end
  end
end
