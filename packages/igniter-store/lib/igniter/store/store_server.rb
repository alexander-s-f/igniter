# frozen_string_literal: true

# Pure-Ruby only: StoreServer deserialises Fact objects from the wire using
# Fact.new, which is not available in the Rust native extension.
# Phase 2 of the network backend will add a Rust-native deserialise path.
return if defined?(Igniter::Store::NATIVE) && Igniter::Store::NATIVE

require "socket"
require "json"
require_relative "wire_protocol"

module Igniter
  module Store
    # StoreServer — a minimal TCP / Unix socket server that exposes an
    # IgniterStore's durable fact storage over the network.
    #
    # The server acts as the "durable backend" half of the network topology:
    # it accepts facts from NetworkBackend clients, persists them, and serves
    # replay requests. Clients rebuild all in-memory state (scope index, cache,
    # coercions) locally; the server only owns durability.
    #
    # Wire protocol: CRC32-framed JSON (same framing as FileBackend WAL).
    #
    # Usage — start in a background thread:
    #   server = Igniter::Store::StoreServer.new(
    #     address:  "127.0.0.1:7400",
    #     backend:  :file,
    #     path:     "/var/lib/igniter/store.wal"
    #   )
    #   server.start_async
    #
    # Or foreground (e.g. a dedicated server process):
    #   server.start   # blocks
    class StoreServer
      include WireProtocol

      def initialize(address:, transport: :tcp, backend: :memory, path: nil)
        @backend_type   = backend
        @backend        = build_backend(backend, path)
        @server         = build_server(address, transport)
        @write_mutex    = Mutex.new   # serialises write_fact + in_memory_facts updates
        @stopped        = false
        @in_memory_facts = []
      end

      # Starts the accept loop in the calling thread (blocks until #stop).
      def start
        until @stopped
          begin
            client = @server.accept
          rescue IOError, Errno::EBADF
            break  # server was closed
          end
          Thread.new { handle_client(client) }
        end
      end

      # Starts the accept loop in a background daemon thread.
      # Returns the Thread so callers can join or inspect it.
      def start_async
        Thread.new do
          Thread.current.abort_on_exception = false
          start
        end
      end

      def stop
        @stopped = true
        @server.close rescue nil
        @write_mutex.synchronize { @backend&.close rescue nil }
      end

      # The port the server is listening on (useful when address uses port 0).
      def port
        @server.addr[1]
      end

      # The address the server is bound to.
      def addr
        @server.addr[3]
      end

      private

      def build_backend(type, path)
        case type
        when :memory then nil  # no persistence — facts served from memory only
        when :file   then FileBackend.new(path.to_s)
        else raise ArgumentError, "StoreServer backend must be :memory or :file, got #{type.inspect}"
        end
      end

      def build_server(address, transport)
        case transport
        when :tcp
          host, port = address.split(":")
          server = TCPServer.new(host, Integer(port))
          server.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
          server
        when :unix
          UNIXServer.new(address)
        else
          raise ArgumentError, "Unknown transport: #{transport.inspect}. Use :tcp or :unix"
        end
      end

      def handle_client(socket)
        loop do
          body = read_frame(socket)
          break unless body

          req  = JSON.parse(body, symbolize_names: true)
          resp = dispatch(req)
          socket.write(encode_frame(JSON.generate(resp)))
          break if req[:op] == "close"
        end
      rescue IOError, Errno::ECONNRESET, Errno::EPIPE
        nil
      ensure
        socket.close rescue nil
      end

      def dispatch(req)
        case req[:op]
        when "write_fact"
          fact = decode_fact(req[:fact])
          @write_mutex.synchronize do
            @backend&.write_fact(fact)
            @in_memory_facts << fact
          end
          { ok: true }

        when "replay"
          # Snapshot the list under the write lock to avoid torn reads.
          facts = @write_mutex.synchronize do
            if @backend
              @backend.replay
            else
              @in_memory_facts.dup
            end
          end
          { ok: true, facts: facts.map(&:to_h) }

        when "write_snapshot"
          if @backend.respond_to?(:write_snapshot)
            facts = (req[:facts] || []).map { |h| decode_fact(h) }
            @write_mutex.synchronize { @backend.write_snapshot(facts) }
            { ok: true }
          else
            { ok: true }  # silently skip — memory backend has no snapshot
          end

        when "ping"
          { ok: true, pong: true }

        when "close"
          { ok: true }

        else
          { ok: false, error: "Unknown op: #{req[:op].inspect}" }
        end
      rescue => e
        { ok: false, error: e.message }
      end

      def decode_fact(h)
        h = h.transform_keys(&:to_sym)
        h[:store]     = h.fetch(:store).to_sym
        h[:timestamp] = h.fetch(:timestamp).to_f
        Fact.new(**h).freeze
      end
    end
  end
end
