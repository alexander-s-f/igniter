# frozen_string_literal: true

module Igniter
  module Runtime
    module Runners
      class InlineRunner
        def initialize(execution, resolver:, max_workers: nil)
          @execution = execution
          @resolver = resolver
          @max_workers = max_workers
        end

        def run(node_names)
          Array(node_names).each do |node_name|
            @resolver.resolve(node_name)
          end
        end
      end
    end
  end
end
