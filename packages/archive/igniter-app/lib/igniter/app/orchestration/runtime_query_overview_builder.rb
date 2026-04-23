# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class RuntimeQueryOverviewBuilder
        def self.build(query:, filters:, order_by:, direction:, limit:)
          query.to_h(limit: limit).merge(
            query: {
              filters: (filters || {}).dup.freeze,
              order_by: order_by&.to_sym,
              direction: direction&.to_sym,
              limit: limit
            }.freeze
          ).freeze
        end
      end
    end
  end
end
