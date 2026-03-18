# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Igniter executors" do
  class MultiplyExecutor < Igniter::Executor
    input :order_total
    input :multiplier

    def call(order_total:, multiplier:)
      order_total * multiplier
    end
  end

  class ContractAwareExecutor < Igniter::Executor
    input :country

    def call(country:)
      "#{contract.class.name}:#{country}"
    end
  end

  class MissingDependencyExecutor < Igniter::Executor
    input :country
    input :vat_rate

    def call(country:, vat_rate:)
      [country, vat_rate]
    end
  end

  it "executes compute nodes through executor classes" do
    contract_class = Class.new(Igniter::Contract) do
      define do
        input :order_total, type: :numeric
        input :multiplier, type: :numeric

        compute :gross_total, depends_on: %i[order_total multiplier], call: MultiplyExecutor
        output :gross_total
      end
    end

    contract = contract_class.new(order_total: 100, multiplier: 1.2)

    expect(contract.result.gross_total).to eq(120.0)
  end

  it "injects execution context into executor instances" do
    contract_class = Class.new(Igniter::Contract) do
      define do
        input :country, type: :string

        compute :tagged_country, depends_on: [:country], call: ContractAwareExecutor
        output :tagged_country
      end
    end

    contract = contract_class.new(country: "UA")

    expect(contract.result.tagged_country).to eq(":UA")
  end

  it "supports plain callable objects for compute nodes" do
    calculator = Object.new
    def calculator.call(order_total:, multiplier:)
      order_total * multiplier
    end

    contract_class = Class.new(Igniter::Contract) do
      define do
        input :order_total, type: :numeric
        input :multiplier, type: :numeric

        compute :gross_total, depends_on: %i[order_total multiplier], call: calculator
        output :gross_total
      end
    end

    contract = contract_class.new(order_total: 100, multiplier: 1.2)

    expect(contract.result.gross_total).to eq(120.0)
  end

  it "fails compilation when executor declarations require undeclared dependencies" do
    expect do
      Class.new(Igniter::Contract) do
        define do
          input :country, type: :string

          compute :analysis_result, depends_on: [:country], call: MissingDependencyExecutor
          output :analysis_result
        end
      end
    end.to raise_error(Igniter::ValidationError, /executor requires undeclared dependencies: vat_rate/i)
  end

  it "includes executor metadata in graph introspection" do
    contract_class = Class.new(Igniter::Contract) do
      define do
        input :order_total, type: :numeric
        input :multiplier, type: :numeric

        compute :gross_total,
                depends_on: %i[order_total multiplier],
                call: MultiplyExecutor,
                label: "Multiply total",
                category: :pricing,
                tags: %i[math revenue]
        output :gross_total
      end
    end

    text = contract_class.graph.to_text

    expect(text).to include("callable=MultiplyExecutor")
    expect(text).to include("label=Multiply total")
    expect(text).to include("category=pricing")
    expect(text).to include("tags=math,revenue")
  end
end
