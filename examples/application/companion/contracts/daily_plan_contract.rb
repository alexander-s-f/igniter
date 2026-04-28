# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :DailyPlanContract, outputs: %i[focus_title block_minutes next_action] do
      input :snapshot
      input :body_battery

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

      compute :focus_title, depends_on: [:snapshot] do |snapshot:|
        snapshot.fetch(:next_reminder_title) || "Daily review"
      end

      compute :next_action, depends_on: %i[focus_title block_minutes energy_status] do |focus_title:, block_minutes:, energy_status:|
        if energy_status == "recovery"
          "Start #{focus_title.inspect} as a #{block_minutes}-minute recovery-safe step."
        else
          "Protect #{block_minutes} minutes for #{focus_title.inspect}."
        end
      end

      output :focus_title
      output :block_minutes
      output :next_action
    end
  end
end
