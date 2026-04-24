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

root = File.expand_path("../../tmp/capsule_inspection_operator", __dir__)
worker = Igniter::Application.blueprint(
  name: :worker,
  root: File.join(root, "worker"),
  env: :test,
  layout_profile: :capsule,
  services: [:worker_queue]
)
operator = Igniter::Application.blueprint(
  name: :operator,
  root: File.join(root, "operator"),
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
      pending_inputs: [
        { name: :clarification, input_type: :textarea, target: :review_plan }
      ],
      pending_actions: [
        { name: :approve_plan, action_type: :contract, target: "Contracts::ResolveIncident" }
      ],
      contracts: ["Contracts::ResolveIncident"],
      services: [:incident_queue],
      surfaces: [:operator_console]
    }
  ]
)

surface = Igniter::Web.surface_manifest(web, name: :operator_console, path: "/operator")
surface_metadata = Igniter::Web.flow_surface_metadata(
  surface,
  declaration: operator.flow_declarations.first,
  feature: operator.feature_slices.first,
  metadata: { source: :capsule_inspection }
)
worker_report = worker.capsule_report.to_h
operator_report = operator.capsule_report(surface_metadata: [surface_metadata]).to_h

puts "application_capsule_report_name=#{operator_report.fetch(:name)}"
puts "application_capsule_report_non_web=#{worker_report.fetch(:web_surfaces).empty?}"
puts "application_capsule_report_groups=#{operator_report.fetch(:groups).fetch(:active).join(",")}"
puts "application_capsule_report_sparse_paths=#{operator_report.fetch(:planned_paths).fetch(:sparse).map { |entry| entry.fetch(:group) }.join(",")}"
puts "application_capsule_report_exports=#{operator_report.fetch(:exports).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_report_imports=#{operator_report.fetch(:imports).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_report_features=#{operator_report.fetch(:feature_slices).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_report_flows=#{operator_report.fetch(:flow_declarations).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_report_surfaces=#{operator_report.fetch(:surfaces).map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_capsule_report_web_projection=#{operator_report.fetch(:surfaces).first.fetch(:status)}"
puts "application_capsule_report_web_projection_flows=#{operator_report.fetch(:surfaces).first.fetch(:flows).join(",")}"
