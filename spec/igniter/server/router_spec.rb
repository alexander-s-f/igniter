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

  describe "custom application routes" do
    before do
      config.custom_routes = [
        {
          method: "POST",
          path: "/webhook",
          handler: lambda do |params:, body:, headers:, raw_body:, **|
            {
              status: 200,
              body: {
                ok: true,
                params: params,
                body: body,
                raw_size: raw_body.bytesize,
                secret: headers["X-Test-Secret"]
              },
              headers: { "Content-Type" => "application/json" }
            }
          end
        }
      ]
    end

    it "dispatches to a custom route handler" do
      result = router.call(
        "POST",
        "/webhook",
        JSON.generate({ "ping" => "pong" }),
        headers: { "X-Test-Secret" => "abc123" }
      )

      expect(result[:status]).to eq(200)
      data = JSON.parse(result[:body])
      expect(data).to include(
        "ok" => true,
        "body" => { "ping" => "pong" },
        "raw_size" => 15,
        "secret" => "abc123"
      )
    end

    it "matches routes before query string" do
      result = router.call("POST", "/webhook?token=1", JSON.generate({}))
      expect(result[:status]).to eq(200)
    end

    it "provides a normalized env hash to custom route handlers" do
      received_env = nil
      config.custom_routes = [
        {
          method: "GET",
          path: "/env-check",
          handler: lambda do |env:, **|
            received_env = env
            { status: 200, body: { ok: true }, headers: { "Content-Type" => "application/json" } }
          end
        }
      ]

      result = router.call(
        "GET",
        "/env-check?token=abc",
        "",
        headers: { "X-Test-Secret" => "abc123" }
      )

      expect(result[:status]).to eq(200)
      expect(received_env).to include(
        "REQUEST_METHOD" => "GET",
        "PATH_INFO" => "/env-check",
        "QUERY_STRING" => "token=abc",
        "HTTP_X_TEST_SECRET" => "abc123"
      )
      expect(received_env.fetch("rack.input").read).to eq("")
    end

    it "parses application/x-www-form-urlencoded bodies for custom routes" do
      result = router.call(
        "POST",
        "/webhook",
        "task=Pay+rent&timing=tomorrow&chat_id=12345",
        headers: { "Content-Type" => "application/x-www-form-urlencoded; charset=utf-8" }
      )

      data = JSON.parse(result[:body])
      expect(data["body"]).to include(
        "task" => "Pay rent",
        "timing" => "tomorrow",
        "chat_id" => "12345"
      )
    end

    it "runs before, around, and after hooks around custom routes" do
      calls = []
      config.before_request_hooks = [
        lambda do |request:|
          calls << [:before, request[:path]]
          request[:body]["extra"] = "from-before"
        end
      ]
      config.around_request_hooks = [
        lambda do |request:, &inner|
          calls << [:around_before, request[:path]]
          result = inner.call
          calls << [:around_after, request[:path]]
          result
        end
      ]
      config.after_request_hooks = [
        lambda do |request:, response:|
          calls << [:after, response[:status]]
          response[:headers]["X-Hook"] = "after"
        end
      ]

      result = router.call("POST", "/webhook", JSON.generate({ "ping" => "pong" }))

      expect(result[:status]).to eq(200)
      expect(result[:headers]["X-Hook"]).to eq("after")
      data = JSON.parse(result[:body])
      expect(data["body"]).to include("ping" => "pong", "extra" => "from-before")
      expect(calls).to eq([
        [:before, "/webhook"],
        [:around_before, "/webhook"],
        [:around_after, "/webhook"],
        [:after, 200]
      ])
    end

    it "allows around hooks to short-circuit custom route handling" do
      config.around_request_hooks = [
        lambda do |request:, &inner|
          {
            status: 202,
            body: { intercepted: true, path: request[:path] },
            headers: { "Content-Type" => "application/json" }
          }
        end
      ]

      result = router.call("POST", "/webhook", JSON.generate({ "ping" => "pong" }))

      expect(result[:status]).to eq(202)
      expect(JSON.parse(result[:body])).to include("intercepted" => true, "path" => "/webhook")
    end
  end

  describe "invalid JSON body" do
    it "returns 400" do
      result = router.call("POST", "/v1/contracts/AddOne/execute", "not-json{")
      expect(result[:status]).to eq(400)
    end
  end
end
