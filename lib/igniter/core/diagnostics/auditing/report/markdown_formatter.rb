# frozen_string_literal: true

module Igniter
  module Diagnostics
    module Auditing
      module Report
        class MarkdownFormatter
          def self.call(player)
            new(player).call
          end

          def initialize(player)
            @player = player
            @definition_graph = player.definition_graph
            @audited_graph = player.current_graph
          end

        end
      end
    end
  end
end
