# frozen_string_literal: true

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
  kind: :feature,
  namespace: "Acme::IgniterPacks"
)

report = Igniter::Extensions::Contracts.creator_report(
  name: :draft_slug,
  kind: :feature,
  namespace: "Acme::IgniterPacks",
  pack: ExampleDraftPack,
  target: environment
)

puts "creator_pack_constant=#{scaffold.pack_constant}"
puts "creator_pack_files=#{scaffold.files.keys.join(',')}"
puts "creator_report_audit_ok=#{report.audit.ok?}"
puts "creator_report_missing_nodes=#{report.audit.missing_node_definitions.join(',')}"
puts "creator_report_next_steps=#{report.next_steps.length}"
