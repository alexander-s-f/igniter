# frozen_string_literal: true

require "time"
require "igniter/data"

module Companion
  module TelegramBindingsStore
    COLLECTION = "companion_telegram_bindings"

    class << self
      def upsert(message)
        chat = message.fetch("chat", {})
        chat_id = chat.fetch("id").to_s

        store.put(
          collection: COLLECTION,
          key: chat_id,
          value: {
            "chat_id" => chat_id,
            "type" => chat["type"],
            "username" => chat["username"],
            "first_name" => chat["first_name"],
            "last_name" => chat["last_name"],
            "language_code" => message.dig("from", "language_code"),
            "updated_at" => Time.now.utc.iso8601
          }.compact
        )
      end

      def get(chat_id)
        store.get(collection: COLLECTION, key: chat_id.to_s)
      end

      def all
        store.all(collection: COLLECTION)
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
