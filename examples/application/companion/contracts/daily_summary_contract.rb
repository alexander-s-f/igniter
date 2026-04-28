# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :DailySummaryContract, outputs: %i[summary recommendation] do
      input :open_reminders
      input :tracker_logs_today
      input :live_ready

      compute :summary, depends_on: %i[open_reminders tracker_logs_today live_ready] do |open_reminders:, tracker_logs_today:, live_ready:|
        mode = live_ready ? "live-ready" : "offline"
        "Mode #{mode}: #{open_reminders} open reminders, #{tracker_logs_today} tracker logs today."
      end

      compute :recommendation, depends_on: %i[open_reminders tracker_logs_today] do |open_reminders:, tracker_logs_today:|
        if open_reminders.positive?
          "Pick one reminder and close the loop."
        elsif tracker_logs_today.zero?
          "Log one small tracker entry to build the day summary."
        else
          "You have enough signal for a lightweight daily review."
        end
      end

      output :summary
      output :recommendation
    end
  end
end
