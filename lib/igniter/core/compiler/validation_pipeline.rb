# frozen_string_literal: true

module Igniter
  module Compiler
    class ValidationPipeline
      DEFAULT_VALIDATORS = [
        Validators::UniquenessValidator,
        Validators::OutputsValidator,
        Validators::DependenciesValidator,
        Validators::TypeCompatibilityValidator,
        Validators::CallableValidator,
        Validators::AwaitValidator,
        Validators::RemoteValidator
      ].freeze

      def self.call(context, validators: DEFAULT_VALIDATORS)
        new(context, validators: validators).call
      end

      def initialize(context, validators:)
        @context = context
        @validators = validators
      end

      def call
        @context.build_indexes!
        @validators.each { |validator| validator.call(@context) }
        @context
      end
    end
  end
end
