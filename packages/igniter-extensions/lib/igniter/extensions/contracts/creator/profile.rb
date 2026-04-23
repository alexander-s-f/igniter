# frozen_string_literal: true

module Igniter
  module Extensions
    module Contracts
      module Creator
        class Profile
          REGISTRY_CAPABILITIES = {
            node: :nodes,
            dsl_keyword: :dsl_keywords,
            validator: :validators,
            runtime_handler: :runtime_handlers,
            diagnostic: :diagnostics_contributors,
            effect: :effects,
            executor: :executors,
            dependency_pack: :pack_manifests
          }.freeze

          PRESETS = {
            feature_node: {
              kind: :feature,
              capabilities: %i[node dsl_keyword validator runtime_handler],
              dependency_hints: [],
              summary: "feature node pack with DSL, validation, and runtime"
            },
            diagnostic_bundle: {
              kind: :bundle,
              capabilities: %i[dependency_pack diagnostic],
              dependency_hints: %w[Igniter::Extensions::Contracts::ExecutionReportPack Igniter::Extensions::Contracts::ProvenancePack],
              summary: "developer-facing diagnostics bundle pack"
            },
            operational_adapter: {
              kind: :operational,
              capabilities: %i[effect executor],
              dependency_hints: [],
              summary: "effect/executor operational adapter pack"
            },
            bundle_pack: {
              kind: :bundle,
              capabilities: %i[dependency_pack],
              dependency_hints: [],
              summary: "bundle pack that installs or presets other packs"
            }
          }.freeze

          attr_reader :name, :kind, :capabilities, :dependency_hints, :summary

          def self.available
            PRESETS.keys
          end

        def self.build(profile: nil, kind: nil, capabilities: nil)
          if profile
            preset = PRESETS.fetch(profile.to_sym) do
              raise ArgumentError, "unknown creator profile #{profile.inspect}"
            end
            effective_capabilities = Array(capabilities)
            effective_capabilities = preset.fetch(:capabilities) if capabilities.nil? || effective_capabilities.empty?

            return new(
              name: profile,
              kind: preset.fetch(:kind),
              capabilities: effective_capabilities,
              dependency_hints: preset.fetch(:dependency_hints),
              summary: preset.fetch(:summary)
            )
          end

            normalized_kind = (kind || infer_kind(Array(capabilities))).to_sym
            inferred_capabilities = Array(capabilities)
            inferred_capabilities = default_capabilities_for(normalized_kind) if inferred_capabilities.empty?

            new(
              name: :custom,
              kind: normalized_kind,
              capabilities: inferred_capabilities,
              dependency_hints: [],
              summary: "custom #{normalized_kind} authoring profile"
            )
          end

          def self.default_capabilities_for(kind)
            case kind.to_sym
            when :feature
              %i[node dsl_keyword validator runtime_handler]
            when :operational
              %i[effect executor]
            when :bundle
              %i[dependency_pack]
            else
              []
            end
          end

          def self.infer_kind(capabilities)
            caps = capabilities.map(&:to_sym)
            return :operational if (caps & %i[effect executor]).any?
            return :bundle if caps.include?(:dependency_pack) && (caps & %i[node dsl_keyword runtime_handler effect executor]).empty?

            :feature
          end

          def initialize(name:, kind:, capabilities:, dependency_hints:, summary:)
            @name = name.to_sym
            @kind = kind.to_sym
            @capabilities = capabilities.map(&:to_sym).uniq.freeze
            @dependency_hints = dependency_hints.dup.freeze
            @summary = summary
            freeze
          end

          def registry_capabilities
            capabilities.filter_map { |capability| REGISTRY_CAPABILITIES[capability] }.uniq
          end

          def capability?(name)
            capabilities.include?(name.to_sym)
          end

          def to_h
            {
              name: name,
              kind: kind,
              capabilities: capabilities,
              registry_capabilities: registry_capabilities,
              dependency_hints: dependency_hints,
              summary: summary
            }
          end
        end
      end
    end
  end
end
