# frozen_string_literal: true

module Igniter
  class Executor
    class << self
      def inherited(subclass)
        super
        subclass.instance_variable_set(:@executor_inputs, executor_inputs.transform_values(&:dup))
        subclass.instance_variable_set(:@executor_metadata, executor_metadata.dup)
      end

      def input(name, required: true, type: nil, **metadata)
        executor_inputs[name.to_sym] = metadata.merge(required: required, type: type).compact
      end

      def executor_inputs
        @executor_inputs ||= {}
      end

      def executor_metadata
        @executor_metadata ||= {}
      end

      def executor_key(value = nil)
        metadata_value(:key, value)
      end

      def label(value = nil)
        metadata_value(:label, value)
      end

      def category(value = nil)
        metadata_value(:category, value)
      end

      def summary(value = nil)
        metadata_value(:summary, value)
      end

      def tags(*values)
        return Array(executor_metadata[:tags]).freeze if values.empty?

        executor_metadata[:tags] = values.flatten.compact.map(&:to_sym).freeze
      end

      def output_schema(value = nil)
        metadata_value(:output_schema, value)
      end

      def call(**dependencies)
        new.call(**dependencies)
      end

      private

      def metadata_value(key, value)
        return executor_metadata[key] if value.nil?

        executor_metadata[key] = value
      end
    end

    attr_reader :execution, :contract

    def initialize(execution: nil, contract: nil)
      @execution = execution
      @contract = contract
    end
  end
end
