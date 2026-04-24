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
  screen :incident_review, intent: :human_decision do
    ask :clarification, as: :textarea
    action :approve_plan, run: "Contracts::ResolveIncident", action_type: :contract
  end

  screen_route "/incident-review", :incident_review
end

root = File.expand_path("../../tmp/feature_flow_operator", __dir__)
surface = Igniter::Web.surface_manifest(web, name: :operator_console, path: "/operator")
pending_state = Igniter::Web.flow_pending_state(surface, current_step: :review_plan)
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
      pending_inputs: pending_state.fetch(:pending_inputs),
      pending_actions: pending_state.fetch(:pending_actions),
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
feature = blueprint.feature_slices.first
projection = Igniter::Web.flow_surface_projection(
  surface,
  declaration: declaration,
  feature: feature,
  metadata: { source: :example }
)
surface_metadata = Igniter::Web.surface_metadata(surface, projections: { flow_surface: projection })
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
puts "application_feature_flow_web_projection=#{projection.fetch(:status)}"
puts "application_feature_flow_web_projection_inputs=#{projection.fetch(:pending_inputs).fetch(:matched).join(",")}"
puts "application_feature_flow_web_projection_actions=#{projection.fetch(:pending_actions).fetch(:matched).join(",")}"
puts "application_feature_flow_surface_metadata=#{surface_metadata.fetch(:status)}"
puts "application_feature_flow_surface_metadata_flows=#{surface_metadata.fetch(:flows).join(",")}"
