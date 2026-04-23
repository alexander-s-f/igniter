# frozen_string_literal: true

require "tmpdir"

require_relative "../../../spec_helper"

RSpec.describe Igniter::Extensions::Contracts::McpPack do
  it "installs debug and creator dependency packs" do
    profile = Igniter::Extensions::Contracts.build_profile(described_class)

    expect(profile.pack_names).to include(:extensions_mcp, :extensions_debug, :extensions_creator)
  end

  it "publishes a tooling catalog" do
    names = described_class.tool_catalog.map { |tool| tool.fetch(:name) }

    expect(names).to include(
      :inspect_profile,
      :audit_pack,
      :creator_wizard,
      :creator_workflow,
      :creator_write_plan,
      :creator_write
    )
  end

  it "invokes creator and debug surfaces through a stable result envelope" do
    environment = Igniter::Extensions::Contracts.with(described_class)

    wizard_result = Igniter::Extensions::Contracts.mcp_call(
      :creator_wizard,
      target: environment,
      name: :delivery,
      capabilities: %i[effect executor]
    )

    debug_result = Igniter::Extensions::Contracts.mcp_call(
      :debug_report,
      target: environment,
      inputs: { amount: 10 }
    ) do
      input :amount
      output :amount
    end

    expect(wizard_result.to_h.fetch(:payload).fetch(:pending_decisions).first.fetch(:key)).to eq(:scope)
    expect(debug_result.to_h.fetch(:payload).fetch(:execution).fetch(:outputs).fetch(:amount)).to eq(10)
  end

  it "can plan and write scaffolds through MCP-oriented creator tools" do
    Dir.mktmpdir("igniter-mcp-pack") do |dir|
      plan = Igniter::Extensions::Contracts.mcp_call(
        :creator_write_plan,
        name: :slug,
        profile: :feature_node,
        scope: :app_local,
        root: dir
      )

      write = Igniter::Extensions::Contracts.mcp_call(
        :creator_write,
        name: :slug,
        profile: :feature_node,
        scope: :app_local,
        root: dir
      )

      expect(plan.to_h.fetch(:mutating)).to eq(false)
      expect(write.to_h.fetch(:mutating)).to eq(true)
      expect(write.to_h.fetch(:payload).fetch(:files_written)).to eq(4)
    end
  end
end
