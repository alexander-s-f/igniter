# frozen_string_literal: true

module Companion
  module ConversationStore
    MAX_TURNS = 20

    class << self
      def append(session_id, role:, content:)
        mutex.synchronize do
          conversations[session_key(session_id)] ||= []
          conversations[session_key(session_id)] << {
            role: role.to_s,
            content: content.to_s
          }
          conversations[session_key(session_id)] = conversations[session_key(session_id)].last(MAX_TURNS)
        end
      end

      def history(session_id)
        mutex.synchronize { Array(conversations[session_key(session_id)]).map(&:dup) }
      end

      def clear(session_id)
        mutex.synchronize { conversations.delete(session_key(session_id)) }
      end

      def reset!
        mutex.synchronize { @conversations = {} }
      end

      private

      def conversations = (@conversations ||= {})
      def mutex = (@mutex ||= Mutex.new)

      def session_key(session_id)
        session_id.to_s
      end
    end
  end
end
