# frozen_string_literal: true

require "securerandom"
require "time"
require "igniter/data"

module Companion
  module ReminderStore
    COLLECTION = "companion_reminders"

    class << self
      def create(task:, timing:, request:, session_id: nil, channel: nil, chat_id: nil, notifications_enabled: nil)
        reminder = {
          "id" => SecureRandom.hex(8),
          "task" => task.to_s,
          "timing" => timing.to_s,
          "note" => "#{task} — #{timing}",
          "request" => request.to_s,
          "session_id" => session_id&.to_s,
          "channel" => channel&.to_s,
          "chat_id" => chat_id&.to_s,
          "notifications_enabled" => notifications_enabled,
          "status" => "active",
          "created_at" => Time.now.utc.iso8601
        }.compact

        store.put(collection: COLLECTION, key: reminder.fetch("id"), value: reminder)
      end

      def get(reminder_id)
        store.get(collection: COLLECTION, key: reminder_id.to_s)
      end

      def all
        store.all(collection: COLLECTION).values.sort_by { |reminder| reminder["created_at"].to_s }
      end

      def active
        all.select { |reminder| reminder["status"] == "active" }
      end

      def for_chat(chat_id)
        active.select { |reminder| reminder["chat_id"].to_s == chat_id.to_s }
      end

      def reset!
        store.clear(collection: COLLECTION)
      end

      private

      def store
        Igniter::Data.default_store
      end
    end
  end
end
