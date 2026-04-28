# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :ActivityFeedContract, outputs: %i[action_count recent_events] do
      input :actions
      input :recent_limit

      compute :ordered_actions, depends_on: [:actions] do |actions:|
        Array(actions).sort_by { |action| action.fetch(:index).to_i }
      end

      compute :action_count, depends_on: [:ordered_actions] do |ordered_actions:|
        ordered_actions.length
      end

      compute :recent_events, depends_on: %i[ordered_actions recent_limit] do |ordered_actions:, recent_limit:|
        ordered_actions.last(Integer(recent_limit || 6)).map(&:dup).freeze
      rescue ArgumentError, TypeError
        ordered_actions.last(6).map(&:dup).freeze
      end

      output :action_count
      output :recent_events
    end
  end
end
