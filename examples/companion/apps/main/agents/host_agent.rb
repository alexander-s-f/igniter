# frozen_string_literal: true

module Companion
  # An Agent is a stateful actor — it holds state between messages and
  # processes them sequentially in its own thread.
  #
  # Handlers that return a Hash  → async state transition (no reply).
  # Handlers that return non-Hash → sync query, value sent back to caller.
  class HostAgent < Igniter::Agent
    Stats = Struct.new(:total, :recent, keyword_init: true)

    initial_state visitors: [], count: 0

    on :greet do |state:, payload:|
      name     = payload.fetch(:name, "stranger")
      greeting = Companion::GreetContract.new(name:).result.greeting
      puts "  [HostAgent] #{greeting[:message]}"

      state.merge(
        visitors: (state[:visitors] + [{ name: name, at: Time.now.iso8601 }]).last(10),
        count:    state[:count] + 1
      )
    end

    on :stats do |state:, **|
      Stats.new(total: state[:count], recent: state[:visitors].last(3))
    end
  end
end
