# frozen_string_literal: true

module Igniter
  module DSL
    class SchemaBuilder
      def self.compile(schema, name: nil)
        new(schema, name: name).compile
      end

      def initialize(schema, name: nil)
        @schema = symbolize(schema)
        @name = name || @schema[:name] || "AnonymousContract"
      end

      def compile
        schema = @schema

        ContractBuilder.compile(name: @name) do
          Array(schema[:inputs]).each do |input_config|
            config = input_config
            input(
              config.fetch(:name),
              type: config[:type],
              required: config[:required],
              default: config.fetch(:default, ContractBuilder::UNDEFINED_INPUT_DEFAULT),
              **config.fetch(:metadata, {})
            )
          end

          Array(schema[:compositions]).each do |composition_config|
            config = composition_config
            compose(
              config.fetch(:name),
              contract: config.fetch(:contract),
              inputs: config.fetch(:inputs),
              **config.fetch(:metadata, {})
            )
          end

          Array(schema[:computes]).each do |compute_config|
            config = compute_config
            options = {
              depends_on: Array(config.fetch(:depends_on)).map(&:to_sym)
            }
            options[:call] = config[:call] if config.key?(:call)
            options[:executor] = config[:executor] if config.key?(:executor)
            compute(config.fetch(:name), **options, **config.fetch(:metadata, {}))
          end

          Array(schema[:outputs]).each do |output_config|
            config = output_config
            output(config.fetch(:name), from: config[:from], **config.fetch(:metadata, {}))
          end
        end
      end

      private

      def symbolize(value)
        case value
        when Hash
          value.each_with_object({}) do |(key, nested), memo|
            memo[key.to_sym] = symbolize(nested)
          end
        when Array
          value.map { |item| symbolize(item) }
        else
          value
        end
      end
    end
  end
end
