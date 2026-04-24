#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "igniter/application"

root = File.expand_path("../../tmp/capsule_authoring_operator", __dir__)
clean = Igniter::Application.blueprint(
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
      contracts: ["Contracts::ResolveIncident"],
      services: [:incident_queue],
      surfaces: [:operator_console]
    }
  ]
)
capsule = Igniter::Application.capsule(:operator, root: root, env: :test) do
  layout :capsule
  groups :contracts, :services
  contract "Contracts::ResolveIncident"
  service :incident_queue
  web_surface :operator_console
  export :resolve_incident, kind: :contract, target: "Contracts::ResolveIncident"
  import :incident_runtime, kind: :service, from: :host, capabilities: [:incidents]

  feature :incidents do
    groups :contracts, :services, :web
    contract "Contracts::ResolveIncident"
    service :incident_queue
    export :resolve_incident
    import :incident_runtime
    flow :incident_review
    surface :operator_console
  end

  flow :incident_review do
    purpose "Review incident plan before execution"
    initial_status :waiting_for_user
    current_step :review_plan
    pending_input :clarification, input_type: :textarea, target: :review_plan
    pending_action :approve_plan, action_type: :contract, target: "Contracts::ResolveIncident"
    contract "Contracts::ResolveIncident"
    service :incident_queue
    surface :operator_console
  end
end

blueprint = capsule.to_blueprint
report = blueprint.capsule_report.to_h

puts "application_capsule_dsl_name=#{blueprint.name}"
puts "application_capsule_dsl_equivalent=#{blueprint.to_h == clean.to_h}"
puts "application_capsule_dsl_exports=#{blueprint.exports.map(&:name).join(",")}"
puts "application_capsule_dsl_imports=#{blueprint.imports.map(&:name).join(",")}"
puts "application_capsule_dsl_features=#{blueprint.feature_slices.map(&:name).join(",")}"
puts "application_capsule_dsl_flows=#{blueprint.flow_declarations.map(&:name).join(",")}"
puts "application_capsule_dsl_report=#{report.fetch(:name)}"
