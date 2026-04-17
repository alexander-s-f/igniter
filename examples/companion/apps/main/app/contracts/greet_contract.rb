# frozen_string_literal: true

module Companion
  # A Contract declares business logic as a validated dependency graph.
  # Igniter resolves execution order and validates edges at compile time.
  class GreetContract < Igniter::Contract
    define do
      input  :name
      compute :greeting, depends_on: :name, call: Companion::Greeter
      output :greeting
    end
  end
end
