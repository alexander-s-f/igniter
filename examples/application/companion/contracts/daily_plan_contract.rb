# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :DailyPlanContract, outputs: %i[focus_title block_minutes next_action signal quick_action] do
      input :daily_focus_title
      input :next_reminder_id
      input :next_reminder_title
      input :suggested_tracker_id
      input :body_battery
      input :open_reminders
      input :tracker_logs_today
      input :urgent_countdown_id
      input :urgent_countdown_title

      compute :energy_status, depends_on: [:body_battery] do |body_battery:|
        body_battery.fetch(:status, "steady")
      end

      compute :block_minutes, depends_on: [:energy_status] do |energy_status:|
        case energy_status
        when "charged"
          45
        when "steady"
          30
        when "low"
          20
        else
          10
        end
      end

      compute :focus_title, depends_on: %i[daily_focus_title next_reminder_title] do |daily_focus_title:, next_reminder_title:|
        daily_focus_title || next_reminder_title || "Daily review"
      end

      compute :signal, depends_on: %i[energy_status open_reminders tracker_logs_today urgent_countdown_title] do |energy_status:, open_reminders:, tracker_logs_today:, urgent_countdown_title:|
        if energy_status == "recovery"
          :recovery
        elsif tracker_logs_today.zero?
          :log_tracker
        elsif open_reminders.positive?
          :close_reminder
        elsif urgent_countdown_title
          :countdown
        else
          :focus_block
        end
      end

      compute :next_action, depends_on: %i[signal focus_title block_minutes next_reminder_title urgent_countdown_title] do |signal:, focus_title:, block_minutes:, next_reminder_title:, urgent_countdown_title:|
        case signal
        when :recovery
          "Start #{focus_title.inspect} as a #{block_minutes}-minute recovery-safe step."
        when :log_tracker
          "Log one tracker entry before planning the next block."
        when :close_reminder
          "Close one open reminder: #{(next_reminder_title || focus_title).inspect}."
        when :countdown
          "Move #{urgent_countdown_title.inspect} forward with one concrete step."
        else
          "Protect #{block_minutes} minutes for #{focus_title.inspect}."
        end
      end

      compute :quick_action,
              depends_on: %i[signal next_reminder_id suggested_tracker_id urgent_countdown_id urgent_countdown_title] do |signal:, next_reminder_id:, suggested_tracker_id:, urgent_countdown_id:, urgent_countdown_title:|
        case signal
        when :log_tracker
          next { kind: :none, subject_id: nil, label: "Add a tracker before logging" } unless suggested_tracker_id

          {
            kind: :tracker_log,
            subject_id: suggested_tracker_id,
            label: "Log tracker"
          }
        when :close_reminder
          next { kind: :none, subject_id: nil, label: "No open reminder target" } unless next_reminder_id

          {
            kind: :complete_reminder,
            subject_id: next_reminder_id,
            label: "Done"
          }
        when :countdown
          {
            kind: :countdown_step,
            subject_id: urgent_countdown_id,
            label: "Move #{(urgent_countdown_title || "countdown").inspect} forward"
          }
        when :recovery
          {
            kind: :none,
            subject_id: nil,
            label: "Keep this block gentle"
          }
        else
          {
            kind: :none,
            subject_id: nil,
            label: "Start focus block"
          }
        end
      end

      output :focus_title
      output :block_minutes
      output :next_action
      output :signal
      output :quick_action
    end
  end
end
