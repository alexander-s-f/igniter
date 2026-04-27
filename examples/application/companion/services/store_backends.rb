# frozen_string_literal: true

require "fileutils"
require "json"

module Companion
  module Services
    module StoreBackends
      class Memory
        def initialize
          @state = nil
        end

        def load_state
          deep_dup(@state)
        end

        def save_state(state)
          @state = deep_dup(state)
          self
        end

        private

        def deep_dup(value)
          case value
          when Hash
            value.transform_values { |entry| deep_dup(entry) }
          when Array
            value.map { |entry| deep_dup(entry) }
          else
            value
          end
        end
      end

      class Sqlite
        KEY = "companion_state"

        def initialize(path:)
          require "sqlite3"

          @path = path.to_s
          FileUtils.mkdir_p(File.dirname(@path))
          @db = SQLite3::Database.new(@path)
          @db.execute("CREATE TABLE IF NOT EXISTS companion_state (key TEXT PRIMARY KEY, payload TEXT NOT NULL)")
        end

        def load_state
          row = @db.get_first_row("SELECT payload FROM companion_state WHERE key = ?", [KEY])
          row ? JSON.parse(row.first, symbolize_names: true) : nil
        end

        def save_state(state)
          payload = JSON.generate(state)
          @db.execute(
            "INSERT INTO companion_state (key, payload) VALUES (?, ?) " \
            "ON CONFLICT(key) DO UPDATE SET payload = excluded.payload",
            [KEY, payload]
          )
          self
        end
      end
    end
  end
end
