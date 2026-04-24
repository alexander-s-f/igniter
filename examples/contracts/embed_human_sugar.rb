#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-embed/lib", __dir__))

require "igniter/embed"

module BillingSugar
  class PriceContract < Igniter::Contract
    define do
      input :amount
      compute :total, depends_on: [:amount] do |amount:|
        amount * 1.2
      end
      output :total
    end
  end

  class LegacyQuote
    def self.call(amount:, **)
      { total: amount * 1.2, status: "accepted" }
    end
  end

  class ContractQuote
    def self.call(amount:, **)
      { total: amount * 1.25, status: "accepted" }
    end
  end

  class QuoteNormalizer
    def self.call(result)
      {
        status: :ok,
        outputs: {
          total: result.fetch(:total),
          status: result.fetch(:status)
        },
        metadata: {}
      }
    end
  end

  class ObservationStore
    @observations = []

    class << self
      attr_reader :observations

      def record(observation)
        observations << observation
      end
    end
  end

  class LogObservationContract < Igniter::Contract
    define do
      input :event
      output :event
    end
  end
end

divergence_events = []
reporting_adapter = ->(_event) {}

host = Igniter::Embed.host(:billing) do
  owner BillingSugar
  path "app/contracts"
  cache true

  contracts do
    add :price_quote, BillingSugar::PriceContract do
      migrate BillingSugar::LegacyQuote, to: BillingSugar::ContractQuote
      shadow async: false, sample: 1.0
      use :normalizer, BillingSugar::QuoteNormalizer
      use :redaction, only: %i[amount customer_id]
      use :acceptance, policy: :shape, outputs: { total: Numeric, status: String }
      use :store, BillingSugar::ObservationStore
      use :logging, contract: BillingSugar::LogObservationContract
      use :reporting, reporting_adapter

      on :divergence do |event|
        divergence_events << event
      end
    end
  end
end

runner = host.contractable(:price_quote)
primary_result = runner.call(amount: 100, customer_id: "cust_1", token: "secret")
observation = BillingSugar::ObservationStore.observations.fetch(0)
expansion = host.sugar_expansion.to_h
contractable = expansion.fetch(:contractables).fetch(0)

puts "embed_sugar_primary_total=#{primary_result.fetch(:total)}"
puts "embed_sugar_runner_names=#{host.contractable_names.join(",")}"
puts "embed_sugar_shadow_match=#{observation.fetch(:match)}"
puts "embed_sugar_shadow_accepted=#{observation.fetch(:accepted)}"
puts "embed_sugar_redacted_inputs=#{observation.fetch(:inputs).keys.join(",")}"
puts "embed_sugar_divergence_events=#{divergence_events.length}"
puts "embed_sugar_capabilities=#{contractable.fetch(:capabilities).map { |capability| "#{capability.fetch(:name)}:#{capability.fetch(:kind)}" }.join(",")}"
puts "embed_sugar_runner_accessor=#{contractable.fetch(:runner).fetch(:accessor)}"
