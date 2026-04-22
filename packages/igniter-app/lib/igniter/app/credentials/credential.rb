# frozen_string_literal: true

module Igniter
  class App
    module Credentials
      class Credential < Igniter::DTO::Record
        field :key, required: true, coerce: ->(value) { value.to_sym }
        field :label, required: true, coerce: ->(value) { value.to_s }
        field :provider, required: true, coerce: ->(value) { value.to_sym }
        field :scope, required: true, coerce: ->(value) { value.to_sym }
        field :node, coerce: ->(value) { value&.to_s }
        field :policy, required: true, coerce: :normalize_policy
        field :metadata, default: -> { {} }, coerce: :normalize_metadata, merge: true

        def local?
          scope == :local
        end

        def remote?
          !local?
        end

        def allowed_in_scope?(target_scope)
          policy.allows_scope?(target_scope)
        end

        private

        def self.normalize_policy(value)
          case value
          when CredentialPolicy
            value
          when Hash
            CredentialPolicy.from_h(value)
          else
            raise ArgumentError, "policy must be a CredentialPolicy or Hash"
          end
        end

        def self.normalize_metadata(hash)
          (hash || {}).each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end.freeze
        end
      end
    end
  end
end
