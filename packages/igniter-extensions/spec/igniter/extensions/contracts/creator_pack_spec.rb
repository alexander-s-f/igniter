# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe Igniter::Extensions::Contracts::CreatorPack do
  module DraftCreatorPack
    module_function

    def manifest
      Igniter::Contracts::PackManifest.new(
        name: :draft_creator_pack,
        node_contracts: [Igniter::Contracts::PackManifest.node(:draft)],
        registry_contracts: [Igniter::Contracts::PackManifest.validator(:draft_sources)]
      )
    end

    def install_into(kernel)
      kernel
    end
  end

  it "installs DebugPack as a dependency" do
    profile = Igniter::Extensions::Contracts.build_profile(described_class)

    expect(profile.pack_names).to include(:extensions_creator, :extensions_debug)
  end

  it "builds a feature scaffold with pack/spec/example/readme templates" do
    scaffold = Igniter::Extensions::Contracts.scaffold_pack(
      name: :slug,
      kind: :feature,
      namespace: "Acme::IgniterPacks"
    )

    expect(scaffold.pack_constant).to eq("Acme::IgniterPacks::SlugPack")
    expect(scaffold.files.keys).to eq([
      "lib/acme/igniter_packs/slug_pack.rb",
      "spec/acme/igniter_packs/slug_pack_spec.rb",
      "examples/slug_pack.rb",
      "README.md"
    ])
    expect(scaffold.files.fetch("lib/acme/igniter_packs/slug_pack.rb")).to include("PackManifest.node(:slug)")
    expect(scaffold.files.fetch("examples/slug_pack.rb")).to include("audit_pack")
  end

  it "builds an operational scaffold with effect/executor templates" do
    scaffold = Igniter::Extensions::Contracts.scaffold_pack(
      name: :audit_trail,
      kind: :operational,
      namespace: "Acme::IgniterPacks"
    )

    expect(scaffold.files.fetch("lib/acme/igniter_packs/audit_trail_pack.rb")).to include("PackManifest.effect(:audit_trail)")
    expect(scaffold.files.fetch("lib/acme/igniter_packs/audit_trail_pack.rb")).to include("PackManifest.executor(:audit_trail_inline)")
  end

  it "builds a creator report and includes audit feedback when a pack is provided" do
    environment = Igniter::Extensions::Contracts.with(described_class)

    report = Igniter::Extensions::Contracts.creator_report(
      name: :draft,
      kind: :feature,
      namespace: "Acme::IgniterPacks",
      pack: DraftCreatorPack,
      target: environment
    )

    expect(report.scaffold.pack_constant).to eq("Acme::IgniterPacks::DraftPack")
    expect(report.audit.ok?).to eq(false)
    expect(report.next_steps).to include("use Igniter::Extensions::Contracts.audit_pack(...) before finalize")
    expect(report.to_h.fetch(:quality_bar).fetch(:includes_example)).to eq(true)
  end
end
