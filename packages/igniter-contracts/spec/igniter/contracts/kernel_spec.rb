# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Contracts::Kernel do
  it "installs the baseline pack through build_kernel" do
    kernel = Igniter::Contracts.build_kernel

    expect(kernel.nodes.fetch(:input)).to be_a(Igniter::Contracts::NodeType)
    expect(kernel.nodes.fetch(:input).kind).to eq(:input)
    expect(kernel.nodes.fetch(:const).kind).to eq(:const)
    expect(kernel.nodes.fetch(:effect).kind).to eq(:effect)
    expect(kernel.dsl_keywords.fetch(:compute)).to be_a(Igniter::Contracts::DslKeyword)
    expect(kernel.dsl_keywords.fetch(:effect)).to be_a(Igniter::Contracts::DslKeyword)
    expect(kernel.runtime_handlers.fetch(:output)).to respond_to(:call)
  end

  it "installs additional packs directly through build_kernel" do
    kernel = Igniter::Contracts.build_kernel(Igniter::Contracts::ProjectPack)

    expect(kernel.nodes.fetch(:const).kind).to eq(:const)
    expect(kernel.dsl_keywords.fetch(:project)).to be_a(Igniter::Contracts::DslKeyword)
  end

  it "finalizes into an immutable profile" do
    kernel = Igniter::Contracts.build_kernel

    profile = kernel.finalize

    expect(profile).to be_a(Igniter::Contracts::Profile)
    expect(profile.supports_node_kind?(:const)).to be(true)
    expect(profile.supports_node_kind?(:branch)).to be(false)
    expect(profile.normalizers.map(&:key)).to include(:normalize_operation_attributes)
    expect(profile.pack_names).to eq([:baseline])
    expect(profile.fingerprint).not_to be_empty
    expect(kernel).to be_finalized
  end

  it "rejects pack installation after finalization" do
    kernel = Igniter::Contracts.build_kernel
    kernel.finalize

    expect { kernel.install(Igniter::Contracts::BaselinePack) }
      .to raise_error(Igniter::Contracts::FrozenKernelError, /kernel already finalized/)
  end

  it "memoizes default kernel and profile until reset" do
    first_kernel = Igniter::Contracts.default_kernel
    first_profile = Igniter::Contracts.default_profile

    expect(Igniter::Contracts.default_kernel).to equal(first_kernel)
    expect(Igniter::Contracts.default_profile).to equal(first_profile)

    Igniter::Contracts.reset_defaults!

    expect(Igniter::Contracts.default_kernel).not_to equal(first_kernel)
    expect(Igniter::Contracts.default_profile).not_to equal(first_profile)
  end

  it "allows explicit kernels to install additional packs before finalization" do
    kernel = Igniter::Contracts.build_kernel.install(Igniter::Contracts::ProjectPack)

    expect(kernel.nodes.registered?(:project)).to be(false)
    expect(kernel.dsl_keywords.fetch(:project)).to be_a(Igniter::Contracts::DslKeyword)
    expect(kernel.dsl_keywords.fetch(:const)).to be_a(Igniter::Contracts::DslKeyword)
  end

  it "builds a finalized profile through build_profile" do
    profile = Igniter::Contracts.build_profile(Igniter::Contracts::ProjectPack)

    expect(profile).to be_a(Igniter::Contracts::Profile)
    expect(profile.pack_names).to eq(%i[baseline project])
  end
end
