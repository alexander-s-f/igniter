# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Contracts::Profile do
  it "exposes installed pack names from finalized manifests" do
    profile = Igniter::Contracts.build_kernel
                               .install(Igniter::Contracts::ConstPack)
                               .install(Igniter::Contracts::ProjectPack)
                               .finalize

    expect(profile.pack_names).to eq(%i[baseline const project])
  end

  it "answers declared registry capabilities from installed pack manifests" do
    profile = Igniter::Contracts.build_kernel
                               .install(Igniter::Contracts::ProjectPack)
                               .finalize

    expect(profile.pack_manifest(:project)).not_to be_nil
    expect(profile.declared_registry_keys(:validators)).to include(:project_sources)
    expect(profile.declared_registry_keys(:diagnostics_contributors)).to include(:baseline_summary)
  end
end
