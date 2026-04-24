# frozen_string_literal: true

require_relative "../../spec_helper"
require "igniter/embed/rails"

RSpec.describe Igniter::Embed::Rails do
  it "is safe to require and install outside Rails with an explicit reloader" do
    callbacks = []
    reloader = Class.new do
      define_method(:initialize) { |store| @store = store }
      define_method(:to_prepare) { |&block| @store << block }
    end.new(callbacks)

    contracts = Igniter::Embed.configure(:sparkcrm)

    described_class.install(contracts, reloader: reloader, cache: false)

    expect(contracts.config.cache).to eq(false)
    expect(callbacks.length).to eq(1)
  end

  it "raises an Igniter-owned error for invalid reloaders" do
    contracts = Igniter::Embed.configure(:sparkcrm)

    expect do
      described_class.install(contracts, reloader: Object.new)
    end.to raise_error(Igniter::Embed::RailsIntegrationError, /reloader/)
  end
end
