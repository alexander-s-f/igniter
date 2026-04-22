# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe Igniter::Extensions::Contracts::LookupPack do
  it "adds an external node kind with compile and runtime semantics" do
    profile = Igniter::Contracts.build_kernel.install(described_class).finalize

    compiled = Igniter::Contracts.compile(profile: profile) do
      input :rates
      lookup :tax_rate, from: :rates, key: :ua
      output :tax_rate
    end

    result = Igniter::Contracts.execute(
      compiled,
      inputs: { rates: { ua: 0.2 } },
      profile: profile
    )

    expect(profile.pack_names).to include(:baseline, :extensions_lookup)
    expect(result.output(:tax_rate)).to eq(0.2)
    expect(result.state.fetch(:tax_rate)).to eq(0.2)
  end

  it "supports a fallback value for missing lookup keys" do
    profile = Igniter::Contracts.build_kernel.install(described_class).finalize

    compiled = Igniter::Contracts.compile(profile: profile) do
      input :rates
      lookup :tax_rate, from: :rates, key: :pl, fallback: 0.23
      output :tax_rate
    end

    result = Igniter::Contracts.execute(
      compiled,
      inputs: { rates: { ua: 0.2 } },
      profile: profile
    )

    expect(result.output(:tax_rate)).to eq(0.23)
  end

  it "raises structured validation findings when the lookup source is missing" do
    profile = Igniter::Contracts.build_kernel.install(described_class).finalize

    expect do
      Igniter::Contracts.compile(profile: profile) do
        lookup :tax_rate, from: :rates, key: :ua
        output :tax_rate
      end
    end.to raise_error(Igniter::Contracts::ValidationError) { |error|
      expect(error.findings.map(&:code)).to eq([:missing_lookup_sources])
      expect(error.findings.first.subjects).to eq([:rates])
    }
  end
end
