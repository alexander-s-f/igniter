# frozen_string_literal: true

module Igniter
  class App
    module Orchestration
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
          actions.empty?
        end

        def attention_required?
          summary[:attention_required].to_i.positive?
        end

        def followup_request
          followup_actions = actions.select { |action| action[:attention_required] }

          FollowupRequest.new(
            app_class: app_class,
            source: source,
            actions: followup_actions,
            summary: {
              total: followup_actions.size,
              manual_completion: followup_actions.count { |action| action[:action] == :require_manual_completion },
              deferred_replies: followup_actions.count { |action| action[:action] == :await_deferred_reply },
              interactive_sessions: followup_actions.count { |action| action[:action] == :open_interactive_session },
              by_action: followup_actions.each_with_object(Hash.new(0)) do |action, memo|
                memo[action[:action]] += 1
              end,
              by_policy: followup_actions.each_with_object(Hash.new(0)) do |action, memo|
                memo[action.dig(:policy, :name)] += 1
              end,
              by_queue: followup_actions.each_with_object(Hash.new(0)) do |action, memo|
                memo[action.dig(:routing, :queue)] += 1 if action.dig(:routing, :queue)
              end,
              by_channel: followup_actions.each_with_object(Hash.new(0)) do |action, memo|
                memo[action.dig(:routing, :channel)] += 1 if action.dig(:routing, :channel)
              end
            }
          )
        end

        def to_h
          {
            app: app_class.name,
            source: source,
            actions: actions,
            summary: summary,
            followup: followup_request.to_h
          }
        end
      end
    end
  end
end
