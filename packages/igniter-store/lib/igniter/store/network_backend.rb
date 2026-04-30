# frozen_string_literal: true

# Pure-Ruby only: NetworkBackend deserialises Fact objects from the wire using
# Fact.new, which is not available in the Rust native extension.
# Phase 2 of the network backend will add a Rust-native deserialise path.
return if defined?(Igniter::Store::NATIVE) && Igniter::Store::NATIVE

require "socket"
require "json"
require_relative "wire_protocol"

module Igniter
  module Store
    # NetworkBackend — client-side backend that proxies write_fact / replay /
    # write_snapshot over a TCP or Unix socket connection to a StoreServer.
    #
    # The wire protocol is CRC32-framed JSON (same framing as the WAL file format).
    # Each request is a single frame; the server replies with a single frame.
    #
    # Usage (via Companion::Store):
    #   store = Igniter::Companion::Store.new(
    #     backend:   :network,
    #     address:   "127.0.0.1:7400",
    #     transport: :tcp           # default; or :unix for Unix domain sockets
    #   )
    #
    # Direct usage:
    #   nb = Igniter::Store::NetworkBackend.new(address: "127.0.0.1:7400")
    class NetworkBackend
      include WireProtocol

      class NetworkError < StandardError; end

      def initialize(address:, transport: :tcp)
        @address   = address
        @transport = transport
        @mutex     = Mutex.new
        @socket    = connect
      end

      def write_fact(fact)
        rpc("write_fact", fact: fact.to_h)
        nil
      end

      # Returns an Array<Fact> from the server's durable store.
      def replay
        response = rpc("replay")
        (response[:facts] || []).map { |h| decode_fact(h) }
      end

      # Sends all +facts+ to the server for snapshot storage.
      # No-op on the server side if the server backend does not support snapshots.
      def write_snapshot(facts)
        rpc("write_snapshot", facts: facts.map(&:to_h))
        nil
      end

      def close
        @mutex.synchronize do
          send_frame({ op: "close" })
        rescue IOError, Errno::EPIPE
          nil
        ensure
          @socket.close rescue nil
        end
      end

      private

      def connect
        case @transport
        when :tcp
          host, port = @address.split(":")
          TCPSocket.new(host, Integer(port))
        when :unix
          UNIXSocket.new(@address)
        else
          raise ArgumentError, "Unknown transport: #{@transport.inspect}. Use :tcp or :unix"
        end
      end

      def rpc(op, **params)
        @mutex.synchronize do
          send_frame(params.merge(op: op))
          body = read_frame(@socket)
          raise NetworkError, "Connection closed by server" unless body
          response = JSON.parse(body, symbolize_names: true)
          raise NetworkError, response[:error] unless response[:ok]
          response
        end
      end

      def send_frame(payload)
        @socket.write(encode_frame(JSON.generate(payload)))
      end

      def decode_fact(h)
        h[:store]     = h.fetch(:store).to_sym
        h[:timestamp] = h.fetch(:timestamp).to_f
        Fact.new(**h).freeze
      end
    end
  end
end
