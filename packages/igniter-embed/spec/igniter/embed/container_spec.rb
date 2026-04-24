# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Embed::Container do
  it "runs two named contracts in one container" do
    contracts = Igniter::Embed.configure(:billing)

    contracts.register(:tax_quote) do
      input :amount
      compute :tax, depends_on: [:amount] do |amount:|
        amount * 0.2
      end
      output :tax
    end

    contracts.register(:discount_quote) do
      input :amount
      compute :discount, depends_on: [:amount] do |amount:|
        amount * 0.1
      end
      output :discount
    end

    tax_result = contracts.call(:tax_quote, amount: 100)
    discount_result = contracts.call(:discount_quote, amount: 100)

    expect(tax_result).to be_success
    expect(tax_result.output(:tax)).to eq(20.0)
    expect(discount_result).to be_success
    expect(discount_result.output(:discount)).to eq(10.0)
  end

  it "compiles lazily and caches registered contracts when cache is enabled" do
    compile_count = 0
    contracts = Igniter::Embed.configure(:billing) do |config|
      config.cache = true
    end

    contracts.register(:quote) do
      compile_count += 1
      input :amount
      output :amount
    end

    expect(compile_count).to eq(0)

    expect(contracts.call(:quote, amount: 1).output(:amount)).to eq(1)
    expect(contracts.call(:quote, amount: 2).output(:amount)).to eq(2)
    expect(compile_count).to eq(1)
  end

  it "can disable the compiled graph cache" do
    compile_count = 0
    contracts = Igniter::Embed.configure(:billing) do |config|
      config.cache = false
    end

    contracts.register(:quote) do
      compile_count += 1
      input :amount
      output :amount
    end

    contracts.call(:quote, amount: 1)
    contracts.call(:quote, amount: 2)

    expect(compile_count).to eq(2)
  end

  it "returns failure envelopes for captured contract exceptions" do
    contracts = Igniter::Embed.configure(:billing) do |config|
      config.capture_exceptions = true
    end

    contracts.register(:broken) do
      input :amount
      compute :quote, depends_on: [:amount] do |amount:|
        raise "boom" if amount
      end
      output :quote
    end

    result = contracts.call(:broken, amount: 10)

    expect(result).to be_failure
    expect(result.errors.first.message).to eq("boom")
    expect(result.to_h[:metadata]).to eq(captured_exception: true)
  end
end
