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

        def save(snapshot)
          execution_id = snapshot[:execution_id] || snapshot["execution_id"]
          @redis.set(redis_key(execution_id), JSON.generate(snapshot))
          execution_id
        end

        def fetch(execution_id)
          payload = @redis.get(redis_key(execution_id))
          raise Igniter::ResolutionError, "No execution snapshot found for '#{execution_id}'" unless payload

          JSON.parse(payload)
        end

        def delete(execution_id)
          @redis.del(redis_key(execution_id))
        end

        def exist?(execution_id)
          result = @redis.exists?(redis_key(execution_id))
          result == true || result.to_i.positive?
        end

        private

        def redis_key(execution_id)
          "#{@namespace}:#{execution_id}"
        end
      end
    end
  end
end
