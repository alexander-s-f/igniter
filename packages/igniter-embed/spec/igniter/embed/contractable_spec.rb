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

  it "uses a non-blocking local thread adapter by default when async is true" do
    store = memory_store
    candidate_started = Queue.new
    release_candidate = Queue.new
    runner = Igniter::Embed.contractable(:quote) do |config|
      config.primary ->(amount:) { { total: amount } }
      config.candidate lambda { |amount:|
        candidate_started << true
        release_candidate.pop
        { total: amount }
      }
      config.store store
      config.redact_inputs ->(**inputs) { inputs }
      config.normalize_primary normalizer
      config.normalize_candidate normalizer
    end

    expect(runner.call(amount: 100)).to eq(total: 100)
    expect(candidate_started.pop).to eq(true)
    expect(store.observations).to eq([])

    release_candidate << true
    sleep 0.05 until store.observations.any?

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

  it "supports migration sugar over contractable config" do
    store = memory_store
    normalize = normalizer
    runner = Igniter::Embed.contractable(:quote) do
      migrate ->(amount:) { { total: amount * 1.2 } },
              to: ->(amount:) { { total: amount * 1.2 } }
      shadow async: false, sample: 1.0
      store store
      redact_inputs ->(**inputs) { inputs }
      normalize_primary normalize
      normalize_candidate normalize
      accept :exact
    end

    expect(runner.config.role).to eq(:migration_candidate)
    expect(runner.config.stage).to eq(:shadowed)
    expect(runner.call(amount: 100)).to eq(total: 120.0)
    expect(store.observations.fetch(0)).to include(match: true, accepted: true)
  end

  it "supports visible adapter capability sugar over contractable config" do
    store = memory_store
    normalize = normalizer
    runner = Igniter::Embed.contractable(:quote) do
      migrate ->(amount:, **) { { total: amount * 1.2, internal_id: "p1" } },
              to: ->(amount:, **) { { total: amount * 1.2, internal_id: "c1" } }
      shadow async: false, sample: 1.0
      use :normalizer, normalize
      use :redaction, only: %i[account_id quote_id]
      use :acceptance, policy: :completed
      use :store, store
    end

    expect(runner.config.normalize_primary).to eq(normalize)
    expect(runner.config.normalize_candidate).to eq(normalize)
    expect(runner.config.accept).to eq(:completed)
    expect(runner.config.store).to eq(store)

    runner.call(amount: 100, account_id: "acct_1", quote_id: "quote_1", token: "secret")
    observation = store.observations.fetch(0)

    expect(observation.fetch(:inputs)).to eq(account_id: "acct_1", quote_id: "quote_1")
    expect(observation.fetch(:accepted)).to eq(true)
  end

  it "supports redaction except sugar" do
    normalize = normalizer
    runner = Igniter::Embed.contractable(:quote) do
      observe ->(**inputs) { inputs }
      normalize_primary normalize
      use :redaction, except: :token
    end

    expect(runner.config.redact_inputs.call(account_id: "acct_1", token: "secret")).to eq(account_id: "acct_1")
  end

  it "rejects broad capability sugar outside the current slice" do
    expect do
      Igniter::Embed.contractable(:quote) do
        use :metrics
      end
    end.to raise_error(Igniter::Embed::SugarError, /use :metrics/)
  end

  it "raises a sugar error when acceptance sugar omits policy" do
    expect do
      Igniter::Embed.contractable(:quote) do
        use :acceptance
      end
    end.to raise_error(Igniter::Embed::SugarError, /policy/)
  end

  it "dispatches typed candidate error events" do
    events = []
    normalize = normalizer
    runner = Igniter::Embed.contractable(:quote) do
      migrate ->(amount:) { { total: amount } },
              to: ->(amount:) { raise "candidate exploded" if amount }
      shadow async: false
      use :normalizer, normalize
      on :candidate_error do |event|
        events << event
      end
    end

    runner.call(amount: 100)

    expect(events.length).to eq(1)
    expect(events.first).to include(name: :quote, role: :migration_candidate, stage: :shadowed, event: :candidate_error)
    expect(events.first.dig(:error, :message)).to eq("candidate exploded")
  end

  it "expands failure alias into typed failure events" do
    events = []
    normalize = normalizer
    runner = Igniter::Embed.contractable(:quote) do
      migrate ->(amount:) { { total: amount } },
              to: ->(amount:) { raise "candidate exploded" if amount }
      shadow async: false
      use :normalizer, normalize
      use :acceptance, policy: :completed
      on :failure do |event|
        events << event.fetch(:event)
      end
    end

    runner.call(amount: 100)

    expect(events).to include(:candidate_error, :acceptance_failure)
    expect(events).not_to include(:divergence)
  end

  it "dispatches divergence separately from failure alias" do
    divergence_events = []
    failure_events = []
    normalize = normalizer
    runner = Igniter::Embed.contractable(:quote) do
      migrate ->(amount:) { { total: amount } },
              to: ->(amount:) { { total: amount + 1 } }
      shadow async: false
      use :normalizer, normalize
      on :divergence do |event|
        divergence_events << event
      end
      on :failure do |event|
        failure_events << event
      end
    end

    runner.call(amount: 100)

    expect(divergence_events.length).to eq(1)
    expect(divergence_events.first.fetch(:event)).to eq(:divergence)
    expect(failure_events.map { |event| event.fetch(:event) }).to eq([:acceptance_failure])
  end

  it "dispatches primary error events before re-raising" do
    events = []
    normalize = normalizer
    runner = Igniter::Embed.contractable(:quote) do
      observe -> { raise "primary exploded" }
      normalize_primary normalize
      on :failure do |event|
        events << event
      end
    end

    expect { runner.call }.to raise_error(RuntimeError, "primary exploded")
    expect(events.length).to eq(1)
    expect(events.first.fetch(:event)).to eq(:primary_error)
    expect(events.first.dig(:error, :message)).to eq("primary exploded")
  end

  it "supports observed service sugar over contractable config" do
    store = memory_store
    normalize = normalizer
    runner = Igniter::Embed.contractable(:quote) do
      observe ->(amount:) { { total: amount } }
      async false
      store store
      redact_inputs ->(**inputs) { inputs }
      normalize_primary normalize
    end

    expect(runner.config.role).to eq(:observed_service)
    expect(runner.config.stage).to eq(:captured)
    runner.call(amount: 100)

    observation = store.observations.fetch(0)
    expect(observation).to include(role: :observed_service, stage: :captured, mode: :observe)
  end

  it "supports discovery probe sugar over contractable config" do
    store = memory_store
    normalize = normalizer
    runner = Igniter::Embed.contractable(:vendor_lookup) do
      discover ->(vendor_id:) { { vendor_id: vendor_id } }
      capture calls: true, timing: true, errors: true
      async false
      store store
      redact_inputs ->(**inputs) { inputs }
      normalize_primary normalize
    end

    expect(runner.config.role).to eq(:discovery_probe)
    expect(runner.config.stage).to eq(:profiled)
    expect(runner.config.metadata).to eq(capture: { calls: true, timing: true, errors: true })
  end
end
