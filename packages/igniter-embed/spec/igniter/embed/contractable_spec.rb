# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Embed::Contractable do
  def memory_store
    Class.new do
      attr_reader :observations

      def initialize
        @observations = []
      end

      def record(observation)
        observations << observation
      end
    end.new
  end

  def queue_adapter
    Class.new do
      attr_reader :jobs

      def initialize
        @jobs = []
      end

      def enqueue(name:, inputs:, metadata:, &block)
        jobs << { name: name, inputs: inputs, metadata: metadata, block: block }
      end
    end.new
  end

  def normalizer
    lambda do |result|
      {
        status: :ok,
        outputs: result,
        metadata: { normalized: true }
      }
    end
  end

  it "returns the primary result synchronously and records an exact match observation" do
    store = memory_store
    runner = Igniter::Embed.contractable(:quote) do |config|
      config.primary ->(amount:) { { total: amount * 1.2 } }
      config.candidate ->(amount:) { { total: amount * 1.2 } }
      config.async false
      config.store store
      config.redact_inputs ->(**inputs) { inputs }
      config.normalize_primary normalizer
      config.normalize_candidate normalizer
      config.accept :exact
    end

    result = runner.call(amount: 100)

    expect(result).to eq(total: 120.0)
    observation = store.observations.fetch(0)
    expect(observation).to include(name: :quote, role: :migration_candidate, stage: :captured)
    expect(observation).to include(match: true, accepted: true)
    expect(observation.fetch(:report)).to include(match: true, summary: "match")
  end

  it "records divergences without changing the primary result" do
    store = memory_store
    runner = Igniter::Embed.contractable(:quote) do |config|
      config.primary ->(amount:) { { total: amount * 1.2 } }
      config.candidate ->(amount:) { { total: amount * 1.3 } }
      config.async false
      config.store store
      config.redact_inputs ->(**inputs) { inputs }
      config.normalize_primary normalizer
      config.normalize_candidate normalizer
      config.accept :exact
    end

    expect(runner.call(amount: 100)).to eq(total: 120.0)

    observation = store.observations.fetch(0)
    expect(observation.fetch(:match)).to eq(false)
    expect(observation.fetch(:accepted)).to eq(false)
    expect(observation.dig(:report, :summary)).to include("value(s) differ")
  end

  it "captures candidate exceptions and accepts completed policy only when candidate completes" do
    store = memory_store
    runner = Igniter::Embed.contractable(:quote) do |config|
      config.primary ->(amount:) { { total: amount } }
      config.candidate ->(amount:) { raise "candidate exploded" if amount }
      config.async false
      config.store store
      config.redact_inputs ->(**inputs) { inputs }
      config.normalize_primary normalizer
      config.normalize_candidate normalizer
      config.accept :completed
    end

    expect(runner.call(amount: 100)).to eq(total: 100)

    observation = store.observations.fetch(0)
    expect(observation.fetch(:candidate)).to include(status: :error)
    expect(observation.dig(:candidate, :error, :message)).to eq("candidate exploded")
    expect(observation.fetch(:accepted)).to eq(false)
  end

  it "supports no-store mode" do
    observations = []
    runner = Igniter::Embed.contractable(:quote) do |config|
      config.primary ->(amount:) { { total: amount } }
      config.candidate ->(amount:) { { total: amount } }
      config.async false
      config.redact_inputs ->(**inputs) { inputs }
      config.normalize_primary normalizer
      config.normalize_candidate normalizer
      config.on_observation ->(observation) { observations << observation }
    end

    expect(runner.call(amount: 100)).to eq(total: 100)
    expect(observations.length).to eq(1)
    expect(observations.first.fetch(:store_error)).to be_nil
  end

  it "enqueues candidate work through the async adapter" do
    store = memory_store
    queue = queue_adapter
    runner = Igniter::Embed.contractable(:quote) do |config|
      config.primary ->(amount:) { { total: amount } }
      config.candidate ->(amount:) { { total: amount } }
      config.async true
      config.async_adapter queue
      config.store store
      config.redact_inputs ->(**inputs) { inputs }
      config.normalize_primary normalizer
      config.normalize_candidate normalizer
    end

    expect(runner.call(amount: 100)).to eq(total: 100)
    expect(store.observations).to eq([])
    expect(queue.jobs.length).to eq(1)

    queue.jobs.first.fetch(:block).call
    expect(store.observations.length).to eq(1)
  end

  it "supports primary-only observed service mode" do
    store = memory_store
    runner = Igniter::Embed.contractable(:quote) do |config|
      config.role :observed_service
      config.stage :profiled
      config.primary ->(amount:) { { total: amount } }
      config.async false
      config.store store
      config.redact_inputs ->(**inputs) { inputs }
      config.normalize_primary normalizer
    end

    expect(runner.call(amount: 100)).to eq(total: 100)

    observation = store.observations.fetch(0)
    expect(observation).to include(role: :observed_service, stage: :profiled, mode: :observe)
    expect(observation.fetch(:candidate)).to be_nil
    expect(observation.fetch(:report)).to be_nil
  end

  it "supports shape acceptance over candidate outputs" do
    store = memory_store
    runner = Igniter::Embed.contractable(:quote) do |config|
      config.primary -> { { total: 100 } }
      config.candidate -> { { total: 120, status: "accepted" } }
      config.async false
      config.store store
      config.normalize_primary normalizer
      config.normalize_candidate normalizer
      config.accept :shape, outputs: { total: Numeric, status: String }
    end

    runner.call

    expect(store.observations.fetch(0).fetch(:accepted)).to eq(true)
  end
end
