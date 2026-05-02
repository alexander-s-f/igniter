# frozen_string_literal: true

require_relative "../../../spec_helper"

RSpec.describe "OP3 — Wire Envelope" do
  subject(:proto) { Igniter::Store::Protocol.new }
  let(:wire)      { proto.wire }

  def envelope(op, packet = {}, request_id: "req_#{SecureRandom.hex(4)}")
    {
      protocol:       :igniter_store,
      schema_version: 1,
      request_id:     request_id,
      op:             op,
      packet:         packet
    }
  end

  # ------------------------------------------------------------------ WireEnvelope accessor

  describe "Interpreter#wire + Interpreter#dispatch" do
    it "wire returns a WireEnvelope" do
      expect(wire).to be_a(Igniter::Store::Protocol::WireEnvelope)
    end

    it "wire is memoized" do
      expect(proto.wire).to be(proto.wire)
    end

    it "dispatch is a shorthand for wire.dispatch" do
      env = envelope(:metadata_snapshot)
      expect(proto.dispatch(env)).to eq(wire.dispatch(env))
    end
  end

  # ------------------------------------------------------------------ Response envelope contract

  describe "response envelope structure" do
    it "ok response carries protocol, schema_version, request_id, status: :ok, result:" do
      resp = wire.dispatch(envelope(:metadata_snapshot, {}, request_id: "req_abc"))
      expect(resp[:protocol]).to       eq(:igniter_store)
      expect(resp[:schema_version]).to eq(1)
      expect(resp[:request_id]).to     eq("req_abc")
      expect(resp[:status]).to         eq(:ok)
      expect(resp).to                  have_key(:result)
    end

    it "error response carries status: :error and error: message" do
      resp = wire.dispatch({ protocol: :igniter_store, schema_version: 1,
                             request_id: "req_xyz", op: :unknown_op, packet: {} })
      expect(resp[:status]).to  eq(:error)
      expect(resp[:error]).to   match(/unknown_op/)
      expect(resp[:request_id]).to eq("req_xyz")
    end

    it "echoes request_id even on error" do
      resp = wire.dispatch({ protocol: :other_protocol, request_id: "req_111", op: :write })
      expect(resp[:request_id]).to eq("req_111")
      expect(resp[:status]).to     eq(:error)
    end
  end

  # ------------------------------------------------------------------ Protocol validation

  describe "protocol validation" do
    it "rejects unknown protocol" do
      resp = wire.dispatch(envelope(:write).merge(protocol: :unknown))
      expect(resp[:status]).to eq(:error)
      expect(resp[:error]).to  match(/protocol/i)
    end

    it "rejects missing op" do
      resp = wire.dispatch({ protocol: :igniter_store, schema_version: 1,
                             request_id: "r1", packet: {} })
      expect(resp[:status]).to eq(:error)
      expect(resp[:error]).to  match(/op/i)
    end

    it "rejects unknown op" do
      resp = wire.dispatch(envelope(:teleport))
      expect(resp[:status]).to eq(:error)
      expect(resp[:error]).to  match(/teleport/)
    end
  end

  # ------------------------------------------------------------------ op: :register_descriptor

  describe "op: :register_descriptor" do
    it "accepts and routes a store descriptor" do
      resp = wire.dispatch(envelope(:register_descriptor, {
        schema_version: 1, kind: :store, name: :tasks, key: :id, fields: []
      }))
      expect(resp[:status]).to         eq(:ok)
      expect(resp[:result].accepted?).to be true
      expect(resp[:result].name).to    eq(:tasks)
    end

    it "rejects an invalid descriptor and returns :ok with rejected receipt" do
      resp = wire.dispatch(envelope(:register_descriptor, {
        schema_version: 1, kind: :store, fields: []  # missing name and key
      }))
      expect(resp[:status]).to           eq(:ok)
      expect(resp[:result].rejected?).to be true
    end
  end

  # ------------------------------------------------------------------ op: :write

  describe "op: :write" do
    it "writes a fact and returns a write receipt" do
      resp = wire.dispatch(envelope(:write, {
        store: :tasks, key: "t1", value: { id: "t1", status: :open }
      }))
      expect(resp[:status]).to           eq(:ok)
      expect(resp[:result].accepted?).to be true
      expect(resp[:result].fact_id).not_to be_nil
    end

    it "returns error when store: is missing" do
      resp = wire.dispatch(envelope(:write, { key: "t1", value: {} }))
      expect(resp[:status]).to eq(:error)
    end
  end

  # ------------------------------------------------------------------ op: :write_fact

  describe "op: :write_fact" do
    it "writes a fact packet and returns a write receipt" do
      resp = wire.dispatch(envelope(:write_fact, {
        kind: :fact, store: :tasks, key: "t1",
        value: { id: "t1", status: :open },
        producer: { system: :external_client }
      }))
      expect(resp[:status]).to           eq(:ok)
      expect(resp[:result].accepted?).to be true
      expect(resp[:result].store).to     eq(:tasks)
    end

    it "returns ok status with rejected receipt for wrong kind" do
      resp = wire.dispatch(envelope(:write_fact, {
        kind: :store, store: :tasks, key: "t1", value: {}
      }))
      expect(resp[:status]).to           eq(:ok)
      expect(resp[:result].rejected?).to be true
    end
  end

  # ------------------------------------------------------------------ op: :read

  describe "op: :read" do
    before do
      wire.dispatch(envelope(:write, { store: :tasks, key: "t1", value: { status: :open } }))
    end

    it "returns found: true and value when key exists" do
      resp = wire.dispatch(envelope(:read, { store: :tasks, key: "t1" }))
      expect(resp[:status]).to           eq(:ok)
      expect(resp[:result][:found]).to   be true
      expect(resp[:result][:value]).to   include(status: :open)
    end

    it "returns found: false when key does not exist" do
      resp = wire.dispatch(envelope(:read, { store: :tasks, key: "missing" }))
      expect(resp[:status]).to           eq(:ok)
      expect(resp[:result][:found]).to   be false
      expect(resp[:result][:value]).to   be_nil
    end

    it "returns error when store: is missing" do
      resp = wire.dispatch(envelope(:read, { key: "t1" }))
      expect(resp[:status]).to eq(:error)
    end
  end

  # ------------------------------------------------------------------ op: :query

  describe "op: :query" do
    before do
      wire.dispatch(envelope(:write, { store: :tasks, key: "t1", value: { status: :open } }))
      wire.dispatch(envelope(:write, { store: :tasks, key: "t2", value: { status: :done } }))
      wire.dispatch(envelope(:write, { store: :tasks, key: "t3", value: { status: :open } }))
    end

    it "returns results and count" do
      resp = wire.dispatch(envelope(:query, { store: :tasks, where: { status: :open } }))
      expect(resp[:status]).to          eq(:ok)
      expect(resp[:result][:count]).to  eq(2)
      expect(resp[:result][:results]).to all(include(status: :open))
    end

    it "returns all records when where: is empty" do
      resp = wire.dispatch(envelope(:query, { store: :tasks }))
      expect(resp[:result][:count]).to eq(3)
    end

    it "returns error when store: is missing" do
      resp = wire.dispatch(envelope(:query, { where: {} }))
      expect(resp[:status]).to eq(:error)
    end
  end

  # ------------------------------------------------------------------ op: :resolve

  describe "op: :resolve" do
    before do
      wire.dispatch(envelope(:register_descriptor, {
        schema_version: 1, kind: :relation,
        name: :project_tasks,
        from: { store: :projects, key: :id },
        to:   { store: :tasks, field: :project_id },
        cardinality: :many
      }))
      wire.dispatch(envelope(:write, { store: :tasks, key: "t1", value: { project_id: "p1", title: "Alpha" } }))
      wire.dispatch(envelope(:write, { store: :tasks, key: "t2", value: { project_id: "p1", title: "Beta" } }))
    end

    it "returns resolved source records as results + count" do
      resp = wire.dispatch(envelope(:resolve, { relation: :project_tasks, from: "p1" }))
      expect(resp[:status]).to         eq(:ok)
      expect(resp[:result][:count]).to eq(2)
      expect(resp[:result][:results].map { |v| v[:title] }).to contain_exactly("Alpha", "Beta")
    end

    it "returns empty results for an unknown partition value" do
      resp = wire.dispatch(envelope(:resolve, { relation: :project_tasks, from: "p99" }))
      expect(resp[:result][:count]).to eq(0)
    end
  end

  # ------------------------------------------------------------------ op: :metadata_snapshot

  describe "op: :metadata_snapshot" do
    before do
      wire.dispatch(envelope(:register_descriptor, {
        schema_version: 1, kind: :store, name: :widgets, key: :id, fields: []
      }))
    end

    it "returns the unified metadata snapshot" do
      resp = wire.dispatch(envelope(:metadata_snapshot))
      expect(resp[:status]).to                       eq(:ok)
      expect(resp[:result][:schema_version]).to      eq(1)
      expect(resp[:result][:stores]).to              have_key(:widgets)
    end
  end

  # ------------------------------------------------------------------ round-trip correlation

  describe "request_id round-trip" do
    it "each response echoes the caller-supplied request_id" do
      ids = %w[req_aaa req_bbb req_ccc]
      responses = ids.map do |id|
        wire.dispatch(envelope(:metadata_snapshot, {}, request_id: id))
      end
      expect(responses.map { |r| r[:request_id] }).to eq(ids)
    end
  end

  # ------------------------------------------------------------------ internal error safety net

  describe "internal error safety net" do
    it "returns error response instead of raising when an op raises unexpectedly" do
      # Force an error by passing a non-symbol relation name to resolve
      resp = wire.dispatch(envelope(:resolve, { relation: nil, from: "x" }))
      expect(resp[:status]).to eq(:error)
      expect(resp[:error]).to  match(/error/i)
    end
  end
end
