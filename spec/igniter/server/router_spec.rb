# frozen_string_literal: true

require "spec_helper"
require "igniter/server"

RSpec.describe Igniter::Server::Router do
  let(:store)    { Igniter::Runtime::Stores::MemoryStore.new }
  let(:config) do
    cfg = Igniter::Server::Config.new
    cfg.store = store
    cfg
  end
  subject(:router) { described_class.new(config) }

  let(:contract_class) do
    Class.new(Igniter::Contract) do
      define { input :x; compute :y, depends_on: :x, call: ->(x:) { x + 1 }; output :y }
    end
  end

  before { config.register("AddOne", contract_class) }

  describe "GET /v1/health" do
    it "returns 200 with health data" do
      result = router.call("GET", "/v1/health", "")
      expect(result[:status]).to eq(200)
      data = JSON.parse(result[:body])
      expect(data["status"]).to eq("ok")
    end
  end

  describe "GET /v1/contracts" do
    it "returns the list of registered contracts" do
      result = router.call("GET", "/v1/contracts", "")
      expect(result[:status]).to eq(200)
      data = JSON.parse(result[:body])
      names = data.map { |c| c["name"] }
      expect(names).to include("AddOne")
    end
  end

  describe "POST /v1/contracts/:name/execute" do
    it "executes a contract and returns outputs" do
      body = JSON.generate({ "inputs" => { "x" => 10 } })
      result = router.call("POST", "/v1/contracts/AddOne/execute", body)
      expect(result[:status]).to eq(200)
      data = JSON.parse(result[:body])
      expect(data["status"]).to eq("succeeded")
      expect(data["outputs"]["y"]).to eq(11)
    end

    it "returns 404 for unknown contract" do
      body = JSON.generate({ "inputs" => {} })
      result = router.call("POST", "/v1/contracts/Unknown/execute", body)
      expect(result[:status]).to eq(404)
    end
  end

  describe "unknown routes" do
    it "returns 404" do
      result = router.call("GET", "/v1/unknown", "")
      expect(result[:status]).to eq(404)
    end
  end

  describe "invalid JSON body" do
    it "returns 400" do
      result = router.call("POST", "/v1/contracts/AddOne/execute", "not-json{")
      expect(result[:status]).to eq(400)
    end
  end
end
