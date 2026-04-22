# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Contracts::Builder do
  it "compiles baseline keywords through the profile registry" do
    compiled = Igniter::Contracts.compile do
      input :amount, type: :numeric
      compute :tax, depends_on: [:amount] do |amount:|
        amount * 0.2
      end
      output :tax
    end

    expect(compiled.operations.map { |op| op[:kind] }).to eq(%i[input compute output])
    expect(compiled.operations.map { |op| op[:name] }).to eq(%i[amount tax tax])
    expect(compiled.profile_fingerprint).to eq(Igniter::Contracts.default_profile.fingerprint)
  end

  it "raises a contracts-owned error for unknown keywords" do
    expect do
      Igniter::Contracts.compile do
        remote :tax_service
      end
    end.to raise_error(Igniter::Contracts::UnknownDslKeywordError, /unknown DSL keyword remote/)
  end

  it "supports installing a tiny experimental pack into an explicit kernel" do
    kernel = Igniter::Contracts.build_kernel.install(Igniter::Contracts::ConstPack)
    profile = kernel.finalize

    compiled = Igniter::Contracts.compile(profile: profile) do
      const :tax_rate, 0.2
      output :tax_rate
    end

    expect(profile.supports_node_kind?(:const)).to be(true)
    expect(compiled.operations.map { |op| op[:kind] }).to eq(%i[const output])
    expect(compiled.operations.first[:attributes]).to eq({ value: 0.2 })
  end
end
