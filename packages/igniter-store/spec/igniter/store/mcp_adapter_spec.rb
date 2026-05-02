# frozen_string_literal: true

require_relative "../../spec_helper"
require "tmpdir"
require "fileutils"

RSpec.describe Igniter::Store::MCPAdapter do
  subject(:adapter) { described_class.new(store) }
  let(:store)       { Igniter::Store.memory }

  after { store.close rescue nil }

  # ── Construction ─────────────────────────────────────────────────────────────

  describe "construction" do
    it "accepts an IgniterStore" do
      expect { described_class.new(store) }.not_to raise_error
    end

    it "accepts a Protocol::Interpreter directly" do
      proto = Igniter::Store::Protocol.new(store)
      expect { described_class.new(proto) }.not_to raise_error
    end

    it "raises ArgumentError for unsupported input" do
      expect { described_class.new("not_a_store") }.to raise_error(ArgumentError, /MCPAdapter expects/)
    end

    it "defaults to READ_TOOLS only" do
      tools = adapter.tool_list.map { |t| t[:name].to_sym }
      expect(tools).to match_array(described_class::READ_TOOLS)
    end
  end

  # ── tool_list ─────────────────────────────────────────────────────────────────

  describe "#tool_list" do
    it "returns an Array of tool schema hashes" do
      expect(adapter.tool_list).to be_an(Array)
      expect(adapter.tool_list).not_to be_empty
    end

    it "each entry has name, description, input_schema" do
      adapter.tool_list.each do |t|
        expect(t[:name]).to        be_a(String)
        expect(t[:description]).to be_a(String)
        expect(t[:input_schema]).to be_a(Hash)
      end
    end

    it "respects enabled_tools restriction" do
      small = described_class.new(store, enabled_tools: [:read, :query])
      names = small.tool_list.map { |t| t[:name] }
      expect(names).to match_array(%w[read query])
    end
  end

  # ── Response envelope ────────────────────────────────────────────────────────

  describe "response envelope structure" do
    it "ok response includes schema_version, request_id, source_protocol_op, status, result" do
      resp = adapter.call_tool(:metadata_snapshot)
      expect(resp[:schema_version]).to     eq(1)
      expect(resp[:request_id]).to         be_a(String)
      expect(resp[:source_protocol_op]).to eq(:metadata_snapshot)
      expect(resp[:status]).to             eq(:ok)
      expect(resp).to                      have_key(:result)
    end

    it "error response has status: :error and error: key" do
      resp = adapter.call_tool(:unknown_tool)
      expect(resp[:status]).to eq(:error)
      expect(resp[:error]).to  be_a(String)
    end

    it "request_id is echoed when provided in arguments" do
      resp = adapter.call_tool(:metadata_snapshot, request_id: "test_req_1")
      expect(resp[:request_id]).to eq("test_req_1")
    end

    it "auto-generates request_id when not provided" do
      resp = adapter.call_tool(:metadata_snapshot)
      expect(resp[:request_id]).to match(/\Amcp_[0-9a-f]+\z/)
    end
  end

  # ── Read tools ───────────────────────────────────────────────────────────────

  describe "metadata_snapshot tool" do
    it "returns ok status" do
      expect(adapter.call_tool(:metadata_snapshot)[:status]).to eq(:ok)
    end

    it "result includes schema_version" do
      result = adapter.call_tool(:metadata_snapshot)[:result]
      expect(result[:schema_version]).to eq(1)
    end
  end

  describe "descriptor_snapshot tool" do
    it "returns ok status" do
      expect(adapter.call_tool(:descriptor_snapshot)[:status]).to eq(:ok)
    end
  end

  describe "read tool" do
    it "returns the current value for a written key" do
      store.write(store: :tasks, key: "t1", value: { done: false })
      resp = adapter.call_tool(:read, store: "tasks", key: "t1")
      expect(resp[:status]).to  eq(:ok)
      expect(resp[:result]).to  include(done: false)
    end

    it "returns nil result for a missing key" do
      resp = adapter.call_tool(:read, store: "tasks", key: "missing")
      expect(resp[:status]).to  eq(:ok)
      expect(resp[:result]).to  be_nil
    end

    it "returns error when store: is missing" do
      resp = adapter.call_tool(:read, key: "t1")
      expect(resp[:status]).to eq(:error)
    end
  end

  describe "query tool" do
    before do
      store.write(store: :tasks, key: "t1", value: { status: "open",   priority: 1 })
      store.write(store: :tasks, key: "t2", value: { status: "closed", priority: 2 })
      store.write(store: :tasks, key: "t3", value: { status: "open",   priority: 3 })
    end

    it "returns bounded results" do
      resp = adapter.call_tool(:query, store: "tasks", where: {}, limit: 2)
      expect(resp[:status]).to           eq(:ok)
      expect(resp[:result].size).to      eq(2)
    end

    it "applies where: filter" do
      resp = adapter.call_tool(:query, store: "tasks",
                                where: { status: "open" }, limit: 10)
      expect(resp[:result].all? { |v| v[:status] == "open" }).to be true
    end

    it "returns error when limit: is missing" do
      resp = adapter.call_tool(:query, store: "tasks", where: {})
      expect(resp[:status]).to eq(:error)
      expect(resp[:error]).to  match(/limit/)
    end
  end

  describe "replay tool" do
    before do
      2.times { |i| store.write(store: :events, key: "e#{i}", value: { n: i }) }
    end

    it "replays facts bounded by store:" do
      resp = adapter.call_tool(:replay, store: "events")
      expect(resp[:status]).to           eq(:ok)
      expect(resp[:result][:count]).to   eq(2)
      expect(resp[:result][:facts]).to   be_an(Array)
    end

    it "applies limit:" do
      resp = adapter.call_tool(:replay, store: "events", limit: 1)
      expect(resp[:result][:count]).to eq(1)
    end

    it "returns error when no bounding argument given" do
      resp = adapter.call_tool(:replay)
      expect(resp[:status]).to eq(:error)
      expect(resp[:error]).to  match(/bounding/)
    end
  end

  # ── storage_stats and segment_manifest (in-memory returns nil) ────────────────

  describe "storage_stats tool (in-memory store)" do
    it "returns ok with nil result for in-memory backend" do
      resp = adapter.call_tool(:storage_stats)
      expect(resp[:status]).to      eq(:ok)
      expect(resp[:result]).to      be_nil
      expect(resp[:source_protocol_op]).to eq(:storage_stats)
    end
  end

  describe "storage_stats tool (segmented backend)" do
    let(:tmpdir) { Dir.mktmpdir("mcp-adapter-spec-") }
    let(:seg)    { Igniter::Store.segmented(tmpdir) }
    let(:seg_adapter) { described_class.new(seg) }

    after do
      seg.close rescue nil
      FileUtils.rm_rf(tmpdir)
    end

    it "returns storage stats with stores key" do
      seg.write(store: :readings, key: "k1", value: { v: 1 })
      resp = seg_adapter.call_tool(:storage_stats, store: "readings")

      expect(resp[:status]).to                           eq(:ok)
      expect(resp[:result]["stores"].keys).to            include("readings")
      expect(resp[:result]["stores"]["readings"]["fact_count"]).to eq(1)
    end

    it "segment_manifest returns segments array" do
      seg.write(store: :readings, key: "k1", value: { v: 1 })
      resp = seg_adapter.call_tool(:segment_manifest, store: "readings")

      expect(resp[:status]).to eq(:ok)
      expect(resp[:result]["stores"]["readings"]["segments"]).to be_an(Array)
    end
  end

  # ── Disabled tool safety ──────────────────────────────────────────────────────

  describe "disabled tool safety" do
    it "returns error for a tool not in enabled_tools" do
      restricted = described_class.new(store, enabled_tools: [:read])
      resp = restricted.call_tool(:query, store: "tasks", limit: 10)
      expect(resp[:status]).to eq(:error)
      expect(resp[:error]).to  match(/not enabled/)
    end
  end

  # ── MCP adapter conformance: embedded equals wire dispatch ────────────────────

  describe "embedded MCP result matches wire dispatch" do
    it "metadata_snapshot result agrees with wire dispatch" do
      mcp_result  = adapter.call_tool(:metadata_snapshot)[:result]
      wire_result = Igniter::Store::Protocol.new(store)
                      .wire.dispatch({
                        protocol: :igniter_store, schema_version: 1,
                        request_id: "r1", op: :metadata_snapshot, packet: {}
                      })[:result]
      expect(mcp_result[:schema_version]).to eq(wire_result[:schema_version])
      expect(mcp_result[:stores]).to         eq(wire_result[:stores])
    end
  end
end
