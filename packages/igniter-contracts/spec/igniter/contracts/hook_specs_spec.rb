# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Contracts::HookSpecs do
  it "declares hook roles and return policies for mature seams" do
    normalizer = described_class.fetch(:normalizers)
    validator = described_class.fetch(:validators)
    runtime_handler = described_class.fetch(:runtime_handlers)

    expect(normalizer.role).to eq(:graph_transformer)
    expect(normalizer.return_policy).to eq(:operations_array)
    expect(validator.role).to eq(:validator)
    expect(validator.return_policy).to eq(:ignored)
    expect(runtime_handler.role).to eq(:runtime_handler)
    expect(runtime_handler.return_policy).to eq(:value)
  end
end
