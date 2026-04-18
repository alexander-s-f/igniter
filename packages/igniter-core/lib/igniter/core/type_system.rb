# frozen_string_literal: true

module Igniter
  module TypeSystem
    SUPPORTED_TYPES = {
      integer: Integer,
      float: Float,
      numeric: Numeric,
      string: String,
      boolean: :boolean,
      array: Array,
      hash: Hash,
      symbol: Symbol,
      result: :result
    }.freeze

    module_function

    def supported?(type)
      return false unless type

      SUPPORTED_TYPES.key?(type.to_sym)
    end

    def compatible?(source_type, target_type)
      return true if source_type.nil? || target_type.nil?

      source = source_type.to_sym
      target = target_type.to_sym
      return true if source == target
      return true if %i[integer float].include?(source) && target == :numeric

      false
    end

    def match?(type, value)
      matcher = SUPPORTED_TYPES.fetch(type.to_sym)
      return false if matcher == :result
      return value == true || value == false if matcher == :boolean

      value.is_a?(matcher)
    end
  end
end
