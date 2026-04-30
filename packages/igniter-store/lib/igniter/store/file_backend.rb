# frozen_string_literal: true

# Pure-Ruby fallback — skipped when the Rust native extension is loaded.
return if defined?(Igniter::Store::NATIVE) && Igniter::Store::NATIVE

require "json"

module Igniter
  module Store
    class FileBackend
      def initialize(path)
        @path = path.to_s
        @file = File.open(@path, "a+")
        @file.sync = true
      end

      def write_fact(fact)
        @file.puts(JSON.generate(fact.to_h))
      end

      def replay
        File.readlines(@path, chomp: true).filter_map do |line|
          next if line.empty?

          payload = JSON.parse(line, symbolize_names: true)
          payload[:store] = payload.fetch(:store).to_sym
          payload[:timestamp] = payload.fetch(:timestamp).to_f
          Fact.new(**payload).freeze
        rescue JSON::ParserError
          nil
        end
      end

      def close
        @file.close
      end
    end
  end
end
