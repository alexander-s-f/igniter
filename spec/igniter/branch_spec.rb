# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Igniter branches" do
  let(:us_contract) do
    Class.new(Igniter::Contract) do
      define do
        input :country
        input :order_total

        compute :price, with: :order_total do |order_total:|
          order_total * 1.1
        end

        compute :eta, with: :country do |country:|
          "#{country}-eta"
        end

        output :price
        output :eta
      end
    end
  end

  let(:ua_contract) do
    Class.new(Igniter::Contract) do
      define do
        input :country
        input :order_total

        compute :price, with: :order_total do |order_total:|
          order_total * 1.2
        end

        compute :eta, with: :country do |country:|
          "#{country}-eta"
        end

        output :price
        output :eta
      end
    end
  end

  let(:default_contract) do
    Class.new(Igniter::Contract) do
      define do
        input :country
        input :order_total

        compute :price, with: :order_total do |order_total:|
          order_total
        end

        compute :eta, with: :country do |country:|
          "#{country}-default"
        end

        output :price
        output :eta
      end
    end
  end

  it "routes to a matching branch contract and exports branch outputs" do
    us = us_contract
    ua = ua_contract
    fallback = default_contract

    contract_class = Class.new(Igniter::Contract) do
      define do
        input :country
        input :order_total

        branch :delivery_strategy, with: :country, inputs: {
          country: :country,
          order_total: :order_total
        } do
          on "US", contract: us
          on "UA", contract: ua
          default contract: fallback
        end

        export :price, :eta, from: :delivery_strategy
      end
    end

    contract = contract_class.new(country: "UA", order_total: 100)

    expect(contract.result.price).to eq(120.0)
    expect(contract.result.eta).to eq("UA-eta")
  end

  it "returns a nested result for branch outputs" do
    us = us_contract
    ua = ua_contract
    fallback = default_contract

    contract_class = Class.new(Igniter::Contract) do
      define do
        input :country
        input :order_total

        branch :delivery_strategy, with: :country, inputs: {
          country: :country,
          order_total: :order_total
        } do
          on "US", contract: us
          on "UA", contract: ua
          default contract: fallback
        end

        output :delivery_strategy
      end
    end

    contract = contract_class.new(country: "US", order_total: 100)

    expect(contract.result.delivery_strategy).to be_a(Igniter::Runtime::Result)
    expect(contract.result.delivery_strategy.price).to be_within(0.001).of(110.0)
  end

  it "uses the default branch when no case matches" do
    us = us_contract
    ua = ua_contract
    fallback = default_contract

    contract_class = Class.new(Igniter::Contract) do
      define do
        input :country
        input :order_total

        branch :delivery_strategy, with: :country, inputs: {
          country: :country,
          order_total: :order_total
        } do
          on "US", contract: us
          on "UA", contract: ua
          default contract: fallback
        end

        export :price, :eta, from: :delivery_strategy
      end
    end

    contract = contract_class.new(country: "PL", order_total: 100)

    expect(contract.result.price).to eq(100)
    expect(contract.result.eta).to eq("PL-default")
  end

  it "emits branch_selected with selected contract details" do
    us = us_contract
    ua = ua_contract
    fallback = default_contract

    contract_class = Class.new(Igniter::Contract) do
      define do
        input :country
        input :order_total

        branch :delivery_strategy, with: :country, inputs: {
          country: :country,
          order_total: :order_total
        } do
          on "US", contract: us
          on "UA", contract: ua
          default contract: fallback
        end

        output :delivery_strategy
      end
    end

    contract = contract_class.new(country: "US", order_total: 100)
    contract.result.delivery_strategy.price

    event = contract.events.find { |item| item.type == :branch_selected }
    expect(event.payload).to include(
      selector: :country,
      selector_value: "US",
      matched_case: "US",
      selected_contract: us.compiled_graph.name
    )
  end

  it "fails compilation when exported outputs do not exist across all branch contracts" do
    incomplete_contract = Class.new(Igniter::Contract) do
      define do
        input :country
        input :order_total
        output :country
      end
    end

    us = us_contract

    expect do
      Class.new(Igniter::Contract) do
        define do
          input :country
          input :order_total

          branch :delivery_strategy, with: :country, inputs: {
            country: :country,
            order_total: :order_total
          } do
            on "US", contract: us
            default contract: incomplete_contract
          end

          export :price, from: :delivery_strategy
        end
      end
    end.to raise_error(Igniter::ValidationError, /unknown child output 'price'/i)
  end

  it "fails the branch node when the selected child contract fails" do
    failing_contract = Class.new(Igniter::Contract) do
      define do
        input :country
        input :order_total

        compute :price, with: :order_total do |order_total:|
          raise "boom" if order_total > 100

          order_total
        end

        output :price
      end
    end

    fallback = default_contract

    contract_class = Class.new(Igniter::Contract) do
      define do
        input :country
        input :order_total

        branch :delivery_strategy, with: :country, inputs: {
          country: :country,
          order_total: :order_total
        } do
          on "US", contract: failing_contract
          default contract: fallback
        end

        output :delivery_strategy
      end
    end

    contract = contract_class.new(country: "US", order_total: 150)

    expect { contract.result.delivery_strategy.price }.to raise_error(Igniter::ResolutionError, /boom/)

    state = contract.execution.cache.fetch(:delivery_strategy)
    expect(state).to be_failed
  end
end
