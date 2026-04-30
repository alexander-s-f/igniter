# frozen_string_literal: true

require_relative "../../spec_helper"

# ── Schema definitions used across the suite ──────────────────────────────────

class Reminder
  include Igniter::Companion::Record
  store_name :reminders

  field :title
  field :status, default: :open
  field :due,    default: nil

  scope :open, filters: { status: :open }
  scope :done, filters: { status: :done }
end

class TrackerLog
  include Igniter::Companion::History
  history_name :tracker_logs

  field :tracker_id
  field :value
  field :notes, default: nil
end

# ── Store specs ───────────────────────────────────────────────────────────────

RSpec.describe Igniter::Companion::Store do
  subject(:store) do
    s = described_class.new
    s.register(Reminder)
    s
  end

  # ── Record round-trip ──────────────────────────────────────────────────────

  describe "Record write / read round-trip" do
    it "returns a typed Record with the written fields" do
      r = store.write(Reminder, key: "r1", title: "Buy milk", status: :open)

      expect(r).to be_a(Reminder)
      expect(r.key).to eq("r1")
      expect(r.title).to eq("Buy milk")
      expect(r.status).to eq(:open)
    end

    it "reads back the same value with Symbol-typed fields" do
      store.write(Reminder, key: "r1", title: "Buy milk", status: :open)
      r = store.read(Reminder, key: "r1")

      expect(r.title).to eq("Buy milk")
      expect(r.status).to eq(:open)    # Symbol survives JSON round-trip via igniter-store
    end

    it "applies field defaults on read when value has no entry for that field" do
      store.write(Reminder, key: "r1", title: "A", status: :open)
      r = store.read(Reminder, key: "r1")

      expect(r.due).to be_nil  # default from field declaration
    end

    it "returns nil for unknown keys" do
      expect(store.read(Reminder, key: "nonexistent")).to be_nil
    end

    it "reflects the latest write after an update" do
      store.write(Reminder, key: "r1", title: "Old",  status: :open)
      store.write(Reminder, key: "r1", title: "New",  status: :done)

      r = store.read(Reminder, key: "r1")
      expect(r.title).to eq("New")
      expect(r.status).to eq(:done)
    end

    it "exposes a causation chain across writes" do
      store.write(Reminder, key: "r1", title: "A", status: :open)
      store.write(Reminder, key: "r1", title: "A", status: :done)

      chain = store.causation_chain(Reminder, key: "r1")
      expect(chain.length).to eq(2)
      expect(chain.first[:causation]).to be_nil
      expect(chain.last[:causation]).not_to be_nil
    end
  end

  # ── Scope queries ──────────────────────────────────────────────────────────

  describe "Record scope queries" do
    before do
      store.write(Reminder, key: "r1", title: "A", status: :open)
      store.write(Reminder, key: "r2", title: "B", status: :done)
      store.write(Reminder, key: "r3", title: "C", status: :open)
    end

    it "returns only records matching the scope filter" do
      results = store.scope(Reminder, :open)
      expect(results.map(&:title).sort).to eq(%w[A C])
    end

    it "returns Record instances, not raw facts" do
      results = store.scope(Reminder, :open)
      expect(results).to all(be_a(Reminder))
    end

    it "reflects state after status change" do
      store.write(Reminder, key: "r1", title: "A", status: :done)

      open_results = store.scope(Reminder, :open)
      done_results = store.scope(Reminder, :done)

      expect(open_results.map(&:title)).to eq(["C"])
      expect(done_results.map(&:title).sort).to eq(%w[A B])
    end

    it "raises ArgumentError for an unregistered scope" do
      expect { store.scope(Reminder, :archived) }
        .to raise_error(ArgumentError, /scope=:archived/)
    end
  end

  # ── Time-travel reads ──────────────────────────────────────────────────────

  describe "time-travel" do
    it "reads the past state of a record via as_of" do
      store.write(Reminder, key: "r1", title: "A", status: :open)
      sleep 0.01
      checkpoint = Process.clock_gettime(Process::CLOCK_REALTIME)
      sleep 0.01
      store.write(Reminder, key: "r1", title: "A", status: :done)

      past = store.read(Reminder, key: "r1", as_of: checkpoint)
      expect(past.status).to eq(:open)

      now = store.read(Reminder, key: "r1")
      expect(now.status).to eq(:done)
    end

    it "queries a scope at a past point in time" do
      store.write(Reminder, key: "r1", title: "A", status: :open)
      sleep 0.01
      checkpoint = Process.clock_gettime(Process::CLOCK_REALTIME)
      sleep 0.01
      store.write(Reminder, key: "r1", title: "A", status: :done)

      at_checkpoint = store.scope(Reminder, :open, as_of: checkpoint)
      expect(at_checkpoint.map(&:title)).to eq(["A"])

      now = store.scope(Reminder, :open)
      expect(now).to be_empty
    end
  end

  # ── Reactive scope consumers ───────────────────────────────────────────────

  describe "reactive scope consumers via on_scope" do
    it "notifies the consumer when the scope cache is invalidated by a write" do
      notifications = []

      store.on_scope(Reminder, :open) { |_store_name, scope| notifications << scope }

      store.write(Reminder, key: "r1", title: "A", status: :open)
      # cache not yet warm — no notification
      expect(notifications).to be_empty

      # warm the cache
      store.scope(Reminder, :open)

      # mutate — scope cache invalidated → consumer fires
      store.write(Reminder, key: "r1", title: "A", status: :done)
      expect(notifications).to eq([:open])
    end

    it "fires consumers for both affected scopes on a status transition" do
      open_notifs = []
      done_notifs = []

      store.on_scope(Reminder, :open) { |_, sc| open_notifs << sc }
      store.on_scope(Reminder, :done) { |_, sc| done_notifs << sc }

      store.write(Reminder, key: "r1", title: "A", status: :open)

      # warm both scopes
      store.scope(Reminder, :open)
      store.scope(Reminder, :done)
      open_notifs.clear
      done_notifs.clear

      store.write(Reminder, key: "r1", title: "A", status: :done)

      expect(open_notifs).to eq([:open])
      expect(done_notifs).to eq([:done])
    end
  end

  # ── History (append-only) ──────────────────────────────────────────────────

  describe "History append / replay" do
    it "appends events and replays them in order" do
      store.append(TrackerLog, tracker_id: "t1", value: 7.0, notes: "morning")
      store.append(TrackerLog, tracker_id: "t1", value: 8.5)

      events = store.replay(TrackerLog)
      expect(events.length).to eq(2)
      expect(events.map(&:value)).to eq([7.0, 8.5])
    end

    it "returns History instances with fact_id and timestamp" do
      store.append(TrackerLog, tracker_id: "t1", value: 9.0)

      events = store.replay(TrackerLog)
      event  = events.first

      expect(event).to be_a(TrackerLog)
      expect(event.fact_id).not_to be_nil
      expect(event.timestamp).to be_a(Float)
    end

    it "applies field defaults on replay" do
      store.append(TrackerLog, tracker_id: "t1", value: 5.0)
      event = store.replay(TrackerLog).first

      expect(event.notes).to be_nil  # default
    end

    it "supports time-filtered replay via since:" do
      store.append(TrackerLog, tracker_id: "t1", value: 1.0)
      sleep 0.01
      cutoff = Process.clock_gettime(Process::CLOCK_REALTIME)
      sleep 0.01
      store.append(TrackerLog, tracker_id: "t1", value: 2.0)

      recent = store.replay(TrackerLog, since: cutoff)
      expect(recent.map(&:value)).to eq([2.0])
    end
  end
end
