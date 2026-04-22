# frozen_string_literal: true

module Igniter
  module Contracts
    class HookSpec
      attr_reader :registry, :method_name, :required_keywords

      def initialize(registry:, method_name:, required_keywords:)
        @registry = registry.to_sym
        @method_name = method_name.to_sym
        @required_keywords = required_keywords.map(&:to_sym).freeze
        freeze
      end

      def validate!(key, implementation)
        unless implementation.respond_to?(method_name)
          raise InvalidHookImplementationError,
                "#{registry} entry #{key} must respond to ##{method_name}"
        end

        parameters = parameters_for(implementation)
        return if accepts_required_keywords?(parameters)

        missing = missing_keywords(parameters)

        raise InvalidHookImplementationError,
              "#{registry} entry #{key} must accept keywords #{required_keywords.map { |name| "#{name}:" }.join(', ')}; missing #{missing.map { |name| "#{name}:" }.join(', ')}"
      end

      private

      def accepts_required_keywords?(parameters)
        missing_keywords(parameters).empty?
      end

      def parameters_for(implementation)
        if method_name == :call && implementation.respond_to?(:parameters)
          implementation.parameters
        else
          implementation.method(method_name).parameters
        end
      end

      def missing_keywords(parameters)
        return [] if parameters.any? { |type, _name| type == :keyrest }

        accepted = parameters.filter_map do |type, name|
          name.to_sym if %i[key keyreq].include?(type) && name
        end

        required_keywords.reject { |keyword| accepted.include?(keyword) }
      end
    end
  end
end
