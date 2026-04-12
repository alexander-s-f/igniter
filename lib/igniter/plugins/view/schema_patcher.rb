# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      module SchemaPatcher
        module_function

        def apply(base, patch)
          deep_merge(deep_copy(base), patch)
        end

        def deep_merge(base, patch)
          return nil if patch.nil?
          return deep_copy(patch) unless base.is_a?(Hash) && patch.is_a?(Hash)

          patch.each do |key, value|
            key_s = key.to_s

            if value.nil?
              base.delete(key_s)
            elsif base[key_s].is_a?(Hash) && value.is_a?(Hash)
              base[key_s] = deep_merge(base[key_s], stringify_keys(value))
            else
              base[key_s] = deep_copy(value)
            end
          end

          base
        end

        def stringify_keys(value)
          case value
          when Hash
            value.each_with_object({}) { |(key, entry), memo| memo[key.to_s] = stringify_keys(entry) }
          when Array
            value.map { |entry| stringify_keys(entry) }
          else
            value
          end
        end

        def deep_copy(value)
          Marshal.load(Marshal.dump(stringify_keys(value)))
        end
      end
    end
  end
end
