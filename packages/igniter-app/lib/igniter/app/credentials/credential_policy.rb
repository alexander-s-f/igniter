# frozen_string_literal: true

module Igniter
  class App
    module Credentials
      class CredentialPolicy
        attr_reader :name, :label, :secret_class, :propagation, :route_over_replicate,
                    :weak_trust_behavior, :operator_approval_required, :description, :metadata

        def initialize(name:, label:, secret_class:, propagation:, route_over_replicate:,
                       weak_trust_behavior:, operator_approval_required:, description: "", metadata: {})
          @name = name.to_sym
          @label = label.to_s
          @secret_class = secret_class.to_sym
          @propagation = propagation.to_sym
          @route_over_replicate = !!route_over_replicate
          @weak_trust_behavior = weak_trust_behavior.to_sym
          @operator_approval_required = !!operator_approval_required
          @description = description.to_s
          @metadata = normalize_metadata(metadata)
          freeze
        end

        def self.from_h(policy_hash)
          normalized = (policy_hash || {}).each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end

          new(
            name: normalized.fetch(:name),
            label: normalized.fetch(:label),
            secret_class: normalized.fetch(:secret_class),
            propagation: normalized.fetch(:propagation),
            route_over_replicate: normalized.fetch(:route_over_replicate),
            weak_trust_behavior: normalized.fetch(:weak_trust_behavior),
            operator_approval_required: normalized.fetch(:operator_approval_required),
            description: normalized.fetch(:description, ""),
            metadata: normalized.fetch(:metadata, {})
          )
        end

        def local_only?
          propagation == :disabled || secret_class == :local_only
        end

        def allows_scope?(scope)
          normalized_scope = scope.to_sym
          return true if normalized_scope == :local

          !local_only?
        end

        def with(**overrides)
          self.class.new(
            name: overrides.fetch(:name, name),
            label: overrides.fetch(:label, label),
            secret_class: overrides.fetch(:secret_class, secret_class),
            propagation: overrides.fetch(:propagation, propagation),
            route_over_replicate: overrides.fetch(:route_over_replicate, route_over_replicate),
            weak_trust_behavior: overrides.fetch(:weak_trust_behavior, weak_trust_behavior),
            operator_approval_required: overrides.fetch(:operator_approval_required, operator_approval_required),
            description: overrides.fetch(:description, description),
            metadata: metadata.merge(normalize_metadata(overrides.fetch(:metadata, {})))
          )
        end

        def to_h
          {
            name: name,
            label: label,
            secret_class: secret_class,
            propagation: propagation,
            route_over_replicate: route_over_replicate,
            weak_trust_behavior: weak_trust_behavior,
            operator_approval_required: operator_approval_required,
            description: description,
            metadata: metadata
          }.freeze
        end

        private

        def normalize_metadata(hash)
          (hash || {}).each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end.freeze
        end
      end
    end
  end
end
