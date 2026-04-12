# frozen_string_literal: true

require "json"

module Igniter
  module Server
    # Minimal structured logger for igniter-server.
    #
    # format: :json  → each line is a JSON object (Loki/ELK/CloudWatch compatible)
    # format: :text  → human-readable single-line string
    #
    # Thread-safe via an internal Mutex.
    class ServerLogger
      def initialize(format: :text, out: $stdout)
        @format = format
        @out    = out
        @mutex  = Mutex.new
      end

      def info(message, **context)
        log("INFO", message, context)
      end

      def warn(message, **context)
        log("WARN", message, context)
      end

      def error(message, **context)
        log("ERROR", message, context)
      end

      private

      def log(level, message, context)
        line = @format == :json ? json_line(level, message, context) : text_line(level, message, context)
        @mutex.synchronize { @out.puts(line) }
      rescue ThreadError
        @out.puts(line)
      end

      def json_line(level, message, context)
        JSON.generate(
          { time: Time.now.utc.iso8601(3), level: level, msg: message }.merge(context)
        )
      end

      def text_line(level, message, context)
        ts    = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
        extra = context.empty? ? "" : " #{context.map { |k, v| "#{k}=#{v}" }.join(" ")}"
        "[#{ts}] #{level} #{message}#{extra}"
      end
    end
  end
end
