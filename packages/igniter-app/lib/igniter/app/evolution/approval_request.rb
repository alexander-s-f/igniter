# frozen_string_literal: true

module Igniter
  class App
    module Evolution
      class ApprovalRequest
        attr_reader :app_class, :source, :actions, :summary

        def initialize(app_class:, source:, actions:, summary: {})
          @app_class = app_class
          @source = source.to_sym
          @actions = Array(actions).map { |action| action.freeze }.freeze
          @summary = summary.freeze
          freeze
        end

        def empty?
          @actions.empty?
        end

        def action_ids
          @actions.map { |action| action[:id] }
        end

        def to_h
          {
            app: app_class.name,
            source: source,
            actions: actions,
            summary: summary
          }
        end
      end
    end
  end
end
