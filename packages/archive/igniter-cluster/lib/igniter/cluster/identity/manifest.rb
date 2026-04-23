# frozen_string_literal: true

require "base64"
require "json"
require "openssl"
require "time"

module Igniter
  module Cluster
    module Identity
      class Manifest
        attr_reader :peer_name, :node_id, :algorithm, :public_key, :url,
                    :capabilities, :tags, :metadata, :contracts, :capability_attestation, :signed_at, :signature

        def self.build(identity:, peer_name:, url:, capabilities:, tags:, metadata:, contracts:, capability_attestation: nil, signed_at: Time.now.utc.iso8601)
          attestation = capability_attestation || Igniter::Cluster::Identity::CapabilityAttestation.build(
            identity: identity,
            peer_name: peer_name,
            url: url,
            capabilities: capabilities,
            tags: tags,
            metadata: metadata
          )

          payload = {
            peer_name: peer_name.to_s,
            node_id: identity.node_id,
            algorithm: identity.algorithm,
            public_key: identity.public_key_pem,
            url: url.to_s,
            capabilities: Array(capabilities).map(&:to_s),
            tags: Array(tags).map(&:to_s),
            metadata: Hash(metadata || {}),
            contracts: Array(contracts).map(&:to_s),
            capability_attestation: attestation.to_h,
            signed_at: signed_at.to_s
          }

          new(payload.merge(signature: identity.sign(payload)))
        end

        def self.from_h(hash)
          new(hash)
        end

        def initialize(hash)
          source = symbolize_keys(hash || {})
          @peer_name = source[:peer_name].to_s.freeze
          @node_id = source[:node_id].to_s.freeze
          @algorithm = source[:algorithm].to_s.freeze
          @public_key = source[:public_key].to_s.freeze
          @url = source[:url].to_s.freeze
          @capabilities = Array(source[:capabilities]).map(&:to_sym).freeze
          @tags = Array(source[:tags]).map(&:to_sym).freeze
          @metadata = Hash(source[:metadata] || {}).freeze
          @contracts = Array(source[:contracts]).map(&:to_s).freeze
          @capability_attestation = source[:capability_attestation].is_a?(Hash) ? Igniter::Cluster::Identity::CapabilityAttestation.from_h(source[:capability_attestation]) : nil
          @signed_at = source[:signed_at].to_s.freeze
          @signature = source[:signature].to_s.freeze
          freeze
        end

        def payload
          {
            peer_name: peer_name,
            node_id: node_id,
            algorithm: algorithm,
            public_key: public_key,
            url: url,
            capabilities: capabilities.map(&:to_s),
            tags: tags.map(&:to_s),
            metadata: metadata,
            contracts: contracts,
            capability_attestation: capability_attestation&.to_h,
            signed_at: signed_at
          }
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

        def identity_summary
          {
            node_id: node_id,
            algorithm: algorithm,
            public_key: public_key,
            fingerprint: fingerprint,
            signed_at: signed_at
          }
        end

        def to_h
          payload.merge(signature: signature)
        end

        private

        def symbolize_keys(hash)
          hash.each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end
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
