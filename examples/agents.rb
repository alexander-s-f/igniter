# frozen_string_literal: true

# Agents — stateful actors with supervision and continuous contract loops
#
# Demonstrates:
#   - Igniter::Agent       — stateful message-driven actor
#   - Igniter::Supervisor  — one_for_one supervision with restart budget
#   - Igniter::Registry    — looking up agents by name
#   - Igniter::StreamLoop  — continuous contract tick-loop
#
# Run: ruby examples/agents.rb

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"
require "igniter/integrations/agents"

# ── Contract used by the stream loop ─────────────────────────────────────────

class ThresholdContract < Igniter::Contract
  define do
    input :value,     type: :numeric
    input :threshold, type: :numeric

    compute :status, depends_on: %i[value threshold] do |value:, threshold:|
      value > threshold ? :alert : :normal
    end

    output :status
  end
end

# ── Counter Agent ─────────────────────────────────────────────────────────────

class CounterAgent < Igniter::Agent
  initial_state counter: 0, history: []

  on :increment do |state:, payload:, **|
    by        = payload.fetch(:by, 1)
    new_count = state[:counter] + by
    state.merge(
      counter: new_count,
      history: (state[:history] + [new_count]).last(10)
    )
  end

  on :reset do |state:, **|
    state.merge(counter: 0, history: [])
  end

  # Returns the current count to sync callers
  on :count do |state:, **|
    state[:counter]
  end

  # Returns the last N history entries
  on :history do |state:, payload:, **|
    state[:history].last(payload.fetch(:n, 5))
  end
end

# ── Logger Agent ──────────────────────────────────────────────────────────────

class LoggerAgent < Igniter::Agent
  initial_state entries: []

  on :log do |state:, payload:, **|
    ts    = Time.now.strftime("%H:%M:%S")
    entry = "[#{ts}] #{payload[:message]}"
    state.merge(entries: (state[:entries] + [entry]).last(100))
  end

  on :dump do |state:, **|
    state[:entries]
  end
end

# ── Supervisor ────────────────────────────────────────────────────────────────

class AppSupervisor < Igniter::Supervisor
  strategy     :one_for_one
  max_restarts 3, within: 10

  children do |c|
    c.worker :counter, CounterAgent
    c.worker :logger,  LoggerAgent
  end
end

# ── Run: Supervised agents ────────────────────────────────────────────────────

puts "=== Supervised agents ==="

sup     = AppSupervisor.start
counter = sup.child(:counter)
logger  = sup.child(:logger)

counter.send(:increment, by: 5)
counter.send(:increment, by: 3)

total = counter.call(:count)
puts "counter=#{total}"

logger.send(:log, message: "Counter reached #{total}")

counter.send(:reset)
counter.send(:increment, by: 10)

new_total = counter.call(:count)
puts "after_reset=#{new_total}"

hist = counter.call(:history, { n: 5 })
puts "history=#{hist.inspect}"

# ── Run: Registry ─────────────────────────────────────────────────────────────

puts "\n=== Registry lookup ==="

named_ref = CounterAgent.start(name: :named_counter)
Igniter::Registry.find(:named_counter).send(:increment, by: 42)
puts "named_counter=#{named_ref.call(:count)}"
named_ref.stop
Igniter::Registry.unregister(:named_counter)

# ── Run: StreamLoop ───────────────────────────────────────────────────────────

puts "\n=== Stream loop ==="

statuses = []

stream = Igniter::StreamLoop.new(
  contract: ThresholdContract,
  tick_interval: 0.05,
  inputs: { value: 20.0, threshold: 25.0 },
  on_result: ->(result) { statuses << result.status }
)

stream.start
sleep(0.15)                            # ~3 ticks at :normal
stream.update_inputs(value: 30.0)
sleep(0.15)                            # ~3 ticks at :alert
stream.stop

puts "statuses_sample=#{statuses.uniq.sort.inspect}"

# ── Teardown ──────────────────────────────────────────────────────────────────

log_entries = logger.call(:dump)
puts "\nlog_entries=#{log_entries.size}"
sup.stop
puts "done=true"
