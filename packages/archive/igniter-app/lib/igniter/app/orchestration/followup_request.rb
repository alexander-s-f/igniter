# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
      class FollowupRequest
        attr_reader :app_class, :actions, :source, :summary

        def initialize(app_class:, actions:, source:, summary: {})
          @app_class = app_class
          @actions = Array(actions).map { |action| action.freeze }.freeze
          @source = source.to_sym
          @summary = summary.freeze
          freeze
        end

        def empty?
          actions.empty?
        end

        def action_ids
          actions.map { |action| action[:id] }
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
