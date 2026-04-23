# frozen_string_literal: true

module Igniter
  module Rails
    # Base ActiveJob class for async contract execution.
    #
    # Usage:
    #   class ProcessOrderJob < Igniter::Rails::ContractJob
    #     contract OrderContract
    #   end
    #
    #   ProcessOrderJob.perform_later(order_id: "ord-123")
    #   ProcessOrderJob.perform_now(order_id: "ord-123")
    #
    # The job starts the contract and persists it to the configured store.
    # If the contract has correlation keys, the execution can be resumed
    # later via Contract.deliver_event.
    class ContractJob
      # No dependency on ActiveJob here — this class acts as a blueprint.
      # When Rails is present, subclasses inherit from ApplicationJob automatically
      # if the user adds `< ApplicationJob` (the recommended pattern).

      class << self
        def contract(klass = nil)
          @contract_class = klass if klass
          @contract_class
        end

        def store(store_instance = nil)
          @store = store_instance if store_instance
          @store || Igniter.execution_store
        end

        # Wraps perform in an ActiveJob-compatible interface.
        # Call this when Rails is available to get ActiveJob queueing.
        def perform_later(**inputs)
          if defined?(::ActiveJob::Base)
            ActiveJobAdapter.perform_later(contract_class: contract, inputs: inputs, store: store)
          else
            perform_now(**inputs)
          end
        end

        def perform_now(**inputs)
          contract.start(inputs, store: store)
        end
      end

      # Included by ActiveJobAdapter to bridge ActiveJob lifecycle.
      module Perform
        def perform(contract_class_name:, inputs:, store_class: nil, store_config: nil)
          klass = Object.const_get(contract_class_name)
          resolved_store = resolve_store(store_class, store_config)
          klass.start(inputs.transform_keys(&:to_sym), store: resolved_store)
        end

        private

        def resolve_store(store_class, _store_config)
          return Igniter.execution_store unless store_class

          Object.const_get(store_class).new
        end
      end
    end

    # ActiveJob adapter — only defined when ActiveJob is available.
    if defined?(::ActiveJob::Base)
      class ActiveJobAdapter < ::ActiveJob::Base
        include ContractJob::Perform

        queue_as :igniter
      end
    end
  end
end
