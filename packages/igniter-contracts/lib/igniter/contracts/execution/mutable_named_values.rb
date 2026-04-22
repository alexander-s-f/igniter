# frozen_string_literal: true

module Igniter
  module Contracts
    module Execution
      class MutableNamedValues
        def initialize(values = {})
          @values = values.transform_keys(&:to_sym)
        end

        def write(name, value)
          @values[name.to_sym] = value
          value
        end

        def fetch(name)
          @values.fetch(name.to_sym)
        end

        def [](name)
          @values[name.to_sym]
        end

        def key?(name)
          @values.key?(name.to_sym)
        end

        def keys
          @values.keys
        end

        def length
          @values.length
        end

        def snapshot
          NamedValues.new(@values)
        end
      end
    end
  end
end
