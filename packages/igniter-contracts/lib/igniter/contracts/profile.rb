# frozen_string_literal: true

require "digest"

module Igniter
  module Contracts
    class Profile
      attr_reader :nodes,
                  :dsl_keywords,
                  :validators,
                  :normalizers,
                  :runtime_handlers,
                  :diagnostics_contributors,
                  :effects,
                  :executors,
                  :fingerprint

      def self.build_from(kernel)
        payload = {
          nodes: kernel.nodes.to_h.freeze,
          dsl_keywords: kernel.dsl_keywords.to_h.freeze,
          validators: kernel.validators.entries.freeze,
          normalizers: kernel.normalizers.entries.freeze,
          runtime_handlers: kernel.runtime_handlers.to_h.freeze,
          diagnostics_contributors: kernel.diagnostics_contributors.entries.freeze,
          effects: kernel.effects.to_h.freeze,
          executors: kernel.executors.to_h.freeze
        }

        new(**payload, fingerprint: fingerprint_for(payload))
      end

      def self.fingerprint_for(payload)
        normalized = payload.map do |key, value|
          serialized =
            case value
            when Hash
              value.map { |entry_key, entry_value| [entry_key.to_s, entry_value.inspect] }
            when Array
              value.map { |entry| [entry.key.to_s, entry.value.inspect] }
            else
              value.inspect
            end
          [key.to_s, serialized]
        end

        Digest::SHA256.hexdigest(normalized.inspect)
      end

      def initialize(nodes:, dsl_keywords:, validators:, normalizers:, runtime_handlers:, diagnostics_contributors:, effects:, executors:, fingerprint:)
        @nodes = nodes
        @dsl_keywords = dsl_keywords
        @validators = validators
        @normalizers = normalizers
        @runtime_handlers = runtime_handlers
        @diagnostics_contributors = diagnostics_contributors
        @effects = effects
        @executors = executors
        @fingerprint = fingerprint
        freeze
      end

      def node_class(kind)
        nodes.fetch(kind.to_sym)
      end

      def dsl_keyword(name)
        dsl_keywords.fetch(name.to_sym)
      end

      def runtime_handler(kind)
        runtime_handlers.fetch(kind.to_sym)
      end

      def supports_node_kind?(kind)
        nodes.key?(kind.to_sym)
      end
    end
  end
end
