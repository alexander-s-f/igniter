# frozen_string_literal: true

module Igniter
  module Store
    # Thread-safe structured logger for StoreServer.
    #
    # Each line is written as:
    #   [2026-04-30T12:34:56.789] INFO  message
    #
    # Pass log_io: nil to silence all output (useful in tests).
    class ServerLogger
      LEVELS = { debug: 0, info: 1, warn: 2, error: 3 }.freeze

      def initialize(io = $stdout, level = :info)
        @io    = io
        @min   = LEVELS.fetch(level, 1)
        @mutex = Mutex.new
      end

      def debug(msg) = log(:debug, msg)
      def info(msg)  = log(:info,  msg)
      def warn(msg)  = log(:warn,  msg)
      def error(msg) = log(:error, msg)

      def level
        LEVELS.key(@min)
      end

      private

      def log(level, msg)
        return if LEVELS[level] < @min
        return unless @io

        ts = Time.now.strftime("%Y-%m-%dT%H:%M:%S.%3N")
        line = "[#{ts}] #{level.to_s.upcase.ljust(5)} #{msg}\n"
        @mutex.synchronize { @io.write(line) }
      rescue IOError
        nil
      end
    end
  end
end
