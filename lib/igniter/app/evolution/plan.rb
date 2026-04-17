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

        def approval_request
          approval_actions = actions.select { |action| action[:requires_approval] }

          ApprovalRequest.new(
            app_class: app_class,
            source: source,
            actions: approval_actions.map do |action|
              {
                id: action[:id],
                action: action[:action],
                scope: action[:scope],
                capability: action.dig(:params, :capability),
                candidates: Array(action.dig(:params, :sdk_capabilities)).map(&:to_sym).uniq.sort,
                constraints: action[:constraints],
                automated: action[:automated],
                requires_approval: action[:requires_approval]
              }.freeze
            end,
            summary: {
              total: approval_actions.size,
              constrained: approval_actions.count { |action| Array(action[:constraints]).any? },
              by_action: approval_actions.each_with_object(Hash.new(0)) do |action, memo|
                memo[action[:action]] += 1
              end
            }
          )
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
