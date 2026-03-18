# frozen_string_literal: true

module Igniter
  module Runtime
    class RunnerFactory
      def self.build(strategy, execution, resolver:, max_workers: nil, store: nil)
        case strategy.to_sym
        when :inline
          Runners::InlineRunner.new(execution, resolver: resolver, max_workers: max_workers)
        when :store
          Runners::StoreRunner.new(execution, resolver: resolver, store: store, max_workers: max_workers)
        when :thread_pool
          Runners::ThreadPoolRunner.new(execution, resolver: resolver, max_workers: max_workers)
        else
          raise CompileError, "Unknown execution runner strategy: #{strategy}"
        end
      end
    end
  end
end
