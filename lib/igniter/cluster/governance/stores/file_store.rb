# frozen_string_literal: true

require "fileutils"
require "json"

module Igniter
  module Cluster
    module Governance
      module Stores
        class FileStore
          attr_reader :path, :max_events, :archive_path, :retention_policy

          def initialize(path:, max_events: nil, archive_path: nil, retention_policy: nil)
            @path = path
            @max_events = max_events&.to_i
            @archive_path = archive_path
            @retention_policy = normalize_retention_policy(retention_policy)
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
            pruned = if retention_policy.empty?
                       prune_by_total_limit(Array(events))
                     else
                       prune_by_class_policy(Array(events))
                     end

            pruned.map { |event| deep_symbolize(event) }
          end

          def persistence_metadata
            {
              enabled: true,
              store_class: self.class.name,
              path: path,
              max_events: max_events,
              retention_policy: retention_policy,
              retained_by_class: counts_by_class(load_events),
              archive_path: archive_path,
              archived_events: archived_events_count,
              archived_by_class: counts_by_class(load_archive_events)
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
            return unless File.exist?(path)

            entries = File.readlines(path, chomp: true).filter_map do |line|
              next if line.strip.empty?

              parsed = JSON.parse(line)
              { line: line, event: deep_symbolize(parsed) }
            rescue JSON::ParserError
              next
            end

            retained_entries = if retention_policy.empty?
                                 prune_entries_by_total_limit(entries)
                               else
                                 prune_entries_by_class_policy(entries)
                               end
            return if retained_entries.size == entries.size

            retained_event_ids = retained_entries.map { |entry| entry.dig(:event, :event_id) }
            overflow = entries.reject { |entry| retained_event_ids.include?(entry.dig(:event, :event_id)) }.map { |entry| entry[:line] }
            retained_lines = retained_entries.map { |entry| entry[:line] }
            append_archive_lines(overflow)
            File.write(path, retained_lines.empty? ? "" : "#{retained_lines.join("\n")}\n")
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

          def load_archive_events
            return [] unless archive_path && File.exist?(archive_path)

            File.readlines(archive_path, chomp: true).filter_map do |line|
              next if line.strip.empty?

              deep_symbolize(JSON.parse(line))
            rescue JSON::ParserError
              next
            end
          end

          def normalize_retention_policy(policy)
            Array(policy || {}).each_with_object({}) do |(key, value), memo|
              next if value.nil?

              memo[key.to_sym] = value.to_i
            end
          end

          def prune_by_total_limit(events)
            return events unless max_events && max_events.positive?
            return events if events.size <= max_events

            events.last(max_events)
          end

          def prune_entries_by_total_limit(entries)
            return entries unless max_events && max_events.positive?
            return entries if entries.size <= max_events

            entries.last(max_events)
          end

          def prune_by_class_policy(events)
            return prune_by_total_limit(events) if retention_policy.empty?

            keep_indexes = []
            counters = Hash.new(0)

            (events.length - 1).downto(0) do |index|
              event = events[index]
              event_class = classify_event(event)
              limit = limit_for_class(event_class)
              if limit.nil?
                keep_indexes << index
                next
              end

              next unless counters[event_class] < limit

              counters[event_class] += 1
              keep_indexes << index
            end

            events.values_at(*keep_indexes.sort)
          end

          def prune_entries_by_class_policy(entries)
            return prune_entries_by_total_limit(entries) if retention_policy.empty?

            keep_indexes = []
            counters = Hash.new(0)

            (entries.length - 1).downto(0) do |index|
              entry = entries[index]
              event_class = classify_event(entry[:event])
              limit = limit_for_class(event_class)
              if limit.nil?
                keep_indexes << index
                next
              end

              next unless counters[event_class] < limit

              counters[event_class] += 1
              keep_indexes << index
            end

            entries.values_at(*keep_indexes.sort)
          end

          def classify_event(event)
            type = event[:type].to_s

            return :applied if type.include?("applied")
            return :blocked if type.include?("blocked")
            return :planning if type.include?("plan")

            :other
          end

          def limit_for_class(event_class)
            return retention_policy[event_class] if retention_policy.key?(event_class)
            return retention_policy[:default] if retention_policy.key?(:default)

            nil
          end

          def counts_by_class(events)
            Array(events).each_with_object(Hash.new(0)) do |event, memo|
              memo[classify_event(event)] += 1
            end
          end
        end
      end
    end
  end
end
