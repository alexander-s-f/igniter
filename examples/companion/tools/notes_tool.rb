# frozen_string_literal: true

require "igniter/tool"

module Companion
  # Thread-safe notes storage.
  #
  # By default stores notes in-process (lost on restart).
  # When backed by a Consensus::Cluster, notes are replicated across all
  # orchestrator nodes and survive individual node failures.
  #
  # Configuration:
  #   Companion::NotesStore.configure_cluster(cluster)  # → consensus-backed
  #   Companion::NotesStore.reset!                       # → back to in-process
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

  # Saves a named note for the user to recall later.
  class SaveNoteTool < Igniter::Tool
    description "Save a note or piece of information to remember later. " \
                "Use this when the user asks you to remember something."

    param :key,   type: :string, required: true,
                  desc: "Short identifier for the note (e.g. 'shopping_list', 'reminder', 'favorite_color')"
    param :value, type: :string, required: true,
                  desc: "The content to save"

    requires_capability :storage

    def call(key:, value:)
      NotesStore.save(key, value)
      "Saved: #{key} = \"#{value}\""
    end
  end

  # Retrieves saved notes.
  class GetNotesTool < Igniter::Tool
    description "Retrieve notes that were previously saved. " \
                "Use this when the user asks to recall something you were asked to remember."

    param :key, type: :string, required: false,
                desc: "Specific note key to look up. Omit to list all saved notes."

    requires_capability :storage

    def call(key: nil)
      if key
        value = NotesStore.get(key)
        value ? "#{key}: \"#{value}\"" : "No note found for \"#{key}\""
      else
        notes = NotesStore.all
        notes.empty? ? "No notes saved yet." : notes.map { |k, v| "  #{k}: \"#{v}\"" }.join("\n")
      end
    end
  end
end
