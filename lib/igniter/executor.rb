# frozen_string_literal: true

module Igniter
  class Executor
    class << self
      def inherited(subclass)
        super
        subclass.instance_variable_set(:@executor_inputs, executor_inputs.dup)
      end

      def input(name, required: true)
        executor_inputs[name.to_sym] = { required: required }
      end

      def executor_inputs
        @executor_inputs ||= {}
      end

      def call(**dependencies)
        new.call(**dependencies)
      end
    end

    attr_reader :execution, :contract

    def initialize(execution: nil, contract: nil)
      @execution = execution
      @contract = contract
    end
  end
end
