# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class Runner
        def initialize(app_class:)
          @app_class = app_class
        end

        def run(plan, graph: nil, execution_id: nil)
          inbox = app_class.orchestration_inbox
          opened = []
          existing = []

          plan.followup_request.actions.each do |action|
            existing_item = inbox.find_active(action[:id])
            if existing_item
              existing << existing_item.merge(status: :existing)
              next
            end

            opened << inbox.open(
              action,
              source: plan.source,
              graph: graph,
              execution_id: execution_id
            )
          end

          Result.new(app_class: app_class, opened: opened, existing: existing)
        end

        private

        attr_reader :app_class
      end
    end
  end
end
