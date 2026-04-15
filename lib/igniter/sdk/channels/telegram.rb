# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Igniter
  module Channels
    class Telegram < Base
      DEFAULT_API_BASE_URL = "https://api.telegram.org"
      DEFAULT_OPEN_TIMEOUT = 10
      DEFAULT_READ_TIMEOUT = 30

      effect_type :telegram
      channel_name :telegram

      def initialize(bot_token: ENV["TELEGRAM_BOT_TOKEN"],
                     default_chat_id: ENV["TELEGRAM_CHAT_ID"],
                     api_base_url: DEFAULT_API_BASE_URL,
                     parse_mode: nil,
                     disable_notification: false,
                     disable_web_page_preview: nil,
                     open_timeout: DEFAULT_OPEN_TIMEOUT,
                     read_timeout: DEFAULT_READ_TIMEOUT)
        @bot_token = bot_token
        @default_chat_id = default_chat_id
        @api_base_url = api_base_url
        @parse_mode = parse_mode
        @disable_notification = disable_notification
        @disable_web_page_preview = disable_web_page_preview
        @open_timeout = open_timeout
        @read_timeout = read_timeout
      end

      private

      def deliver_message(message)
        raise ArgumentError, "Telegram bot token is required" if blank?(@bot_token)

        chat_id = resolve_chat_id(message)
        uri = endpoint_uri
        request = Net::HTTP::Post.new(uri.request_uri)
        request["Content-Type"] = "application/json"
        request.body = JSON.generate(payload_for(message, chat_id))

        response = perform_request(uri, request)
        parsed = parse_response(response.body)

        unless response.is_a?(Net::HTTPSuccess) && parsed.fetch("ok", false)
          raise DeliveryError.new(
            "Telegram delivery failed: #{parsed["description"] || "HTTP #{response.code}"}",
            context: {
              channel: self.class.channel_name,
              recipient: chat_id,
              status_code: response.code.to_i,
              response_body: response.body.to_s[0, 300]
            }
          )
        end

        telegram_message = parsed["result"] || {}

        DeliveryResult.new(
          status: :delivered,
          provider: self.class.channel_name,
          recipient: chat_id,
          message_id: telegram_message["message_id"],
          external_id: telegram_message["message_id"]&.to_s,
          payload: parsed
        )
      rescue URI::InvalidURIError => e
        raise DeliveryError.new(
          "Invalid Telegram API URL: #{e.message}",
          context: { channel: self.class.channel_name }
        )
      rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
        raise DeliveryError.new(
          "Cannot deliver Telegram message: #{e.message}",
          context: { channel: self.class.channel_name, recipient: message.to || @default_chat_id }
        )
      end

      def resolve_chat_id(message)
        chat_id = message.metadata[:chat_id] || message.to || @default_chat_id
        raise ArgumentError, "Telegram chat_id is required" if blank?(chat_id)

        chat_id.to_s.sub(/\Atelegram:/, "")
      end

      def endpoint_uri
        base = @api_base_url.to_s.sub(%r{/+\z}, "")
        URI.parse("#{base}/bot#{@bot_token}/sendMessage")
      end

      def payload_for(message, chat_id)
        raise ArgumentError, "Telegram attachments are not supported yet" if message.attachments.any?

        text = render_text(message)
        raise ArgumentError, "Telegram message body is required" if blank?(text)

        payload = {
          chat_id: chat_id,
          text: text,
          disable_notification: resolve_disable_notification(message)
        }

        parse_mode = message.metadata[:parse_mode] || @parse_mode
        payload[:parse_mode] = parse_mode if parse_mode

        preview = resolve_preview_flag(message)
        payload[:link_preview_options] = { is_disabled: true } unless preview.nil? || !preview

        thread_id = message.metadata[:message_thread_id]
        payload[:message_thread_id] = thread_id if thread_id

        reply_to_message_id = message.metadata[:reply_to_message_id]
        payload[:reply_to_message_id] = reply_to_message_id if reply_to_message_id

        reply_markup = message.metadata[:reply_markup]
        payload[:reply_markup] = reply_markup if reply_markup

        payload
      end

      def render_text(message)
        parts = [message.subject, message.body].compact.map(&:to_s).reject(&:empty?)
        parts.join("\n\n")
      end

      def resolve_disable_notification(message)
        return message.metadata[:disable_notification] unless message.metadata[:disable_notification].nil?

        @disable_notification
      end

      def resolve_preview_flag(message)
        return message.metadata[:disable_web_page_preview] unless message.metadata[:disable_web_page_preview].nil?

        @disable_web_page_preview
      end

      def perform_request(uri, request)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = @open_timeout
        http.read_timeout = @read_timeout
        http.request(request)
      end

      def parse_response(body)
        JSON.parse(body.to_s)
      rescue JSON::ParserError
        {}
      end

      def blank?(value)
        value.nil? || value.to_s.strip.empty?
      end
    end
  end
end
