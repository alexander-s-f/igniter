# frozen_string_literal: true

module Igniter
  module Memory
    module Stores
      # SQLite-backed persistent Store implementation.
      #
      # Uses SQLite3 with FTS5 for fast full-text search on episode content.
      # Requires the +sqlite3+ gem (soft dependency — not declared in the gemspec).
      # Raises +Igniter::Memory::ConfigurationError+ if the gem is not available.
      #
      # @example In-memory SQLite (for tests)
      #   store = Igniter::Memory::Stores::SQLite.new(path: ":memory:")
      #
      # @example Persistent file
      #   store = Igniter::Memory::Stores::SQLite.new(path: "/tmp/agent_memory.db")
      class SQLite < Store # rubocop:disable Metrics/ClassLength
        # @param path [String] file path for the database, or ":memory:" for transient storage
        def initialize(path:) # rubocop:disable Lint/MissingSuper
          require "sqlite3"
        rescue LoadError
          raise ConfigurationError,
                "SQLite store requires the 'sqlite3' gem. Add it to your Gemfile: gem 'sqlite3'"
        else
          @mutex = Mutex.new
          @db    = ::SQLite3::Database.new(path)
          @db.results_as_hash = true
          create_schema!
        end

        # @see Store#record
        def record(agent_id:, type:, content:, session_id: nil, outcome: nil, importance: 0.5) # rubocop:disable Metrics/ParameterLists
          @mutex.synchronize do
            @db.execute(
              "INSERT INTO episodes (agent_id, session_id, ts, type, content, outcome, importance) " \
              "VALUES (?, ?, ?, ?, ?, ?, ?)",
              [agent_id, session_id, Time.now.to_i, type.to_s, content.to_s, outcome, importance.to_f]
            )
            row_to_episode(
              @db.get_first_row("SELECT * FROM episodes WHERE id = last_insert_rowid()")
            )
          end
        end

        # @see Store#episodes
        def episodes(agent_id:, last: 50, type: nil) # rubocop:disable Metrics/MethodLength
          @mutex.synchronize do
            rows = if type
                     @db.execute(
                       "SELECT * FROM episodes WHERE agent_id = ? AND type = ? ORDER BY ts ASC LIMIT ?",
                       [agent_id, type.to_s, last]
                     )
                   else
                     @db.execute(
                       "SELECT * FROM episodes WHERE agent_id = ? ORDER BY ts ASC LIMIT ?",
                       [agent_id, last]
                     )
                   end
            rows.map { |r| row_to_episode(r) }
          end
        end

        # @see Store#retrieve
        def retrieve(agent_id:, query: nil, limit: 10, type: nil) # rubocop:disable Metrics/MethodLength
          @mutex.synchronize do
            if query
              fts_retrieve(agent_id, query, limit, type)
            else
              rows = if type
                       @db.execute(
                         "SELECT * FROM episodes WHERE agent_id = ? AND type = ? ORDER BY ts ASC LIMIT ?",
                         [agent_id, type.to_s, limit]
                       )
                     else
                       @db.execute(
                         "SELECT * FROM episodes WHERE agent_id = ? ORDER BY ts ASC LIMIT ?",
                         [agent_id, limit]
                       )
                     end
              rows.map { |r| row_to_episode(r) }
            end
          end
        end

        # @see Store#store_fact
        def store_fact(agent_id:, key:, value:, confidence: 1.0) # rubocop:disable Metrics/MethodLength
          @mutex.synchronize do
            serialized = value.to_s
            @db.execute(
              "INSERT OR REPLACE INTO facts (agent_id, key, value, confidence, updated_at) " \
              "VALUES (?, ?, ?, ?, ?)",
              [agent_id, key.to_s, serialized, confidence.to_f, Time.now.to_i]
            )
            row_to_fact(
              @db.get_first_row("SELECT * FROM facts WHERE agent_id = ? AND key = ?", [agent_id, key.to_s])
            )
          end
        end

        # @see Store#facts
        def facts(agent_id:)
          @mutex.synchronize do
            rows = @db.execute("SELECT * FROM facts WHERE agent_id = ?", [agent_id])
            rows.each_with_object({}) do |row, hash|
              fact = row_to_fact(row)
              hash[fact.key] = fact
            end
          end
        end

        # @see Store#record_reflection
        def record_reflection(agent_id:, summary:, system_patch: nil, applied: false)
          @mutex.synchronize do
            @db.execute(
              "INSERT INTO reflections (agent_id, ts, summary, system_patch, applied) " \
              "VALUES (?, ?, ?, ?, ?)",
              [agent_id, Time.now.to_i, summary, system_patch, applied ? 1 : 0]
            )
            row_to_reflection(
              @db.get_first_row("SELECT * FROM reflections WHERE id = last_insert_rowid()")
            )
          end
        end

        # @see Store#reflections
        def reflections(agent_id:, applied: nil) # rubocop:disable Metrics/MethodLength
          @mutex.synchronize do
            rows = if applied.nil?
                     @db.execute("SELECT * FROM reflections WHERE agent_id = ? ORDER BY ts ASC", [agent_id])
                   else
                     @db.execute(
                       "SELECT * FROM reflections WHERE agent_id = ? AND applied = ? ORDER BY ts ASC",
                       [agent_id, applied ? 1 : 0]
                     )
                   end
            rows.map { |r| row_to_reflection(r) }
          end
        end

        # @see Store#apply_reflection
        def apply_reflection(id:)
          @mutex.synchronize do
            changes_before = @db.changes
            @db.execute("UPDATE reflections SET applied = 1 WHERE id = ?", [id])
            @db.changes > changes_before || @db.changes == 1
          end
        end

        # @see Store#clear
        def clear(agent_id:)
          @mutex.synchronize do
            @db.execute("DELETE FROM episodes WHERE agent_id = ?", [agent_id])
            @db.execute("DELETE FROM facts WHERE agent_id = ?", [agent_id])
            @db.execute("DELETE FROM reflections WHERE agent_id = ?", [agent_id])
          end
        end

        private

        def fts_retrieve(agent_id, query, limit, type) # rubocop:disable Metrics/MethodLength
          rows = if type
                   @db.execute(
                     "SELECT e.* FROM episodes e " \
                     "JOIN episodes_fts fts ON fts.rowid = e.id " \
                     "WHERE fts.content MATCH ? AND e.agent_id = ? AND e.type = ? " \
                     "ORDER BY e.ts ASC LIMIT ?",
                     [query.to_s, agent_id, type.to_s, limit]
                   )
                 else
                   @db.execute(
                     "SELECT e.* FROM episodes e " \
                     "JOIN episodes_fts fts ON fts.rowid = e.id " \
                     "WHERE fts.content MATCH ? AND e.agent_id = ? " \
                     "ORDER BY e.ts ASC LIMIT ?",
                     [query.to_s, agent_id, limit]
                   )
                 end
          rows.map { |r| row_to_episode(r) }
        rescue ::SQLite3::Exception
          # FTS5 match error (e.g. invalid query syntax) — fall back to LIKE
          fallback_retrieve(agent_id, query, limit, type)
        end

        def fallback_retrieve(agent_id, query, limit, type) # rubocop:disable Metrics/MethodLength
          q = "%#{query}%"
          rows = if type
                   @db.execute(
                     "SELECT * FROM episodes WHERE agent_id = ? AND type = ? AND content LIKE ? " \
                     "ORDER BY ts ASC LIMIT ?",
                     [agent_id, type.to_s, q, limit]
                   )
                 else
                   @db.execute(
                     "SELECT * FROM episodes WHERE agent_id = ? AND content LIKE ? " \
                     "ORDER BY ts ASC LIMIT ?",
                     [agent_id, q, limit]
                   )
                 end
          rows.map { |r| row_to_episode(r) }
        end

        def row_to_episode(row) # rubocop:disable Metrics/MethodLength
          return nil unless row

          Episode.new(
            id: row["id"],
            agent_id: row["agent_id"],
            session_id: row["session_id"],
            ts: row["ts"],
            type: row["type"],
            content: row["content"],
            outcome: row["outcome"],
            importance: row["importance"]
          )
        end

        def row_to_fact(row)
          return nil unless row

          Fact.new(
            id: row["id"],
            agent_id: row["agent_id"],
            key: row["key"],
            value: row["value"],
            confidence: row["confidence"],
            updated_at: row["updated_at"]
          )
        end

        def row_to_reflection(row)
          return nil unless row

          ReflectionRecord.new(
            id: row["id"],
            agent_id: row["agent_id"],
            ts: row["ts"],
            summary: row["summary"],
            system_patch: row["system_patch"],
            applied: row["applied"] == 1
          )
        end

        def create_schema! # rubocop:disable Metrics/MethodLength
          @db.execute_batch(<<~SQL)
            CREATE TABLE IF NOT EXISTS episodes (
              id         INTEGER PRIMARY KEY AUTOINCREMENT,
              agent_id   TEXT NOT NULL,
              session_id TEXT,
              ts         INTEGER NOT NULL,
              type       TEXT NOT NULL,
              content    TEXT NOT NULL,
              outcome    TEXT,
              importance REAL NOT NULL DEFAULT 0.5
            );
            CREATE INDEX IF NOT EXISTS idx_ep_agent ON episodes(agent_id, ts);
            CREATE VIRTUAL TABLE IF NOT EXISTS episodes_fts USING fts5(
              content, content='episodes', content_rowid='id'
            );
            CREATE TRIGGER IF NOT EXISTS ep_ai AFTER INSERT ON episodes BEGIN
              INSERT INTO episodes_fts(rowid, content) VALUES (new.id, new.content);
            END;
            CREATE TABLE IF NOT EXISTS facts (
              id         INTEGER PRIMARY KEY AUTOINCREMENT,
              agent_id   TEXT NOT NULL,
              key        TEXT NOT NULL,
              value      TEXT,
              confidence REAL DEFAULT 1.0,
              updated_at INTEGER,
              UNIQUE(agent_id, key)
            );
            CREATE TABLE IF NOT EXISTS reflections (
              id           INTEGER PRIMARY KEY AUTOINCREMENT,
              agent_id     TEXT NOT NULL,
              ts           INTEGER NOT NULL,
              summary      TEXT,
              system_patch TEXT,
              applied      INTEGER DEFAULT 0
            );
          SQL
        end
      end
    end
  end
end
