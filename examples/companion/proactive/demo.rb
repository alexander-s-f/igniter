# frozen_string_literal: true

# Standalone demo for the Proactive Agents in the companion context.
#
# Demonstrates all three proactive agent concepts without any live hardware:
#   1. Generic ProactiveAgent — custom watchers + triggers
#   2. AlertAgent            — numeric threshold monitoring
#   3. HealthCheckAgent      — dependency liveness polling
#   4. ConversationNudgeAgent — reactive + proactive conversation management
#
# Run:
#   ruby examples/companion/proactive/demo.rb
#
$LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)

require "igniter"
require "igniter/agents"
require_relative "conversation_nudge_agent"
require_relative "system_watch_agent"

puts "=" * 60
puts " Proactive Agents — companion demo"
puts "=" * 60

# ── Helper ──────────────────────────────────────────────────────────────────

def separator(title)
  puts
  puts "── #{title} " + "─" * [0, 50 - title.length].max
end

def call_handler(klass, type, state, payload = {})
  handler = klass.handlers[type]
  raise "No handler :#{type} on #{klass}" unless handler

  handler.call(state: state, payload: payload)
end

# ── 1. Raw ProactiveAgent ────────────────────────────────────────────────────
separator "1. Custom ProactiveAgent"

class TemperatureMonitor < Igniter::Agents::ProactiveAgent
  intent "Alert when server room temperature exceeds safe range"

  # Simulated sensor — real code would call a hardware API
  SENSOR = [22.0, 24.5, 26.0, 28.3, 32.1, 35.7].cycle

  scan_interval 2.0

  watch :temp_celsius, poll: -> { SENSOR.next }

  trigger :overheating,
    condition: ->(ctx) { ctx[:temp_celsius].to_f > 30 },
    action:    ->(state:, context:) {
      puts "  ⚠ TRIGGER :overheating  temp=#{context[:temp_celsius]}°C"
      state.merge(last_alert: context[:temp_celsius])
    }

  proactive_initial_state last_alert: nil
end

# Drive 6 scans manually (no timer, deterministic)
state = TemperatureMonitor.default_state
6.times do |i|
  state = call_handler(TemperatureMonitor, :_scan, state)
  puts "  Scan #{i + 1}: temp=#{state[:context][:temp_celsius]}°C  " \
       "triggers_fired=#{state[:trigger_history].size}"
end

status = call_handler(TemperatureMonitor, :status, state)
puts "  Intent:     #{status.intent}"
puts "  Scans:      #{status.scan_count}"
puts "  Watchers:   #{status.watchers}"
puts "  Triggers:   #{status.triggers}"

# ── 2. AlertAgent ────────────────────────────────────────────────────────────
separator "2. AlertAgent — numeric thresholds"

class ApiMonitor < Igniter::Agents::AlertAgent
  intent "Watch API error rate and latency"

  scan_interval 5.0

  monitor :error_rate, source: -> { 0.08 }   # simulated: always above 5%
  monitor :p99_ms,     source: -> { 350 }    # simulated: within 500ms threshold

  threshold :error_rate, above: 0.05
  threshold :p99_ms,     above: 500

  proactive_initial_state alerts: [], silenced: false
end

state = ApiMonitor.default_state
state = call_handler(ApiMonitor, :_scan, state)
alerts = call_handler(ApiMonitor, :alerts, state)
puts "  Alerts fired: #{alerts.size}"
alerts.each do |a|
  puts "  → metric=#{a.metric}  value=#{a.value}  kind=#{a.kind}  threshold=#{a.threshold}"
end

# Silence and re-scan
state  = call_handler(ApiMonitor, :silence, state)
state  = call_handler(ApiMonitor, :_scan, state)
alerts = call_handler(ApiMonitor, :alerts, state)
puts "  After silence — alerts: #{alerts.size} (expected: same count, no new)"

# ── 3. HealthCheckAgent ──────────────────────────────────────────────────────
separator "3. HealthCheckAgent — dependency liveness"

class InfraHealth < Igniter::Agents::HealthCheckAgent
  intent "Monitor fake database and cache"

  scan_interval 15.0

  # Simulate: db is healthy, cache is down
  check :database, poll: -> { true  }
  check :cache,    poll: -> { false }

  proactive_initial_state health: {}, transitions: []
end

state      = InfraHealth.default_state
state      = call_handler(InfraHealth, :_scan, state)
health     = call_handler(InfraHealth, :health, state)
all_ok     = call_handler(InfraHealth, :all_healthy, state)
transitions = call_handler(InfraHealth, :transitions, state)

puts "  Health:        #{health}"
puts "  All healthy?   #{all_ok}"
puts "  Transitions:   #{transitions.map { |t| "#{t.service}:#{t.from}→#{t.to}" }}"

# Second scan — cache still down, no duplicate transition
state = call_handler(InfraHealth, :_scan, state)
transitions2 = call_handler(InfraHealth, :transitions, state)
puts "  After 2nd scan transitions: #{transitions2.size} (no duplicate expected)"

# ── 4. ConversationNudgeAgent ────────────────────────────────────────────────
separator "4. ConversationNudgeAgent — reactive + proactive"

state = Companion::ConversationNudgeAgent.default_state

# Record 3 user turns without assistant responses → silence trigger fires
3.times do |i|
  state = call_handler(Companion::ConversationNudgeAgent, :record_turn, state,
                       role: :user, text: "What about the weather #{i}?")
end

state  = call_handler(Companion::ConversationNudgeAgent, :_scan, state)
nudges = call_handler(Companion::ConversationNudgeAgent, :nudges, state)
puts "  After 3 unanswered user turns:"
nudges.each { |n| puts "  → [#{n.kind}] #{n.suggestion}" }

# Simulate 3 turns all about "weather" → stagnation trigger
Thread.current[:nudge_silent_turns]  = 0
Thread.current[:nudge_recent_topics] = %w[weather weather weather]
state  = call_handler(Companion::ConversationNudgeAgent, :_scan, state)
nudges = call_handler(Companion::ConversationNudgeAgent, :nudges, state)
puts "\n  After topic stagnation (3× 'weather'):"
nudges.last(2).each { |n| puts "  → [#{n.kind}] #{n.suggestion}" }

# ── 5. Status / pause / resume ──────────────────────────────────────────────
separator "5. pause / resume"

state  = ApiMonitor.default_state
state  = call_handler(ApiMonitor, :pause, state)
status = call_handler(ApiMonitor, :status, state)
puts "  After :pause  — active=#{status.active}"

state  = call_handler(ApiMonitor, :resume, state)
status = call_handler(ApiMonitor, :status, state)
puts "  After :resume — active=#{status.active}"

puts
puts "Done."
