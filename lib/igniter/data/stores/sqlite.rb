# frozen_string_literal: true

require "fileutils"
require "json"

module Igniter
  module Data
    module Stores
      class SQLite < Store
        def initialize(path:) # rubocop:disable Lint/MissingSuper
          require "sqlite3"
        rescue LoadError
          raise ConfigurationError,
                "SQLite data store requires the 'sqlite3' gem. Add it to your Gemfile: gem 'sqlite3'"
        else
          prepare_path!(path)
          @mutex = Mutex.new
          @db = ::SQLite3::Database.new(path)
          @db.results_as_hash = true
          create_schema!
        end

        def put(collection:, key:, value:)
          @mutex.synchronize do
            @db.execute(
              "INSERT OR REPLACE INTO data_records (collection, key, value_json, updated_at) VALUES (?, ?, ?, ?)",
              [collection.to_s, key.to_s, JSON.generate(value), Time.now.to_i]
            )
            decode(value)
          end
        end

        def get(collection:, key:)
          @mutex.synchronize do
            row = @db.get_first_row(
              "SELECT value_json FROM data_records WHERE collection = ? AND key = ?",
              [collection.to_s, key.to_s]
            )
            row ? decode_json(row["value_json"]) : nil
          end
        end

        def delete(collection:, key:)
          @mutex.synchronize do
            row = @db.get_first_row(
              "SELECT value_json FROM data_records WHERE collection = ? AND key = ?",
              [collection.to_s, key.to_s]
            )
            @db.execute(
              "DELETE FROM data_records WHERE collection = ? AND key = ?",
              [collection.to_s, key.to_s]
            )
            row ? decode_json(row["value_json"]) : nil
          end
        end

        def all(collection:)
          @mutex.synchronize do
            rows = @db.execute(
              "SELECT key, value_json FROM data_records WHERE collection = ? ORDER BY key ASC",
              [collection.to_s]
            )
            rows.each_with_object({}) do |row, memo|
              memo[row["key"]] = decode_json(row["value_json"])
            end
          end
        end

        def keys(collection:)
          @mutex.synchronize do
            @db.execute(
              "SELECT key FROM data_records WHERE collection = ? ORDER BY key ASC",
              [collection.to_s]
            ).map { |row| row["key"] }
          end
        end

        def clear(collection: nil)
          @mutex.synchronize do
            if collection
              @db.execute("DELETE FROM data_records WHERE collection = ?", [collection.to_s])
            else
              @db.execute("DELETE FROM data_records")
            end
          end
        end

        private

        def create_schema!
          @db.execute_batch(<<~SQL)
            CREATE TABLE IF NOT EXISTS data_records (
              collection TEXT NOT NULL,
              key TEXT NOT NULL,
              value_json TEXT NOT NULL,
              updated_at INTEGER NOT NULL,
              PRIMARY KEY (collection, key)
            );
            CREATE INDEX IF NOT EXISTS idx_data_records_collection_updated_at
              ON data_records(collection, updated_at);
          SQL
        end

        def decode_json(payload)
          JSON.parse(payload)
        end

        def decode(value)
          decode_json(JSON.generate(value))
        end

        def prepare_path!(path)
          return if path.to_s.empty? || path == ":memory:"

          FileUtils.mkdir_p(::File.dirname(path))
        end
      end
    end
  end
end
