# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "Igniter::Extensions::Contracts ergonomics" do
  it "exposes available packs and builds a profile with them by default" do
    expect(Igniter::Extensions::Contracts.default_packs).to eq([
      Igniter::Extensions::Contracts::ExecutionReportPack,
      Igniter::Extensions::Contracts::LookupPack
    ])

    expect(Igniter::Extensions::Contracts.available_packs).to eq([
      Igniter::Extensions::Contracts::ExecutionReportPack,
      Igniter::Extensions::Contracts::LookupPack,
      Igniter::Extensions::Contracts::AggregatePack,
      Igniter::Extensions::Contracts::CommercePack,
      Igniter::Extensions::Contracts::JournalPack
    ])

    expect(Igniter::Extensions::Contracts.presets).to eq({
      default: [
        Igniter::Extensions::Contracts::ExecutionReportPack,
        Igniter::Extensions::Contracts::LookupPack
      ],
      commerce: [
        Igniter::Extensions::Contracts::ExecutionReportPack,
        Igniter::Extensions::Contracts::CommercePack
      ]
    })

    profile = Igniter::Extensions::Contracts.build_profile

    expect(profile.pack_names).to eq(%i[baseline extensions_execution_report extensions_lookup])
  end

  it "builds an environment with the package's default external packs" do
    environment = Igniter::Extensions::Contracts.with

    result = environment.run(inputs: { rates: { ua: 0.2 } }) do
      input :rates
      lookup :tax_rate, from: :rates, key: :ua
      output :tax_rate
    end
    report = environment.diagnose(result)

    expect(result.output(:tax_rate)).to eq(0.2)
    expect(report.section(:execution_report)).to include(
      output_count: 1,
      state_count: 2
    )
  end

  it "does not install opt-in operational packs by default" do
    profile = Igniter::Extensions::Contracts.build_profile

    expect(profile.supports_effect?(:journal)).to be(false)
    expect(profile.supports_executor?(:journaled_inline)).to be(false)
  end

  it "builds an environment from a named preset" do
    environment = Igniter::Extensions::Contracts.with_preset(:commerce)

    result = environment.run(inputs: {
      order: { items: [{ amount: 10 }, { amount: 20 }] },
      tax_rate: 0.2
    }) do
      input :order
      input :tax_rate
      order_items from: :order
      subtotal from: :items
      tax_amount amount: :subtotal, rate: :tax_rate
      grand_total subtotal: :subtotal, tax: :tax
      output :grand_total
    end

    expect(result.output(:grand_total)).to eq(36.0)
  end
end
