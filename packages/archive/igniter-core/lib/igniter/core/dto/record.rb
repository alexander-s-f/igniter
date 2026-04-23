# frozen_string_literal: true

module Igniter
  module DTO
    class Record
      UNSET = Object.new

      class << self
        def field(name, required: false, allow_nil: !required, default: UNSET, coerce: nil, merge: false)
          local_fields[name.to_sym] = {
            name: name.to_sym,
            required: required,
            allow_nil: allow_nil,
            default: default,
            coerce: coerce,
            merge: merge
          }.freeze

          attr_reader name unless method_defined?(name)
        end

        def from_h(attributes)
          new(**normalize_input_attributes(attributes))
        end

        def dto_fields
          inherited_fields.merge(local_fields)
        end

        def field_names
          dto_fields.keys.freeze
        end

        private

        def inherited_fields
          return {} unless superclass.respond_to?(:dto_fields)

          superclass.dto_fields
        end

        def local_fields
          @local_fields ||= {}
        end

        def normalize_input_attributes(attributes)
          symbolize_hash(attributes || {})
        end

        def symbolize_hash(hash)
          return {} unless hash.is_a?(Hash)

          hash.each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end
        end

        def resolve_default(spec)
          default = spec.fetch(:default, UNSET)
          return UNSET if default.equal?(UNSET)

          value = default.respond_to?(:call) ? default.call : deep_dup(default)
          deep_freeze(value)
        end

        def coerce_field_value(spec, value)
          coerce = spec[:coerce]
          return value if coerce.nil?

          case coerce
          when Symbol
            send(coerce, value)
          else
            coerce.arity == 2 ? coerce.call(value, spec) : coerce.call(value)
          end
        end

        def deep_dup(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, nested), memo|
              memo[deep_dup(key)] = deep_dup(nested)
            end
          when Array
            value.map { |item| deep_dup(item) }
          else
            value.dup
          end
        rescue TypeError
          value
        end

        def deep_freeze(value)
          case value
          when Hash
            value.each do |key, nested|
              deep_freeze(key)
              deep_freeze(nested)
            end
          when Array
            value.each { |item| deep_freeze(item) }
          end

          value.freeze if value.respond_to?(:freeze)
          value
        end

        def serialize_value(value)
          case value
          when Record
            value.to_h
          when Hash
            value.each_with_object({}) do |(key, nested), memo|
              memo[key] = serialize_value(nested)
            end
          when Array
            value.map { |item| serialize_value(item) }
          else
            value
          end
        end
      end

      def initialize(**attributes)
        normalized = self.class.send(:normalize_input_attributes, attributes)
        unknown_keys = normalized.keys - self.class.field_names
        unless unknown_keys.empty?
          raise ArgumentError, "#{self.class} received unknown fields: #{unknown_keys.map(&:inspect).join(", ")}"
        end

        self.class.dto_fields.each do |name, spec|
          value = if normalized.key?(name)
                    normalized[name]
                  else
                    self.class.send(:resolve_default, spec)
                  end

          if value.equal?(UNSET)
            raise ArgumentError, "#{self.class} requires #{name}" if spec[:required]

            value = nil
          end

          if value.nil?
            raise ArgumentError, "#{self.class} requires #{name}" unless spec[:allow_nil]
          else
            value = self.class.send(:coerce_field_value, spec, value)
            value = self.class.send(:deep_freeze, value)
          end

          instance_variable_set(:"@#{name}", value)
        end

        freeze
      end

      def with(**overrides)
        normalized = self.class.send(:normalize_input_attributes, overrides)

        merged = self.class.dto_fields.each_with_object({}) do |(name, spec), memo|
          current = public_send(name)

          if normalized.key?(name)
            override = normalized[name]
            memo[name] =
              if spec[:merge] && current.respond_to?(:merge) && override.is_a?(Hash)
                current.merge(override)
              else
                override
              end
          else
            memo[name] = current
          end
        end

        self.class.new(**merged)
      end

      def to_h
        self.class.dto_fields.each_with_object({}) do |(name, _spec), memo|
          value = public_send(name)
          memo[name] = self.class.send(:serialize_value, value) unless value.nil?
        end.freeze
      end

      alias attributes to_h
    end
  end
end
