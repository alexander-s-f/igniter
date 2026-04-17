# frozen_string_literal: true

require "base64"
require "json"
require "openssl"
require "time"

module Igniter
  module Cluster
    module Identity
      class NodeIdentity
        DEFAULT_ALGORITHM = "rsa-sha256"

        attr_reader :node_id, :algorithm, :created_at

        def self.generate(node_id:, created_at: Time.now.utc.iso8601)
          key = OpenSSL::PKey::RSA.generate(2048)
          new(
            node_id: node_id,
            public_key_pem: key.public_key.to_pem,
            private_key_pem: key.to_pem,
            algorithm: DEFAULT_ALGORITHM,
            created_at: created_at
          )
        end

        def initialize(node_id:, public_key_pem:, private_key_pem:, algorithm: DEFAULT_ALGORITHM, created_at: nil)
          @node_id = node_id.to_s.freeze
          @public_key_pem = public_key_pem.to_s.freeze
          @private_key_pem = private_key_pem.to_s.freeze
          @algorithm = algorithm.to_s.freeze
          @created_at = (created_at || Time.now.utc.iso8601).to_s.freeze
          freeze
        end

        def sign(payload)
          encoded = canonical_json(payload)
          Base64.strict_encode64(private_key.sign(OpenSSL::Digest::SHA256.new, encoded))
        end

        def verify(payload, signature:)
          public_key.verify(
            OpenSSL::Digest::SHA256.new,
            Base64.strict_decode64(signature.to_s),
            canonical_json(payload)
          )
        rescue OpenSSL::PKey::PKeyError, ArgumentError
          false
        end

        def public_key_pem
          @public_key_pem
        end

        def private_key_pem
          @private_key_pem
        end

        def fingerprint
          OpenSSL::Digest::SHA256.hexdigest(public_key.to_der)[0, 24]
        end

        def to_h(include_private: false)
          payload = {
            node_id: node_id,
            algorithm: algorithm,
            public_key: public_key_pem,
            fingerprint: fingerprint,
            created_at: created_at
          }
          payload[:private_key] = private_key_pem if include_private
          payload
        end

        private

        def public_key
          OpenSSL::PKey.read(@public_key_pem)
        end

        def private_key
          OpenSSL::PKey.read(@private_key_pem)
        end

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
      end
    end
  end
end
