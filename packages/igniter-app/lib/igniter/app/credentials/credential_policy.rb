# frozen_string_literal: true

module Igniter
  class App
    module Credentials
      class CredentialPolicy < Igniter::DTO::Record
        field :name, required: true, coerce: ->(value) { value.to_sym }
        field :label, required: true, coerce: ->(value) { value.to_s }
        field :secret_class, required: true, coerce: ->(value) { value.to_sym }
        field :propagation, required: true, coerce: ->(value) { value.to_sym }
        field :route_over_replicate, required: true, coerce: ->(value) { !!value }
        field :weak_trust_behavior, required: true, coerce: ->(value) { value.to_sym }
        field :operator_approval_required, required: true, coerce: ->(value) { !!value }
        field :description, default: "", coerce: ->(value) { value.to_s }
        field :metadata, default: -> { {} }, coerce: :normalize_metadata, merge: true

        def local_only?
          propagation == :disabled || secret_class == :local_only
        end

        def allows_scope?(scope)
          normalized_scope = scope.to_sym
          return true if normalized_scope == :local

          !local_only?
        end

        private

        def self.normalize_metadata(hash)
          (hash || {}).each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end.freeze
        end
      end
    end
  end
end
