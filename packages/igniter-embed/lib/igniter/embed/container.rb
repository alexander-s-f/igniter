# frozen_string_literal: true

module Igniter
  module Embed
    class Container
      attr_reader :config, :registry

      def initialize(config:)
        @config = config
        @registry = Registry.new
        @compiled_contracts = {}
      end

      def profile
        @profile ||= Igniter::Contracts.build_profile(config.packs)
      end

      def register(name, definition = nil, &block)
        contract_definition = definition || block
        raise ArgumentError, "contract definition is required" unless contract_definition

        registry.register(name, contract_definition)
        compiled_contracts.delete(name.to_sym)
        ContractHandle.new(name: name, container: self)
      end

      def fetch(name)
        registry.fetch(name)
        ContractHandle.new(name: name, container: self)
      end

      def compile(name = nil, &block)
        return compile_block(&block) if block

        compile_registered(name)
      end

      def call(name, inputs = {}, **keyword_inputs)
        normalized_inputs = inputs.merge(keyword_inputs)
        compiled_graph = compile_registered(name)
        result = Igniter::Contracts.execute_with(
          config.executor_name,
          compiled_graph,
          inputs: normalized_inputs,
          profile: profile
        )
        ExecutionEnvelope.new(name: name, inputs: normalized_inputs, result: result)
      rescue StandardError => e
        raise unless config.capture_exceptions?

        ExecutionEnvelope.new(
          name: name,
          inputs: normalized_inputs || {},
          errors: [e],
          metadata: { captured_exception: true }
        )
      end

      def clear_cache
        compiled_contracts.clear
        @profile = nil
        self
      end

      private

      attr_reader :compiled_contracts

      def compile_block(&block)
        Igniter::Contracts.compile(profile: profile, &block)
      end

      def compile_registered(name)
        key = name.to_sym
        return compiled_contracts.fetch(key) if config.cache? && compiled_contracts.key?(key)

        compiled = compile_registration(registry.fetch(key))
        compiled_contracts[key] = compiled if config.cache?
        compiled
      end

      def compile_registration(registration)
        return compile_block(&registration.definition) if registration.block?

        registration.definition.compile(profile: profile)
      end
    end
  end
end
