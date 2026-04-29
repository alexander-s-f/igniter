# frozen_string_literal: true

require "date"

require_relative "../contracts"

module Companion
  module Contracts
    contracts :CountdownReadModelContract, outputs: %i[countdown_snapshots] do
      input :countdowns
      input :date

      compute :countdown_snapshots, depends_on: %i[countdowns date] do |countdowns:, date:|
        today = Date.iso8601(date.to_s)
        countdowns.map do |countdown|
          Services::CompanionState::CountdownSnapshot.new(
            id: countdown.id,
            title: countdown.title,
            target_date: countdown.target_date,
            days_remaining: Companion::Contracts.countdown_days_until(countdown.target_date, today)
          )
        end.freeze
      end

      output :countdown_snapshots
    end

    def self.countdown_days_until(target_date, today)
      (Date.iso8601(target_date.to_s) - today).to_i
    rescue Date::Error, TypeError
      nil
    end
  end
end
