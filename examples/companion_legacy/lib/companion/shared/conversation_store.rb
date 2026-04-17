# frozen_string_literal: true

require "igniter/sdk/data"

module Companion
  module ConversationStore
    MAX_TURNS = 20
    COLLECTION = "companion_conversations"

    class << self
      def append(session_id, role:, content:)
        history = history(session_id)
        history << normalize_turn("role" => role.to_s, "content" => content.to_s)
        store.put(collection: COLLECTION, key: session_key(session_id), value: history.last(MAX_TURNS).map(&method(:serialize_turn)))
      end

      def history(session_id)
        Array(store.get(collection: COLLECTION, key: session_key(session_id))).map do |turn|
          normalize_turn(turn)
        end
      end

      def clear(session_id)
        store.delete(collection: COLLECTION, key: session_key(session_id))
      end

      def reset!
        store.clear(collection: COLLECTION)
      end

      private

      def store
        Igniter::Data.default_store
      end

      def session_key(session_id)
        session_id.to_s
      end

      def serialize_turn(turn)
        {
          "role" => turn[:role].to_s,
          "content" => turn[:content].to_s
        }
      end

      def normalize_turn(turn)
        {
          role: (turn[:role] || turn["role"]).to_s,
          content: (turn[:content] || turn["content"]).to_s
        }
      end
    end
  end
end
