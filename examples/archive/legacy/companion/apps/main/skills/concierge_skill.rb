# frozen_string_literal: true

module Companion
  # A Skill is a full LLM reasoning loop with access to your Tools.
  # Unlike a single Tool call, a Skill plans, reasons, and uses tools
  # iteratively until the task is complete.
  #
  # To activate:
  #   1. Add your API key: export ANTHROPIC_API_KEY=sk-ant-...
  #   2. Uncomment the code below.
  #   3. Add require "igniter/ai" to apps/main/app.rb.
  #
  # require "igniter/ai"
  #
  # class ConciergeSkill < Igniter::AI::Skill
  #   description "An AI concierge that greets visitors and answers questions"
  #
  #   param :request, type: :string, required: true, desc: "The visitor's request"
  #
  #   provider :anthropic           # or :openai, :ollama
  #   model    "claude-haiku-4-5-20251001"
  #   tools    Companion::GreetTool
  #
  #   system_prompt <<~PROMPT
  #     You are a friendly concierge. Help visitors feel welcome.
  #     Use the greet_tool to greet people by name.
  #   PROMPT
  #
  #   def call(request:)
  #     complete(request)
  #   end
  # end
end
