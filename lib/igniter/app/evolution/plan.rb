# frozen_string_literal: true

module Igniter
  class App
    module Evolution
      class Plan
        attr_reader :app_class, :actions, :source, :summary

        def initialize(app_class:, actions:, source:, summary: {})
          @app_class = app_class
          @actions = Array(actions).map { |action| action.freeze }.freeze
          @source = source.to_sym
          @summary = summary.freeze
          freeze
        end

        def empty?
          @actions.empty?
        end

        def approval_required?
          @actions.any? { |action| action[:requires_approval] }
        end

        def automated_actions
          @actions.select { |action| action[:automated] }
        end

        def manual_actions
          @actions.reject { |action| action[:automated] }
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
