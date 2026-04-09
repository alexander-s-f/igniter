# frozen_string_literal: true

require "socket"

module Igniter
  module Server
    # Pure-Ruby HTTP/1.1 server built on TCPServer (stdlib, zero external deps).
    # Spawns one thread per connection. Intended for development and orchestration use.
    # For production, use RackApp with Puma via `Igniter::Server.rack_app`.
    class HttpServer
      CRLF = "\r\n"
      STATUS_MESSAGES = {
        200 => "OK",
        400 => "Bad Request",
        404 => "Not Found",
        422 => "Unprocessable Entity",
        500 => "Internal Server Error"
      }.freeze

      def initialize(config)
        @config = config
        @router = Router.new(config)
      end

      def start # rubocop:disable Metrics/MethodLength
        @tcp_server = TCPServer.new(@config.host, @config.port)
        @running    = true

        trap("INT")  { stop }
        trap("TERM") { stop }

        log("igniter-server listening on http://#{@config.host}:#{@config.port}")

        loop do
          break unless @running

          client = accept_connection
          Thread.new(client) { |conn| handle_connection(conn) } if client
        end
      rescue IOError
        # Server socket closed via stop
      end

      def stop
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

      def handle_connection(socket) # rubocop:disable Metrics/MethodLength
        request_line = socket.gets&.chomp
        return unless request_line&.include?(" ")

        http_method, path, = request_line.split(" ", 3)
        headers = read_headers(socket)
        body    = read_body(socket, headers["content-length"].to_i)

        result = @router.call(http_method, path, body)
        write_response(socket, result)
      rescue StandardError => e
        log("Connection error: #{e.message}")
      ensure
        socket.close rescue nil # rubocop:disable Style/RescueModifier
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

      def write_response(socket, result)
        body   = result[:body].to_s
        code   = result[:status].to_i
        phrase = STATUS_MESSAGES.fetch(code, "Unknown")

        response  = "HTTP/1.1 #{code} #{phrase}#{CRLF}"
        response += "Content-Type: application/json#{CRLF}"
        response += "Content-Length: #{body.bytesize}#{CRLF}"
        response += "Connection: close#{CRLF}"
        response += CRLF
        response += body

        socket.write(response)
      end

      def log(message)
        @config.logger&.puts(message) || $stdout.puts(message)
      end
    end
  end
end
