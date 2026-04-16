# frozen_string_literal: true

require "json"
require "igniter/sdk/channels"
require_relative "current_session"
require_relative "conversation_store"
require_relative "notification_preferences_store"
require_relative "reminder_store"
require_relative "telegram_bindings_store"

module Companion
  module TelegramWebhook
    module_function

    def call(params:, body:, headers:, raw_body:, config:) # rubocop:disable Lint/UnusedMethodArgument
      return unauthorized("Telegram webhook secret mismatch") unless valid_secret?(headers)

      update = body || {}
      message = extract_message(update)
      return json(200, ok: true, ignored: true, reason: "unsupported_update") unless message

      text = message["text"].to_s.strip
      chat_id = message.dig("chat", "id")&.to_s
      return json(200, ok: true, ignored: true, reason: "missing_text_or_chat") if text.empty? || chat_id.to_s.empty?

      TelegramBindingsStore.upsert(message, prefer: prefer_chat_command?(text))

      session_id = "telegram:#{chat_id}"
      response_text =
        if start_command?(text)
          ConversationStore.clear(session_id)
          NotificationPreferencesStore.set_telegram_enabled(chat_id, true)
          welcome_message
        elsif use_here_command?(text)
          TelegramBindingsStore.select!(chat_id)
          preferred_chat_message
        elsif notifications_on_command?(text)
          NotificationPreferencesStore.set_telegram_enabled(chat_id, true)
          notifications_enabled_message
        elsif notifications_off_command?(text)
          NotificationPreferencesStore.set_telegram_enabled(chat_id, false)
          notifications_disabled_message
        elsif reminders_command?(text)
          reminders_message(chat_id)
        else
          history = ConversationStore.history(session_id)
          intent = { category: "other", confidence: 0.5, language: "en" }
          response = Companion::CurrentSession.with(session_context(chat_id, session_id, message)) do
            Companion::ChatContract.new(
              message: text,
              conversation_history: history,
              intent: intent
            ).result.response_text
          end

          ConversationStore.append(session_id, role: :user, content: text)
          ConversationStore.append(session_id, role: :assistant, content: response)
          response
        end

      Igniter::Channels::Telegram.new.deliver(
        to: chat_id,
        body: response_text,
        metadata: { reply_to_message_id: message["message_id"] }
      )

      json(200, ok: true, chat_id: chat_id, response_text: response_text, raw_size: raw_body.to_s.bytesize)
    rescue Igniter::Channels::DeliveryError => e
      json(422, ok: false, error: e.message)
    rescue StandardError => e
      json(500, ok: false, error: e.message)
    end

    def valid_secret?(headers)
      expected = ENV["TELEGRAM_WEBHOOK_SECRET"].to_s
      return true if expected.empty?

      actual = normalized_headers(headers)["x-telegram-bot-api-secret-token"].to_s
      actual == expected
    end

    def normalized_headers(headers)
      (headers || {}).each_with_object({}) do |(key, value), memo|
        memo[key.to_s.downcase] = value
      end
    end

    def extract_message(update)
      update["message"] || update["edited_message"]
    end

    def start_command?(text)
      text == "/start"
    end

    def use_here_command?(text)
      text == "/use_here"
    end

    def notifications_on_command?(text)
      text == "/notifications on"
    end

    def notifications_off_command?(text)
      text == "/notifications off"
    end

    def reminders_command?(text)
      text == "/reminders"
    end

    def prefer_chat_command?(text)
      start_command?(text) || use_here_command?(text)
    end

    def welcome_message
      "Hello! I'm Companion. This chat is now linked for Telegram updates. " \
        "Ask me about time, weather, notes, reminders, or research topics."
    end

    def preferred_chat_message
      "This chat is now the default Telegram destination for Companion messages."
    end

    def notifications_enabled_message
      "Telegram notifications are now enabled for this chat."
    end

    def notifications_disabled_message
      "Telegram notifications are now disabled for this chat."
    end

    def reminders_message(chat_id)
      reminders = Companion::ReminderStore.for_chat(chat_id)
      return "No active reminders for this chat yet." if reminders.empty?

      lines = reminders.last(5).map { |reminder| "- #{reminder["note"]}" }
      "Active reminders for this chat:\n" + lines.join("\n")
    end

    def session_context(chat_id, session_id, message)
      {
        channel: :telegram,
        chat_id: chat_id.to_s,
        session_id: session_id.to_s,
        user_id: message.dig("from", "id")&.to_s,
        username: message.dig("from", "username")
      }
    end

    def json(status, payload)
      {
        status: status,
        body: JSON.generate(payload),
        headers: { "Content-Type" => "application/json" }
      }
    end

    def unauthorized(message)
      json(401, ok: false, error: message)
    end
  end
end
