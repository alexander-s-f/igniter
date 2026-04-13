# frozen_string_literal: true

require "spec_helper"
require "igniter/cluster"
require "igniter/data"
require "igniter"

RSpec.describe Igniter::Cluster::Events do
  let(:store) { Igniter::Data::Stores::InMemory.new }

  describe Igniter::Cluster::Events::Envelope do
    it "builds a serializable cluster event envelope" do
      envelope = Igniter::Cluster::Events::Envelope.build(
        type: :voice_session_created,
        topic: :voice_sessions,
        source: :edge,
        entity_type: :voice_session,
        entity_id: "abc123",
        payload: { transcript: "hello" },
        metadata: { owner: "edge-1" }
      )

      expect(envelope.topic).to eq("voice_sessions")
      expect(envelope.type).to eq("voice_session_created")
      expect(envelope.source).to eq("edge")
      expect(envelope.payload).to include("transcript" => "hello")
      expect(envelope.metadata).to include("owner" => "edge-1")
      expect(Igniter::Cluster::Events::Envelope.from_h(envelope.as_json).event_id).to eq(envelope.event_id)
    end

    it "wraps a runtime event for cluster transport" do
      runtime_event = Igniter::Events::Event.new(
        event_id: "evt-1",
        type: :node_succeeded,
        execution_id: "exec-1",
        node_id: "node-1",
        node_name: :gross_total,
        path: "gross_total",
        status: :succeeded,
        payload: { value: 42 },
        timestamp: Time.now.utc
      )

      envelope = Igniter::Cluster::Events::Envelope.from_runtime_event(runtime_event, source: :main)

      expect(envelope.topic).to eq("runtime")
      expect(envelope.entity_type).to eq("execution")
      expect(envelope.entity_id).to eq("exec-1")
      expect(envelope.payload["type"]).to eq("node_succeeded")
    end
  end

  describe Igniter::Cluster::Events::Log do
    subject(:log) { described_class.new(store: store) }

    it "publishes and replays events from the store" do
      published = log.publish(
        type: :voice_session_created,
        topic: :voice_sessions,
        source: :edge,
        entity_type: :voice_session,
        entity_id: "abc123",
        payload: { transcript: "hello" }
      )

      expect(log.all(topic: :voice_sessions).map(&:event_id)).to eq([published.event_id])
      expect(log.since(timestamp: published.timestamp - 1).map(&:event_id)).to eq([published.event_id])
    end

    it "supports local subscribers" do
      observed = []
      log.subscribe { |event| observed << event.type }

      log.publish(type: :voice_session_created, source: :edge)

      expect(observed).to eq(["voice_session_created"])
    end
  end

  describe Igniter::Cluster::Events::ProjectionFeed do
    let(:log) { Igniter::Cluster::Events::Log.new(store: store) }

    it "processes published events and stores a checkpoint" do
      observed = []
      feed = described_class.new(
        name: :voice_session_dashboard,
        log: log,
        store: store,
        projector: ->(event) { observed << [event.topic, event.type, event.entity_id] }
      ).start!

      event = log.publish(
        type: :voice_session_responded,
        topic: :voice_sessions,
        source: :edge,
        entity_type: :voice_session,
        entity_id: "abc123"
      )

      expect(observed).to eq([["voice_sessions", "voice_session_responded", "abc123"]])
      expect(feed.checkpoint).to include(
        "name" => "voice_session_dashboard",
        "event_id" => event.event_id,
        "topic" => "voice_sessions"
      )
    end

    it "can replay missed events from the log" do
      log.publish(type: :voice_session_created, topic: :voice_sessions, source: :edge, entity_id: "a")
      log.publish(type: :camera_event_created, topic: :camera_events, source: :edge, entity_id: "b")

      observed = []
      feed = described_class.new(
        name: :voice_session_projection,
        log: log,
        store: store,
        projector: ->(event) { observed << event.entity_id }
      )

      replayed = feed.replay!(topic: :voice_sessions)

      expect(replayed.map(&:entity_id)).to eq(["a"])
      expect(observed).to eq(["a"])
    end
  end
end
