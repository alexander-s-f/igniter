# frozen_string_literal: true

module Igniter
  module Memory
    module Stores
      # Thread-safe in-memory implementation of the Store interface.
      #
      # Stores all data in process memory. Suitable for testing and
      # single-process applications where persistence is not required.
      # All operations are protected by a single Mutex for thread safety.
      #
      # @example
      #   store = Igniter::Memory::Stores::InMemory.new
      #   ep    = store.record(agent_id: "bot:1", type: :tool_call, content: "searched web")
      #   store.episodes(agent_id: "bot:1") # => [ep]
      class InMemory < Store
        def initialize # rubocop:disable Lint/MissingSuper
          @episodes    = []
          @facts       = {}
          @reflections = []
          @seq         = 0
          @mutex       = Mutex.new
        end

        # @see Store#record
        def record(agent_id:, type:, content:, session_id: nil, outcome: nil, importance: 0.5) # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
          @mutex.synchronize do
            ep = Episode.new(
              id: next_id,
              agent_id: agent_id,
              session_id: session_id,
              ts: Time.now.to_i,
              type: type,
              content: content,
              outcome: outcome,
              importance: importance
            )
            @episodes << ep
            ep
          end
        end

        # @see Store#episodes
        def episodes(agent_id:, last: 50, type: nil)
          @mutex.synchronize do
            result = @episodes.select { |e| e.agent_id == agent_id }
            result = result.select { |e| e.type == type } if type
            result.last(last)
          end
        end

        # @see Store#retrieve
        def retrieve(agent_id:, query: nil, limit: 10, type: nil)
          eps = episodes(agent_id: agent_id, last: 1000, type: type)
          return eps.last(limit) unless query

          q = query.to_s.downcase
          eps.select { |e| e.content.to_s.downcase.include?(q) }.last(limit)
        end

        # @see Store#store_fact
        def store_fact(agent_id:, key:, value:, confidence: 1.0) # rubocop:disable Metrics/MethodLength
          @mutex.synchronize do
            @facts[agent_id] ||= {}
            fact = Fact.new(
              id: next_id,
              agent_id: agent_id,
              key: key.to_s,
              value: value,
              confidence: confidence,
              updated_at: Time.now.to_i
            )
            @facts[agent_id][key.to_s] = fact
            fact
          end
        end

        # @see Store#facts
        def facts(agent_id:)
          @mutex.synchronize { (@facts[agent_id] || {}).dup }
        end

        # @see Store#record_reflection
        def record_reflection(agent_id:, summary:, system_patch: nil, applied: false) # rubocop:disable Metrics/MethodLength
          @mutex.synchronize do
            rec = ReflectionRecord.new(
              id: next_id,
              agent_id: agent_id,
              ts: Time.now.to_i,
              summary: summary,
              system_patch: system_patch,
              applied: applied
            )
            @reflections << rec
            rec
          end
        end

        # @see Store#reflections
        def reflections(agent_id:, applied: nil)
          @mutex.synchronize do
            result = @reflections.select { |r| r.agent_id == agent_id }
            applied.nil? ? result : result.select { |r| r.applied == applied }
          end
        end

        # @see Store#apply_reflection
        def apply_reflection(id:)
          @mutex.synchronize do
            rec = @reflections.find { |r| r.id == id }
            return false unless rec

            idx = @reflections.index(rec)
            @reflections[idx] = ReflectionRecord.new(**rec.to_h.merge(applied: true))
            true
          end
        end

        # @see Store#clear
        def clear(agent_id:)
          @mutex.synchronize do
            @episodes.reject! { |e| e.agent_id == agent_id }
            @facts.delete(agent_id)
            @reflections.reject! { |r| r.agent_id == agent_id }
          end
        end

        private

        def next_id
          @seq += 1
        end
      end
    end
  end
end
