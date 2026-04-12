# frozen_string_literal: true

require "fileutils"
require "json"

module Igniter
  module Data
    module Stores
      class File < Store
        def initialize(path:) # rubocop:disable Lint/MissingSuper
          @path = path.to_s
          raise ConfigurationError, "File data store path cannot be blank" if @path.empty?

          prepare_path!
        end

        def put(collection:, key:, value:)
          mutate do |data|
            data[collection.to_s] ||= {}
            data[collection.to_s][key.to_s] = deep_copy(value)
            deep_copy(value)
          end
        end

        def get(collection:, key:)
          read_data do |data|
            value = data.fetch(collection.to_s, {}).fetch(key.to_s, nil)
            value.nil? ? nil : deep_copy(value)
          end
        end

        def delete(collection:, key:)
          mutate do |data|
            collection_data = data.fetch(collection.to_s, {})
            value = collection_data.delete(key.to_s)
            data.delete(collection.to_s) if collection_data.empty?
            value.nil? ? nil : deep_copy(value)
          end
        end

        def all(collection:)
          read_data do |data|
            data.fetch(collection.to_s, {}).each_with_object({}) do |(key, value), memo|
              memo[key] = deep_copy(value)
            end
          end
        end

        def keys(collection:)
          read_data do |data|
            data.fetch(collection.to_s, {}).keys.sort
          end
        end

        def clear(collection: nil)
          mutate do |data|
            if collection
              data.delete(collection.to_s)
            else
              data.clear
            end

            nil
          end
        end

        private

        def mutate
          ::File.open(@path, ::File::RDWR | ::File::CREAT, 0o644) do |file|
            file.flock(::File::LOCK_EX)
            data = parse(file.read)
            result = yield(data)
            file.rewind
            file.truncate(0)
            file.write(JSON.generate(data))
            file.flush
            result
          ensure
            file.flock(::File::LOCK_UN) rescue nil # rubocop:disable Style/RescueModifier
          end
        end

        def read_data
          ::File.open(@path, ::File::RDWR | ::File::CREAT, 0o644) do |file|
            file.flock(::File::LOCK_SH)
            yield(parse(file.read))
          ensure
            file.flock(::File::LOCK_UN) rescue nil # rubocop:disable Style/RescueModifier
          end
        end

        def parse(payload)
          content = payload.to_s.strip
          return {} if content.empty?

          JSON.parse(content)
        rescue JSON::ParserError
          {}
        end

        def prepare_path!
          FileUtils.mkdir_p(::File.dirname(@path))
          ::File.write(@path, "{}") unless ::File.exist?(@path)
        end

        def deep_copy(value)
          JSON.parse(JSON.generate(value))
        end
      end
    end
  end
end
