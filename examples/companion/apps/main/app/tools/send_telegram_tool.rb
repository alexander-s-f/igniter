# frozen_string_literal: true

require "igniter/channels"
require "igniter/core/tool"
require_relative "../../../../lib/companion/shared/telegram_bindings_store"

module Companion
  class SendTelegramTool < Igniter::Tool
    description "Send a message to Telegram. Use this when the user asks to forward " \
                "a summary, reminder, or note to a Telegram chat."

    param :message, type: :string, required: true,
                    desc: "The message text to send to Telegram"
    param :chat_id, type: :string, required: false,
                    desc: "Optional Telegram chat id. If omitted, Companion uses the configured or linked default chat."
    param :title, type: :string, required: false,
                  desc: "Optional title shown above the Telegram message body"

    requires_capability :network

    def call(message:, chat_id: nil, title: nil)
      resolved_chat_id = resolve_chat_id(chat_id)

      unless telegram_configured?(resolved_chat_id)
        return "Telegram is not configured. Set TELEGRAM_BOT_TOKEN and either provide chat_id, " \
               "set TELEGRAM_CHAT_ID, or link a chat by sending /start to the bot."
      end

      result = telegram_channel.deliver(
        to: resolved_chat_id,
        subject: title,
        body: message
      )

      "Sent Telegram message to #{result.recipient} via #{chat_source(chat_id)} " \
        "(message_id=#{result.external_id || "unknown"})"
    rescue Igniter::Channels::DeliveryError => e
      "Telegram delivery failed: #{e.message}"
    end

    private

    def telegram_channel
      @telegram_channel ||= Igniter::Channels::Telegram.new
    end

    def telegram_configured?(chat_id)
      ENV["TELEGRAM_BOT_TOKEN"].to_s.strip != "" && (chat_id.to_s.strip != "" || ENV["TELEGRAM_CHAT_ID"].to_s.strip != "")
    end

    def resolve_chat_id(chat_id)
      explicit = chat_id.to_s.strip
      return explicit unless explicit.empty?

      env_chat_id = ENV["TELEGRAM_CHAT_ID"].to_s.strip
      return env_chat_id unless env_chat_id.empty?

      TelegramBindingsStore.preferred_chat_id || TelegramBindingsStore.latest_chat_id
    end

    def chat_source(chat_id)
      explicit = chat_id.to_s.strip
      return "explicit chat_id" unless explicit.empty?

      env_chat_id = ENV["TELEGRAM_CHAT_ID"].to_s.strip
      return "TELEGRAM_CHAT_ID" unless env_chat_id.empty?
      return "linked Telegram chat" if TelegramBindingsStore.preferred_chat_id

      "most recent Telegram chat"
    end
  end
end
