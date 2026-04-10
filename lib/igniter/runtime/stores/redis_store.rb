# frozen_string_literal: true

require "json"

module Igniter
  module Runtime
    module Stores
      class RedisStore
        def initialize(redis:, namespace: "igniter:executions")
          @redis = redis
          @namespace = namespace
        end

        # Save a snapshot. Maintains secondary indexes:
        #   {namespace}:all               — set of all execution_ids
        #   {namespace}:graph:{name}      — set of execution_ids for a given graph
        #   {namespace}:corr:{graph}      — hash of JSON(sorted_correlation) → execution_id
        def save(snapshot, correlation: nil, graph: nil) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
          execution_id = snapshot[:execution_id] || snapshot["execution_id"]
          @redis.set(redis_key(execution_id), JSON.generate(snapshot))
          @redis.sadd(all_key, execution_id)

          if graph
            @redis.sadd(graph_key(graph), execution_id)
            if correlation && !correlation.empty?
              corr_json = JSON.generate(correlation.transform_keys(&:to_s).sort.to_h)
              @redis.hset(correlation_key(graph), corr_json, execution_id)
            end
          end

          execution_id
        end

        def find_by_correlation(graph:, correlation:)
          normalized = correlation.transform_keys(&:to_s).sort.to_h
          @redis.hget(correlation_key(graph), JSON.generate(normalized))
        end

        def list_all(graph: nil)
          @redis.smembers(graph ? graph_key(graph) : all_key)
        end

        def list_pending(graph: nil)
          list_all(graph: graph).select do |id|
            payload = @redis.get(redis_key(id))
            next false unless payload

            snapshot = JSON.parse(payload)
            states   = snapshot["states"] || {}
            states.any? { |_name, state| state["status"].to_s == "pending" }
          rescue StandardError
            false
          end
        end

        def fetch(execution_id)
          payload = @redis.get(redis_key(execution_id))
          raise Igniter::ResolutionError, "No execution snapshot found for '#{execution_id}'" unless payload

          JSON.parse(payload)
        end

        def delete(execution_id)
          @redis.del(redis_key(execution_id))
          @redis.srem(all_key, execution_id)
        end

        def exist?(execution_id)
          result = @redis.exists?(redis_key(execution_id))
          result == true || result.to_i.positive?
        end

        private

        def redis_key(execution_id)
          "#{@namespace}:#{execution_id}"
        end

        def all_key
          "#{@namespace}:all"
        end

        def graph_key(graph)
          "#{@namespace}:graph:#{graph}"
        end

        def correlation_key(graph)
          "#{@namespace}:corr:#{graph}"
        end
      end
    end
  end
end
