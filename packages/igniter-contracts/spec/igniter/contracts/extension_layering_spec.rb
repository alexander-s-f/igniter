# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Igniter::Contracts extension layering" do
  it "locates experimental packs under Assembly" do
    expect(Igniter::Contracts::Assembly::ConstPack).to equal(Igniter::Contracts::ConstPack)
    expect(Igniter::Contracts::Assembly::ProjectPack).to equal(Igniter::Contracts::ProjectPack)
  end

  it "locates extension execution helpers under Execution" do
    expect(Igniter::Contracts::Execution::ConstRuntime).to equal(Igniter::Contracts::ConstRuntime)
    expect(Igniter::Contracts::Execution::ProjectValidators).to equal(Igniter::Contracts::ProjectValidators)
    expect(Igniter::Contracts::Execution::ProjectRuntime).to equal(Igniter::Contracts::ProjectRuntime)
  end
end
