# frozen_string_literal: true

module Igniter
  module Contracts
    module Contractable
      Observation = Struct.new(:name, :value, :metadata, keyword_init: true) do
        def initialize(name:, value:, metadata: {})
          super(name: name.to_sym, value: value, metadata: metadata.dup.freeze)
          freeze
        end

        def to_h
          {
            name: name,
            value: value,
            metadata: metadata.dup
          }
        end
      end

      Result = Struct.new(:status, :outputs, :observations, :error, :metadata, keyword_init: true) do
        def initialize(status:, outputs: {}, observations: [], error: nil, metadata: {})
          super(
            status: status.to_sym,
            outputs: outputs.transform_keys(&:to_sym).freeze,
            observations: observations.map { |observation| normalize_observation(observation) }.freeze,
            error: error,
            metadata: metadata.dup.freeze
          )
          freeze
        end

        def success?
          status == :success
        end

        def failure?
          !success?
        end

        def to_h
          {
            status: status,
            success: success?,
            outputs: outputs,
            observations: observations.map(&:to_h),
            error: error,
            metadata: metadata.dup
          }.compact
        end

        private

        def normalize_observation(observation)
          return observation if observation.is_a?(Observation)

          Observation.new(**observation.to_h)
        end
      end

      Definition = Struct.new(:method_name, :inputs, :outputs, :metadata, keyword_init: true) do
        def initialize(method_name:, inputs: [], outputs: [], metadata: {})
          super(
            method_name: method_name.to_sym,
            inputs: inputs.map(&:to_sym).freeze,
            outputs: outputs.map(&:to_sym).freeze,
            metadata: metadata.dup.freeze
          )
          freeze
        end

        def to_h
          {
            method_name: method_name,
            inputs: inputs,
            outputs: outputs,
            metadata: metadata.dup
          }
        end
      end

      class DefinitionBuilder
        attr_reader :method_name, :inputs, :outputs, :metadata

        def initialize(method_name)
          @method_name = method_name.to_sym
          @inputs = []
          @outputs = []
          @metadata = {}
        end

        def input(name, **)
          inputs << name.to_sym
        end

        def output(name, **)
          outputs << name.to_sym
        end

        def meta(key, value)
          metadata[key.to_sym] = value
        end

        def build
          Definition.new(method_name: method_name, inputs: inputs, outputs: outputs, metadata: metadata)
        end
      end

      class ExecutionContext
        attr_reader :observations

        def initialize
          @observations = []
        end

        def observe(name, metadata: {})
          value = yield
          observations << Observation.new(name: name, value: value, metadata: metadata)
          value
        end
      end

      module InstanceMethods
        def observe(name, metadata: {}, &block)
          raise Error, "observe requires a block" unless block
          raise Error, "observe can only be used during a contractable call" unless @__igniter_contractable_context

          @__igniter_contractable_context.observe(name, metadata: metadata, &block)
        end

        def success(**outputs)
          Result.new(status: :success, outputs: outputs, observations: current_observations)
        end

        def failure(code:, message:, details: {})
          Result.new(
            status: :failure,
            outputs: {},
            observations: current_observations,
            error: { code: code.to_sym, message: message, details: details }
          )
        end

        private

        def current_observations
          @__igniter_contractable_context&.observations || []
        end
      end

      module ClassMethods
        def contractable(method_name, &block)
          builder = DefinitionBuilder.new(method_name)
          builder.instance_eval(&block) if block
          @__igniter_contractable_definition = builder.build
        end

        def contractable_definition
          @__igniter_contractable_definition || Definition.new(method_name: :call)
        end
      end

      class << self
        def included(base)
          base.extend(ClassMethods)
          base.include(InstanceMethods)
        end

        def invoke(target, **inputs)
          instance = target.is_a?(Class) ? target.new : target
          definition = instance.class.contractable_definition
          context = ExecutionContext.new
          instance.instance_variable_set(:@__igniter_contractable_context, context)
          raw = instance.public_send(definition.method_name, **inputs)
          normalize_result(raw, observations: context.observations)
        rescue StandardError => e
          Result.new(
            status: :failure,
            outputs: {},
            observations: context&.observations || [],
            error: { code: :contractable_error, message: e.message, class: e.class.name }
          )
        ensure
          instance&.remove_instance_variable(:@__igniter_contractable_context) if instance&.instance_variable_defined?(:@__igniter_contractable_context)
        end

        def contractable?(target)
          klass = target.is_a?(Class) ? target : target.class
          klass.respond_to?(:contractable_definition)
        end

        private

        def normalize_result(value, observations:)
          return value if value.is_a?(Result)

          if value.respond_to?(:to_h)
            Result.new(status: :success, outputs: value.to_h, observations: observations)
          else
            Result.new(status: :success, outputs: { value: value }, observations: observations)
          end
        end
      end
    end
  end
end
