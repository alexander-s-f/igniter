#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "igniter/application"

root = File.expand_path("../../tmp/feature_flow_operator", __dir__)
blueprint = Igniter::Application.blueprint(
  name: :operator,
  root: root,
  env: :test,
  layout_profile: :capsule,
  groups: %i[contracts services],
  contracts: ["Contracts::ResolveIncident"],
  services: [:incident_queue],
  web_surfaces: [:operator_console],
  exports: [
    { name: :resolve_incident, kind: :contract, target: "Contracts::ResolveIncident" }
  ],
  imports: [
    { name: :incident_runtime, kind: :service, from: :host, capabilities: [:incidents] }
  ],
  features: [
    {
      name: :incidents,
      groups: %i[contracts services web],
      paths: {
        contracts: "features/incidents/contracts",
        web: "features/incidents/web"
      },
      contracts: ["Contracts::ResolveIncident"],
      services: [:incident_queue],
      exports: [:resolve_incident],
      imports: [:incident_runtime],
      flows: [:incident_review],
      surfaces: [:operator_console]
    }
  ],
  flows: [
    {
      name: :incident_review,
      purpose: "Review incident plan before execution",
      initial_status: :waiting_for_user,
      current_step: :review_plan,
      pending_inputs: [
        { name: :clarification, input_type: :textarea, target: :review_plan }
      ],
      pending_actions: [
        { name: :approve_plan, action_type: :contract, target: "Contracts::ResolveIncident" }
      ],
      artifacts: [
        { name: :draft_plan, artifact_type: :markdown, uri: "memory://draft-plan" }
      ],
      contracts: ["Contracts::ResolveIncident"],
      services: [:incident_queue],
      surfaces: [:operator_console],
      exports: [:resolve_incident],
      imports: [:incident_runtime],
      metadata: { feature: :incidents }
    }
  ]
)

declaration = blueprint.flow_declarations.first
environment = Igniter::Application::Environment.new(
  profile: blueprint.apply_to(Igniter::Application.build_kernel).finalize
)
snapshot = environment.start_flow(
  declaration.name,
  session_id: "incident-review/1",
  status: declaration.initial_status,
  current_step: declaration.current_step,
  pending_inputs: declaration.pending_inputs.map(&:to_h),
  pending_actions: declaration.pending_actions.map(&:to_h),
  artifacts: declaration.artifacts.map(&:to_h),
  metadata: { declaration: declaration.name, feature: :incidents }
)

report = blueprint.feature_slice_report
manifest = blueprint.to_manifest

puts "application_feature_flow_slices=#{report.to_h.fetch(:slices).map { |slice| slice.fetch(:name) }.join(",")}"
puts "application_feature_flow_exports=#{manifest.exports.map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_feature_flow_imports=#{manifest.imports.map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_feature_flow_declarations=#{manifest.flow_declarations.map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_feature_flow_pending_inputs=#{snapshot.pending_inputs.map(&:name).join(",")}"
puts "application_feature_flow_pending_actions=#{snapshot.pending_actions.map(&:name).join(",")}"
puts "application_feature_flow_status=#{snapshot.status}"
