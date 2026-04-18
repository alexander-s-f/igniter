# frozen_string_literal: true

module Igniter
  module Runtime
    module Runners
      class StoreRunner
        def initialize(execution, resolver:, store:, max_workers: nil)
          @execution = execution
          @delegate = InlineRunner.new(execution, resolver: resolver, max_workers: max_workers)
          @store = store
        end

        def run(node_names)
          @delegate.run(node_names)
        end

        def persist!
          return unless @store

          if @execution.pending?
            @store.save(@execution.snapshot(include_resolution: false))
          else
            @store.delete(@execution.events.execution_id)
          end
        end
      end
    end
  end
end
