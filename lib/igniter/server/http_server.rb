# frozen_string_literal: true

require "socket"

module Igniter
  module Server
    # Pure-Ruby HTTP/1.1 server built on TCPServer (stdlib, zero external deps).
    # Spawns one thread per connection. Intended for development and orchestration use.
    # For production, use RackApp with Puma via `Igniter::Server.rack_app`.
    class HttpServer # rubocop:disable Metrics/ClassLength
      CRLF = "\r\n"
      STATUS_MESSAGES = {
        200 => "OK",
        400 => "Bad Request",
        404 => "Not Found",
        422 => "Unprocessable Entity",
        500 => "Internal Server Error",
        501 => "Not Implemented",
        503 => "Service Unavailable"
      }.freeze

      def initialize(config)
        @config       = config
        @router       = Router.new(config)
        @logger       = ServerLogger.new(format: config.log_format)
        @in_flight    = 0
        @in_flight_mu = Mutex.new
      end

      def start # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        @tcp_server = TCPServer.new(@config.host, @config.port)
        @running    = true

        trap("INT")  { stop }
        trap("TERM") { graceful_stop }

        @logger.info("igniter-server started",
                     host: @config.host, port: @config.port, pid: Process.pid)

        loop do
          break unless @running

          client = accept_connection
          Thread.new(client) { |conn| handle_connection(conn) } if client
        end
      rescue IOError
        # Server socket closed via stop
      ensure
        drain_in_flight
        @logger.info("igniter-server stopped", pid: Process.pid)
      end

      def stop
        @running = false
        @tcp_server&.close
      end

      def graceful_stop
        @logger.info("SIGTERM received — draining",
                     drain_timeout: @config.drain_timeout, pid: Process.pid)
        @running = false
        @tcp_server&.close
      end

      private

      def accept_connection
        @tcp_server.accept_nonblock
      rescue IO::WaitReadable
        IO.select([@tcp_server], nil, nil, 0.5)
        nil
      rescue IOError
        nil
      end

      def handle_connection(socket) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        request_line = socket.gets&.chomp
        return unless request_line&.include?(" ")

        http_method, path, = request_line.split(" ", 3)
        headers = read_headers(socket)
        body    = read_body(socket, headers["content-length"].to_i)

        with_in_flight do
          result = @router.call(http_method, path, body, headers: headers)
          write_response(socket, result)
          @logger.info("#{http_method} #{path}", status: result[:status])
        end
      rescue StandardError => e
        @logger.error("Connection error", error: e.message)
      ensure
        socket.close rescue nil # rubocop:disable Style/RescueModifier
      end

      def with_in_flight
        @in_flight_mu.synchronize { @in_flight += 1 }
        yield
      ensure
        @in_flight_mu.synchronize { @in_flight -= 1 }
      end

      def drain_in_flight
        timeout  = @config.drain_timeout.to_i
        deadline = Time.now + timeout

        loop do
          remaining = @in_flight_mu.synchronize { @in_flight }
          break if remaining.zero?
          break if Time.now > deadline

          @logger.info("Draining in-flight connections", remaining: remaining)
          sleep 0.1
        end
      end

      def read_headers(socket)
        headers = {}
        while (line = socket.gets&.chomp) && !line.empty?
          name, value = line.split(": ", 2)
          headers[name.downcase] = value if name
        end
        headers
      end

      def read_body(socket, length)
        length.positive? ? socket.read(length).to_s : ""
      end

      def write_response(socket, result) # rubocop:disable Metrics/MethodLength
        body   = result[:body].to_s
        code   = result[:status].to_i
        phrase = STATUS_MESSAGES.fetch(code, "Unknown")
        ct     = result.dig(:headers, "Content-Type") || "application/json"

        response  = "HTTP/1.1 #{code} #{phrase}#{CRLF}"
        response += "Content-Type: #{ct}#{CRLF}"
        response += "Content-Length: #{body.bytesize}#{CRLF}"
        response += "Connection: close#{CRLF}"
        response += CRLF
        response += body

        socket.write(response)
      end
    end
  end
end
