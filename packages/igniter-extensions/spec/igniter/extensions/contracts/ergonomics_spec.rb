# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "Igniter::Extensions::Contracts ergonomics" do
  it "exposes available packs and builds a profile with them by default" do
    expect(Igniter::Extensions::Contracts.available_packs).to eq([
      Igniter::Extensions::Contracts::ExecutionReportPack,
      Igniter::Extensions::Contracts::LookupPack
    ])

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
end
