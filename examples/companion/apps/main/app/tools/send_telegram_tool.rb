# frozen_string_literal: true

require "igniter/channels"
require "igniter/core/tool"

module Companion
  class SendTelegramTool < Igniter::Tool
    description "Send a message to Telegram. Use this when the user asks to forward " \
                "a summary, reminder, or note to a Telegram chat."

    param :message, type: :string, required: true,
                    desc: "The message text to send to Telegram"
    param :chat_id, type: :string, required: false,
                    desc: "Optional Telegram chat id. If omitted, TELEGRAM_CHAT_ID is used."
    param :title, type: :string, required: false,
                  desc: "Optional title shown above the Telegram message body"

    requires_capability :network

    def call(message:, chat_id: nil, title: nil)
      unless telegram_configured?(chat_id)
        return "Telegram is not configured. Set TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID, " \
               "or pass chat_id explicitly."
      end

      result = telegram_channel.deliver(
        to: chat_id,
        subject: title,
        body: message
      )

      "Sent Telegram message to #{result.recipient} (message_id=#{result.external_id || "unknown"})"
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
  end
end
