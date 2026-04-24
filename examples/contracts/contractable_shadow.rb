#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-embed/lib", __dir__))

require "igniter/embed"

class ContractableMemoryStore
  attr_reader :observations

  def initialize
    @observations = []
  end

  def record(observation)
    observations << observation
  end
end

QuoteNormalizer = lambda do |result|
  {
    status: :ok,
    outputs: {
      total: result.fetch(:total),
      status: result.fetch(:status)
    },
    metadata: {}
  }
end

store = ContractableMemoryStore.new

quote_shadow = Igniter::Embed.contractable(:quote) do |config|
  config.role :migration_candidate
  config.stage :shadowed
  config.primary ->(amount:) { { total: amount * 1.2, status: "accepted" } }
  config.candidate ->(amount:) { { total: amount * 1.25, status: "accepted" } }
  config.async false
  config.store store
  config.redact_inputs ->(**inputs) { inputs }
  config.normalize_primary QuoteNormalizer
  config.normalize_candidate QuoteNormalizer
  config.accept :shape, outputs: { total: Numeric, status: String }
end

observed_store = ContractableMemoryStore.new
observed_quote = Igniter::Embed.contractable(:observed_quote) do |config|
  config.role :observed_service
  config.stage :profiled
  config.primary ->(amount:) { { total: amount * 1.2, status: "accepted" } }
  config.async false
  config.store observed_store
  config.redact_inputs ->(**inputs) { inputs }
  config.normalize_primary QuoteNormalizer
end

primary_result = quote_shadow.call(amount: 100)
observed_quote.call(amount: 50)
shadow_observation = store.observations.fetch(0)
observed_observation = observed_store.observations.fetch(0)

puts "contractable_primary_total=#{primary_result.fetch(:total)}"
puts "contractable_shadow_match=#{shadow_observation.fetch(:match)}"
puts "contractable_shadow_accepted=#{shadow_observation.fetch(:accepted)}"
puts "contractable_shadow_policy=#{shadow_observation.fetch(:acceptance).fetch(:policy)}"
puts "contractable_observed_mode=#{observed_observation.fetch(:mode)}"
