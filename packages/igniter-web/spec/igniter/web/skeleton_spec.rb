# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe Igniter::Web do
  it "builds an application skeleton with route and api declarations" do
    app = described_class.application do
      get "/", to: "Pages::Home"
      post "/messages", to: "Actions::Messages::Create"
      stream "/messages/stream", to: "Projections::Messages"
    end

    expect(app.routes.map { |route| [route.verb, route.path, route.target] }).to eq([
      [:get, "/", "Pages::Home"],
      [:post, "/messages", "Actions::Messages::Create"]
    ])
    expect(app.api_surface.endpoints.map { |endpoint| [endpoint.kind, endpoint.verb, endpoint.path, endpoint.target] }).to eq([
      [:stream, :get, "/messages/stream", "Projections::Messages"]
    ])
  end

  it "builds a contracts-first api skeleton" do
    api = described_class.api do
      command "/projects/:id/advance", to: "Contracts::AdvanceProject"
      query "/projects/:id", to: "Queries::ProjectSnapshot"
      webhook "/mesh/events", to: "Ingress::MeshEvents", auth: :signature
    end

    expect(api.endpoints.map { |endpoint| [endpoint.kind, endpoint.verb, endpoint.path, endpoint.target] }).to eq([
      [:command, :post, "/projects/:id/advance", "Contracts::AdvanceProject"],
      [:query, :get, "/projects/:id", "Queries::ProjectSnapshot"],
      [:webhook, :post, "/mesh/events", "Ingress::MeshEvents"]
    ])
    expect(api.endpoints.last.metadata).to eq({ auth: :signature })
  end

  it "provides an adapter-oriented record skeleton" do
    record_class = Class.new(Igniter::Web::Record) do
      adapter :memory
      attribute :title, :string
      attribute :status, :symbol, default: :draft
    end

    record = record_class.new(title: "Launch", status: :active)

    expect(record_class.adapter_definition).to eq(name: :memory, options: {})
    expect(record_class.attribute_definitions.map { |definition| [definition[:name], definition[:type]] }).to eq([
      [:title, :string],
      [:status, :symbol]
    ])
    expect(record[:title]).to eq("Launch")
    expect(record.to_h).to eq(title: "Launch", status: :active)
  end
end
