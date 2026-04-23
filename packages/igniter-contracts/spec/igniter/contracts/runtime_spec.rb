# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Contracts::Runtime do
  it "executes a baseline input-compute-output flow" do
    compiled = Igniter::Contracts.compile do
      input :amount
      compute :tax, depends_on: [:amount] do |amount:|
        amount * 0.2
      end
      output :tax
    end

    result = Igniter::Contracts.execute(compiled, inputs: { amount: 10 })

    expect(result.output(:tax)).to eq(2.0)
    expect(result.state).to be_a(Igniter::Contracts::NamedValues)
    expect(result.outputs).to be_a(Igniter::Contracts::NamedValues)
    expect(result.compiled_graph).to eq(compiled)
    expect(result.state.fetch(:amount)).to eq(10)
    expect(result.state.fetch(:tax)).to eq(2.0)
  end

  it "executes an explicit profile with the const experimental pack" do
    kernel = Igniter::Contracts.build_kernel.install(Igniter::Contracts::ConstPack)
    profile = kernel.finalize

    compiled = Igniter::Contracts.compile(profile: profile) do
      const :tax_rate, 0.2
      output :tax_rate
    end

    result = Igniter::Contracts.execute(compiled, inputs: {}, profile: profile)

    expect(result.output(:tax_rate)).to eq(0.2)
  end

  it "executes through the explicit inline executor seam" do
    compiled = Igniter::Contracts.compile do
      input :amount
      output :amount
    end

    result = Igniter::Contracts.execute_with(:inline, compiled, inputs: { amount: 15 })

    expect(result.output(:amount)).to eq(15)
  end

  it "executes an explicit profile with the project pack" do
    profile = Igniter::Contracts.build_kernel.install(Igniter::Contracts::ProjectPack).finalize

    compiled = Igniter::Contracts.compile(profile: profile) do
      input :pricing
      project :country, from: :pricing, key: :country
      output :country
    end

    result = Igniter::Contracts.execute(
      compiled,
      inputs: { pricing: { country: "UA" } },
      profile: profile
    )

    expect(result.output(:country)).to eq("UA")
    expect(result.state.fetch(:country)).to eq("UA")
  end

  it "rejects execution against a different profile fingerprint" do
    compiled = Igniter::Contracts.compile do
      input :amount
      output :amount
    end

    other_profile = Igniter::Contracts.build_kernel.install(Igniter::Contracts::ConstPack).finalize

    expect do
      Igniter::Contracts.execute(compiled, inputs: { amount: 10 }, profile: other_profile)
    end.to raise_error(Igniter::Contracts::ProfileMismatchError, /does not match profile/)
  end
end
