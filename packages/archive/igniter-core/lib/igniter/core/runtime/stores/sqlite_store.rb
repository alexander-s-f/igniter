# frozen_string_literal: true

require "fileutils"
require "json"

module Igniter
  module Runtime
    module Stores
      class SQLiteStore
        def initialize(path:)
          require "sqlite3"
        rescue LoadError
          raise Igniter::Runtime::ConfigurationError,
                "`igniter` now ships with a required `sqlite3` dependency. " \
                "If it is missing in this environment, run bundle install or reinstall the gem."
        else
          prepare_path!(path)
          @mutex = Mutex.new
          @db = ::SQLite3::Database.new(path)
          @db.results_as_hash = true
          create_schema!
        end

        def save(snapshot, correlation: nil, graph: nil)
          execution_id = snapshot[:execution_id] || snapshot["execution_id"]
          resolved_graph = graph || snapshot[:graph] || snapshot["graph"]
          correlation_json = normalized_correlation_json(correlation)
          pending = pending_snapshot?(snapshot) ? 1 : 0

          @mutex.synchronize do
            @db.execute(
              <<~SQL,
                INSERT OR REPLACE INTO execution_snapshots
                  (execution_id, graph, correlation_json, pending, snapshot_json, updated_at)
                VALUES (?, ?, ?, ?, ?, ?)
              SQL
              [execution_id, resolved_graph, correlation_json, pending, JSON.generate(snapshot), Time.now.to_i]
            )
          end

          execution_id
        end

        def find_by_correlation(graph:, correlation:)
          @mutex.synchronize do
            row = @db.get_first_row(
              "SELECT execution_id FROM execution_snapshots WHERE graph = ? AND correlation_json = ?",
              [graph, normalized_correlation_json(correlation)]
            )
            row && row["execution_id"]
          end
        end

        def list_all(graph: nil)
          @mutex.synchronize do
            rows =
              if graph
                @db.execute(
                  "SELECT execution_id FROM execution_snapshots WHERE graph = ? ORDER BY updated_at ASC",
                  [graph]
                )
              else
                @db.execute("SELECT execution_id FROM execution_snapshots ORDER BY updated_at ASC")
              end
            rows.map { |row| row["execution_id"] }
          end
        end

        def list_pending(graph: nil)
          @mutex.synchronize do
            rows =
              if graph
                @db.execute(
                  "SELECT execution_id FROM execution_snapshots WHERE graph = ? AND pending = 1 ORDER BY updated_at ASC",
                  [graph]
                )
              else
                @db.execute("SELECT execution_id FROM execution_snapshots WHERE pending = 1 ORDER BY updated_at ASC")
              end
            rows.map { |row| row["execution_id"] }
          end
        end

        def fetch(execution_id)
          @mutex.synchronize do
            row = @db.get_first_row(
              "SELECT snapshot_json FROM execution_snapshots WHERE execution_id = ?",
              [execution_id]
            )
            raise Igniter::ResolutionError, "No execution snapshot found for '#{execution_id}'" unless row

            JSON.parse(row["snapshot_json"])
          end
        end

        def delete(execution_id)
          @mutex.synchronize do
            @db.execute("DELETE FROM execution_snapshots WHERE execution_id = ?", [execution_id])
          end
        end

        def exist?(execution_id)
          @mutex.synchronize do
            row = @db.get_first_row(
              "SELECT 1 FROM execution_snapshots WHERE execution_id = ? LIMIT 1",
              [execution_id]
            )
            !row.nil?
          end
        end

        private

        def create_schema!
          @db.execute_batch(<<~SQL)
            CREATE TABLE IF NOT EXISTS execution_snapshots (
              execution_id TEXT PRIMARY KEY,
              graph TEXT,
              correlation_json TEXT,
              pending INTEGER NOT NULL DEFAULT 0,
              snapshot_json TEXT NOT NULL,
              updated_at INTEGER NOT NULL
            );
            CREATE INDEX IF NOT EXISTS idx_execution_snapshots_graph
              ON execution_snapshots(graph);
            CREATE INDEX IF NOT EXISTS idx_execution_snapshots_pending
              ON execution_snapshots(pending, updated_at);
            CREATE INDEX IF NOT EXISTS idx_execution_snapshots_graph_correlation
              ON execution_snapshots(graph, correlation_json);
          SQL
        end

        def normalized_correlation_json(correlation)
          return nil if correlation.nil? || correlation.empty?

          JSON.generate(correlation.transform_keys(&:to_s).sort.to_h)
        end

        def pending_snapshot?(snapshot)
          states = snapshot[:states] || snapshot["states"] || {}
          states.any? do |_name, state|
            status = state[:status] || state["status"]
            status.to_s == "pending"
          end
        end

        def prepare_path!(path)
          return if path.to_s.empty? || path == ":memory:"

          FileUtils.mkdir_p(::File.dirname(path))
        end
      end
    end
  end
end
