# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

environment = Igniter::Contracts.with(
  Igniter::Extensions::Contracts::AuditPack,
  Igniter::Extensions::Contracts::IncrementalPack
)

session = Igniter::Extensions::Contracts.build_incremental_session(environment) do
  input :order_total
  input :country

  compute :vat_rate, depends_on: [:country] do |country:|
    country == "UA" ? 0.2 : 0.0
  end

  compute :gross_total, depends_on: %i[order_total vat_rate] do |order_total:, vat_rate:|
    (order_total * (1 + vat_rate)).round(2)
  end

  output :gross_total
end

result = session.run(inputs: { order_total: 100, country: "UA" })
snapshot = Igniter::Extensions::Contracts.audit_snapshot(result)
diagnostics = environment.diagnose(result.execution_result)

puts "contracts_auditing_event_types=#{snapshot.event_types.inspect}"
puts "contracts_auditing_state=#{snapshot.state(:gross_total).slice(:status, :value).inspect}"
puts "contracts_auditing_event_count=#{snapshot.event_count}"
puts "contracts_auditing_sections=#{diagnostics.section_names.join(",")}"
