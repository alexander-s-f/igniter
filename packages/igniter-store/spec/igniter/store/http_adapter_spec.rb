# frozen_string_literal: true

require_relative "../../spec_helper"
require "stringio"

RSpec.describe Igniter::Store::HTTPAdapter do
  def make_interpreter
    Igniter::Store::Protocol::Interpreter.new(Igniter::Store::IgniterStore.new)
  end

  def make_adapter(interpreter = make_interpreter)
    Igniter::Store::HTTPAdapter.new(interpreter: interpreter)
  end

  def dispatch_env(envelope, path: "/v1/dispatch")
    {
      "REQUEST_METHOD" => "POST",
      "PATH_INFO"      => path,
      "SCRIPT_NAME"    => "",
      "rack.input"     => StringIO.new(JSON.generate(envelope))
    }
  end

  def get_env(path)
    {
      "REQUEST_METHOD" => "GET",
      "PATH_INFO"      => path,
      "SCRIPT_NAME"    => "",
      "rack.input"     => StringIO.new("")
    }
  end

  def base_envelope(op, packet = {})
    {
      protocol:       "igniter_store",
      schema_version: 1,
      request_id:     "test-#{SecureRandom.hex(4)}",
      op:             op,
      packet:         packet
    }
  end

  let(:interpreter) { make_interpreter }
  let(:adapter)     { make_adapter(interpreter) }
  let(:app)         { adapter.rack_app }

  # ── /v1/health ──────────────────────────────────────────────────────────────

  describe "GET /v1/health" do
    it "returns 200 with ready status" do
      status, headers, body = app.call(get_env("/v1/health"))

      expect(status).to eq(200)
      expect(headers["Content-Type"]).to eq("application/json")
      data = JSON.parse(body.join, symbolize_names: true)
      expect(data[:status]).to eq("ready")
      expect(data[:protocol]).to eq("igniter_store")
      expect(data[:schema_version]).to eq(1)
    end

    it "returns 405 for POST /v1/health" do
      env = dispatch_env({}, path: "/v1/health")
      status, _, body = app.call(env)
      expect(status).to eq(405)
      expect(JSON.parse(body.join)["error"]).to match(/not allowed/i)
    end
  end

  # ── /v1/metadata ────────────────────────────────────────────────────────────

  describe "GET /v1/metadata" do
    it "returns 200 with schema_version key" do
      status, headers, body = app.call(get_env("/v1/metadata"))

      expect(status).to eq(200)
      data = JSON.parse(body.join, symbolize_names: true)
      expect(data[:schema_version]).to eq(1)
      expect(data).to have_key(:stores)
      expect(data).to have_key(:histories)
    end

    it "returns 405 for POST /v1/metadata" do
      env = dispatch_env({}, path: "/v1/metadata")
      status, _, _ = app.call(env)
      expect(status).to eq(405)
    end

    it "reflects registered store names" do
      interpreter.register(
        schema_version: 1, kind: :store, name: :tasks, key: :id,
        fields: [{ name: :title, type: :string }]
      )
      _, _, body = app.call(get_env("/v1/metadata"))
      data = JSON.parse(body.join, symbolize_names: true)
      store_names = data[:stores].keys.map(&:to_s)
      expect(store_names).to include("tasks")
    end
  end

  # ── /v1/dispatch ────────────────────────────────────────────────────────────

  describe "POST /v1/dispatch" do
    it "returns 405 for GET /v1/dispatch" do
      status, _, body = app.call(get_env("/v1/dispatch"))
      expect(status).to eq(405)
    end

    it "returns 400 for non-JSON body" do
      env = {
        "REQUEST_METHOD" => "POST",
        "PATH_INFO"      => "/v1/dispatch",
        "SCRIPT_NAME"    => "",
        "rack.input"     => StringIO.new("not json!!!")
      }
      status, _, body = app.call(env)
      expect(status).to eq(400)
      expect(JSON.parse(body.join)["error"]).to match(/invalid json/i)
    end

    it "returns 200 with error status for unknown op" do
      env = dispatch_env(base_envelope("nonexistent_op"))
      status, _, body = app.call(env)
      expect(status).to eq(200)
      data = JSON.parse(body.join, symbolize_names: true)
      expect(data[:status].to_s).to eq("error")
    end

    it "returns 200 with error status for unknown protocol" do
      env = dispatch_env(
        base_envelope("metadata_snapshot").merge(protocol: "wrong_protocol")
      )
      status, _, body = app.call(env)
      expect(status).to eq(200)
      data = JSON.parse(body.join, symbolize_names: true)
      expect(data[:status].to_s).to eq("error")
    end

    context "smoke: register → write → read → query → metadata_snapshot" do
      it "round-trips through all major operations" do
        # register_descriptor
        reg_env = dispatch_env(base_envelope("register_descriptor", {
          schema_version: 1, kind: :store, name: :tasks, key: :id,
          fields: [{ name: :title, type: :string }, { name: :done, type: :boolean }]
        }))
        _, _, body = app.call(reg_env)
        reg = JSON.parse(body.join, symbolize_names: true)
        expect(reg[:status].to_s).to eq("ok")

        # write
        write_env = dispatch_env(base_envelope("write", {
          store: :tasks, key: "t1", value: { title: "Buy milk", done: false }
        }))
        _, _, body = app.call(write_env)
        write_resp = JSON.parse(body.join, symbolize_names: true)
        expect(write_resp[:status].to_s).to eq("ok")

        # read
        read_env = dispatch_env(base_envelope("read", { store: :tasks, key: "t1" }))
        _, _, body = app.call(read_env)
        read_resp = JSON.parse(body.join, symbolize_names: true)
        expect(read_resp[:status].to_s).to eq("ok")
        expect(read_resp[:result][:found]).to be true
        expect(read_resp[:result][:value][:title]).to eq("Buy milk")

        # query
        query_env = dispatch_env(base_envelope("query", {
          store: :tasks, where: { done: false }
        }))
        _, _, body = app.call(query_env)
        query_resp = JSON.parse(body.join, symbolize_names: true)
        expect(query_resp[:status].to_s).to eq("ok")
        expect(query_resp[:result][:count]).to eq(1)

        # metadata_snapshot
        meta_env = dispatch_env(base_envelope("metadata_snapshot"))
        _, _, body = app.call(meta_env)
        meta_resp = JSON.parse(body.join, symbolize_names: true)
        expect(meta_resp[:status].to_s).to eq("ok")
        expect(meta_resp[:result][:schema_version]).to eq(1)
      end
    end

    context "sync_hub_profile" do
      it "returns a sync profile through dispatch" do
        env = dispatch_env(base_envelope("sync_hub_profile", {}))
        _, _, body = app.call(env)
        resp = JSON.parse(body.join, symbolize_names: true)
        expect(resp[:status].to_s).to eq("ok")
        result = resp[:result]
        expect(result[:kind].to_s).to eq("sync_hub_profile")
        expect(result[:schema_version]).to eq(1)
        expect(result).to have_key(:facts)
      end
    end
  end

  # ── unknown path ────────────────────────────────────────────────────────────

  describe "unknown path" do
    it "returns 404 for GET /unknown" do
      status, _, body = app.call(get_env("/unknown"))
      expect(status).to eq(404)
      expect(JSON.parse(body.join)["error"]).to match(/not found/i)
    end

    it "returns 404 for POST /other" do
      env = dispatch_env({}, path: "/other")
      status, _, _ = app.call(env)
      expect(status).to eq(404)
    end
  end

  # ── bind_address ────────────────────────────────────────────────────────────

  describe "#bind_address" do
    it "returns host:port string" do
      a = Igniter::Store::HTTPAdapter.new(interpreter: make_interpreter, port: 7300, host: "0.0.0.0")
      expect(a.bind_address).to eq("0.0.0.0:7300")
    end
  end
end
