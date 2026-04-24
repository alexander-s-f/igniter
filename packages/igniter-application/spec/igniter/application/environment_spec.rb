# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Application::Environment do
  class LifecycleScheduler
    attr_reader :starts, :stops

    def initialize
      @starts = []
      @stops = []
    end

    def start(environment:)
      @starts << environment.profile.scheduler_name
      self
    end

    def stop(environment:)
      @stops << environment.profile.scheduler_name
      self
    end
  end

  class LifecycleLoader
    attr_reader :loads

    def initialize
      @loads = []
    end

    def load!(base_dir:, paths:, environment:)
      @loads << {
        base_dir: base_dir.to_s,
        paths: paths,
        loader: environment.profile.loader_name
      }
      self
    end
  end

  class LifecycleHost
    attr_reader :activations, :deactivations

    def initialize
      @activations = 0
      @deactivations = 0
    end

    def activate!(environment:)
      @activations += 1
      environment
    end

    def deactivate!(environment:)
      @deactivations += 1
      environment
    end

    def start(environment:)
      environment.snapshot
    end

    def rack_app(_environment:)
      ->(_env) { [200, { "content-type" => "text/plain" }, ["LifecycleHost"]] }
    end
  end

  class LifecycleProvider < Igniter::Application::Provider
    attr_reader :boot_calls, :shutdown_calls

    def initialize
      @boot_calls = 0
      @shutdown_calls = 0
    end

    def services(environment:)
      endpoint = environment.config.fetch(:services, :analytics, :endpoint)
      {
        analytics_api: -> { endpoint }
      }
    end

    def interfaces(environment:)
      endpoint = environment.config.fetch(:services, :analytics, :endpoint)
      {
        public_analytics_api: Igniter::Application::Interface.new(
          name: :public_analytics_api,
          callable: -> { endpoint },
          metadata: { audience: :external },
          source: :analytics
        )
      }
    end

    def boot(environment:)
      @boot_calls += 1
      environment.config.fetch(:runtime, :mode)
    end

    def shutdown(environment:)
      @shutdown_calls += 1
      environment.config.fetch(:runtime, :mode)
    end
  end

  it "publishes an application manifest and canonical layout through the profile" do
    root = File.expand_path("/tmp/igniter_shop")
    profile = Igniter::Application.build_kernel(Igniter::Extensions::Contracts::ComposePack)
                                  .manifest(:shop, root: root, env: :test, metadata: { owner: :commerce })
                                  .providers_path("app/providers")
                                  .services_path("app/services")
                                  .effects_path("app/effects")
                                  .packs_path("app/packs")
                                  .contracts_path("app/contracts")
                                  .config_path("config/igniter.rb")
                                  .set(:runtime, :mode, value: :test)
                                  .provide(:pricing_api, -> { :ok })
                                  .expose(:public_pricing_api, -> { :ok }, metadata: { audience: :public })
                                  .register("PricingContract", Object)
                                  .finalize
    environment = described_class.new(profile: profile)

    expect(environment.manifest.to_h).to include(
      name: :shop,
      root: root,
      env: :test,
      packs: include("Igniter::Extensions::Contracts::ComposePack"),
      contracts: ["PricingContract"],
      services: %i[pricing_api public_pricing_api],
      interfaces: [:public_pricing_api],
      config: include(runtime: { mode: :test }),
      metadata: { owner: :commerce }
    )
    expect(environment.layout.to_h).to include(
      root: root,
      paths: include(
        contracts: "app/contracts",
        providers: "app/providers",
        services: "app/services",
        effects: "app/effects",
        packs: "app/packs",
        config: "config/igniter.rb",
        spec: "spec/igniter"
      ),
      absolute_paths: include(
        contracts: File.join(root, "app/contracts"),
        config: File.join(root, "config/igniter.rb")
      )
    )
    expect(profile.to_h.fetch(:manifest)).to include(
      name: :shop,
      layout: include(paths: include(contracts: "app/contracts"))
    )
    expect(environment.snapshot.to_h.fetch(:manifest)).to include(name: :shop, env: :test)
  end

  it "persists compose sessions through the application session store" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::ComposePack)
    pricing_graph = environment.compile do
      input :amount
      input :tax_rate

      compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
        amount + (amount * tax_rate)
      end

      output :total
    end

    result = environment.run_compose_session(
      session_id: "pricing/1",
      compiled_graph: pricing_graph,
      inputs: { amount: 100, tax_rate: 0.2 },
      metadata: { origin: :quote_preview }
    )
    entry = environment.fetch_session("pricing/1")

    expect(result.output(:total)).to eq(120.0)
    expect(entry.kind).to eq(:compose)
    expect(entry.status).to eq(:completed)
    expect(entry.metadata).to include(origin: :quote_preview)
    expect(entry.payload).to include(
      inputs: { amount: 100, tax_rate: 0.2 },
      outputs: { total: 120.0 },
      output_names: [:total]
    )
    expect(environment.snapshot.to_h.fetch(:runtime).fetch(:session_count)).to eq(1)
  end

  it "persists collection sessions through the application session store" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::CollectionPack)
    item_graph = environment.compile do
      input :sku
      input :amount
      input :tax_rate

      compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
        amount + (amount * tax_rate)
      end

      output :total
    end

    result = environment.run_collection_session(
      session_id: "pricing-collection/1",
      items: [
        { sku: "a", amount: 10 },
        { sku: "b", amount: 20 }
      ],
      compiled_graph: item_graph,
      key: :sku,
      inputs: { tax_rate: 0.2 },
      metadata: { origin: :quote_batch }
    )
    entry = environment.fetch_session("pricing-collection/1")

    expect(result.keys).to eq(%w[a b])
    expect(result.fetch("b").output(:total)).to eq(24.0)
    expect(entry.kind).to eq(:collection)
    expect(entry.status).to eq(:completed)
    expect(entry.metadata).to include(origin: :quote_batch, key: :sku)
    expect(entry.payload).to include(
      inputs: { tax_rate: 0.2 },
      item_count: 2,
      keys: %w[a b]
    )
    expect(entry.payload.fetch(:summary)).to include(total: 2, added: 2)
  end

  it "allows replacing the default session store seam" do
    custom_store = Class.new do
      attr_reader :written

      def initialize
        @written = {}
      end

      def write(entry)
        @written[entry.id] = entry
        entry
      end

      def fetch(id)
        @written.fetch(id.to_s)
      end

      def entries
        @written.values.sort_by(&:id)
      end
    end.new

    profile = Igniter::Application.build_kernel(Igniter::Extensions::Contracts::ComposePack)
                                  .session_store(:custom, seam: custom_store)
                                  .finalize

    expect(profile.session_store_name).to eq(:custom)
    expect(profile.to_h.fetch(:session_store)).to eq(:custom)

    environment = described_class.new(profile: profile)
    graph = environment.compile do
      input :amount
      output :amount
    end
    environment.run_compose_session(
      session_id: "manual/1",
      compiled_graph: graph,
      inputs: { amount: 10 },
      metadata: { source: :manual_spec }
    )

    expect(custom_store.fetch("manual/1").payload).to include(outputs: { amount: 10 })
  end

  it "exposes application-owned compose invokers for contracts via:" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::ComposePack)

    result = environment.run(inputs: { subtotal: 100, rate: 0.2 }) do
      input :subtotal
      input :rate

      compose :pricing_total,
              inputs: { amount: :subtotal, tax_rate: :rate },
              output: :total,
              via: environment.compose_invoker(namespace: :quotes, metadata: { source: :dsl }) do
        input :amount
        input :tax_rate

        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end

        output :total
      end

      output :pricing_total
    end

    entry = environment.fetch_session("quotes/pricing_total/1")

    expect(result.output(:pricing_total)).to eq(120.0)
    expect(entry.kind).to eq(:compose)
    expect(entry.status).to eq(:completed)
    expect(entry.metadata).to include(namespace: "quotes", source: :dsl, session_id: "quotes/pricing_total/1")
  end

  it "exposes application-owned collection invokers for contracts via:" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::CollectionPack)

    result = environment.run(inputs: {
                               items: [
                                 { sku: "a", amount: 10 },
                                 { sku: "b", amount: 20 }
                               ],
                               tax_rate: 0.2
                             }) do
      input :items
      input :tax_rate

      collection :priced_items,
                 from: :items,
                 key: :sku,
                 inputs: { tax_rate: :tax_rate },
                 via: environment.collection_invoker(namespace: :quotes, metadata: { source: :dsl }) do
        input :sku
        input :amount
        input :tax_rate

        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end

        output :total
      end

      output :priced_items
    end

    entry = environment.fetch_session("quotes/priced_items/1")

    expect(result.output(:priced_items).fetch("a").output(:total)).to eq(12.0)
    expect(entry.kind).to eq(:collection)
    expect(entry.status).to eq(:completed)
    expect(entry.metadata).to include(namespace: "quotes", source: :dsl, session_id: "quotes/priced_items/1")
  end

  it "records failed compose sessions in the session store" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::ComposePack)
    graph = environment.compile do
      input :amount
      output :amount
    end

    expect do
      environment.run_compose_session(
        session_id: "pricing/failure",
        compiled_graph: graph,
        inputs: { amount: 10 },
        invoker: ->(invocation:) { raise "transport unavailable for #{invocation.operation.name}" }
      )
    end.to raise_error(RuntimeError, /transport unavailable/)

    entry = environment.fetch_session("pricing/failure")

    expect(entry.status).to eq(:failed)
    expect(entry.payload.fetch(:error)).to include(
      class: "RuntimeError",
      message: "transport unavailable for pricing/failure"
    )
  end

  it "builds transport-ready remote compose invokers" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::ComposePack)
    requests = []
    transport = lambda do |request:|
      requests << request
      result = Igniter::Contracts.execute(
        request.compiled_graph,
        inputs: request.inputs,
        profile: environment.profile.contracts_profile
      )
      Igniter::Application::TransportResponse.new(
        result: result,
        metadata: { adapter: :stub_remote, target: "node-a" }
      )
    end

    result = environment.run(inputs: { subtotal: 50, rate: 0.1 }) do
      input :subtotal
      input :rate

      compose :pricing_total,
              inputs: { amount: :subtotal, tax_rate: :rate },
              output: :total,
              via: environment.remote_compose_invoker(transport: transport, namespace: :mesh) do
        input :amount
        input :tax_rate
        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end
        output :total
      end

      output :pricing_total
    end

    entry = environment.fetch_session("mesh/pricing_total/1")

    expect(result.output(:pricing_total)).to eq(55.0)
    expect(requests.length).to eq(1)
    expect(requests.first).to be_a(Igniter::Application::TransportRequest)
    expect(requests.first.kind).to eq(:compose)
    expect(requests.first.session_id).to eq("mesh/pricing_total/1")
    expect(entry.payload.fetch(:transport)).to eq(adapter: :stub_remote, target: "node-a")
  end

  it "builds transport-ready remote collection invokers" do
    environment = Igniter::Application.with(Igniter::Extensions::Contracts::CollectionPack)
    requests = []
    transport = lambda do |request:|
      requests << request
      result = Igniter::Extensions::Contracts::CollectionPack::LocalInvoker.call(
        invocation: Igniter::Extensions::Contracts::CollectionPack::Invocation.new(
          operation: Igniter::Contracts::Operation.new(kind: :collection, name: request.operation_name, attributes: {}),
          items: request.items,
          inputs: request.inputs,
          compiled_graph: request.compiled_graph,
          profile: environment.profile.contracts_profile,
          key_name: request.key_name,
          window: request.window
        )
      )
      Igniter::Application::TransportResponse.new(
        result: result,
        metadata: { adapter: :stub_remote, target: "node-b" }
      )
    end

    result = environment.run(inputs: {
                               items: [
                                 { sku: "a", amount: 10 },
                                 { sku: "b", amount: 20 }
                               ],
                               tax_rate: 0.2
                             }) do
      input :items
      input :tax_rate

      collection :priced_items,
                 from: :items,
                 key: :sku,
                 inputs: { tax_rate: :tax_rate },
                 via: environment.remote_collection_invoker(transport: transport, namespace: :mesh) do
        input :sku
        input :amount
        input :tax_rate
        compute :total, depends_on: %i[amount tax_rate] do |amount:, tax_rate:|
          amount + (amount * tax_rate)
        end
        output :total
      end

      output :priced_items
    end

    entry = environment.fetch_session("mesh/priced_items/1")

    expect(result.output(:priced_items).fetch("b").output(:total)).to eq(24.0)
    expect(requests.length).to eq(1)
    expect(requests.first.kind).to eq(:collection)
    expect(requests.first.session_id).to eq("mesh/priced_items/1")
    expect(requests.first.key_name).to eq(:sku)
    expect(entry.payload.fetch(:transport)).to eq(adapter: :stub_remote, target: "node-b")
  end

  it "keeps provider registry resolution separate from provider boot" do
    provider = LifecycleProvider.new
    environment = Igniter::Application.build_kernel
                                      .register_provider(:analytics, provider)
                                      .set(:runtime, :mode, value: :test)
                                      .set(:services, :analytics, :endpoint, value: "memory://analytics")
                                      .finalize
                                      .then { |profile| described_class.new(profile: profile) }

    expect(environment.service(:analytics_api).call).to eq("memory://analytics")
    expect(provider.boot_calls).to eq(0)
    expect(environment.provider_resolution_report.to_h).to include(
      phase: :resolve,
      status: :completed,
      providers: [:analytics],
      services: %i[analytics_api public_analytics_api],
      interfaces: [:public_analytics_api]
    )
  end

  it "builds a boot plan before execution" do
    environment = Igniter::Application.build_kernel
                                      .register_provider(:analytics, LifecycleProvider.new)
                                      .set(:services, :analytics, :endpoint, value: "memory://analytics")
                                      .contracts_path("contracts")
                                      .then { |kernel| described_class.new(profile: kernel.finalize) }

    plan = environment.plan_boot(base_dir: Dir.pwd, load_code: true, start_scheduler: false, activate_transport: false)

    expect(plan).to be_a(Igniter::Application::BootPlan)
    expect(plan.actions).to eq(%i[load_code resolve_providers boot_providers])
    expect(plan.load_code_step.to_h).to include(
      seam: :loader,
      action: :load,
      status: :planned
    )
    expect(plan.scheduler_step.to_h).to include(
      seam: :scheduler,
      action: :start,
      status: :skipped,
      reason: "start_scheduler disabled"
    )
    expect(plan.host_step.to_h).to include(
      seam: :host,
      action: :activate_transport,
      status: :skipped,
      reason: "activate_transport disabled"
    )
  end

  it "executes an explicit boot plan through the plan executor" do
    provider = LifecycleProvider.new
    scheduler = LifecycleScheduler.new
    loader = LifecycleLoader.new
    host = LifecycleHost.new
    environment = Igniter::Application.build_kernel
                                      .register_provider(:analytics, provider)
                                      .loader(:filesystem, seam: loader)
                                      .scheduler(:threaded, seam: scheduler)
                                      .host(:rack, seam: host)
                                      .set(:runtime, :mode, value: :test)
                                      .set(:services, :analytics, :endpoint, value: "memory://analytics")
                                      .contracts_path("contracts")
                                      .then { |kernel| described_class.new(profile: kernel.finalize) }

    plan = environment.plan_boot(base_dir: Dir.pwd, activate_transport: true)
    report = environment.execute_boot_plan(plan)

    expect(report.plan).to equal(plan)
    expect(environment.booted?).to be(true)
    expect(loader.loads.length).to eq(1)
    expect(scheduler.starts).to eq([:threaded])
    expect(host.activations).to eq(1)
    expect(provider.boot_calls).to eq(1)
  end

  it "boots through explicit provider lifecycle and returns structured reports" do
    provider = LifecycleProvider.new
    scheduler = LifecycleScheduler.new
    loader = LifecycleLoader.new
    host = LifecycleHost.new
    environment = Igniter::Application.build_kernel
                                      .register_provider(:analytics, provider)
                                      .loader(:filesystem, seam: loader)
                                      .scheduler(:threaded, seam: scheduler)
                                      .host(:rack, seam: host)
                                      .set(:runtime, :mode, value: :test)
                                      .set(:services, :analytics, :endpoint, value: "memory://analytics")
                                      .contracts_path("contracts")
                                      .then { |kernel| described_class.new(profile: kernel.finalize) }

    report = environment.boot(base_dir: Dir.pwd, activate_transport: true)

    expect(report).to be_a(Igniter::Application::BootReport)
    expect(report.plan).to be_a(Igniter::Application::BootPlan)
    expect(report.loaded_code?).to be(true)
    expect(report.providers_resolved?).to be(true)
    expect(report.providers_booted?).to be(true)
    expect(report.scheduler_started?).to be(true)
    expect(provider.boot_calls).to eq(1)
    expect(loader.loads.first).to include(
      base_dir: Dir.pwd,
      loader: :filesystem
    )
    expect(scheduler.starts).to eq([:threaded])
    expect(host.activations).to eq(1)
    expect(environment.service(:analytics_api).call).to eq("memory://analytics")
    expect(environment.interface(:public_analytics_api).call).to eq("memory://analytics")
    expect(report.loader_result.to_h).to include(
      seam: :loader,
      action: :load,
      status: :completed
    )
    expect(report.scheduler_result.to_h).to include(
      seam: :scheduler,
      action: :start,
      status: :completed
    )
    expect(report.host_result.to_h).to include(
      seam: :host,
      action: :activate_transport,
      status: :completed
    )
    expect(report.to_h.fetch(:plan).fetch(:actions)).to eq(
      %i[load_code resolve_providers boot_providers start_scheduler activate_transport]
    )
    expect(report.provider_resolution_report.to_h).to include(
      providers: [:analytics],
      services: %i[analytics_api public_analytics_api],
      interfaces: [:public_analytics_api]
    )
    expect(report.provider_boot_report.to_h).to include(
      phase: :boot,
      status: :completed,
      completed_providers: [:analytics]
    )
    expect(environment.snapshot.to_h.fetch(:runtime)).to include(
      providers_resolved: true,
      providers_booted: true,
      providers_shutdown: false,
      scheduler_running: true,
      transport_activated: true
    )
  end

  it "builds a shutdown plan from current runtime state" do
    provider = LifecycleProvider.new
    scheduler = LifecycleScheduler.new
    host = LifecycleHost.new
    environment = Igniter::Application.build_kernel
                                      .register_provider(:analytics, provider)
                                      .scheduler(:threaded, seam: scheduler)
                                      .host(:rack, seam: host)
                                      .set(:runtime, :mode, value: :test)
                                      .set(:services, :analytics, :endpoint, value: "memory://analytics")
                                      .then { |kernel| described_class.new(profile: kernel.finalize) }

    pre_boot_plan = environment.plan_shutdown
    expect(pre_boot_plan.actions).to eq([])
    expect(pre_boot_plan.host_step.to_h).to include(status: :skipped, reason: "transport not active")
    expect(pre_boot_plan.scheduler_step.to_h).to include(status: :skipped, reason: "scheduler not running")
    expect(pre_boot_plan.provider_shutdown_step.to_h).to include(status: :skipped, reason: "providers not booted")

    environment.boot(load_code: false, activate_transport: true)
    plan = environment.plan_shutdown

    expect(plan).to be_a(Igniter::Application::ShutdownPlan)
    expect(plan.actions).to eq(%i[deactivate_transport stop_scheduler shutdown_providers])
    expect(plan.host_step.to_h).to include(
      seam: :host,
      action: :deactivate_transport,
      status: :planned
    )
    expect(plan.scheduler_step.to_h).to include(
      seam: :scheduler,
      action: :stop,
      status: :planned
    )
    expect(plan.provider_shutdown_step.to_h).to include(
      seam: :providers,
      action: :shutdown,
      status: :planned
    )
  end

  it "executes an explicit shutdown plan through the plan executor" do
    provider = LifecycleProvider.new
    scheduler = LifecycleScheduler.new
    host = LifecycleHost.new
    environment = Igniter::Application.build_kernel
                                      .register_provider(:analytics, provider)
                                      .scheduler(:threaded, seam: scheduler)
                                      .host(:rack, seam: host)
                                      .set(:runtime, :mode, value: :test)
                                      .set(:services, :analytics, :endpoint, value: "memory://analytics")
                                      .then { |kernel| described_class.new(profile: kernel.finalize) }

    environment.boot(load_code: false, activate_transport: true)
    plan = environment.plan_shutdown
    report = environment.execute_shutdown_plan(plan)

    expect(report.plan).to equal(plan)
    expect(environment.booted?).to be(false)
    expect(host.deactivations).to eq(1)
    expect(scheduler.stops).to eq([:threaded])
    expect(provider.shutdown_calls).to eq(1)
  end

  it "shuts down providers through an explicit lifecycle report" do
    provider = LifecycleProvider.new
    scheduler = LifecycleScheduler.new
    host = LifecycleHost.new
    environment = Igniter::Application.build_kernel
                                      .register_provider(:analytics, provider)
                                      .scheduler(:threaded, seam: scheduler)
                                      .host(:rack, seam: host)
                                      .set(:runtime, :mode, value: :test)
                                      .set(:services, :analytics, :endpoint, value: "memory://analytics")
                                      .then { |kernel| described_class.new(profile: kernel.finalize) }

    environment.boot(load_code: false, activate_transport: true)
    report = environment.shutdown

    expect(report).to be_a(Igniter::Application::ShutdownReport)
    expect(report.plan).to be_a(Igniter::Application::ShutdownPlan)
    expect(report.transport_deactivated?).to be(true)
    expect(report.scheduler_stopped?).to be(true)
    expect(report.providers_shutdown?).to be(true)
    expect(provider.shutdown_calls).to eq(1)
    expect(host.deactivations).to eq(1)
    expect(scheduler.stops).to eq([:threaded])
    expect(report.host_result.to_h).to include(
      seam: :host,
      action: :deactivate_transport,
      status: :completed
    )
    expect(report.scheduler_result.to_h).to include(
      seam: :scheduler,
      action: :stop,
      status: :completed
    )
    expect(report.to_h.fetch(:plan).fetch(:actions)).to eq(
      %i[deactivate_transport stop_scheduler shutdown_providers]
    )
    expect(report.provider_shutdown_report.to_h).to include(
      phase: :shutdown,
      status: :completed,
      completed_providers: [:analytics]
    )
    expect(environment.snapshot.to_h.fetch(:runtime)).to include(
      booted: false,
      providers_booted: false,
      providers_shutdown: true,
      scheduler_running: false,
      transport_activated: false
    )
  end
end
