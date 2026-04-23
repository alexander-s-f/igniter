# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

module ExampleIncompletePack
  class << self
    def manifest
      Igniter::Contracts::PackManifest.new(
        name: :example_incomplete_pack,
        node_contracts: [Igniter::Contracts::PackManifest.node(:draft_slug)],
        registry_contracts: [Igniter::Contracts::PackManifest.validator(:draft_slug_sources)]
      )
    end

    def install_into(kernel)
      kernel
    end
  end
end

environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::DebugPack)
audit = Igniter::Extensions::Contracts.audit_pack(ExampleIncompletePack, environment)

puts "contracts_pack_audit_ok=#{audit.ok?}"
puts "contracts_pack_audit_installed=#{audit.installed_in_target_profile}"
puts "contracts_pack_audit_missing_nodes=#{audit.missing_node_definitions.join(',')}"
puts "contracts_pack_audit_missing_validators=#{audit.missing_registry_contracts.fetch(:validators).join(',')}"
puts "contracts_pack_audit_finalize_error=#{audit.finalize_error.include?('IncompletePackError')}"
