# frozen_string_literal: true

# Pure-Ruby fallback — skipped when the Rust native extension is loaded.
return if defined?(Igniter::Store::NATIVE) && Igniter::Store::NATIVE

require "json"
require "zlib"

module Igniter
  module Store
    # WAL format (v2): length-prefixed frames with CRC32 integrity check.
    #
    # Each frame:
    #   [4 bytes BE uint32: body_len][body_len bytes: JSON][4 bytes BE uint32: CRC32(body)]
    #
    # On replay, a frame with a bad CRC or truncated body stops replay at that
    # point — everything after is treated as an uncommitted write. Silent data
    # loss from a mid-write process kill is now detectable.
    #
    # Breaking change from v1 (JSON-Lines). Existing JSONL WAL files are not
    # compatible with this reader.
    class FileBackend
      FRAME_HEADER_SIZE = 4
      FRAME_CRC_SIZE    = 4

      def initialize(path)
        @path = path.to_s
        @file = File.open(@path, "ab")
        @file.sync = true
      end

      def write_fact(fact)
        body  = JSON.generate(fact.to_h)
        frame = [body.bytesize].pack("N") << body.b << [Zlib.crc32(body)].pack("N")
        @file.write(frame)
      end

      def replay
        return [] unless File.exist?(@path)

        facts = []
        File.open(@path, "rb") do |f|
          loop do
            header = f.read(FRAME_HEADER_SIZE)
            break if header.nil? || header.bytesize < FRAME_HEADER_SIZE

            len  = header.unpack1("N")
            body = f.read(len)
            break if body.nil? || body.bytesize < len

            crc_bytes = f.read(FRAME_CRC_SIZE)
            break if crc_bytes.nil? || crc_bytes.bytesize < FRAME_CRC_SIZE

            stored_crc = crc_bytes.unpack1("N")
            break unless Zlib.crc32(body) == stored_crc

            begin
              payload = JSON.parse(body, symbolize_names: true)
              payload[:store]     = payload.fetch(:store).to_sym
              payload[:timestamp] = payload.fetch(:timestamp).to_f
              facts << Fact.new(**payload).freeze
            rescue JSON::ParserError
              next
            end
          end
        end
        facts
      end

      def close
        @file.close
      end
    end
  end
end
