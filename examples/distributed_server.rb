# frozen_string_literal: true

# Distributed Contract — job application review workflow
#
# Shows the full distributed lifecycle:
#   1. Application submitted   → execution starts, suspends at both await nodes
#   2. Background screening    → first event delivered, execution still pending
#   3. Manager review          → second event delivered, execution completes
#   4. on_success callback     → fires when the decision node resolves
#
# Uses an in-process MemoryStore — no real server needed to run this example.
#
# Run: ruby examples/distributed_server.rb

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "igniter"

# ── Workflow Contract ─────────────────────────────────────────────────────────

class ApplicationReviewWorkflow < Igniter::Contract
  correlate_by :application_id

  define do
    input :application_id
    input :applicant_name
    input :position

    # Execution suspends at each await until the named event is delivered
    await :screening_result, event: :screening_completed
    await :manager_review,   event: :manager_reviewed

    compute :decision, depends_on: %i[screening_result manager_review] do |screening_result:, manager_review:|
      passed   = screening_result[:passed]
      approved = manager_review[:approved]

      if passed && approved
        { status: :hired,    note: manager_review[:note] }
      elsif !passed
        { status: :rejected, note: "Did not pass background screening" }
      else
        { status: :rejected, note: manager_review[:note] }
      end
    end

    output :decision
  end

  on_success :decision do |value:, **|
    puts "[callback] Decision reached: #{value[:status].upcase}"
  end
end

# ── Run ───────────────────────────────────────────────────────────────────────

store = Igniter::Runtime::Stores::MemoryStore.new

puts "=== Step 1: Application submitted ==="
execution = ApplicationReviewWorkflow.start(
  { application_id: "app-42", applicant_name: "Alice Chen", position: "Senior Engineer" },
  store: store
)
puts "pending=#{execution.pending?}"
waiting = execution.execution.cache.values
                   .select { |s| s.pending? && s.node.kind == :await }
                   .map { |s| s.value.payload[:event] }
puts "waiting_for=#{waiting.inspect}"

puts "\n=== Step 2: Background screening completed ==="
ApplicationReviewWorkflow.deliver_event(
  :screening_completed,
  correlation: { application_id: "app-42" },
  payload: { passed: true, score: 92 },
  store: store
)

# Restore from store to inspect mid-flight state
exec_id = store.find_by_correlation(
  graph: "ApplicationReviewWorkflow",
  correlation: { application_id: "app-42" }
)
mid_state = ApplicationReviewWorkflow.restore_from_store(exec_id, store: store)
puts "still_pending=#{mid_state.execution.cache.values.any?(&:pending?)}"

puts "\n=== Step 3: Manager review completed ==="
final = ApplicationReviewWorkflow.deliver_event(
  :manager_reviewed,
  correlation: { application_id: "app-42" },
  payload: { approved: true, note: "Excellent system design skills" },
  store: store
)

puts "\n=== Final result ==="
puts "success=#{final.success?}"
puts "decision=#{final.result.decision.inspect}"
