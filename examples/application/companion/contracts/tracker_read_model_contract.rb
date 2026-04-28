# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :TrackerReadModelContract, outputs: %i[tracker_snapshots logs_today sleep_hours_today training_minutes_today] do
      input :trackers
      input :tracker_logs
      input :date

      compute :tracker_snapshots, depends_on: %i[trackers tracker_logs] do |trackers:, tracker_logs:|
        trackers.map do |tracker|
          Services::CompanionState::TrackerSnapshot.new(
            id: tracker.id,
            name: tracker.name,
            template: tracker.template,
            unit: tracker.unit,
            log_entries: tracker_logs.select { |entry| entry.fetch(:tracker_id).to_s == tracker.id.to_s }
                                     .map { |entry| { date: entry.fetch(:date), value: entry.fetch(:value) } }
                                     .freeze
          )
        end.freeze
      end

      compute :logs_for_date, depends_on: %i[tracker_logs date] do |tracker_logs:, date:|
        tracker_logs.select { |entry| entry.fetch(:date) == date.to_s }
      end

      compute :logs_today, depends_on: [:logs_for_date] do |logs_for_date:|
        logs_for_date.length
      end

      compute :sleep_hours_today, depends_on: [:logs_for_date] do |logs_for_date:|
        Companion::Contracts.sum_tracker_values(logs_for_date, "sleep")
      end

      compute :training_minutes_today, depends_on: [:logs_for_date] do |logs_for_date:|
        Companion::Contracts.sum_tracker_values(logs_for_date, "training")
      end

      output :tracker_snapshots
      output :logs_today
      output :sleep_hours_today
      output :training_minutes_today
    end

    def self.sum_tracker_values(entries, tracker_id)
      entries.select { |entry| entry.fetch(:tracker_id).to_s == tracker_id }.sum do |entry|
        Float(entry.fetch(:value))
      rescue ArgumentError, TypeError
        0
      end
    end
  end
end
