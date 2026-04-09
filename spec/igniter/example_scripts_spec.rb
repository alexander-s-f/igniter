# frozen_string_literal: true

require "spec_helper"
require "open3"

RSpec.describe "Igniter example scripts" do
  def run_example(name)
    example_path = File.expand_path("../../examples/#{name}", __dir__)
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, example_path)
    [stdout, stderr, status]
  end

  it "runs the basic pricing example" do
    stdout, stderr, status = run_example("basic_pricing.rb")

    expect(status.success?).to eq(true), stderr
    expect(stdout).to include("gross_total=120.0")
    expect(stdout).to include("updated_gross_total=180.0")
  end

  it "runs the composition example" do
    stdout, stderr, status = run_example("composition.rb")

    expect(status.success?).to eq(true), stderr
    expect(stdout).to include("pricing={:pricing=>{:gross_total=>120.0}}")
  end

  it "runs the diagnostics example" do
    stdout, stderr, status = run_example("diagnostics.rb")

    expect(status.success?).to eq(true), stderr
    expect(stdout).to include("Diagnostics PriceContract")
    expect(stdout).to include(":outputs=>{:gross_total=>120.0}")
  end

  it "runs the async store example" do
    stdout, stderr, status = run_example("async_store.rb")

    expect(status.success?).to eq(true), stderr
    expect(stdout).to include("pending_token=quote-100")
    expect(stdout).to include("pending_status=true")
    expect(stdout).to include("resumed_gross_total=180.0")
  end

  it "runs the marketing ergonomics example" do
    stdout, stderr, status = run_example("marketing_ergonomics.rb")

    expect(status.success?).to eq(true), stderr
    expect(stdout).to include("Plan MarketingQuoteContract")
    expect(stdout).to include('response={:vendor_id=>"eLocal", :trade=>"HVAC", :zip_code=>"60601", :bid=>45.0}')
    expect(stdout).to include('outbox=[{:vendor_id=>"eLocal", :zip_code=>"60601"}]')
  end

  it "runs the collection example" do
    stdout, stderr, status = run_example("collection.rb")

    expect(status.success?).to eq(true), stderr
    expect(stdout).to include("keys=[1, 2]")
    expect(stdout).to include(':status=>:succeeded')
    expect(stdout).to include(':summary=>{:id=>1, :name=>"Anna"}')
  end

  it "runs the ringcentral routing example" do
    stdout, stderr, status = run_example("ringcentral_routing.rb")

    expect(status.success?).to eq(true), stderr
    expect(stdout).to include("Plan RingcentralWebhookContract")
    expect(stdout).to include('routing_summary={:extension_id=>62872332031, :telephony_status=>"CallConnected"')
    expect(stdout).to include("status_route_branch=CallConnected")
    expect(stdout).to include('child_collection_summary={:mode=>:collect, :total=>3, :succeeded=>3, :failed=>0, :status=>:succeeded}')
    expect(stdout).to include('"s-outbound-1"')
  end

  it "runs the collection partial failure example" do
    stdout, stderr, status = run_example("collection_partial_failure.rb")

    expect(status.success?).to eq(true), stderr
    expect(stdout).to include('summary={:mode=>:collect, :total=>3, :succeeded=>2, :failed=>1, :status=>:partial_failure}')
    expect(stdout).to include('items_summary={1=>{:status=>:succeeded}, 2=>{:status=>:failed')
    expect(stdout).to include('failed_items={2=>{:type=>"Igniter::ResolutionError"')
    expect(stdout).to include('Collections: technicians total=3 succeeded=2 failed=1 status=partial_failure')
  end

  it "runs the order pipeline example" do
    stdout, stderr, status = run_example("order_pipeline.rb")

    expect(status.success?).to eq(true), stderr
    expect(stdout).to include("order_subtotal=199.96")
    expect(stdout).to include("shipping_cost=0.0")
    expect(stdout).to include("eta=2-3 business days")
    expect(stdout).to include("grand_total=199.96")
    expect(stdout).to include("shipping_cost=29.99")
    expect(stdout).to include("eta=7-14 business days")
    expect(stdout).to include("grand_total=229.95")
    expect(stdout).to include("items are out of stock")
  end

  it "runs the distributed server example" do
    stdout, stderr, status = run_example("distributed_server.rb")

    expect(status.success?).to eq(true), stderr
    expect(stdout).to include("pending=true")
    expect(stdout).to include("waiting_for=")
    expect(stdout).to include(":screening_completed")
    expect(stdout).to include("still_pending=true")
    expect(stdout).to include("[callback] Decision reached: HIRED")
    expect(stdout).to include("success=true")
    expect(stdout).to include("status=>:hired")
    expect(stdout).to include("Excellent system design skills")
  end

  it "runs the LLM tool use example" do
    stdout, stderr, status = run_example("llm/tool_use.rb")

    expect(status.success?).to eq(true), stderr
    expect(stdout).to include("=== Feedback Triage Pipeline ===")
    expect(stdout).to include("category=category: bug_report")
    expect(stdout).to include("priority=priority: high")
    expect(stdout).to include("response=We have logged this issue")
  end
end
