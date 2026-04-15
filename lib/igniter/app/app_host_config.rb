# frozen_string_literal: true

module Igniter
  class Application
    # Server-specific host settings owned by the application layer but scoped
    # under the default server host instead of AppConfig's top level.
    class AppHostConfig
      attr_accessor :host, :port, :log_format, :drain_timeout

      def initialize
        @host = "0.0.0.0"
        @port = 4567
        @log_format = :text
        @drain_timeout = 30
      end

      def to_h
        {
          host: host,
          port: port,
          log_format: log_format,
          drain_timeout: drain_timeout
        }
      end
    end
  end
end
