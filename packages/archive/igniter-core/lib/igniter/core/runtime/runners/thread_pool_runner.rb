# frozen_string_literal: true

require "thread"

module Igniter
  module Runtime
    module Runners
      class ThreadPoolRunner
        def initialize(execution, resolver:, max_workers: nil)
          @execution = execution
          @resolver = resolver
          @max_workers = [Integer(max_workers || 4), 1].max
        end

        def run(node_names)
          queue = Queue.new
          Array(node_names).each { |node_name| queue << node_name }
          worker_count = [@max_workers, queue.size].min
          return if worker_count.zero?

          threads = worker_count.times.map do
            Thread.new do
              loop do
                node_name = queue.pop(true)
                @resolver.resolve(node_name)
              rescue ThreadError
                break
              end
            end
          end

          threads.each(&:join)
        end
      end
    end
  end
end
