# frozen_string_literal: true

module Igniter
  module Memory
    # Abstract base class defining the Store interface for episodic memory.
    #
    # Concrete adapters must subclass Store and implement all public methods.
    # All methods raise +NotImplementedError+ by default.
    #
    # == Interface
    #
    #   store.record(agent_id:, type:, content:)             # => Episode
    #   store.episodes(agent_id:, last: 50)                  # => Array<Episode>
    #   store.retrieve(agent_id:, query: "keyword")          # => Array<Episode>
    #   store.store_fact(agent_id:, key:, value:)
    #   store.facts(agent_id:)                               # => Hash{key => Fact}
    #   store.record_reflection(agent_id:, summary:)         # => ReflectionRecord
    #   store.reflections(agent_id:)                         # => Array<ReflectionRecord>
    #   store.apply_reflection(id:)                          # => true/false
    #   store.clear(agent_id:)
    class Store
      # Record an episode. Returns the persisted Episode.
      #
      # @param agent_id  [String]         identifier of the owning agent
      # @param type      [String, Symbol]  category tag for the episode
      # @param content   [String]          textual description of the event
      # @param session_id [String, nil]    optional session grouping key
      # @param outcome   [String, nil]     result label, e.g. "success"/"failure"
      # @param importance [Float]          relevance weight 0.0-1.0 (default 0.5)
      # @return [Episode]
      def record(agent_id:, type:, content:, session_id: nil, outcome: nil, importance: 0.5) # rubocop:disable Metrics/ParameterLists
        raise NotImplementedError, "#{self.class}#record not implemented"
      end

      # Return episodes for an agent, newest last.
      #
      # @param agent_id [String]         identifier of the agent
      # @param last     [Integer]        maximum number of episodes to return
      # @param type     [String, Symbol, nil] optional type filter
      # @return [Array<Episode>]
      def episodes(agent_id:, last: 50, type: nil)
        raise NotImplementedError, "#{self.class}#episodes not implemented"
      end

      # Keyword-search episodes. Returns Array<Episode>.
      #
      # When +query+ is nil, returns the last +limit+ episodes.
      # When +query+ is provided, filters by case-insensitive substring or FTS match.
      #
      # @param agent_id [String]
      # @param query    [String, nil] search term
      # @param limit    [Integer]     maximum results (default 10)
      # @param type     [String, Symbol, nil] optional type filter
      # @return [Array<Episode>]
      def retrieve(agent_id:, query: nil, limit: 10, type: nil)
        raise NotImplementedError, "#{self.class}#retrieve not implemented"
      end

      # Upsert a fact for an agent.
      #
      # @param agent_id   [String]  identifier of the owning agent
      # @param key        [String]  fact name
      # @param value      [Object]  fact value
      # @param confidence [Float]   confidence score 0.0-1.0 (default 1.0)
      # @return [Fact]
      def store_fact(agent_id:, key:, value:, confidence: 1.0)
        raise NotImplementedError, "#{self.class}#store_fact not implemented"
      end

      # Returns all facts for an agent as a Hash keyed by string key.
      #
      # @param agent_id [String]
      # @return [Hash{String => Fact}]
      def facts(agent_id:)
        raise NotImplementedError, "#{self.class}#facts not implemented"
      end

      # Store a reflection record. Returns the persisted ReflectionRecord.
      #
      # @param agent_id    [String]      owning agent identifier
      # @param summary     [String]      human-readable reflection summary
      # @param system_patch [String, nil] optional suggested system prompt patch
      # @param applied     [Boolean]     whether already applied (default false)
      # @return [ReflectionRecord]
      def record_reflection(agent_id:, summary:, system_patch: nil, applied: false)
        raise NotImplementedError, "#{self.class}#record_reflection not implemented"
      end

      # Returns reflection records for an agent.
      #
      # @param agent_id [String]
      # @param applied  [Boolean, nil] nil returns all; true/false filters by applied flag
      # @return [Array<ReflectionRecord>]
      def reflections(agent_id:, applied: nil)
        raise NotImplementedError, "#{self.class}#reflections not implemented"
      end

      # Mark a reflection as applied.
      #
      # @param id [Integer] reflection identifier
      # @return [Boolean] true if found and updated, false if not found
      def apply_reflection(id:)
        raise NotImplementedError, "#{self.class}#apply_reflection not implemented"
      end

      # Clear all stored data for an agent.
      #
      # @param agent_id [String]
      # @return [void]
      def clear(agent_id:)
        raise NotImplementedError, "#{self.class}#clear not implemented"
      end
    end
  end
end
