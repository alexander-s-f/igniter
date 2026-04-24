# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Igniter::Embed.host sugar" do
  before do
    billing = Module.new do
      def self.root
        "/tmp/billing"
      end
    end
    stub_const("Billing", billing)
    stub_const("Billing::PriceQuoteContract", Class.new(Igniter::Contract) do
      define do
        input :amount
        compute :total, depends_on: [:amount] do |amount:|
          amount * 1.2
        end
        output :total
      end
    end)
    stub_const("Billing::LegacyQuoteService", Class.new)
    stub_const("Billing::ContractQuoteService", Class.new)
    stub_const("Billing::QuoteObserver", Class.new)
    stub_const("Billing::QuoteNormalizer", Class.new)
    stub_const("Billing::ObservationStore", Class.new)
  end

  it "builds the same plain contract registration as the clean form" do
    clean = Igniter::Embed.configure(:billing) do |config|
      config.owner Billing
      config.root Billing.root
      config.cache = false
      config.contract Billing::PriceQuoteContract, as: :price_quote
    end

    sugar = Igniter::Embed.host(:billing) do
      owner Billing
      path "."
      cache false

      contracts do
        add :price_quote, Billing::PriceQuoteContract
      end
    end

    expect(sugar.config.name).to eq(clean.config.name)
    expect(sugar.config.owner).to eq(clean.config.owner)
    expect(sugar.config.root).to eq(clean.config.root)
    expect(sugar.config.cache?).to eq(clean.config.cache?)
    expect(sugar.registry.to_h).to eq(clean.registry.to_h)
    expect(sugar.call(:price_quote, amount: 100).output(:total)).to eq(120.0)
  end

  it "infers contract names the same way container registration does" do
    contracts = Igniter::Embed.host(:billing) do
      contracts do
        add Billing::PriceQuoteContract
      end
    end

    expect(contracts.registry.names).to eq([:price_quote])
    expect(contracts.call(:price_quote, amount: 100).output(:total)).to eq(120.0)
  end

  it "supports the explicit config.contracts form as the same first slice" do
    contracts = Igniter::Embed.configure(:billing) do |config|
      config.owner Billing
      config.path "."
      config.contracts do
        add :price_quote, Billing::PriceQuoteContract
      end
    end

    expect(contracts.config.root).to eq("/tmp/billing")
    expect(contracts.registry.names).to eq([:price_quote])
  end

  it "exposes structured sugar expansion output" do
    contracts = Igniter::Embed.host(:billing) do
      owner Billing
      path "app/contracts"
      cache false

      contracts do
        add Billing::PriceQuoteContract
      end
    end

    expect(contracts.sugar_expansion.to_h).to include(
      host: :billing,
      owner: "Billing",
      root: "/tmp/billing/app/contracts",
      cache: false,
      contractables: [],
      capabilities: [],
      events: []
    )
    expect(contracts.sugar_expansion.to_h.fetch(:contracts)).to eq(
      [
        {
          name: :price_quote,
          class: "Billing::PriceQuoteContract",
          kind: :class
        }
      ]
    )
  end

  it "includes generated migration contractables in sugar expansion output" do
    contracts = Igniter::Embed.host(:billing) do
      contracts do
        add :price_quote, Billing::PriceQuoteContract do
          migration from: Billing::LegacyQuoteService,
                    to: Billing::ContractQuoteService
          shadow async: false, sample: 0.25
        end
      end
    end

    expect(contracts.config.contractable_configs.length).to eq(1)
    expect(contracts.sugar_expansion.to_h.fetch(:contractables)).to match(
      [
        include(
          name: :price_quote,
          role: :migration_candidate,
          stage: :shadowed,
          primary: "Billing::LegacyQuoteService",
          candidate: "Billing::ContractQuoteService",
          async: false,
          sample: 0.25,
          metadata: {},
          adapters: {
            redaction: a_string_matching(/Proc/),
            acceptance: { policy: :exact, options: {} }
          }
        )
      ]
    )
  end

  it "includes visible host-boundary adapters in sugar expansion output" do
    contracts = Igniter::Embed.host(:billing) do
      contracts do
        add :price_quote, Billing::PriceQuoteContract do
          migration from: Billing::LegacyQuoteService,
                    to: Billing::ContractQuoteService
          use :normalizer, Billing::QuoteNormalizer
          use :redaction, only: %i[account_id quote_id]
          use :acceptance, policy: :completed
          use :store, Billing::ObservationStore
        end
      end
    end

    expect(contracts.sugar_expansion.to_h.fetch(:contractables).first.fetch(:adapters)).to include(
      normalizer: "Billing::QuoteNormalizer",
      redaction: a_string_matching(/Proc/),
      acceptance: { policy: :completed, options: {} },
      store: "Billing::ObservationStore"
    )
  end

  it "does not generate a contractable for an empty add block" do
    contracts = Igniter::Embed.host(:billing) do
      contracts do
        add :price_quote, Billing::PriceQuoteContract do
        end
      end
    end

    expect(contracts.registry.names).to eq([:price_quote])
    expect(contracts.config.contractable_configs).to eq([])
    expect(contracts.sugar_expansion.to_h.fetch(:contractables)).to eq([])
  end

  it "includes generated observed and discovery contractables in sugar expansion output" do
    contracts = Igniter::Embed.host(:billing) do
      contracts do
        add :quote_observer, Billing::PriceQuoteContract do
          observe Billing::QuoteObserver
        end

        add :quote_probe, Billing::PriceQuoteContract do
          discover Billing::LegacyQuoteService
          capture calls: true, timing: true, errors: true
        end
      end
    end

    expect(contracts.sugar_expansion.to_h.fetch(:contractables)).to contain_exactly(
      include(
        name: :quote_observer,
        role: :observed_service,
        stage: :captured,
        primary: "Billing::QuoteObserver",
        candidate: nil,
        adapters: include(acceptance: { policy: :exact, options: {} })
      ),
      include(
        name: :quote_probe,
        role: :discovery_probe,
        stage: :profiled,
        primary: "Billing::LegacyQuoteService",
        candidate: nil,
        metadata: { capture: { calls: true, timing: true, errors: true } },
        adapters: include(acceptance: { policy: :exact, options: {} })
      )
    )
  end

  it "raises the same anonymous contract error as clean registration" do
    anonymous_contract = Class.new(Igniter::Contract) do
      define do
        input :amount
        output :amount
      end
    end

    expect do
      Igniter::Embed.host(:billing) do
        contracts do
          add anonymous_contract
        end
      end
    end.to raise_error(Igniter::Embed::InvalidContractRegistrationError, /anonymous/)
  end

  it "rejects ambiguous path arrays in the first implementation slice" do
    expect do
      Igniter::Embed.host(:billing) do
        path ["app/contracts", "engines/billing/app/contracts"]
      end
    end.to raise_error(Igniter::Embed::SugarError, /exactly one path/)
  end
end
