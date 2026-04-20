# frozen_string_literal: true

module Igniter
  module Server
    class AgentSessionStore
      def initialize
        @sessions = {}
        @mutex = Mutex.new
      end

      def save(session)
        normalized = normalize_session(session)
        @mutex.synchronize { @sessions[normalized.token] = deep_copy(normalized.to_h) }
        normalized
      end

      def fetch(token)
        data = @mutex.synchronize { deep_copy(@sessions.fetch(token.to_s)) }
        Igniter::Runtime::AgentSession.from_h(data)
      rescue KeyError
        raise Igniter::ResolutionError, "No agent session found for token '#{token}'"
      end

      def delete(token)
        @mutex.synchronize { @sessions.delete(token.to_s) }
      end

      def exist?(token)
        @mutex.synchronize { @sessions.key?(token.to_s) }
      end

      def list_tokens
        @mutex.synchronize { @sessions.keys.dup }
      end

      private

      def normalize_session(session)
        return session if session.is_a?(Igniter::Runtime::AgentSession)

        data = session.respond_to?(:to_h) ? session.to_h : session
        Igniter::Runtime::AgentSession.from_h(data)
      end

      def deep_copy(value)
        Marshal.load(Marshal.dump(value))
      end
    end
  end
end
