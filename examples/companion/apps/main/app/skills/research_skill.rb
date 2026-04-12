# frozen_string_literal: true

require "igniter/ai"
require_relative "../tools/save_note_tool"
require_relative "../tools/get_notes_tool"

module Companion
  class ResearchSkill < Igniter::AI::Skill
    description "Research a topic in depth and return a clear, concise summary. " \
                "Use this when the user asks a factual question that requires " \
                "looking up information rather than a quick recall."

    param :topic, type: :string, required: true,
                  desc: "The subject or question to research (e.g. 'Ruby fibers', 'how black holes form')"

    requires_capability :network

    provider :ollama
    model ENV.fetch("CHAT_MODEL", "llama3.1:8b")
    tools SaveNoteTool, GetNotesTool
    max_tool_iterations 6

    MOCK_RESULTS = {
      /ruby/i => "Ruby is a dynamic, object-oriented language created by Matz in 1995. " \
                 "Known for its elegant syntax, strong community, and frameworks like Rails.",
      /igniter/i => "Igniter is a Ruby gem for declaring business logic as validated " \
                    "dependency graphs with compile-time validation and lazy runtime resolution.",
      /black hole/i => "Black holes are regions of spacetime where gravity is so strong " \
                       "that nothing — not even light — can escape. They form when massive stars collapse.",
      /ai|llm/i => "Large Language Models are neural networks trained on vast text corpora. " \
                   "They use transformer architecture and attention mechanisms to generate coherent text."
    }.freeze

    def call(topic:)
      if ENV["COMPANION_REAL_LLM"]
        complete(
          "Research this topic thoroughly and provide a concise 2-3 sentence summary " \
          "with the most important facts. Topic: #{topic}"
        )
      else
        mock_research(topic)
      end
    end

    private

    def mock_research(topic)
      result = MOCK_RESULTS.find { |pattern, _| topic.match?(pattern) }&.last
      result ||= "\"#{topic}\" is an interesting subject. In a real deployment I would " \
                 "search multiple sources and synthesize a detailed summary for you."
      "[research] #{result}"
    end
  end
end
