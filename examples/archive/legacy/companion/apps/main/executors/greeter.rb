# frozen_string_literal: true

module Companion
  # A pure function: given inputs, produce an output. No side effects.
  # Executors are the leaf nodes in a Contract dependency graph.
  class Greeter < Igniter::Executor
    def call(name:)
      { message: "Hello, #{name}!", greeted_at: Time.now.iso8601 }
    end
  end
end
