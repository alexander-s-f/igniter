# frozen_string_literal: true

module Igniter
  module Extensions
    module Contracts
      module Mcp
        class ToolDefinition
          attr_reader :name, :summary, :mutating

          def initialize(name:, summary:, mutating: false)
            @name = name.to_sym
            @summary = summary
            @mutating = !!mutating
            freeze
          end

          def to_h
            {
              name: name,
              summary: summary,
              mutating: mutating
            }
          end
        end
      end
    end
  end
end
