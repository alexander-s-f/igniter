# frozen_string_literal: true

require_relative "../../spec_helper"
require "tmpdir"

RSpec.describe Igniter::Store::FileBackend do
  it "replays facts from a JSONL WAL" do
    path = File.join(Dir.mktmpdir("igniter-store-spec"), "store.jsonl")

    first = Igniter::Store.open(path)
    first.write(store: :tasks, key: "t1", value: { title: "Package", done: false })
    first.write(store: :tasks, key: "t1", value: { title: "Package", done: true })
    first.close

    replayed = Igniter::Store.open(path)

    expect(replayed.read(store: :tasks, key: "t1")).to include(done: true)
    expect(replayed.fact_count).to eq(2)
  end
end
