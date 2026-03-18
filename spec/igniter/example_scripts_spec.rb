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
end
