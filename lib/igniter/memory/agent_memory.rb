# frozen_string_literal: true

module Igniter
  module Memory
    # Facade that pre-fills +agent_id+ on all Store operations.
    #
    # Callers interact with AgentMemory instead of the raw Store so they never
    # have to pass +agent_id:+ explicitly. An optional +session_id+ groups
    # episodes within a single interaction session.
    #
    # @example
    #   store  = Igniter::Memory::Stores::InMemory.new
    #   memory = Igniter::Memory::AgentMemory.new(store: store, agent_id: "MyAgent:1")
    #
    #   memory.record(type: :tool_call, content: "searched web for Ruby docs")
    #   memory.recall(query: "Ruby")      # => [Episode, ...]
    #   memory.remember(:user_tz, "UTC")
    #   memory.facts                      # => { "user_tz" => Fact }
    class AgentMemory
      # @param store      [Store]         backing store implementation
      # @param agent_id   [String]        identifier for this agent
      # @param session_id [String, nil]   optional session grouping key
      def initialize(store:, agent_id:, session_id: nil)
        @store      = store
        @agent_id   = agent_id
        @session_id = session_id
      end

      # Record a new episode.
      #
      # @param type       [String, Symbol] category tag
      # @param content    [String]         textual description of the event
      # @param outcome    [String, nil]    result label, e.g. "success"/"failure"
      # @param importance [Float]          relevance weight 0.0–1.0
      # @return [Episode]
      def record(type:, content:, outcome: nil, importance: 0.5)
        @store.record(
          agent_id: @agent_id,
          type: type,
          content: content,
          session_id: @session_id,
          outcome: outcome,
          importance: importance
        )
      end

      # Keyword-search episodes for this agent.
      #
      # @param query [String, nil] search term; nil returns most recent
      # @param limit [Integer]     maximum results (default 10)
      # @param type  [String, Symbol, nil] optional type filter
      # @return [Array<Episode>]
      def recall(query: nil, limit: 10, type: nil)
        @store.retrieve(agent_id: @agent_id, query: query, limit: limit, type: type)
      end

      # Store or update a named fact.
      #
      # @param key        [String, Symbol]  fact name
      # @param value      [Object]          fact value
      # @param confidence [Float]           confidence score 0.0–1.0
      # @return [Fact]
      def remember(key, value, confidence: 1.0)
        @store.store_fact(agent_id: @agent_id, key: key, value: value, confidence: confidence)
      end

      # Returns all stored facts for this agent.
      #
      # @return [Hash{String => Fact}]
      def facts
        @store.facts(agent_id: @agent_id)
      end

      # Returns recent episodes.
      #
      # @param last [Integer]              maximum episodes to return
      # @param type [String, Symbol, nil]  optional type filter
      # @return [Array<Episode>]
      def recent(last: 20, type: nil)
        @store.episodes(agent_id: @agent_id, last: last, type: type)
      end

      # Run a reflection cycle and record the result.
      #
      # @param current_system_prompt [String, nil] current prompt to compare against
      # @return [ReflectionRecord]
      def reflect(current_system_prompt: nil)
        ReflectionCycle.new(store: @store).reflect(
          agent_id: @agent_id,
          current_system_prompt: current_system_prompt
        )
      end

      # Check whether the agent should run a reflection cycle.
      #
      # Returns true when the recent failure rate exceeds the threshold.
      #
      # @return [Boolean]
      def should_reflect?
        ReflectionCycle.new(store: @store).should_reflect?(agent_id: @agent_id)
      end
    end
  end
end
