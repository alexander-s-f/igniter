# frozen_string_literal: true

module Igniter
  module Cluster
    class MemoryIncidentRegistry
      def initialize(entries: {})
        @entries = {}
        @next_sequence = 0
        @mutex = Mutex.new

        entries.each_value { |entry| write(entry) }
      end

      def record(report, metadata: {})
        @mutex.synchronize do
          @next_sequence += 1
          write_unlocked(IncidentEntry.from_report(report, sequence: @next_sequence, metadata: metadata))
        end
      end

      def write(entry)
        @mutex.synchronize do
          write_unlocked(entry)
        end
      end

      def fetch(id)
        @mutex.synchronize do
          @entries.fetch(id.to_s)
        end
      end

      def entries
        @mutex.synchronize do
          @entries.values.sort_by(&:sequence)
        end
      end

      def active_set
        snapshot = entries
        latest_entries = snapshot.group_by(&:incident_key).values.map { |group| group.max_by(&:sequence) }

        ActiveIncidentSet.new(
          entries: latest_entries.select(&:active?),
          metadata: {
            registry: :memory,
            total_entries: snapshot.length
          }
        )
      end

      private

      def write_unlocked(entry)
        @entries[entry.id] = entry
        @next_sequence = [@next_sequence, entry.sequence].max
        entry
      end
    end
  end
end
