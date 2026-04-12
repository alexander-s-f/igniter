# frozen_string_literal: true

require "json"

module Companion
  module Dashboard
    module ReminderActionHandler
      module_function

      def call(params:, body:, headers:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        reminder_id = params[:id].to_s
        reminder = Companion::ReminderStore.complete(reminder_id)
        return error(404, "reminder not found") unless reminder

        {
          status: 200,
          body: JSON.generate(ok: true, reminder: reminder),
          headers: { "Content-Type" => "application/json" }
        }
      end

      def error(status, message)
        {
          status: status,
          body: JSON.generate(ok: false, error: message),
          headers: { "Content-Type" => "application/json" }
        }
      end
    end
  end
end
