# frozen_string_literal: true

require "uri"

require "igniter/application"

require_relative "services/finding_extractor"
require_relative "services/research_session_store"
require_relative "services/source_library"
require_relative "web/research_workspace"

module Scout
  APP_ROOT = File.expand_path(__dir__)
  DATA_ROOT = File.join(APP_ROOT, "data")

  def self.default_workdir
    ENV.fetch("SCOUT_WORKDIR", "/tmp/igniter_scout_poc")
  end

  def self.feedback_path(params)
    "/?#{URI.encode_www_form(params)}"
  end

  def self.result_feedback_path(result)
    feedback_param = result.success? ? :notice : :error
    feedback_path(
      {
        feedback_param => result.feedback_code,
        session: result.session_id,
        source: result.source_id,
        finding: result.finding_id,
        receipt: result.receipt_id
      }.compact
    )
  end

  def self.events_read_model(snapshot)
    recent = snapshot.recent_events.map do |event|
      source_id = event.fetch(:source_id) || "-"
      finding_id = event.fetch(:finding_id) || "-"
      "#{event.fetch(:kind)}:#{source_id}:#{finding_id}:#{event.fetch(:status)}"
    end
    "topic=#{snapshot.topic || "none"} session=#{snapshot.session_id || "none"} status=#{snapshot.status} sources=#{snapshot.source_count} findings=#{snapshot.finding_count} contradictions=#{snapshot.contradiction_count} checkpoint=#{snapshot.checkpoint_choice || "none"} receipt=#{snapshot.receipt_id || "none"} actions=#{snapshot.action_count} recent=#{recent.join("|")}"
  end

  def self.build(data_root: DATA_ROOT, workdir: Scout.default_workdir)
    Igniter::Application.rack_app(:scout, root: APP_ROOT, env: :test) do
      service(:scout) { App.new(data_root: data_root, workdir: workdir) }

      mount_web(
        :research_workspace,
        Web.research_workspace_mount,
        at: "/",
        capabilities: %i[screen command],
        metadata: { poc: true }
      )

      get "/events" do
        text Scout.events_read_model(service(:scout).snapshot)
      end

      get "/receipt" do
        text service(:scout).latest_receipt_text
      end

      post "/sessions/start" do |params|
        result = service(:scout).start_session(
          topic: params.fetch("topic", ""),
          source_ids: params.fetch("source_ids", "")
        )
        redirect Scout.result_feedback_path(result)
      end

      post "/findings/extract" do |params|
        result = service(:scout).extract_findings(session_id: params.fetch("session_id", ""))
        redirect Scout.result_feedback_path(result)
      end

      post "/sources/add" do |params|
        result = service(:scout).add_local_source(
          session_id: params.fetch("session_id", ""),
          source_id: params.fetch("source_id", "")
        )
        redirect Scout.result_feedback_path(result)
      end

      post "/checkpoints" do |params|
        result = service(:scout).choose_checkpoint(
          session_id: params.fetch("session_id", ""),
          direction: params.fetch("direction", "")
        )
        redirect Scout.result_feedback_path(result)
      end

      post "/receipts" do |params|
        result = service(:scout).emit_receipt(
          session_id: params.fetch("session_id", ""),
          metadata: { source: :scout_web }
        )
        redirect Scout.result_feedback_path(result)
      end
    end
  end

  class App
    attr_reader :sources, :extractor, :sessions

    def initialize(data_root: DATA_ROOT, workdir: Scout.default_workdir)
      @sources = Services::SourceLibrary.new(root: data_root)
      @extractor = Services::FindingExtractor.new
      @sessions = Services::ResearchSessionStore.new(workdir: workdir)
    end

    def default_topic
      sources.default_topic
    end

    def default_source_ids
      sources.default_source_ids
    end

    def start_session(topic:, source_ids:)
      ids = normalize_source_ids(source_ids)
      return sessions.command_refusal(feedback_code: :scout_no_sources, session_id: nil, source_id: nil, finding_id: nil, status: :no_sources) if ids.empty?

      unknown = ids.find { |id| sources.find(id).nil? }
      return unknown_source(unknown) if unknown

      sessions.start_session(topic: topic, sources: sources.fetch_many(ids))
    end

    def extract_findings(session_id:)
      session_sources(session_id) do |selected_sources|
        sessions.extract_findings(session_id: session_id, sources: selected_sources, extractor: extractor)
      end
    end

    def add_local_source(session_id:, source_id:)
      source = sources.find(source_id)
      return unknown_source(source_id, session_id: session_id) unless source

      snapshot = sessions.snapshot
      selected_ids = (snapshot.source_refs.map { |ref| ref.fetch(:source_id) } | [source.fetch(:id)])
      sessions.add_local_source(
        session_id: session_id,
        source: source,
        sources: sources.fetch_many(selected_ids),
        extractor: extractor
      )
    end

    def choose_checkpoint(session_id:, direction:)
      session_sources(session_id) do |selected_sources|
        sessions.choose_checkpoint(
          session_id: session_id,
          direction: direction,
          sources: selected_sources,
          extractor: extractor
        )
      end
    end

    def emit_receipt(session_id:, metadata: {})
      sessions.emit_receipt(session_id: session_id, metadata: metadata)
    end

    def snapshot(recent_limit: 8)
      sessions.snapshot(recent_limit: recent_limit)
    end

    def events
      sessions.events
    end

    def latest_receipt_text
      path = sessions.latest_receipt_path
      path ? File.read(path) : ""
    end

    private

    def normalize_source_ids(source_ids)
      Array(source_ids).flat_map { |entry| entry.to_s.split(",") }.map(&:strip).reject(&:empty?)
    end

    def session_sources(session_id)
      snapshot = sessions.snapshot
      if snapshot.session_id != session_id.to_s
        return sessions.command_refusal(
          feedback_code: :scout_unknown_session,
          session_id: session_id,
          source_id: nil,
          finding_id: nil,
          status: :unknown_session
        )
      end

      yield sources.fetch_many(snapshot.source_refs.map { |ref| ref.fetch(:source_id) })
    end

    def unknown_source(source_id, session_id: nil)
      sessions.command_refusal(
        feedback_code: :scout_unknown_source,
        session_id: session_id,
        source_id: source_id.to_s,
        finding_id: nil,
        status: :unknown_source
      )
    end
  end
end
