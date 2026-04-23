# frozen_string_literal: true

require "tmpdir"

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

module ExampleDraftPack
  class << self
    def manifest
      Igniter::Contracts::PackManifest.new(
        name: :example_draft_pack,
        node_contracts: [Igniter::Contracts::PackManifest.node(:draft_slug)],
        registry_contracts: [Igniter::Contracts::PackManifest.validator(:draft_slug_sources)]
      )
    end

    def install_into(kernel)
      kernel
    end
  end
end

environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::CreatorPack)

scaffold = Igniter::Extensions::Contracts.scaffold_pack(
  name: :slug,
  profile: :feature_node,
  scope: :app_local,
  namespace: "Acme::IgniterPacks"
)

report = Igniter::Extensions::Contracts.creator_report(
  name: :draft_slug,
  profile: :feature_node,
  scope: :standalone_gem,
  namespace: "Acme::IgniterPacks",
  pack: ExampleDraftPack,
  target: environment
)

workflow = Igniter::Extensions::Contracts.creator_workflow(
  name: :draft_slug,
  profile: :feature_node,
  scope: :standalone_gem,
  namespace: "Acme::IgniterPacks",
  pack: ExampleDraftPack,
  target: environment
)

wizard = Igniter::Extensions::Contracts.creator_wizard(
  name: :delivery,
  capabilities: %i[effect executor],
  target: environment
)

completed_wizard = wizard.apply(scope: :standalone_gem)

write_summary = nil
Dir.mktmpdir("igniter_creator_example") do |dir|
  writer = Igniter::Extensions::Contracts.creator_writer(
    name: :slug,
    profile: :feature_node,
    scope: :app_local,
    namespace: "Acme::IgniterPacks",
    root: dir
  )

  plan = writer.plan
  result = writer.write

  write_summary = {
    plan_steps: plan.steps.length,
    files_written: result.files_written,
    directories_created: result.directories_created
  }
end

bundle_scaffold = Igniter::Extensions::Contracts.scaffold_pack(
  name: :developer_console,
  profile: :diagnostic_bundle,
  scope: :monorepo_package,
  namespace: "Acme::IgniterPacks"
)

puts "creator_pack_constant=#{scaffold.pack_constant}"
puts "creator_pack_files=#{scaffold.files.keys.join(',')}"
puts "creator_profiles=#{Igniter::Extensions::Contracts.creator_profiles.join(',')}"
puts "creator_scopes=#{Igniter::Extensions::Contracts.creator_scopes.join(',')}"
puts "creator_report_audit_ok=#{report.audit.ok?}"
puts "creator_report_missing_nodes=#{report.audit.missing_node_definitions.join(',')}"
puts "creator_bundle_dependency_hints=#{bundle_scaffold.profile.dependency_hints.join(',')}"
puts "creator_workflow_stage=#{workflow.current_stage.key}"
puts "creator_workflow_status=#{workflow.current_stage.status}"
puts "creator_workflow_development_packs=#{workflow.recommended_packs.fetch(:development).join(',')}"
puts "creator_wizard_current_decision=#{wizard.current_decision.fetch(:key)}"
puts "creator_wizard_ready_for_writer=#{completed_wizard.ready_for_writer?}"
puts "creator_writer_plan_steps=#{write_summary.fetch(:plan_steps)}"
puts "creator_writer_files_written=#{write_summary.fetch(:files_written)}"
puts "creator_scope_root=#{scaffold.scope.root}"
puts "creator_report_next_steps=#{report.next_steps.length}"
