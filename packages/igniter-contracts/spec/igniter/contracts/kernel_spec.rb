# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Contracts::Kernel do
  it "installs the baseline pack through build_kernel" do
    kernel = Igniter::Contracts.build_kernel

    expect(kernel.nodes.fetch(:input)).to eq(:baseline_input_node)
    expect(kernel.dsl_keywords.fetch(:compute)).to eq(:baseline_compute_keyword)
    expect(kernel.runtime_handlers.fetch(:output)).to eq(:baseline_output_runtime_handler)
  end

  it "finalizes into an immutable profile" do
    kernel = Igniter::Contracts.build_kernel

    profile = kernel.finalize

    expect(profile).to be_a(Igniter::Contracts::Profile)
    expect(profile.supports_node_kind?(:branch)).to be(true)
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
end
