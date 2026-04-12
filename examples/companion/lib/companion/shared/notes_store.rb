# frozen_string_literal: true

module Companion
  module NotesStore
    class << self
      def configure_cluster(cluster)
        @cluster = cluster
      end

      def save(key, value)
        if @cluster
          @cluster.write(type: :set_note, key: key.to_s, value: value.to_s)
        else
          mutex.synchronize { local_notes[key.to_s] = value.to_s }
        end
      end

      def get(key)
        if @cluster
          (@cluster.state_machine_snapshot[:notes] || {})[key.to_s]
        else
          mutex.synchronize { local_notes[key.to_s] }
        end
      end

      def all
        if @cluster
          @cluster.state_machine_snapshot[:notes] || {}
        else
          mutex.synchronize { local_notes.dup }
        end
      end

      def cluster? = !@cluster.nil?

      def reset!
        @cluster = nil
        mutex.synchronize { @local_notes = {} }
      end

      private

      def mutex = (@mutex ||= Mutex.new)
      def local_notes = (@local_notes ||= {})
    end
  end
end
