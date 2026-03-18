# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Igniter reactive" do
  it "runs reactions for matching runtime events" do
    observed = []

    contract_class = Class.new(Igniter::Contract) do
      define do
        input :order_total
        compute :gross_total, depends_on: [:order_total] do |order_total:|
          order_total * 1.2
        end
        output :gross_total
      end

      react_to :node_succeeded, path: "gross_total" do |event:, contract:, execution:|
        observed << [event.type, event.path, contract.class.name, execution.compiled_graph.name]
      end
    end

    contract = contract_class.new(order_total: 100)
    contract.result.gross_total

    expect(observed).to eq([[:node_succeeded, "gross_total", nil, "AnonymousContract"]])
  end

  it "passes node value into effect callbacks when requested" do
    observed = []

    contract_class = Class.new(Igniter::Contract) do
      define do
        input :order_total
        compute :gross_total, depends_on: [:order_total] do |order_total:|
          order_total * 1.2
        end
        output :gross_total
      end

      effect "gross_total" do |event:, value:, **|
        observed << [event.type, value]
      end
    end

    contract = contract_class.new(order_total: 100)
    contract.result.gross_total

    expect(observed).to eq([[:node_succeeded, 120.0]])
  end

  it "reacts to invalidation events after input updates" do
    invalidated = []

    contract_class = Class.new(Igniter::Contract) do
      define do
        input :order_total
        compute :gross_total, depends_on: [:order_total] do |order_total:|
          order_total * 1.2
        end
        output :gross_total
      end

      react_to :node_invalidated, path: "gross_total" do |event:, **|
        invalidated << event.payload[:cause]
      end
    end

    contract = contract_class.new(order_total: 100)
    contract.result.gross_total
    contract.update_inputs(order_total: 150)

    expect(invalidated).to eq([:order_total])
  end

  it "captures reaction errors without breaking execution" do
    contract_class = Class.new(Igniter::Contract) do
      define do
        input :order_total
        output :order_total
      end

      react_to :node_succeeded, path: "order_total" do |event:, **|
        event
        raise "side effect failed"
      end
    end

    contract = contract_class.new(order_total: 100)

    expect(contract.result.order_total).to eq(100)
    expect(contract.reactive.errors.size).to eq(1)
    expect(contract.reactive.errors.first[:error].message).to eq("side effect failed")
  end

  it "supports on_success for final outputs without intermediate nodes" do
    observed = []

    contract_class = Class.new(Igniter::Contract) do
      define do
        input :order_total
        compute :gross_total, depends_on: [:order_total] do |order_total:|
          order_total * 1.2
        end
        expose :gross_total, as: :response
      end

      on_success :response do |value:, contract:, **|
        observed << [value, contract.result.response]
      end
    end

    contract = contract_class.new(order_total: 100)
    expect(contract.result.response).to eq(120.0)
    expect(observed).to eq([[120.0, 120.0]])
  end

  it "keeps parent reactions isolated from child composition events" do
    observed = []

    pricing_contract = Class.new(Igniter::Contract) do
      define do
        input :order_total
        compute :gross_total, depends_on: [:order_total] do |order_total:|
          order_total * 1.2
        end
        output :gross_total
      end
    end

    checkout_contract = Class.new(Igniter::Contract) do
      define do
        input :order_total
        compose :pricing, contract: pricing_contract, inputs: { order_total: :order_total }
        output :pricing
      end

      react_to :node_succeeded, path: "pricing" do |event:, **|
        observed << event.path
      end
    end

    contract = checkout_contract.new(order_total: 100)
    contract.result.pricing.gross_total

    expect(observed).to eq(["pricing"])
    expect(contract.events.map(&:path)).not_to include("gross_total")
  end
end
