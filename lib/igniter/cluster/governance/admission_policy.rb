# frozen_string_literal: true

module Igniter
  module Cluster
    module Governance
      # Declarative policy that governs how new peer admission requests are evaluated.
      #
      # Evaluation order (first match wins):
      #   1. Peer's node_id already in TrustStore            → :already_trusted
      #   2. Request carries a forbidden capability           → :rejected
      #   3. Peer's fingerprint matches a known_key entry     → :admitted (auto)
      #   4. require_approval: true (default)                 → :pending_approval
      #   5. require_approval: false                          → :admitted (open)
      #
      # Usage:
      #   policy = AdmissionPolicy.new(
      #     known_keys:          { "node-a" => "abc123fingerprint" },
      #     require_approval:    true,
      #     forbidden_capabilities: [:admin]
      #   )
      class AdmissionPolicy
        attr_reader :known_keys, :require_approval, :forbidden_capabilities, :max_pending_ttl

        # @param known_keys           [Hash<node_id → fingerprint>]  auto-admit these nodes
        # @param require_approval     [Boolean]  default true — unknown peers queue for approval
        # @param forbidden_capabilities [Array<Symbol>]  immediate rejection if present
        # @param max_pending_ttl      [Integer]  seconds before a pending request expires (default 3600)
        def initialize(known_keys: {}, require_approval: true, forbidden_capabilities: [], max_pending_ttl: 3600)
          @known_keys             = Hash(known_keys).transform_keys(&:to_s).freeze
          @require_approval       = require_approval
          @forbidden_capabilities = Array(forbidden_capabilities).map(&:to_sym).freeze
          @max_pending_ttl        = max_pending_ttl.to_i
        end

        # Evaluate the request against this policy given the current TrustStore.
        #
        # @param request    [AdmissionRequest]
        # @param trust_store [Trust::TrustStore]
        # @return [Symbol]  :admitted | :rejected | :pending_approval | :already_trusted
        def evaluate(request, trust_store)
          return :already_trusted if trust_store.known?(request.node_id)

          if forbidden_capabilities.any? { |cap| request.capabilities.include?(cap) }
            return :rejected
          end

          expected_fp = known_keys[request.node_id]
          if expected_fp && expected_fp.to_s == request.fingerprint
            return :admitted
          end

          require_approval ? :pending_approval : :admitted
        end

        def to_h
          {
            known_keys:             known_keys,
            require_approval:       require_approval,
            forbidden_capabilities: forbidden_capabilities,
            max_pending_ttl:        max_pending_ttl
          }
        end
      end
    end
  end
end
