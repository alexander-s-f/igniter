# frozen_string_literal: true

require "igniter/sdk/agents/proactive_agent"

module Companion
  # Proactive agent that watches the conversation history and takes action
  # when the conversation appears stuck or inactive.
  #
  # Demonstrates ProactiveAgent with:
  # - A watcher that reads shared state (conversation turns)
  # - Two triggers: silence detection and topic stagnation
  # - A custom :record_turn message handler layered on top
  #
  # In the companion voice assistant this agent can be started alongside
  # the VoiceAssistantContract to provide ambient conversational guidance.
  #
  # Usage:
  #   ref = ConversationNudgeAgent.start
  #   ref.send(:record_turn, role: :user, text: "What's the weather?")
  #   ref.send(:record_turn, role: :assistant, text: "It is sunny, 22°C.")
  #   # … after 3 turns on the same topic, :topic_stagnation fires
  class ConversationNudgeAgent < Igniter::Agents::ProactiveAgent
    intent "Detect conversation silence or stagnation and propose nudges"

    NudgeRecord = Struct.new(:kind, :suggestion, :fired_at, keyword_init: true)

    # ── Proactive configuration ──────────────────────────────────────────────

    scan_interval 5.0

    # Watcher: read from shared agent state (updated via :record_turn).
    # Returns the number of turns recorded since the last assistant response.
    watch :silent_turns, poll: -> {
      # The runner calls this lambda; it has no access to agent state directly.
      # ConversationNudgeAgent stores a thread-local counter updated in the
      # :record_turn handler for this lightweight demo.
      Thread.current[:nudge_silent_turns] || 0
    }

    # Watcher: most recent user topics (last 3 distinct intents).
    watch :recent_topics, poll: -> {
      Thread.current[:nudge_recent_topics] || []
    }

    # Trigger 1 — user has been silent for ≥ 3 scans
    trigger :long_silence,
      condition: ->(ctx) { ctx[:silent_turns].to_i >= 3 },
      action:    ->(state:, context:) {
        nudge = NudgeRecord.new(
          kind:       :silence,
          suggestion: "The user has been quiet. You could ask: 'Is there anything else I can help you with?'",
          fired_at:   Time.now
        )
        Thread.current[:nudge_silent_turns] = 0  # reset after nudge
        state.merge(nudges: (state[:nudges] + [nudge]).last(50))
      }

    # Trigger 2 — last 3 topics are all the same (conversation stuck in a loop)
    trigger :topic_stagnation,
      condition: ->(ctx) {
        topics = ctx[:recent_topics]
        topics.size >= 3 && topics.uniq.size == 1
      },
      action:    ->(state:, context:) {
        topic = context[:recent_topics].last
        nudge = NudgeRecord.new(
          kind:       :stagnation,
          suggestion: "Conversation appears stuck on '#{topic}'. Try broadening: 'Would you like to explore a different angle?'",
          fired_at:   Time.now
        )
        state.merge(nudges: (state[:nudges] + [nudge]).last(50))
      }

    proactive_initial_state \
      nudges:       [],
      turn_count:   0,
      last_turn_at: nil

    # ── Reactive handlers ────────────────────────────────────────────────────

    # Record a new conversation turn and update the thread-local watchers.
    #
    # Payload keys:
    #   role [Symbol]  — :user | :assistant
    #   text [String]  — turn text
    on :record_turn do |state:, payload:|
      role = payload.fetch(:role)
      text = payload.fetch(:text, "")

      if role == :user
        Thread.current[:nudge_silent_turns] = (Thread.current[:nudge_silent_turns] || 0) + 1
        # Simple topic extraction: first significant word (lowercased)
        topic = text.downcase.split.find { |w| w.length > 4 } || text[0, 10]
        recent = ((Thread.current[:nudge_recent_topics] || []) + [topic]).last(3)
        Thread.current[:nudge_recent_topics] = recent
      else
        Thread.current[:nudge_silent_turns] = 0
      end

      state.merge(turn_count: state[:turn_count] + 1, last_turn_at: Time.now)
    end

    # Sync query — recent nudge suggestions.
    #
    # @return [Array<NudgeRecord>]
    on :nudges do |state:, **|
      state[:nudges].dup
    end
  end
end
