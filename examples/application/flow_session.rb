#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "igniter/application"

environment = Igniter::Application.with

snapshot = environment.start_flow(
  :plan_review,
  session_id: "plan-review/1",
  input: { plan_id: "plan-1" },
  current_step: :review_plan,
  pending_inputs: [
    { name: :clarification, input_type: :textarea, target: :review_plan }
  ],
  pending_actions: [
    { name: :approve_plan, action_type: :contract, target: "Contracts::ApprovePlan" }
  ],
  artifacts: [
    { name: :draft_plan, artifact_type: :markdown, uri: "memory://draft-plan", summary: "Draft plan" }
  ],
  metadata: { surface: :operator_console }
)

updated = environment.resume_flow(
  snapshot.session_id,
  event: {
    id: "event-1",
    type: :user_reply,
    source: :user,
    target: :clarification,
    payload: { text: "Check source citations first." }
  }
)
entry = environment.fetch_session(snapshot.session_id)
read_model = environment.flow_session(snapshot.session_id)
flow_session_ids = environment.flow_sessions.map(&:session_id)

puts "application_flow_session_kind=#{entry.kind}"
puts "application_flow_session_status=#{entry.status}"
puts "application_flow_session_read_model=#{read_model.flow_name}"
puts "application_flow_session_ids=#{flow_session_ids.join(",")}"
puts "application_flow_session_pending_inputs=#{snapshot.pending_inputs.map(&:name).join(",")}"
puts "application_flow_session_pending_actions=#{snapshot.pending_actions.map(&:name).join(",")}"
puts "application_flow_session_artifacts=#{snapshot.artifacts.map(&:name).join(",")}"
puts "application_flow_session_events_before=#{snapshot.events.length}"
puts "application_flow_session_events_after=#{updated.events.length}"
puts "application_flow_session_event_type=#{updated.events.first.type}"
puts "application_flow_session_payload_keys=#{entry.payload.keys.join(",")}"
