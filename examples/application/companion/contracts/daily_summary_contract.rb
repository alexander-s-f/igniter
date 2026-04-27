# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :DailySummaryContract, outputs: %i[summary recommendation] do
      input :snapshot

      compute :summary, depends_on: [:snapshot] do |snapshot:|
        reminders = snapshot.fetch(:open_reminders)
        tracker_logs = snapshot.fetch(:tracker_logs_today)
        live_ready = snapshot.fetch(:live_ready)

        mode = live_ready ? "live-ready" : "offline"
        "Mode #{mode}: #{reminders} open reminders, #{tracker_logs} tracker logs today."
      end

      compute :recommendation, depends_on: [:snapshot] do |snapshot:|
        if snapshot.fetch(:open_reminders).positive?
          "Pick one reminder and close the loop."
        elsif snapshot.fetch(:tracker_logs_today).zero?
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
