# frozen_string_literal: true

require "spec_helper"
require "igniter/cluster"

RSpec.describe "Igniter Mesh — Phase 2: Dynamic Discovery" do
  after { Igniter::Cluster::Mesh.reset! }

  # ─────────────────────────────────────────────────────────────────────────────
  # PeerRegistry
  # ─────────────────────────────────────────────────────────────────────────────
  describe Igniter::Cluster::Mesh::PeerRegistry do
    subject(:registry) { described_class.new }

    let(:peer_a) { Igniter::Cluster::Mesh::Peer.new(name: "orders", url: "http://orders:4567", capabilities: [:orders]) }
    let(:peer_b) { Igniter::Cluster::Mesh::Peer.new(name: "audit",  url: "http://audit:4567",  capabilities: [:audit]) }

    it "starts empty" do
      expect(registry.all).to be_empty
      expect(registry.size).to eq(0)
    end

    it "registers a peer" do
      registry.register(peer_a)
      expect(registry.all).to contain_exactly(peer_a)
      expect(registry.size).to eq(1)
    end

    it "register is idempotent — latest version wins" do
      registry.register(peer_a)
      updated = Igniter::Cluster::Mesh::Peer.new(name: "orders", url: "http://orders-v2:4567", capabilities: [:orders])
      registry.register(updated)
      expect(registry.size).to eq(1)
      expect(registry.peer_named("orders").url).to eq("http://orders-v2:4567")
    end

    it "unregisters a peer by name" do
      registry.register(peer_a)
      registry.unregister("orders")
      expect(registry.all).to be_empty
    end

    it "unregister is a no-op for unknown peers" do
      expect { registry.unregister("ghost") }.not_to raise_error
    end

    it "peers_with_capability filters correctly" do
      registry.register(peer_a)
      registry.register(peer_b)
      expect(registry.peers_with_capability(:orders)).to contain_exactly(peer_a)
      expect(registry.peers_with_capability(:audit)).to contain_exactly(peer_b)
      expect(registry.peers_with_capability(:unknown)).to be_empty
    end

    it "peer_named finds by name" do
      registry.register(peer_a)
      expect(registry.peer_named("orders")).to eq(peer_a)
      expect(registry.peer_named("missing")).to be_nil
    end

    it "peer_named coerces string/symbol" do
      registry.register(peer_a)
      expect(registry.peer_named("orders")).to eq(peer_a)
    end

    it "clear removes all peers" do
      registry.register(peer_a)
      registry.register(peer_b)
      registry.clear
      expect(registry.all).to be_empty
    end

    it "all returns a snapshot (not the live hash)" do
      snapshot = registry.all
      registry.register(peer_a)
      expect(snapshot).to be_empty
    end

    it "is thread-safe under concurrent writes" do
      threads = 50.times.map do |i|
        Thread.new do
          p = Igniter::Cluster::Mesh::Peer.new(name: "peer-#{i}", url: "http://p#{i}:4567")
          registry.register(p)
        end
      end
      threads.each(&:join)
      expect(registry.size).to eq(50)
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Config — new Phase 2 attrs
  # ─────────────────────────────────────────────────────────────────────────────
  describe Igniter::Cluster::Mesh::Config do
    subject(:config) { described_class.new }

    it "defaults seeds to []" do
      expect(config.seeds).to eq([])
    end

    it "defaults discovery_interval to 30" do
      expect(config.discovery_interval).to eq(30)
    end

    it "defaults auto_announce to true" do
      expect(config.auto_announce).to be true
    end

    it "defaults local_url to nil" do
      expect(config.local_url).to be_nil
    end

    it "has a PeerRegistry by default" do
      expect(config.peer_registry).to be_a(Igniter::Cluster::Mesh::PeerRegistry)
    end

    it "allows configuring seeds" do
      config.seeds = %w[http://seed1:4567 http://seed2:4567]
      expect(config.seeds).to eq(%w[http://seed1:4567 http://seed2:4567])
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Announcer
  # ─────────────────────────────────────────────────────────────────────────────
  describe Igniter::Cluster::Mesh::Announcer do
    let(:config) do
      Igniter::Cluster::Mesh::Config.new.tap do |c|
        c.peer_name          = "api-node"
        c.local_url          = "http://api.internal:4567"
        c.local_capabilities = %i[api]
        c.seeds              = %w[http://seed1:4567 http://seed2:4567]
      end
    end
    subject(:announcer) { described_class.new(config) }

    it "POSTs self to every seed on announce_all" do
      client_double = instance_double(Igniter::Server::Client)
      allow(client_double).to receive(:register_peer)
      allow(Igniter::Server::Client).to receive(:new).and_return(client_double)

      announcer.announce_all

      expect(Igniter::Server::Client).to have_received(:new).with("http://seed1:4567", timeout: 5)
      expect(Igniter::Server::Client).to have_received(:new).with("http://seed2:4567", timeout: 5)
      expect(client_double).to have_received(:register_peer).twice.with(
        name: "api-node", url: "http://api.internal:4567", capabilities: %i[api]
      )
    end

    it "swallows ConnectionError on announce" do
      allow(Igniter::Server::Client).to receive(:new)
        .and_raise(Igniter::Server::Client::ConnectionError, "refused")

      expect { announcer.announce_all }.not_to raise_error
    end

    it "is a no-op when peer_name is not set" do
      config.peer_name = nil
      expect(Igniter::Server::Client).not_to receive(:new)
      announcer.announce_all
    end

    it "is a no-op when local_url is not set" do
      config.local_url = nil
      expect(Igniter::Server::Client).not_to receive(:new)
      announcer.announce_all
    end

    it "DELETEs self from every seed on deannounce_all" do
      client_double = instance_double(Igniter::Server::Client)
      allow(client_double).to receive(:unregister_peer)
      allow(Igniter::Server::Client).to receive(:new).and_return(client_double)

      announcer.deannounce_all

      expect(client_double).to have_received(:unregister_peer).twice.with("api-node")
    end

    it "swallows ConnectionError on deannounce" do
      allow(Igniter::Server::Client).to receive(:new)
        .and_raise(Igniter::Server::Client::ConnectionError, "refused")

      expect { announcer.deannounce_all }.not_to raise_error
    end

    it "deannounce is a no-op when peer_name is not set" do
      config.peer_name = nil
      expect(Igniter::Server::Client).not_to receive(:new)
      announcer.deannounce_all
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Poller
  # ─────────────────────────────────────────────────────────────────────────────
  describe Igniter::Cluster::Mesh::Poller do
    let(:config) do
      Igniter::Cluster::Mesh::Config.new.tap do |c|
        c.peer_name          = "api-node"
        c.seeds              = %w[http://seed1:4567]
        c.discovery_interval = 0.05
      end
    end
    subject(:poller) { described_class.new(config) }

    after { poller.stop }

    it "starts not running" do
      expect(poller).not_to be_running
    end

    it "start/stop changes running state" do
      poller.start
      expect(poller).to be_running
      poller.stop
      expect(poller).not_to be_running
    end

    it "start is idempotent" do
      poller.start
      thread_before = poller.instance_variable_get(:@thread)
      poller.start
      expect(poller.instance_variable_get(:@thread)).to be(thread_before)
    end

    it "poll_once registers peers from seeds (excluding self)" do
      client_double = instance_double(Igniter::Server::Client)
      allow(Igniter::Server::Client).to receive(:new).and_return(client_double)
      allow(client_double).to receive(:list_peers).and_return([
        { name: "orders-node", url: "http://orders:4567", capabilities: [:orders] },
        { name: "api-node",    url: "http://api:4567",    capabilities: [:api] }  # self — skipped
      ])

      poller.poll_once

      expect(config.peer_registry.peer_named("orders-node")).not_to be_nil
      expect(config.peer_registry.peer_named("api-node")).to be_nil
    end

    it "poll_once swallows ConnectionError" do
      allow(Igniter::Server::Client).to receive(:new)
        .and_raise(Igniter::Server::Client::ConnectionError, "refused")

      expect { poller.poll_once }.not_to raise_error
    end

    it "poll_once skips peers with nil name or url" do
      client_double = instance_double(Igniter::Server::Client)
      allow(Igniter::Server::Client).to receive(:new).and_return(client_double)
      allow(client_double).to receive(:list_peers).and_return([
        { name: nil, url: "http://x:4567", capabilities: [] },
        { name: "ok", url: nil,            capabilities: [] }
      ])

      poller.poll_once

      expect(config.peer_registry.all).to be_empty
    end

    it "background thread calls poll_once periodically" do
      call_count = 0
      allow(poller).to receive(:poll_once) { call_count += 1 }

      poller.start
      sleep(0.25)
      poller.stop

      expect(call_count).to be >= 2
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Discovery
  # ─────────────────────────────────────────────────────────────────────────────
  describe Igniter::Cluster::Mesh::Discovery do
    let(:config) do
      Igniter::Cluster::Mesh::Config.new.tap do |c|
        c.peer_name = "api-node"
        c.local_url = "http://api:4567"
        c.seeds     = %w[http://seed1:4567]
      end
    end
    subject(:discovery) { described_class.new(config) }

    let(:announcer_double) { instance_double(Igniter::Cluster::Mesh::Announcer, announce_all: nil, deannounce_all: nil) }
    let(:poller_double)    { instance_double(Igniter::Cluster::Mesh::Poller, poll_once: nil, start: nil, stop: nil, running?: false) }

    before do
      allow(Igniter::Cluster::Mesh::Announcer).to receive(:new).and_return(announcer_double)
      allow(Igniter::Cluster::Mesh::Poller).to receive(:new).and_return(poller_double)
    end

    it "start triggers announce_all, poll_once, and poller.start" do
      discovery.start

      expect(announcer_double).to have_received(:announce_all)
      expect(poller_double).to have_received(:poll_once)
      expect(poller_double).to have_received(:start)
    end

    it "stop triggers deannounce_all and poller.stop" do
      discovery.stop

      expect(announcer_double).to have_received(:deannounce_all)
      expect(poller_double).to have_received(:stop)
    end

    it "running? delegates to poller" do
      allow(poller_double).to receive(:running?).and_return(true)
      expect(discovery).to be_running
    end

    it "start returns self" do
      expect(discovery.start).to be(discovery)
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Mesh module — start/stop_discovery!
  # ─────────────────────────────────────────────────────────────────────────────
  describe "Igniter::Cluster::Mesh module" do
    it "start_discovery! starts discovery and returns self" do
      disc = instance_double(Igniter::Cluster::Mesh::Discovery, start: nil, stop: nil, running?: true)
      allow(Igniter::Cluster::Mesh::Discovery).to receive(:new).and_return(disc)

      result = Igniter::Cluster::Mesh.start_discovery!

      expect(disc).to have_received(:start)
      expect(result).to be(Igniter::Cluster::Mesh)
    end

    it "stop_discovery! stops discovery and clears the singleton" do
      disc = instance_double(Igniter::Cluster::Mesh::Discovery, start: nil, stop: nil, running?: false)
      allow(Igniter::Cluster::Mesh::Discovery).to receive(:new).and_return(disc)
      Igniter::Cluster::Mesh.start_discovery!

      Igniter::Cluster::Mesh.stop_discovery!

      expect(disc).to have_received(:stop)
      expect(Igniter::Cluster::Mesh.instance_variable_get(:@discovery)).to be_nil
    end

    it "reset! stops discovery and clears config + router" do
      Igniter::Cluster::Mesh.configure { |c| c.peer_name = "x" }
      disc = instance_double(Igniter::Cluster::Mesh::Discovery, start: nil, stop: nil, running?: false)
      allow(Igniter::Cluster::Mesh::Discovery).to receive(:new).and_return(disc)
      Igniter::Cluster::Mesh.start_discovery!

      Igniter::Cluster::Mesh.reset!

      expect(disc).to have_received(:stop)
      expect(Igniter::Cluster::Mesh.instance_variable_get(:@config)).to be_nil
      expect(Igniter::Cluster::Mesh.instance_variable_get(:@router)).to be_nil
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Router — merged static + dynamic routing
  # ─────────────────────────────────────────────────────────────────────────────
  describe Igniter::Cluster::Mesh::Router, "merged peer routing" do
    let(:config) { Igniter::Cluster::Mesh::Config.new }
    let(:router) { described_class.new(config) }

    def stub_alive(url)
      client = instance_double(Igniter::Server::Client)
      allow(Igniter::Server::Client).to receive(:new).with(url, timeout: 3).and_return(client)
      allow(client).to receive(:health).and_return({ "status" => "ok" })
    end

    def stub_dead(url)
      client = instance_double(Igniter::Server::Client)
      allow(Igniter::Server::Client).to receive(:new).with(url, timeout: 3).and_return(client)
      allow(client).to receive(:health).and_raise(Igniter::Server::Client::ConnectionError, "refused")
    end

    let(:deferred) { Igniter::Runtime::DeferredResult.build(payload: {}, source_node: :x, waiting_on: :x) }

    it "finds a dynamic peer when no static peers are configured" do
      config.peer_registry.register(
        Igniter::Cluster::Mesh::Peer.new(name: "dyn-orders", url: "http://dyn:4567", capabilities: [:orders])
      )
      stub_alive("http://dyn:4567")

      url = router.find_peer_for(:orders, deferred)
      expect(url).to eq("http://dyn:4567")
    end

    it "static peer takes precedence over same-named dynamic peer" do
      config.add_peer("orders-node", url: "http://static:4567", capabilities: [:orders])
      config.peer_registry.register(
        Igniter::Cluster::Mesh::Peer.new(name: "orders-node", url: "http://dynamic:4567", capabilities: [:orders])
      )
      stub_alive("http://static:4567")

      url = router.find_peer_for(:orders, deferred)
      expect(url).to eq("http://static:4567")
    end

    it "falls back to dynamic peer when static peer with same capability is dead" do
      config.add_peer("static-orders", url: "http://static:4567", capabilities: [:orders])
      config.peer_registry.register(
        Igniter::Cluster::Mesh::Peer.new(name: "dyn-orders", url: "http://dyn:4567", capabilities: [:orders])
      )
      stub_dead("http://static:4567")
      stub_alive("http://dyn:4567")

      url = router.find_peer_for(:orders, deferred)
      expect(url).to eq("http://dyn:4567")
    end

    it "raises DeferredCapabilityError when all peers (static + dynamic) are dead" do
      config.add_peer("s", url: "http://s:4567", capabilities: [:orders])
      config.peer_registry.register(
        Igniter::Cluster::Mesh::Peer.new(name: "d", url: "http://d:4567", capabilities: [:orders])
      )
      stub_dead("http://s:4567")
      stub_dead("http://d:4567")

      expect { router.find_peer_for(:orders, deferred) }
        .to raise_error(Igniter::Cluster::Mesh::DeferredCapabilityError)
    end

    it "resolve_pinned finds a dynamic peer by name" do
      config.peer_registry.register(
        Igniter::Cluster::Mesh::Peer.new(name: "audit-node", url: "http://audit:4567", capabilities: [:audit])
      )
      stub_alive("http://audit:4567")

      url = router.resolve_pinned("audit-node")
      expect(url).to eq("http://audit:4567")
    end

    it "resolve_pinned raises IncidentError when peer exists nowhere" do
      expect { router.resolve_pinned("ghost") }
        .to raise_error(Igniter::Cluster::Mesh::IncidentError)
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Server handlers
  # ─────────────────────────────────────────────────────────────────────────────
  describe Igniter::Server::Handlers::MeshPeersListHandler do
    subject(:handler) { described_class.new(double("registry"), double("store")) }

    it "returns empty array when Igniter::Cluster::Mesh is not configured" do
      # Force reset so no Mesh is configured
      result = handler.call(params: {}, body: {})
      expect(result[:status]).to eq(200)
      expect(JSON.parse(result[:body])).to eq([])
    end

    it "returns static peers" do
      Igniter::Cluster::Mesh.configure do |c|
        c.add_peer "orders-node", url: "http://orders:4567", capabilities: %i[orders]
      end

      result = handler.call(params: {}, body: {})
      data   = JSON.parse(result[:body])
      expect(data.size).to eq(1)
      expect(data.first["name"]).to eq("orders-node")
      expect(data.first["capabilities"]).to eq(["orders"])
    end

    it "returns dynamic peers" do
      Igniter::Cluster::Mesh.configure { |_c| }
      Igniter::Cluster::Mesh.config.peer_registry.register(
        Igniter::Cluster::Mesh::Peer.new(name: "dyn", url: "http://dyn:4567", capabilities: [:audit])
      )

      result = handler.call(params: {}, body: {})
      data   = JSON.parse(result[:body])
      expect(data.map { |p| p["name"] }).to include("dyn")
    end

    it "merges static + dynamic, static names win" do
      Igniter::Cluster::Mesh.configure do |c|
        c.add_peer "shared", url: "http://static:4567", capabilities: %i[orders]
      end
      Igniter::Cluster::Mesh.config.peer_registry.register(
        Igniter::Cluster::Mesh::Peer.new(name: "shared", url: "http://dynamic:4567", capabilities: [:orders])
      )
      Igniter::Cluster::Mesh.config.peer_registry.register(
        Igniter::Cluster::Mesh::Peer.new(name: "dynamic-only", url: "http://d2:4567", capabilities: [:audit])
      )

      result = handler.call(params: {}, body: {})
      data   = JSON.parse(result[:body])

      shared = data.find { |p| p["name"] == "shared" }
      expect(shared["url"]).to eq("http://static:4567")
      expect(data.map { |p| p["name"] }).to include("dynamic-only")
      expect(data.size).to eq(2)
    end
  end

  describe Igniter::Server::Handlers::MeshPeersRegisterHandler do
    subject(:handler) { described_class.new(double("registry"), double("store")) }

    before { Igniter::Cluster::Mesh.configure { |_c| } }

    it "registers a peer and returns 200" do
      body = { "name" => "orders-node", "url" => "http://orders:4567", "capabilities" => ["orders"] }
      result = handler.call(params: {}, body: body)

      expect(result[:status]).to eq(200)
      expect(JSON.parse(result[:body])["registered"]).to be true
      expect(Igniter::Cluster::Mesh.config.peer_registry.peer_named("orders-node")).not_to be_nil
    end

    it "returns 400 when name is missing" do
      result = handler.call(params: {}, body: { "url" => "http://x:4567" })
      expect(result[:status]).to eq(400)
      expect(JSON.parse(result[:body])["error"]).to match(/name/)
    end

    it "returns 400 when url is missing" do
      result = handler.call(params: {}, body: { "name" => "x" })
      expect(result[:status]).to eq(400)
      expect(JSON.parse(result[:body])["error"]).to match(/url/)
    end

    it "coerces capabilities to symbols in the registered peer" do
      body = { "name" => "x", "url" => "http://x:4567", "capabilities" => ["orders", "billing"] }
      handler.call(params: {}, body: body)

      peer = Igniter::Cluster::Mesh.config.peer_registry.peer_named("x")
      expect(peer.capabilities).to eq(%i[orders billing])
    end
  end

  describe Igniter::Server::Handlers::MeshPeersDeleteHandler do
    subject(:handler) { described_class.new(double("registry"), double("store")) }

    before { Igniter::Cluster::Mesh.configure { |_c| } }

    it "removes a registered peer and returns 200" do
      Igniter::Cluster::Mesh.config.peer_registry.register(
        Igniter::Cluster::Mesh::Peer.new(name: "orders-node", url: "http://orders:4567")
      )

      result = handler.call(params: { name: "orders-node" }, body: {})

      expect(result[:status]).to eq(200)
      expect(JSON.parse(result[:body])["unregistered"]).to be true
      expect(Igniter::Cluster::Mesh.config.peer_registry.peer_named("orders-node")).to be_nil
    end

    it "is idempotent — returns 200 even for unknown peers" do
      result = handler.call(params: { name: "ghost" }, body: {})
      expect(result[:status]).to eq(200)
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Server::Client mesh methods
  # ─────────────────────────────────────────────────────────────────────────────
  describe Igniter::Server::Client do
    subject(:client) { described_class.new("http://seed:4567") }

    describe "#list_peers" do
      it "fetches and parses GET /v1/mesh/peers" do
        stub_response = [
          { "name" => "orders-node", "url" => "http://orders:4567", "capabilities" => ["orders"] }
        ]
        allow(client).to receive(:get).with("/v1/mesh/peers").and_return(stub_response)

        peers = client.list_peers
        expect(peers.size).to eq(1)
        expect(peers.first[:name]).to eq("orders-node")
        expect(peers.first[:capabilities]).to eq([:orders])
      end

      it "returns empty array when response is empty" do
        allow(client).to receive(:get).with("/v1/mesh/peers").and_return([])
        expect(client.list_peers).to eq([])
      end
    end

    describe "#register_peer" do
      it "POSTs to /v1/mesh/peers with correct payload" do
        allow(client).to receive(:post).with(
          "/v1/mesh/peers",
          { "name" => "api-node", "url" => "http://api:4567", "capabilities" => ["api"] }
        ).and_return({ "registered" => true })

        client.register_peer(name: "api-node", url: "http://api:4567", capabilities: %i[api])
      end
    end

    describe "#unregister_peer" do
      it "sends DELETE to /v1/mesh/peers/:name" do
        allow(client).to receive(:delete_request).with("/v1/mesh/peers/orders-node").and_return({})
        client.unregister_peer("orders-node")
        expect(client).to have_received(:delete_request).with("/v1/mesh/peers/orders-node")
      end
    end
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Server route table
  # ─────────────────────────────────────────────────────────────────────────────
  describe "Server::Router ROUTES" do
    let(:routes) { Igniter::Server::Router::ROUTES }

    it "includes GET /v1/mesh/peers" do
      expect(routes).to include(hash_including(method: "GET", handler: :mesh_peers_list))
    end

    it "includes POST /v1/mesh/peers" do
      expect(routes).to include(hash_including(method: "POST", handler: :mesh_peers_register))
    end

    it "includes DELETE /v1/mesh/peers/:name" do
      expect(routes).to include(hash_including(method: "DELETE", handler: :mesh_peers_delete))
    end

    it "DELETE pattern matches paths with hyphens and dots" do
      route = routes.find { |r| r[:handler] == :mesh_peers_delete }
      expect(route[:pattern]).to match("/v1/mesh/peers/orders-node")
      expect(route[:pattern]).to match("/v1/mesh/peers/orders.node.v2")
    end
  end
end
