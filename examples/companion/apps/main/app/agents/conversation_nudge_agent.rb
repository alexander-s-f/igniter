# frozen_string_literal: true

require "igniter/agents/proactive_agent"

module Companion
  class ConversationNudgeAgent < Igniter::Agents::ProactiveAgent
    intent "Detect conversation silence or stagnation and propose nudges"

    NudgeRecord = Struct.new(:kind, :suggestion, :fired_at, keyword_init: true)

    scan_interval 5.0

    watch :silent_turns, poll: -> { Thread.current[:nudge_silent_turns] || 0 }
    watch :recent_topics, poll: -> { Thread.current[:nudge_recent_topics] || [] }

    trigger :long_silence,
            condition: ->(ctx) { ctx[:silent_turns].to_i >= 3 },
            action: ->(state:, context:) {
              nudge = NudgeRecord.new(
                kind: :silence,
                suggestion: "The user has been quiet. You could ask: 'Is there anything else I can help you with?'",
                fired_at: Time.now
              )
              Thread.current[:nudge_silent_turns] = 0
              state.merge(nudges: (state[:nudges] + [nudge]).last(50))
            }

    trigger :topic_stagnation,
            condition: lambda { |ctx|
              topics = ctx[:recent_topics]
              topics.size >= 3 && topics.uniq.size == 1
            },
            action: ->(state:, context:) {
              topic = context[:recent_topics].last
              nudge = NudgeRecord.new(
                kind: :stagnation,
                suggestion: "Conversation appears stuck on '#{topic}'. Try broadening: 'Would you like to explore a different angle?'",
                fired_at: Time.now
              )
              state.merge(nudges: (state[:nudges] + [nudge]).last(50))
            }

    proactive_initial_state nudges: [], turn_count: 0, last_turn_at: nil

    on :record_turn do |state:, payload:|
      role = payload.fetch(:role)
      text = payload.fetch(:text, "")

      if role == :user
        Thread.current[:nudge_silent_turns] = (Thread.current[:nudge_silent_turns] || 0) + 1
        topic = text.downcase.split.find { |word| word.length > 4 } || text[0, 10]
        recent = ((Thread.current[:nudge_recent_topics] || []) + [topic]).last(3)
        Thread.current[:nudge_recent_topics] = recent
      else
        Thread.current[:nudge_silent_turns] = 0
      end

      state.merge(turn_count: state[:turn_count] + 1, last_turn_at: Time.now)
    end

    on :nudges do |state:, **|
      state[:nudges].dup
    end
  end
end
