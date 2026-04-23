# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))

require "igniter/extensions/contracts"

Igniter::Extensions::Contracts.reset_content_cache!

calls = []

tax = Igniter::Extensions::Contracts.content_addressed(fingerprint: "tax_v1") do |country:, amount:|
  calls << :called
  rate = { ua: 0.2, us: 0.1 }.fetch(country)
  amount * rate
end

environment = Igniter::Contracts.with(Igniter::Extensions::Contracts::ContentAddressingPack)
compiled = environment.compile do
  input :country
  input :amount
  compute :tax, depends_on: %i[country amount], callable: tax
  output :tax
end

environment.execute(compiled, inputs: { country: :ua, amount: 100 })
second = environment.execute(compiled, inputs: { amount: 100, country: :ua })
key = Igniter::Extensions::Contracts.content_key(callable: tax, inputs: { amount: 100, country: :ua })

puts "contracts_content_addressing_tax=#{second.output(:tax)}"
puts "contracts_content_addressing_calls=#{calls.length}"
puts "contracts_content_addressing_key=#{key}"
puts "contracts_content_addressing_stats=#{Igniter::Extensions::Contracts::ContentAddressingPack.stats.inspect}"
