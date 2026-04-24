#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))

require "igniter/application"
require "igniter/web"

web = Igniter::Web.application do
  screen :plan_review, intent: :human_decision do
    title "Plan review"
    show :plan_summary
    ask :clarification, as: :textarea, required: true, schema: { min_length: 10 }
    stream :agent_activity, from: "Projections::PlanReviewEvents"
    chat with: "Agents::ProjectLead", purpose: :review_support
    action :approve_plan,
           run: "Contracts::ApprovePlan",
           action_type: :contract,
           purpose: :approval,
           payload_schema: { plan_id: :string }
    compose with: :decision_workspace
  end

  screen_route "/plan-review", :plan_review
end

surface = Igniter::Web.surface_manifest(web, name: :operator_console, path: "/operator")
surface_metadata = surface.to_h
pending_state = Igniter::Web.flow_pending_state(
  surface,
  current_step: :plan_review,
  metadata: { surface: :operator_console }
)

blueprint = Igniter::Application.blueprint(
  name: :operator,
  root: "/tmp/igniter_agent_native_plan_review",
  env: :test,
  layout_profile: :capsule,
  web_surfaces: [:operator_console],
  exports: [surface.to_capsule_export],
  imports: [
    { name: :llm_reviewer, kind: :service, from: :host, capabilities: [:agent] }
  ]
)
environment = Igniter::Application::Environment.new(
  profile: blueprint.apply_to(Igniter::Application.build_kernel).finalize
)

snapshot = environment.start_flow(
  :plan_review,
  session_id: "plan-review/1",
  input: { plan_id: "plan-123" },
  current_step: :plan_review,
  pending_inputs: pending_state.fetch(:pending_inputs),
  pending_actions: pending_state.fetch(:pending_actions),
  artifacts: [
    {
      name: :draft_plan,
      artifact_type: :markdown,
      uri: "memory://draft-plan",
      summary: "Initial project plan"
    }
  ],
  metadata: { surface: :operator_console }
)
session_entry = environment.fetch_session(snapshot.session_id)
updated = environment.resume_flow(
  snapshot.session_id,
  event: {
    id: "event-1",
    type: :user_reply,
    source: :user,
    target: :clarification,
    payload: { text: "Check source citations first." },
    metadata: { surface: :operator_console }
  }
)
exports = surface_metadata.fetch(:exports).map { |entry| "#{entry.fetch(:kind)}:#{entry[:path] || entry[:name]}" }
imports = surface_metadata.fetch(:imports).map { |entry| "#{entry.fetch(:kind)}:#{entry.fetch(:name)}" }

puts "agent_native_plan_review_session_kind=#{session_entry.kind}"
puts "agent_native_plan_review_status=#{snapshot.status}"
puts "agent_native_plan_review_pending_inputs=#{snapshot.pending_inputs.map(&:name).join(",")}"
puts "agent_native_plan_review_pending_actions=#{snapshot.pending_actions.map(&:name).join(",")}"
puts "agent_native_plan_review_artifacts=#{snapshot.artifacts.map(&:name).join(",")}"
puts "agent_native_plan_review_events_before=#{snapshot.events.length}"
puts "agent_native_plan_review_events_after=#{updated.events.length}"
puts "agent_native_plan_review_surface_imports=#{imports.join(",")}"
puts "agent_native_plan_review_surface_exports=#{exports.join(",")}"
puts "agent_native_plan_review_manifest_export=#{blueprint.to_manifest.exports.first.fetch(:kind)}"
