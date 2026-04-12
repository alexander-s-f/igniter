# frozen_string_literal: true

require "time"
require "igniter/data"

module Companion
  module TelegramBindingsStore
    COLLECTION = "companion_telegram_bindings"
    META_COLLECTION = "companion_telegram_meta"
    PREFERRED_CHAT_KEY = "preferred_chat_id"
    LAST_CHAT_KEY = "last_chat_id"

    class << self
      def upsert(message, prefer: false)
        chat = message.fetch("chat", {})
        chat_id = chat.fetch("id").to_s

        binding = store.put(
          collection: COLLECTION,
          key: chat_id,
          value: {
            "chat_id" => chat_id,
            "type" => chat["type"],
            "title" => chat["title"],
            "username" => chat["username"],
            "first_name" => chat["first_name"],
            "last_name" => chat["last_name"],
            "user_id" => message.dig("from", "id")&.to_s,
            "user_username" => message.dig("from", "username"),
            "language_code" => message.dig("from", "language_code"),
            "updated_at" => Time.now.utc.iso8601
          }.compact
        )

        store.put(collection: META_COLLECTION, key: LAST_CHAT_KEY, value: chat_id)
        select!(chat_id) if prefer || preferred_chat_id.nil?

        binding
      end

      def get(chat_id)
        store.get(collection: COLLECTION, key: chat_id.to_s)
      end

      def latest_chat_id
        store.get(collection: META_COLLECTION, key: LAST_CHAT_KEY)
      end

      def latest_binding
        chat_id = latest_chat_id
        chat_id ? get(chat_id) : nil
      end

      def preferred_chat_id
        store.get(collection: META_COLLECTION, key: PREFERRED_CHAT_KEY)
      end

      def preferred_binding
        chat_id = preferred_chat_id
        chat_id ? get(chat_id) : nil
      end

      def select!(chat_id)
        binding = get(chat_id)
        return nil unless binding

        store.put(collection: META_COLLECTION, key: PREFERRED_CHAT_KEY, value: chat_id.to_s)
        binding
      end

      def all
        store.all(collection: COLLECTION)
      end

      def reset!
        store.clear(collection: COLLECTION)
        store.clear(collection: META_COLLECTION)
      end

      private

      def store
        Igniter::Data.default_store
      end
    end
  end
end
