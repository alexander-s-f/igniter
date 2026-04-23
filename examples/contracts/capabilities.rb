# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Contracts.with(Igniter::Extensions::Contracts::CapabilitiesPack)

database_lookup = Igniter::Extensions::Contracts.declare_capabilities(:database) do |sku:|
  { sku: sku.upcase }
end

compiled = environment.compile do
  input :sku
  compute :fetched, depends_on: [:sku], capabilities: [:network], callable: database_lookup
  output :fetched
end

report = Igniter::Extensions::Contracts.capability_report(
  compiled,
  profile: environment.profile,
  policy: Igniter::Extensions::Contracts.capability_policy(denied: [:network])
)

strict = Igniter::Extensions::Contracts.capability_report(
  compiled,
  policy: Igniter::Extensions::Contracts.capability_policy(on_undeclared: :error)
)

puts "contracts_capabilities_required=#{Igniter::Extensions::Contracts.required_capabilities(compiled).inspect}"
puts "contracts_capabilities_invalid=#{report.invalid?}"
puts "contracts_capabilities_violation_kinds=#{report.violations.map(&:kind).inspect}"
puts "contracts_capabilities_undeclared=#{strict.undeclared_nodes.inspect}"
