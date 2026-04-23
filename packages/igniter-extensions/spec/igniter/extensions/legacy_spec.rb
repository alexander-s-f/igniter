# frozen_string_literal: true

require_relative "../../spec_helper"
require "igniter/extensions/legacy"

RSpec.describe Igniter::Extensions::Legacy do
  it "publishes a replacement map for legacy extension activators" do
    expect(described_class.entrypoints).to include(
      "igniter/extensions/auditing",
      "igniter/extensions/differential",
      "igniter/extensions/execution_report",
      "igniter/extensions/dataflow",
      "igniter/extensions/reactive",
      "igniter/extensions/saga"
    )

    expect(described_class.replacement_for("igniter/extensions/execution_report"))
      .to eq("Igniter::Extensions::Contracts::ExecutionReportPack")
    expect(described_class.replacement_for("igniter/extensions/execution_report.rb"))
      .to eq("Igniter::Extensions::Contracts::ExecutionReportPack")
    expect(described_class.replacement_for("igniter/extensions/dataflow"))
      .to eq("Igniter::Extensions::Contracts::DataflowPack")
    expect(described_class.replacement_for("igniter/extensions/auditing"))
      .to eq("Igniter::Extensions::Contracts::AuditPack")
    expect(described_class.replacement_for("igniter/extensions/differential"))
      .to eq("Igniter::Extensions::Contracts::DifferentialPack")
    expect(described_class.replacement_for("igniter/extensions/reactive"))
      .to eq("Igniter::Extensions::Contracts::ReactivePack")
  end

  it "bakes the replacement guidance into the warning message" do
    message = described_class.message_for("igniter/extensions/execution_report", replacement: nil)

    expect(message).to include("legacy core-backed extension activator")
    expect(message).to include("Igniter::Extensions::Contracts::ExecutionReportPack")
    expect(message).to include("igniter/extensions/contracts")
  end
end
