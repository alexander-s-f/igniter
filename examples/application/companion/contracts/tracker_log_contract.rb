# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :TrackerLogContract, outputs: %i[result mutation] do
      input :tracker_id
      input :value
      input :date
      input :trackers

      compute :normalized_value, depends_on: [:value] do |value:|
        value.to_s.strip
      end

      compute :existing_tracker, depends_on: %i[trackers tracker_id] do |trackers:, tracker_id:|
        trackers.find { |entry| entry.id == tracker_id.to_s }
      end

      compute :result, depends_on: %i[tracker_id normalized_value existing_tracker] do |tracker_id:, normalized_value:, existing_tracker:|
        if existing_tracker.nil?
          Companion::Contracts.command_result(:failure, :tracker_not_found, tracker_id.to_s, :tracker_log_refused, :refused)
        elsif normalized_value.empty?
          Companion::Contracts.command_result(:failure, :blank_tracker_value, existing_tracker.id, :tracker_log_refused, :refused)
        else
          Companion::Contracts.command_result(:success, :tracker_logged, existing_tracker.id, :tracker_logged, :logged)
        end
      end

      compute :mutation, depends_on: %i[result normalized_value date] do |result:, normalized_value:, date:|
        if result.fetch(:success)
          Companion::Contracts.history_append(
            :tracker_logs,
            {
              tracker_id: result.fetch(:subject_id),
              date: date,
              value: normalized_value
            }
          )
        else
          Companion::Contracts.no_mutation
        end
      end

      output :result
      output :mutation
    end
  end
end
