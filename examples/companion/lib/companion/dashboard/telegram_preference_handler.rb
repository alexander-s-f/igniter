# frozen_string_literal: true

require "json"

module Companion
  module Dashboard
    module TelegramPreferenceHandler
      module_function

      def call(params:, body:, headers:, env: nil, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
        chat_id = body["chat_id"].to_s.strip
        enabled = body["enabled"]

        return error(422, "chat_id is required") if chat_id.empty?
        return error(422, "enabled must be true or false") unless [true, false].include?(enabled)

        prefs = Companion::NotificationPreferencesStore.set_telegram_enabled(chat_id, enabled)

        {
          status: 200,
          body: JSON.generate(
            ok: true,
            chat_id: chat_id,
            telegram_enabled: prefs["telegram_enabled"]
          ),
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
