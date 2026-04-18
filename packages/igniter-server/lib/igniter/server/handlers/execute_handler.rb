# frozen_string_literal: true

module Igniter
  module Server
    module Handlers
      class ExecuteHandler < Base
        def initialize(registry, store, collector: nil)
          super(registry, store)
          @collector = collector
        end

        private

        def handle(params:, body:)
          contract_class = @registry.fetch(params[:name])
          inputs = symbolize_inputs(body["inputs"] || {})
          contract = run_contract(contract_class, inputs)
          json_ok(serialize_execution(contract, contract_class))
        end

        def run_contract(contract_class, inputs) # rubocop:disable Metrics/MethodLength
          if use_distributed_start?(contract_class)
            contract_class.start(inputs, store: @store)
          else
            contract = contract_class.new(inputs)
            contract.execution.events.subscribe(@collector) if @collector
            begin
              contract.resolve_all
            rescue Igniter::Error
              nil # failed state is already written to cache; serialize_execution handles it
            end
            contract
          end
        end

        # Use .start for contracts that declare correlate_by (distributed workflows).
        def use_distributed_start?(contract_class)
          contract_class.respond_to?(:correlation_keys) && !contract_class.correlation_keys.empty?
        end
      end
    end
  end
end
