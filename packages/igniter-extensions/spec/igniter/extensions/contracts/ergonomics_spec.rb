# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "Igniter::Extensions::Contracts ergonomics" do
  it "exposes available packs and builds a profile with them by default" do
    expect(Igniter::Extensions::Contracts.default_packs).to eq([
      Igniter::Extensions::Contracts::ExecutionReportPack,
      Igniter::Extensions::Contracts::LookupPack
    ])

    expect(Igniter::Extensions::Contracts.available_packs).to eq([
      Igniter::Extensions::Contracts::ExecutionReportPack,
      Igniter::Extensions::Contracts::LookupPack,
      Igniter::Extensions::Contracts::AggregatePack,
      Igniter::Extensions::Contracts::CommercePack,
      Igniter::Extensions::Contracts::CreatorPack,
      Igniter::Extensions::Contracts::DataflowPack,
      Igniter::Extensions::Contracts::DebugPack,
      Igniter::Extensions::Contracts::IncrementalPack,
      Igniter::Extensions::Contracts::JournalPack,
      Igniter::Extensions::Contracts::ProvenancePack,
      Igniter::Extensions::Contracts::SagaPack
    ])

    expect(Igniter::Extensions::Contracts.presets).to eq({
      default: [
        Igniter::Extensions::Contracts::ExecutionReportPack,
        Igniter::Extensions::Contracts::LookupPack
      ],
      commerce: [
        Igniter::Extensions::Contracts::ExecutionReportPack,
        Igniter::Extensions::Contracts::CommercePack
      ]
    })

    profile = Igniter::Extensions::Contracts.build_profile

    expect(profile.pack_names).to eq(%i[baseline extensions_execution_report extensions_lookup])
  end

  it "builds an environment with the package's default external packs" do
    environment = Igniter::Extensions::Contracts.with

    result = environment.run(inputs: { rates: { ua: 0.2 } }) do
      input :rates
      lookup :tax_rate, from: :rates, key: :ua
      output :tax_rate
    end
    report = environment.diagnose(result)

    expect(result.output(:tax_rate)).to eq(0.2)
    expect(report.section(:execution_report)).to include(
      output_count: 1,
      state_count: 2
    )
  end

  it "does not install opt-in operational packs by default" do
    profile = Igniter::Extensions::Contracts.build_profile

    expect(profile.supports_effect?(:journal)).to be(false)
    expect(profile.supports_executor?(:journaled_inline)).to be(false)
  end

  it "builds an environment from a named preset" do
    environment = Igniter::Extensions::Contracts.with_preset(:commerce)

    result = environment.run(inputs: {
      order: { items: [{ amount: 10 }, { amount: 20 }] },
      tax_rate: 0.2
    }) do
      input :order
      input :tax_rate
      order_items from: :order
      subtotal from: :items
      tax_amount amount: :subtotal, rate: :tax_rate
      grand_total subtotal: :subtotal, tax: :tax
      output :grand_total
    end

    expect(result.output(:grand_total)).to eq(36.0)
  end

  it "exposes provenance helpers over execution results" do
    environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::ProvenancePack)

    result = environment.run(inputs: { amount: 10 }) do
      input :amount
      compute :tax, depends_on: [:amount] do |amount:|
        amount * 0.2
      end
      output :tax
    end

    lineage = Igniter::Extensions::Contracts.lineage(result, :tax)

    expect(lineage.contributing_inputs).to eq(amount: 10)
    expect(Igniter::Extensions::Contracts.explain(result, :tax)).to include("tax = 2.0  [compute]")
  end

  it "exposes saga helpers over environments" do
    environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::SagaPack)
    compensations = Igniter::Extensions::Contracts.build_compensations do
      compensate(:amount) { |**| }
    end

    result = Igniter::Extensions::Contracts.run_saga(
      environment,
      inputs: { amount: 10 },
      compensations: compensations
    ) do
      input :amount
      output :amount
    end

    expect(result.success?).to eq(true)
    expect(result.output(:amount)).to eq(10)
  end

  it "exposes incremental session helpers over environments" do
    environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::IncrementalPack)

    session = Igniter::Extensions::Contracts.build_incremental_session(environment) do
      input :amount
      compute :tax, depends_on: [:amount] do |amount:|
        amount * 0.2
      end
      output :tax
    end

    session.run(inputs: { amount: 10 })
    result = session.run(inputs: { amount: 10 })

    expect(result.fully_memoized?).to eq(true)
    expect(result.output(:tax)).to eq(2.0)
  end

  it "exposes dataflow session helpers over environments" do
    environment = Igniter::Extensions::Contracts.with(
      Igniter::Extensions::Contracts::DataflowPack,
      Igniter::Extensions::Contracts::IncrementalPack
    )

    session = Igniter::Extensions::Contracts.build_dataflow_session(
      environment,
      source: :readings,
      key: :sensor_id
    ) do
      item do
        input :sensor_id
        input :value
        output :value
      end

      count :total
    end

    result = session.run(inputs: { readings: [{ sensor_id: "s1", value: 10 }] })

    expect(result.total).to eq(1)
    expect(result.processed.keys).to eq(["s1"])
  end

  it "exposes debug helpers over environments and profiles" do
    environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::DebugPack)

    profile_snapshot = Igniter::Extensions::Contracts.debug_profile(environment)
    pack_snapshot = Igniter::Extensions::Contracts.debug_pack(:extensions_debug, environment)

    report = Igniter::Extensions::Contracts.debug_report(environment, inputs: { amount: 10 }) do
      input :amount
      output :amount
    end

    expect(profile_snapshot.pack_names).to include(:extensions_debug)
    expect(pack_snapshot.name).to eq(:extensions_debug)
    expect(report.execution_result.output(:amount)).to eq(10)
  end

  it "exposes pack audit helpers for custom packs" do
    environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::DebugPack)

    pack = Module.new do
      module_function

      def manifest
        Igniter::Contracts::PackManifest.new(
          name: :draft_pack,
          node_contracts: [Igniter::Contracts::PackManifest.node(:draft_node)]
        )
      end

      def install_into(kernel)
        kernel
      end
    end

    audit = Igniter::Extensions::Contracts.audit_pack(pack, environment)

    expect(audit.ok?).to eq(false)
    expect(audit.missing_node_definitions).to eq([:draft_node])
  end

  it "exposes creator scaffold and report helpers" do
    environment = Igniter::Extensions::Contracts.with(Igniter::Extensions::Contracts::CreatorPack)

    scaffold = Igniter::Extensions::Contracts.scaffold_pack(name: :slug, profile: :feature_node, scope: :monorepo_package)
    report = Igniter::Extensions::Contracts.creator_report(name: :slug, profile: :feature_node, scope: :monorepo_package, target: environment)
    workflow = Igniter::Extensions::Contracts.creator_workflow(name: :slug, profile: :feature_node, scope: :monorepo_package, target: environment)
    writer = Igniter::Extensions::Contracts.creator_writer(name: :slug, profile: :feature_node, scope: :monorepo_package, root: Dir.pwd)

    expect(scaffold.pack_constant).to eq("MyCompany::IgniterPacks::SlugPack")
    expect(Igniter::Extensions::Contracts.creator_profiles).to include(:feature_node)
    expect(Igniter::Extensions::Contracts.creator_scopes).to include(:monorepo_package)
    expect(report.to_h.fetch(:quality_bar).fetch(:includes_spec)).to eq(true)
    expect(workflow.current_stage.key).to eq(:implement_pack)
    expect(writer.plan.to_h.fetch(:steps).any? { |step| step.fetch(:kind) == :file }).to eq(true)
    expect(environment.profile.pack_names).to include(:extensions_creator, :extensions_debug)
  end
end
