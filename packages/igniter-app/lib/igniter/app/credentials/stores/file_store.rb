# frozen_string_literal: true

require "fileutils"
require "json"

module Igniter
  class App
    module Credentials
      module Stores
        class FileStore < Store
          attr_reader :path, :max_events, :archive_path

          def initialize(path:, max_events: nil, archive_path: nil)
            @path = path
            @max_events = max_events&.to_i
            @archive_path = archive_path
            FileUtils.mkdir_p(File.dirname(path))
            FileUtils.mkdir_p(File.dirname(archive_path)) if archive_path
          end

          def append(event)
            File.open(path, "a") do |file|
              file.puts(JSON.generate(event))
            end
            rotate_if_needed!
            event
          end

          def load_events
            return [] unless File.exist?(path)

            File.readlines(path, chomp: true).filter_map do |line|
              next if line.strip.empty?

              deep_symbolize(JSON.parse(line))
            rescue JSON::ParserError
              next
            end
          end

          def clear!
            FileUtils.rm_f(path)
            FileUtils.rm_f(archive_path) if archive_path
            self
          end

          def retained_limit
            max_events
          end

          def prune_events(events)
            return Array(events) unless max_events && max_events.positive?
            return Array(events) if events.size <= max_events

            Array(events).last(max_events).map { |event| deep_symbolize(event) }
          end

          def persistence_metadata
            {
              enabled: true,
              store_class: self.class.name,
              path: path,
              max_events: max_events,
              archive_path: archive_path,
              archived_events: archived_events_count
            }.compact
          end

          private

          def deep_symbolize(value)
            case value
            when Hash
              value.each_with_object({}) do |(key, nested), memo|
                memo[key.to_sym] = deep_symbolize(nested)
              end
            when Array
              value.map { |item| deep_symbolize(item) }
            else
              value
            end
          end

          def rotate_if_needed!
            return unless max_events && max_events.positive?
            return unless File.exist?(path)

            lines = File.readlines(path, chomp: true).reject(&:empty?)
            return if lines.size <= max_events

            overflow = lines[0...(lines.size - max_events)]
            retained = lines.last(max_events)
            append_archive_lines(overflow)
            File.write(path, retained.empty? ? "" : "#{retained.join("\n")}\n")
          end

          def append_archive_lines(lines)
            return if lines.empty? || archive_path.nil?

            File.open(archive_path, "a") do |file|
              lines.each { |line| file.puts(line) }
            end
          end

          def archived_events_count
            return 0 unless archive_path && File.exist?(archive_path)

            File.foreach(archive_path).count
          end
        end
      end
    end
  end
end
