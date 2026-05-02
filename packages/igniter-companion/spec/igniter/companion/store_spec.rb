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
  partition_key :tracker_id

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
    it "returns a WriteReceipt that delegates to the typed record" do
      r = store.write(Reminder, key: "r1", title: "Buy milk", status: :open)

      expect(r).to be_a(Igniter::Companion::WriteReceipt)
      expect(r.mutation_intent).to eq(:record_write)
      expect(r.fact_id).not_to be_nil
      expect(r.value_hash).not_to be_nil
      expect(r.key).to eq("r1")
      expect(r.record).to be_a(Reminder)
      # delegation to record
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

    it "returns an AppendReceipt that delegates to the typed event" do
      receipt = store.append(TrackerLog, tracker_id: "t1", value: 9.0)

      expect(receipt).to be_a(Igniter::Companion::AppendReceipt)
      expect(receipt.mutation_intent).to eq(:history_append)
      expect(receipt.fact_id).not_to be_nil
      expect(receipt.timestamp).to be_a(Float)
      expect(receipt.event).to be_a(TrackerLog)
      # delegation to event
      expect(receipt.value).to eq(9.0)
      expect(receipt.tracker_id).to eq("t1")
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

    it "replays all events without partition filter" do
      store.append(TrackerLog, tracker_id: "sleep",    value: 7.0)
      store.append(TrackerLog, tracker_id: "training", value: 45.0)
      store.append(TrackerLog, tracker_id: "sleep",    value: 8.5)

      all = store.replay(TrackerLog)
      expect(all.length).to eq(3)
    end
  end

  describe "History partition replay" do
    it "filters events by the declared partition_key value" do
      store.append(TrackerLog, tracker_id: "sleep",    value: 7.0)
      store.append(TrackerLog, tracker_id: "training", value: 45.0)
      store.append(TrackerLog, tracker_id: "sleep",    value: 8.5)

      sleep_logs    = store.replay(TrackerLog, partition: "sleep")
      training_logs = store.replay(TrackerLog, partition: "training")

      expect(sleep_logs.map(&:value)).to eq([7.0, 8.5])
      expect(training_logs.map(&:value)).to eq([45.0])
    end

    it "returns empty array for a partition with no events" do
      store.append(TrackerLog, tracker_id: "sleep", value: 7.0)
      expect(store.replay(TrackerLog, partition: "weight")).to be_empty
    end

    it "returns TrackerLog instances from partition replay" do
      store.append(TrackerLog, tracker_id: "sleep", value: 7.0)
      results = store.replay(TrackerLog, partition: "sleep")
      expect(results).to all(be_a(TrackerLog))
    end

    it "respects since: combined with partition:" do
      store.append(TrackerLog, tracker_id: "sleep", value: 6.0)
      sleep 0.01
      cutoff = Process.clock_gettime(Process::CLOCK_REALTIME)
      sleep 0.01
      store.append(TrackerLog, tracker_id: "sleep", value: 8.5)

      recent = store.replay(TrackerLog, partition: "sleep", since: cutoff)
      expect(recent.map(&:value)).to eq([8.5])
    end
  end

  # ── Manifest-generated classes ─────────────────────────────────────────────

  RECORD_MANIFEST = {
    storage: { shape: :store, name: :gen_items, key: :id },
    fields: [
      { name: :id,         attributes: {} },
      { name: :title,      attributes: { type: :string } },
      { name: :status,     attributes: { type: :enum, values: %i[open done], default: :open } },
      { name: :due,        attributes: {} },
      { name: :created_at, attributes: { type: :datetime } }
    ],
    scopes: [
      { name: :open, attributes: { where: { status: :open } } },
      { name: :done, attributes: { where: { status: :done } } }
    ]
  }.freeze

  HISTORY_MANIFEST = {
    storage: { shape: :history, name: :gen_events, key: :tracker_id },
    history: { kind: :history, key: :tracker_id },
    fields: [
      { name: :tracker_id, attributes: {} },
      { name: :value,      attributes: {} },
      { name: :notes,      attributes: { default: nil } }
    ]
  }.freeze

  describe "Record.from_manifest" do
    subject(:klass) { Igniter::Companion::Record.from_manifest(RECORD_MANIFEST) }

    it "returns a class that includes Record" do
      expect(klass.ancestors).to include(Igniter::Companion::Record)
    end

    it "uses storage.name from manifest when store: is omitted" do
      expect(klass.store_name).to eq(:gen_items)
    end

    it "overrides store_name when store: is given explicitly" do
      override = Igniter::Companion::Record.from_manifest(RECORD_MANIFEST, store: :custom)
      expect(override.store_name).to eq(:custom)
    end

    it "raises when manifest has no storage.name and store: is omitted" do
      nameless = { storage: { shape: :store, key: :id }, fields: [], scopes: [] }
      expect { Igniter::Companion::Record.from_manifest(nameless) }
        .to raise_error(ArgumentError, /store:/)
    end

    it "declares all manifest fields as attributes" do
      expect(klass._fields.keys).to eq(%i[id title status due created_at])
    end

    it "applies field defaults declared in the manifest" do
      obj = klass.new(key: "x", id: "x", title: "T")
      expect(obj.status).to eq(:open)
    end

    it "declares all manifest scopes" do
      expect(klass._scopes.keys).to eq(%i[open done])
    end

    it "scope filters map from manifest where: attributes" do
      expect(klass._scopes[:open][:filters]).to eq({ status: :open })
    end

    it "works end-to-end with Store write/read/scope" do
      s = Igniter::Companion::Store.new
      s.register(klass)

      s.write(klass, key: "r1", id: "r1", title: "Foo", status: :open)
      s.write(klass, key: "r2", id: "r2", title: "Bar", status: :done)

      expect(s.read(klass, key: "r1").title).to eq("Foo")
      expect(s.scope(klass, :open).map(&:title)).to eq(["Foo"])
      expect(s.scope(klass, :done).map(&:title)).to eq(["Bar"])
    ensure
      s&.close
    end
  end

  describe "History.from_manifest" do
    subject(:klass) { Igniter::Companion::History.from_manifest(HISTORY_MANIFEST) }

    it "returns a class that includes History" do
      expect(klass.ancestors).to include(Igniter::Companion::History)
    end

    it "uses storage.name from manifest when store: is omitted" do
      expect(klass.store_name).to eq(:gen_events)
    end

    it "sets partition_key from history.key in manifest" do
      expect(klass._partition_key).to eq(:tracker_id)
    end

    it "declares all manifest fields" do
      expect(klass._fields.keys).to eq(%i[tracker_id value notes])
    end

    it "works end-to-end with Store append/replay/partition" do
      s = Igniter::Companion::Store.new
      s.append(klass, tracker_id: "sleep",    value: 7.0)
      s.append(klass, tracker_id: "training", value: 45.0)
      s.append(klass, tracker_id: "sleep",    value: 8.5)

      expect(s.replay(klass).length).to eq(3)
      expect(s.replay(klass, partition: "sleep").map(&:value)).to eq([7.0, 8.5])
    ensure
      s&.close
    end
  end

  describe "Igniter::Companion.from_manifest" do
    it "returns a Record class for shape: :store using manifest name" do
      klass = Igniter::Companion.from_manifest(RECORD_MANIFEST)
      expect(klass.ancestors).to include(Igniter::Companion::Record)
      expect(klass.store_name).to eq(:gen_items)
    end

    it "returns a History class for shape: :history using manifest name" do
      klass = Igniter::Companion.from_manifest(HISTORY_MANIFEST)
      expect(klass.ancestors).to include(Igniter::Companion::History)
      expect(klass.store_name).to eq(:gen_events)
    end

    it "overrides manifest name when store: is given" do
      klass = Igniter::Companion.from_manifest(RECORD_MANIFEST, store: :override)
      expect(klass.store_name).to eq(:override)
    end

    it "raises ArgumentError for unknown shape" do
      bad_manifest = { storage: { shape: :graph } }
      expect { Igniter::Companion.from_manifest(bad_manifest, store: :x) }
        .to raise_error(ArgumentError, /Unknown storage shape/)
    end
  end

  # ── Relation auto-wire (Belt 10) ──────────────────────────────────────────

  # Schema classes used only in this section to avoid polluting global fixtures.
  BlogPost = Class.new do
    include Igniter::Companion::Record
    store_name :blog_posts
    field :title
    relation :comments_by_post, kind: :event_owner, to: :blog_comments,
             join: { id: :post_id }, cardinality: :one_to_many
    relation :tags_by_post,     kind: :ownership, to: :blog_tags,
             join: { id: :post_id }, cardinality: :one_to_many
    relation :author_ref,       kind: :reference, to: :users,
             join: { author_id: :id }, cardinality: :many_to_one  # should NOT be auto-wired
  end

  BlogComment = Class.new do
    include Igniter::Companion::Record
    store_name :blog_comments
    field :body
    field :post_id
  end

  describe "Companion::Store register — relation auto-wire" do
    subject(:store) do
      s = described_class.new
      s.register(BlogPost)
      s
    end

    it "auto-wires one_to_many/event_owner relation on register" do
      snap = store._relations
      expect(snap.keys).to include(:comments_by_post)
    end

    it "auto-wires one_to_many/ownership relation on register" do
      snap = store._relations
      expect(snap.keys).to include(:tags_by_post)
    end

    it "does NOT auto-wire many_to_one/reference relations" do
      snap = store._relations
      expect(snap.keys).not_to include(:author_ref)
    end

    it "resolves an empty array before any comments are written" do
      expect(store.resolve(:comments_by_post, from: "p1")).to eq([])
    end

    it "resolve returns source values after a comment is written" do
      store.write(BlogComment, key: "c1", body: "Great post!", post_id: "p1")
      result = store.resolve(:comments_by_post, from: "p1")
      expect(result.size).to eq(1)
      # write auto-registers BlogComment, so typed BlogComment instances are returned
      expect(result.first.body).to eq("Great post!")
    end

    it "accumulates multiple comments for the same post" do
      store.write(BlogComment, key: "c1", body: "First",  post_id: "p1")
      store.write(BlogComment, key: "c2", body: "Second", post_id: "p1")
      result = store.resolve(:comments_by_post, from: "p1")
      expect(result.size).to eq(2)
      expect(result.map(&:body)).to contain_exactly("First", "Second")
    end

    it "keeps per-post indexes separate" do
      store.write(BlogComment, key: "c1", body: "On P1", post_id: "p1")
      store.write(BlogComment, key: "c2", body: "On P2", post_id: "p2")
      expect(store.resolve(:comments_by_post, from: "p1").size).to eq(1)
      expect(store.resolve(:comments_by_post, from: "p2").size).to eq(1)
    end

    it "returns latest comment value after update" do
      store.write(BlogComment, key: "c1", body: "old", post_id: "p1")
      store.write(BlogComment, key: "c1", body: "new", post_id: "p1")
      result = store.resolve(:comments_by_post, from: "p1")
      expect(result.size).to eq(1)
      expect(result.first.body).to eq("new")
    end

    it "_relations snapshot includes index_store key" do
      snap = store._relations
      expect(snap[:comments_by_post][:index_store]).to eq(:__rel_comments_by_post)
    end
  end

  describe "Companion::Store register — idempotency" do
    it "calling register twice with the same class is a no-op (no duplicate rules)" do
      s = described_class.new
      s.register(BlogPost)
      s.register(BlogPost)

      # Only one scatter rule per relation, not two
      scatter = s.instance_variable_get(:@inner).schema_graph.scatter_snapshot
      comments_scatters = scatter.select { |r| r[:source_store] == :blog_comments }
      expect(comments_scatters.size).to eq(1)
    ensure
      s&.close
    end

    it "returns self (chainable)" do
      s = described_class.new
      expect(s.register(BlogPost)).to be(s)
    ensure
      s&.close
    end
  end

  describe "Companion::Store register — schema class without _relations" do
    it "does not raise when schema_class has no _relations (plain Reminder)" do
      s = described_class.new
      expect { s.register(Reminder) }.not_to raise_error
    ensure
      s&.close
    end
  end

  # ── Belt 12: auto-register on write + time-travel resolve ─────────────────

  describe "auto-register schema class on write (Belt 12)" do
    subject(:store) do
      s = described_class.new
      s.register(BlogPost)   # registers BlogPost + wires the relation
      # BlogComment NOT explicitly registered
      s
    end

    it "write(BlogComment, ...) registers the class for typed resolve" do
      store.write(BlogComment, key: "c1", body: "Auto-registered!", post_id: "p1")
      result = store.resolve(:comments_by_post, from: "p1")
      expect(result.first).to be_a(BlogComment)
    end

    it "typed instance has correct fields after auto-register" do
      store.write(BlogComment, key: "c1", body: "Hello", post_id: "p1")
      comment = store.resolve(:comments_by_post, from: "p1").first
      expect(comment.body).to    eq("Hello")
      expect(comment.key).to     eq("c1")
      expect(comment.post_id).to eq("p1")
    end

    it "auto-register is idempotent across multiple writes" do
      store.write(BlogComment, key: "c1", body: "One",   post_id: "p1")
      store.write(BlogComment, key: "c2", body: "Two",   post_id: "p1")
      result = store.resolve(:comments_by_post, from: "p1")
      expect(result).to all(be_a(BlogComment))
      expect(result.size).to eq(2)
    end
  end

  describe "resolve with as_of: (Belt 12 time-travel)" do
    subject(:store) do
      s = described_class.new
      s.register(BlogPost)
      s.register(BlogComment)
      s
    end

    it "returns the relation state at a past checkpoint" do
      store.write(BlogComment, key: "c1", body: "Early",  post_id: "p1")
      sleep 0.005
      checkpoint = Process.clock_gettime(Process::CLOCK_REALTIME)
      sleep 0.005
      store.write(BlogComment, key: "c2", body: "Later",  post_id: "p1")

      past    = store.resolve(:comments_by_post, from: "p1", as_of: checkpoint)
      current = store.resolve(:comments_by_post, from: "p1")

      expect(past.size).to    eq(1)
      expect(past.first).to   be_a(BlogComment)
      expect(past.first.body).to eq("Early")
      expect(current.size).to eq(2)
    end

    it "returns [] when partition had no entries before the checkpoint" do
      sleep 0.005
      checkpoint = Process.clock_gettime(Process::CLOCK_REALTIME)
      sleep 0.005
      store.write(BlogComment, key: "c1", body: "Post", post_id: "p1")

      expect(store.resolve(:comments_by_post, from: "p1", as_of: checkpoint)).to eq([])
    end

    it "returns the source value at the past checkpoint, not the current value" do
      store.write(BlogComment, key: "c1", body: "v1", post_id: "p1")
      sleep 0.005
      checkpoint = Process.clock_gettime(Process::CLOCK_REALTIME)
      sleep 0.005
      store.write(BlogComment, key: "c1", body: "v2", post_id: "p1")

      past = store.resolve(:comments_by_post, from: "p1", as_of: checkpoint)
      expect(past.first.body).to eq("v1")
    end
  end

  # ── Portable field types ───────────────────────────────────────────────────

  describe "portable field types" do
    subject(:klass) { Igniter::Companion::Record.from_manifest(RECORD_MANIFEST) }

    it "stores type: in _fields metadata" do
      expect(klass._fields[:title][:type]).to eq(:string)
      expect(klass._fields[:created_at][:type]).to eq(:datetime)
    end

    it "stores values: for enum fields" do
      expect(klass._fields[:status][:type]).to eq(:enum)
      expect(klass._fields[:status][:values]).to eq(%i[open done])
    end

    it "stores nil type for untyped fields" do
      expect(klass._fields[:id][:type]).to be_nil
      expect(klass._fields[:due][:type]).to be_nil
    end

    it "combines type with default" do
      expect(klass._fields[:status][:default]).to eq(:open)
      expect(klass._fields[:status][:type]).to eq(:enum)
    end

    it "supports type: kwarg on hand-written field declarations" do
      klass = Class.new do
        include Igniter::Companion::Record
        store_name :typed_test
        field :score,  type: :float
        field :active, type: :boolean
        field :label,  type: :string, default: "n/a"
      end
      expect(klass._fields[:score][:type]).to eq(:float)
      expect(klass._fields[:active][:type]).to eq(:boolean)
      expect(klass._fields[:label][:default]).to eq("n/a")
    end

    it "typed field round-trips correctly through Store write/read" do
      s = Igniter::Companion::Store.new
      s.register(klass)

      s.write(klass, key: "t1", id: "t1", title: "Hello", status: :open,
              created_at: "2026-04-30")
      record = s.read(klass, key: "t1")

      expect(record.title).to eq("Hello")
      expect(record.status).to eq(:open)
      expect(record.created_at).to eq("2026-04-30")
    ensure
      s&.close
    end
  end

  # ── Typed resolve (Belt 11) ────────────────────────────────────────────────

  describe "Companion::Store#resolve — typed records (Belt 11)" do
    # Store where both BlogPost and BlogComment are registered.
    subject(:store) do
      s = described_class.new
      s.register(BlogPost)
      s.register(BlogComment)
      s
    end

    it "returns typed BlogComment instances when source class is registered" do
      store.write(BlogComment, key: "c1", body: "Hello", post_id: "p1")
      result = store.resolve(:comments_by_post, from: "p1")
      expect(result.first).to be_a(BlogComment)
    end

    it "typed instance has the correct field values" do
      store.write(BlogComment, key: "c1", body: "Nice article", post_id: "p1")
      comment = store.resolve(:comments_by_post, from: "p1").first
      expect(comment.body).to   eq("Nice article")
      expect(comment.post_id).to eq("p1")
    end

    it "typed instance has a key" do
      store.write(BlogComment, key: "c1", body: "Hi", post_id: "p1")
      comment = store.resolve(:comments_by_post, from: "p1").first
      expect(comment.key).to eq("c1")
    end

    it "returns the latest typed value after an update" do
      store.write(BlogComment, key: "c1", body: "v1", post_id: "p1")
      store.write(BlogComment, key: "c1", body: "v2", post_id: "p1")
      result = store.resolve(:comments_by_post, from: "p1")
      expect(result.size).to eq(1)
      expect(result.first.body).to eq("v2")
    end

    it "returns multiple typed instances for different comment keys" do
      store.write(BlogComment, key: "c1", body: "First",  post_id: "p1")
      store.write(BlogComment, key: "c2", body: "Second", post_id: "p1")
      result = store.resolve(:comments_by_post, from: "p1")
      expect(result).to all(be_a(BlogComment))
      expect(result.map(&:body)).to contain_exactly("First", "Second")
    end

    it "returns [] for an unknown partition value" do
      expect(store.resolve(:comments_by_post, from: "p99")).to eq([])
    end

    it "raises ArgumentError for an unregistered relation" do
      expect { store.resolve(:nonexistent, from: "p1") }
        .to raise_error(ArgumentError, /No relation registered/)
    end

    context "when source class is NOT registered" do
      subject(:store) do
        # Only BlogPost registered, BlogComment is not
        s = described_class.new
        s.register(BlogPost)
        s
      end

      it "falls back to raw Hash values when source class is not in schema registry" do
        # Write directly via the inner store to bypass companion write
        store.instance_variable_get(:@inner).write(
          store: :blog_comments, key: "c1",
          value: { body: "raw write", post_id: "p1" }
        )
        result = store.resolve(:comments_by_post, from: "p1")
        # The scatter triggers and builds the index since BlogPost registered BlogComment relation
        expect(result).not_to be_empty
        expect(result.first).to be_a(Hash)
        expect(result.first[:body]).to eq("raw write")
      end
    end
  end

  # ── Protocol adoption (OP1/OP2 visibility) ───────────────────────────────────

  describe "Companion::Store — protocol adoption (OP1/OP2)" do
    describe "#metadata_snapshot" do
      it "returns a Hash with schema_version: 1" do
        snap = store.metadata_snapshot
        expect(snap).to be_a(Hash)
        expect(snap[:schema_version]).to eq(1)
      end

      it "includes :stores key with Reminder's store name after register" do
        snap = store.metadata_snapshot
        expect(snap[:stores]).to include(Reminder.store_name)
      end

      it "includes :histories key" do
        s = described_class.new
        s.register(TrackerLog)
        snap = s.metadata_snapshot
        expect(snap[:histories]).to include(TrackerLog.store_name)
      ensure
        s&.close
      end

      it "includes access_paths, relations, projections, scatters, retention keys" do
        snap = store.metadata_snapshot
        expect(snap).to have_key(:access_paths)
        expect(snap).to have_key(:relations)
        expect(snap).to have_key(:projections)
        expect(snap).to have_key(:scatters)
        expect(snap).to have_key(:retention)
      end
    end

    describe "#descriptor_snapshot" do
      it "returns a Hash with :stores and :histories keys" do
        snap = store.descriptor_snapshot
        expect(snap).to have_key(:stores)
        expect(snap).to have_key(:histories)
      end

      it "descriptor_snapshot[:stores] contains the Reminder descriptor" do
        snap = store.descriptor_snapshot
        expect(snap[:stores]).to have_key(Reminder.store_name)
      end

      it "Reminder descriptor has kind: :store and expected name" do
        desc = store.descriptor_snapshot[:stores][Reminder.store_name]
        expect(desc[:kind]).to eq(:store)
        expect(desc[:name]).to eq(Reminder.store_name)
      end

      it "Reminder descriptor carries a producer from igniter_companion" do
        desc = store.descriptor_snapshot[:stores][Reminder.store_name]
        expect(desc[:producer][:system]).to eq(:igniter_companion)
        expect(desc[:producer][:name]).to   be_a(String)
      end

      it "TrackerLog descriptor appears in :histories" do
        s = described_class.new
        s.register(TrackerLog)
        desc = s.descriptor_snapshot[:histories][TrackerLog.store_name]
        expect(desc[:kind]).to eq(:history)
        expect(desc[:name]).to eq(TrackerLog.store_name)
      ensure
        s&.close
      end

      it "TrackerLog descriptor key equals the declared partition_key" do
        s = described_class.new
        s.register(TrackerLog)
        desc = s.descriptor_snapshot[:histories][TrackerLog.store_name]
        expect(desc[:key]).to eq(TrackerLog._partition_key)
      ensure
        s&.close
      end
    end

    describe "descriptor field content" do
      subject(:record_class) { Igniter::Companion::Record.from_manifest(RECORD_MANIFEST) }

      it "store descriptor fields list matches manifest fields" do
        s = described_class.new
        s.register(record_class)
        desc = s.descriptor_snapshot[:stores][record_class.store_name]
        field_names = desc[:fields].map { |f| f[:name] }
        expect(field_names).to eq(record_class._fields.keys)
      ensure
        s&.close
      end

      it "store descriptor carries type metadata for typed fields" do
        s = described_class.new
        s.register(record_class)
        desc  = s.descriptor_snapshot[:stores][record_class.store_name]
        title = desc[:fields].find { |f| f[:name] == :title }
        expect(title[:type]).to eq(:string)
      ensure
        s&.close
      end

      it "store descriptor carries values: for enum fields" do
        s = described_class.new
        s.register(record_class)
        desc   = s.descriptor_snapshot[:stores][record_class.store_name]
        status = desc[:fields].find { |f| f[:name] == :status }
        expect(status[:values]).to eq(%i[open done])
      ensure
        s&.close
      end
    end

    describe "register idempotency with descriptors" do
      it "calling register twice does not create duplicate store descriptors" do
        s = described_class.new
        s.register(Reminder)
        s.register(Reminder)
        snap = s.descriptor_snapshot
        expect(snap[:stores].keys.count { |k| k == Reminder.store_name }).to eq(1)
      ensure
        s&.close
      end
    end
  end

  describe "from_manifest with relations → register → typed resolve (end-to-end)" do
    RELATION_MANIFEST = {
      storage: { shape: :store, name: :wiki_pages, key: :id },
      fields: [
        { name: :id,    attributes: {} },
        { name: :title, attributes: { type: :string } }
      ],
      scopes: [],
      indexes: [],
      commands: [],
      relations: [
        {
          name: :revisions_by_page,
          attributes: {
            kind: :event_owner, to: :wiki_revisions,
            join: { id: :page_id }, cardinality: :one_to_many
          }
        }
      ]
    }.freeze

    REVISION_MANIFEST = {
      storage: { shape: :store, name: :wiki_revisions, key: :id },
      fields: [
        { name: :id,      attributes: {} },
        { name: :page_id, attributes: {} },
        { name: :body,    attributes: { type: :string } }
      ],
      scopes: [],
      indexes: [],
      commands: [],
      relations: []
    }.freeze

    it "from_manifest parses relations and register auto-wires them" do
      wiki_page     = Igniter::Companion.from_manifest(RELATION_MANIFEST)
      wiki_revision = Igniter::Companion.from_manifest(REVISION_MANIFEST)

      s = described_class.new
      s.register(wiki_page)
      s.register(wiki_revision)

      s.write(wiki_revision, key: "r1", id: "r1", page_id: "p1", body: "First draft")
      s.write(wiki_revision, key: "r2", id: "r2", page_id: "p1", body: "Second draft")

      result = s.resolve(:revisions_by_page, from: "p1")
      expect(result.size).to eq(2)
      expect(result).to all(be_a(wiki_revision))
      expect(result.map(&:body)).to contain_exactly("First draft", "Second draft")
    ensure
      s&.close
    end

    it "relation_snapshot is populated after register" do
      wiki_page = Igniter::Companion.from_manifest(RELATION_MANIFEST)

      s = described_class.new
      s.register(wiki_page)

      expect(s._relations.keys).to include(:revisions_by_page)
    ensure
      s&.close
    end
  end
end
