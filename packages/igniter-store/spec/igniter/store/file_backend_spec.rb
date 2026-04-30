# frozen_string_literal: true

require_relative "../../spec_helper"
require "tmpdir"
require "zlib"

RSpec.describe Igniter::Store::FileBackend do
  def tmp_path
    File.join(Dir.mktmpdir("igniter-store-spec"), "store.wal")
  end

  it "replays facts written across two sessions (WAL durability)" do
    path = tmp_path

    first = Igniter::Store.open(path)
    first.write(store: :tasks, key: "t1", value: { title: "Package", done: false })
    first.write(store: :tasks, key: "t1", value: { title: "Package", done: true })
    first.close

    replayed = Igniter::Store.open(path)

    expect(replayed.read(store: :tasks, key: "t1")).to include(done: true)
    expect(replayed.fact_count).to eq(2)
  end

  it "preserves causation chain across WAL replay" do
    path = tmp_path

    s1 = Igniter::Store.open(path)
    f1 = s1.write(store: :items, key: "k1", value: { v: 1 })
    f2 = s1.write(store: :items, key: "k1", value: { v: 2 })
    s1.close

    s2 = Igniter::Store.open(path)
    chain = s2.causation_chain(store: :items, key: "k1")

    expect(chain.length).to eq(2)
    expect(chain[0][:id]).to eq(f1.id)
    expect(chain[1][:causation]).to eq(f1.id)
  end

  it "stops replay at a truncated frame without raising and returns committed facts" do
    path = tmp_path

    s = Igniter::Store.open(path)
    s.write(store: :items, key: "k1", value: { v: 1 })
    s.write(store: :items, key: "k1", value: { v: 2 })
    s.close

    # Simulate a mid-write process kill: truncate the last 6 bytes
    File.open(path, "ab") { }   # no-op open to confirm file exists
    raw = File.binread(path)
    File.binwrite(path, raw[0...-6])

    replayed = Igniter::Store.open(path)
    # At least the first fact survived; the truncated second frame is ignored
    expect(replayed.fact_count).to be >= 1
    expect { replayed.read(store: :items, key: "k1") }.not_to raise_error
  end

  it "detects a CRC mismatch and stops replay at the corrupt frame" do
    path = tmp_path

    s = Igniter::Store.open(path)
    s.write(store: :items, key: "k1", value: { v: 1 })
    s.write(store: :items, key: "k1", value: { v: 2 })
    s.close

    # Flip a byte in the second frame's CRC (last 4 bytes of the file)
    raw = File.binread(path).bytes
    raw[-1] ^= 0xFF
    File.binwrite(path, raw.pack("C*"))

    replayed = Igniter::Store.open(path)
    # First frame (good CRC) replayed; second frame (bad CRC) stops replay
    expect(replayed.fact_count).to eq(1)
  end

  it "replays an empty WAL without error" do
    path = tmp_path
    FileUtils.touch(path)

    store = Igniter::Store.open(path)
    expect(store.fact_count).to eq(0)
  end
end
