# frozen_string_literal: true

module Igniter
  module Data
    module Stores
      class InMemory < Store
        def initialize # rubocop:disable Lint/MissingSuper
          @collections = Hash.new { |hash, key| hash[key] = {} }
          @mutex = Mutex.new
        end

        def put(collection:, key:, value:)
          @mutex.synchronize do
            @collections[collection.to_s][key.to_s] = deep_copy(value)
            deep_copy(value)
          end
        end

        def get(collection:, key:)
          @mutex.synchronize do
            value = @collections[collection.to_s][key.to_s]
            value.nil? ? nil : deep_copy(value)
          end
        end

        def delete(collection:, key:)
          @mutex.synchronize do
            value = @collections[collection.to_s].delete(key.to_s)
            value.nil? ? nil : deep_copy(value)
          end
        end

        def all(collection:)
          @mutex.synchronize do
            @collections[collection.to_s].each_with_object({}) do |(key, value), memo|
              memo[key] = deep_copy(value)
            end
          end
        end

        def keys(collection:)
          @mutex.synchronize { @collections[collection.to_s].keys.sort }
        end

        def clear(collection: nil)
          @mutex.synchronize do
            if collection
              @collections.delete(collection.to_s)
            else
              @collections = Hash.new { |hash, key| hash[key] = {} }
            end
          end
        end

        private

        def deep_copy(value)
          Marshal.load(Marshal.dump(value))
        end
      end
    end
  end
end
