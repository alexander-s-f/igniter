# frozen_string_literal: true

module Igniter
  module Server
    class AgentSessionStore
      STORAGE_GRAPH = "__igniter_server_agent_sessions__"
      ID_PREFIX = "agent-session:"

      def initialize(store: nil)
        @store = store
        @sessions = {}
        @mutex = Mutex.new
      end

      def save(session)
        normalized = normalize_session(session)
        if runtime_store
          runtime_store.save(
            {
              execution_id: storage_id(normalized.token),
              graph: STORAGE_GRAPH,
              token: normalized.token,
              session: normalized.to_h
            },
            graph: STORAGE_GRAPH,
            correlation: { token: normalized.token.to_s }
          )
        else
          @mutex.synchronize { @sessions[normalized.token] = deep_copy(normalized.to_h) }
        end
        normalized
      end

      def fetch(token)
        data =
          if runtime_store
            snapshot = runtime_store.fetch(storage_id(token))
            snapshot[:session] || snapshot["session"]
          else
            @mutex.synchronize { deep_copy(@sessions.fetch(token.to_s)) }
          end
        Igniter::Runtime::AgentSession.from_h(data)
      rescue KeyError
        raise Igniter::ResolutionError, "No agent session found for token '#{token}'"
      end

      def delete(token)
        if runtime_store
          runtime_store.delete(storage_id(token))
        else
          @mutex.synchronize { @sessions.delete(token.to_s) }
        end
      end

      def exist?(token)
        if runtime_store
          runtime_store.exist?(storage_id(token))
        else
          @mutex.synchronize { @sessions.key?(token.to_s) }
        end
      end

      def list_tokens
        if runtime_store
          runtime_store.list_all(graph: STORAGE_GRAPH).map { |id| extract_token(id) }
        else
          @mutex.synchronize { @sessions.keys.dup }
        end
      end

      private

      def runtime_store
        resolved = @store.respond_to?(:call) ? @store.call : @store
        resolved if resolved&.respond_to?(:save) && resolved.respond_to?(:fetch)
      end

      def normalize_session(session)
        return session if session.is_a?(Igniter::Runtime::AgentSession)

        data = session.respond_to?(:to_h) ? session.to_h : session
        Igniter::Runtime::AgentSession.from_h(data)
      end

      def storage_id(token)
        "#{ID_PREFIX}#{token}"
      end

      def extract_token(storage_id)
        storage_id.to_s.start_with?(ID_PREFIX) ? storage_id.to_s.delete_prefix(ID_PREFIX) : storage_id.to_s
      end

      def deep_copy(value)
        Marshal.load(Marshal.dump(value))
      end
    end
  end
end
