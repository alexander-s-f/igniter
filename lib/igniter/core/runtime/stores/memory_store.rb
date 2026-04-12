# frozen_string_literal: true

module Igniter
  module Runtime
    module Stores
      class MemoryStore
        def initialize
          @snapshots = {}
          @correlation_index = {}
          @mutex = Mutex.new
        end

        def save(snapshot, correlation: nil, graph: nil) # rubocop:disable Metrics/MethodLength
          execution_id = snapshot[:execution_id] || snapshot["execution_id"]
          @mutex.synchronize do
            @snapshots[execution_id] = deep_copy(snapshot)
            if graph
              @correlation_index[execution_id] = {
                graph: graph,
                correlation: (correlation || {}).transform_keys(&:to_sym)
              }
            end
          end
          execution_id
        end

        def find_by_correlation(graph:, correlation:)
          normalized = correlation.transform_keys(&:to_sym)
          @mutex.synchronize do
            @correlation_index.each do |execution_id, entry|
              next unless entry[:graph] == graph
              return execution_id if entry[:correlation] == normalized
            end
            nil
          end
        end

        def list_all(graph: nil)
          @mutex.synchronize do
            if graph
              @correlation_index.select { |_id, entry| entry[:graph] == graph }.keys
            else
              @snapshots.keys
            end
          end
        end

        def list_pending(graph: nil) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
          ids = @mutex.synchronize do
            if graph
              @correlation_index.select { |_id, entry| entry[:graph] == graph }.keys
            else
              @snapshots.keys
            end
          end

          @mutex.synchronize do
            ids.select do |id|
              snapshot = @snapshots[id]
              next false unless snapshot

              states = snapshot[:states] || snapshot["states"] || {}
              states.any? do |_name, state|
                status = state[:status] || state["status"]
                status.to_s == "pending"
              end
            end
          end
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
