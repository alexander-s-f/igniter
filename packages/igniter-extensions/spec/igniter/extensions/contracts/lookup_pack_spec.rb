# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe Igniter::Extensions::Contracts::LookupPack do
  it "adds external lookup DSL that lowers into compute semantics" do
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
    expect(profile.dsl_keyword(:lookup)).to be_a(Igniter::Contracts::DslKeyword)
    expect(profile.supports_node_kind?(:lookup)).to be(false)
    expect(compiled.operations.map(&:kind)).to eq(%i[input compute output])
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

  it "uses baseline dependency validation when the lookup source is missing" do
    profile = Igniter::Contracts.build_kernel.install(described_class).finalize

    expect do
      Igniter::Contracts.compile(profile: profile) do
        lookup :tax_rate, from: :rates, key: :ua
        output :tax_rate
      end
    end.to raise_error(Igniter::Contracts::ValidationError) { |error|
      expect(error.findings.map(&:code)).to eq([:missing_compute_dependencies])
      expect(error.findings.first.subjects).to eq([:rates])
    }
  end
end
