# frozen_string_literal: true

require "singleton"

class SparkContractableReceiptStore
  include Singleton

  attr_reader :latest_observation_id

  def initialize
    ledger = Igniter::Ledger::LedgerStore.new
    @sink = Igniter::Ledger::ContractableReceiptSink.new(
      store: ledger,
      observations_store: :rails_contract_observations,
      events_store: :rails_contract_events,
      producer: { type: :rails_example, name: :spark_contractable_receipt_store }
    )
  end

  def record_observation(receipt)
    @latest_observation_id = receipt.fetch(:observation_id)
    @sink.record_observation(receipt)
  end

  def record_event(receipt)
    @sink.record_event(receipt)
  end

  def observation(observation_id)
    @sink.observation(observation_id)
  end

  def events_for(observation_id)
    @sink.events_for(observation_id)
  end
end
