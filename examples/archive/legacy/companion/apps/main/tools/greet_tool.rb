# frozen_string_literal: true

module Companion
  # A Tool wraps an Executor with LLM-friendly metadata.
  # Any LLM (Anthropic, OpenAI) can call this via function-calling —
  # the schema is generated automatically from the param declarations.
  class GreetTool < Igniter::Tool
    description "Greet a person by name and return a welcome message"

    param :name, type: :string, required: true, desc: "The person's name"

    def call(name:)
      Companion::GreetContract.new(name:).result.greeting
    end
  end
end
