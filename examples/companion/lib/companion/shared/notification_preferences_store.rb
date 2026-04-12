# frozen_string_literal: true

require "time"
require "igniter/data"

module Companion
  module NotificationPreferencesStore
    COLLECTION = "companion_notification_preferences"

    class << self
      def get(scope)
        store.get(collection: COLLECTION, key: scope_key(scope))
      end

      def set(scope, attributes)
        current = get(scope) || {}
        store.put(
          collection: COLLECTION,
          key: scope_key(scope),
          value: current.merge(stringify_keys(attributes)).merge(
            "scope" => scope_key(scope),
            "updated_at" => Time.now.utc.iso8601
          )
        )
      end

      def telegram_preferences(chat_id)
        get(telegram_scope(chat_id))
      end

      def set_telegram_enabled(chat_id, enabled)
        set(telegram_scope(chat_id), "telegram_enabled" => enabled ? true : false)
      end

      def all
        store.all(collection: COLLECTION)
      end

      def telegram_enabled?(chat_id)
        prefs = telegram_preferences(chat_id)
        return true if prefs.nil?

        prefs["telegram_enabled"] != false
      end

      def reset!
        store.clear(collection: COLLECTION)
      end

      private

      def store
        Igniter::Data.default_store
      end

      def telegram_scope(chat_id)
        "telegram:#{chat_id}"
      end

      def scope_key(scope)
        scope.to_s
      end

      def stringify_keys(hash)
        hash.each_with_object({}) do |(key, value), memo|
          memo[key.to_s] = value
        end
      end
    end
  end
end
