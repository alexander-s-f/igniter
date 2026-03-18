# frozen_string_literal: true

module Igniter
  module Runtime
    module Stores
      class MemoryStore
        def initialize
          @snapshots = {}
          @mutex = Mutex.new
        end

        def save(snapshot)
          execution_id = snapshot[:execution_id] || snapshot["execution_id"]
          @mutex.synchronize { @snapshots[execution_id] = deep_copy(snapshot) }
          execution_id
        end

        def fetch(execution_id)
          @mutex.synchronize { deep_copy(@snapshots.fetch(execution_id)) }
        rescue KeyError
          raise Igniter::ResolutionError, "No execution snapshot found for '#{execution_id}'"
        end

        def delete(execution_id)
          @mutex.synchronize { @snapshots.delete(execution_id) }
        end

        def exist?(execution_id)
          @mutex.synchronize { @snapshots.key?(execution_id) }
        end

        private

        def deep_copy(value)
          Marshal.load(Marshal.dump(value))
        end
      end
    end
  end
end
