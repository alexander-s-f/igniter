# frozen_string_literal: true

require "uri"

require "igniter/application"

require_relative "services/dispatch_analyzer"
require_relative "services/incident_library"
require_relative "services/incident_session_store"
require_relative "web/command_center"

module Dispatch
  APP_ROOT = File.expand_path(__dir__)
  DATA_ROOT = File.join(APP_ROOT, "data")

  def self.default_workdir
    ENV.fetch("DISPATCH_WORKDIR", "/tmp/igniter_dispatch_poc")
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
        incident: result.incident_id,
        event: result.event_id,
        team: result.team,
        receipt: result.receipt_id
      }.compact
    )
  end

  def self.events_read_model(snapshot)
    recent = snapshot.recent_events.map do |event|
      event_id = event.fetch(:event_id) || "-"
      team = event.fetch(:team) || "-"
      "#{event.fetch(:kind)}:#{event.fetch(:incident_id)}:#{event_id}:#{team}:#{event.fetch(:status)}"
    end
    "incident=#{snapshot.incident_id || "none"} session=#{snapshot.session_id || "none"} status=#{snapshot.status} severity=#{snapshot.severity} cause=#{snapshot.suspected_cause} events=#{snapshot.event_count} assigned=#{snapshot.assigned_team || "none"} escalated=#{snapshot.escalated_team || "none"} handoff=#{snapshot.handoff_ready} receipt=#{snapshot.receipt_id || "none"} actions=#{snapshot.action_count} recent=#{recent.join("|")}"
  end

  def self.build(data_root: DATA_ROOT, workdir: Dispatch.default_workdir)
    Igniter::Application.rack_app(:dispatch, root: APP_ROOT, env: :test) do
      service(:dispatch) { App.new(data_root: data_root, workdir: workdir) }

      mount_web(
        :command_center,
        Web.command_center_mount,
        at: "/",
        capabilities: %i[screen command],
        metadata: { poc: true }
      )

      get "/events" do
        text Dispatch.events_read_model(service(:dispatch).snapshot)
      end

      get "/receipt" do
        text service(:dispatch).latest_receipt_text
      end

      post "/incidents/open" do |params|
        result = service(:dispatch).open_incident(incident_id: params.fetch("incident_id", ""))
        redirect Dispatch.result_feedback_path(result)
      end

      post "/incidents/triage" do |params|
        result = service(:dispatch).triage_incident(session_id: params.fetch("session_id", ""))
        redirect Dispatch.result_feedback_path(result)
      end

      post "/assignments" do |params|
        result = service(:dispatch).assign_owner(
          session_id: params.fetch("session_id", ""),
          team: params.fetch("team", "")
        )
        redirect Dispatch.result_feedback_path(result)
      end

      post "/escalations" do |params|
        result = service(:dispatch).escalate_incident(
          session_id: params.fetch("session_id", ""),
          team: params.fetch("team", ""),
          reason: params.fetch("reason", "")
        )
        redirect Dispatch.result_feedback_path(result)
      end

      post "/receipts" do |params|
        result = service(:dispatch).emit_receipt(
          session_id: params.fetch("session_id", ""),
          metadata: { source: :dispatch_web }
        )
        redirect Dispatch.result_feedback_path(result)
      end
    end
  end

  class App
    attr_reader :incidents, :analyzer, :sessions

    def initialize(data_root: DATA_ROOT, workdir: Dispatch.default_workdir)
      @incidents = Services::IncidentLibrary.new(root: data_root)
      @analyzer = Services::DispatchAnalyzer.new
      @sessions = Services::IncidentSessionStore.new(workdir: workdir)
    end

    def default_incident_id
      incidents.default_incident_id
    end

    def open_incident(incident_id:)
      bundle = incidents.bundle(incident_id.to_s)
      return unknown_incident(incident_id) unless bundle

      sessions.open_incident(bundle: bundle)
    end

    def triage_incident(session_id:)
      session_bundle(session_id) do |bundle|
        sessions.triage_incident(session_id: session_id, bundle: bundle, analyzer: analyzer)
      end
    end

    def assign_owner(session_id:, team:)
      return unknown_team(session_id, team) unless incidents.team?(team)

      session_bundle(session_id) do |bundle|
        sessions.assign_owner(session_id: session_id, team: team, bundle: bundle, analyzer: analyzer)
      end
    end

    def escalate_incident(session_id:, team:, reason:)
      return unknown_team(session_id, team) unless incidents.team?(team)

      session_bundle(session_id) do |bundle|
        sessions.escalate_incident(
          session_id: session_id,
          team: team,
          reason: reason,
          bundle: bundle,
          analyzer: analyzer
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

    def session_bundle(session_id)
      snapshot = sessions.snapshot
      if snapshot.session_id != session_id.to_s
        return sessions.command_refusal(
          feedback_code: :dispatch_unknown_session,
          session_id: session_id,
          incident_id: nil,
          event_id: nil,
          team: nil,
          status: :unknown_session
        )
      end

      bundle = incidents.bundle(snapshot.incident_id)
      return unknown_incident(snapshot.incident_id) unless bundle

      yield bundle
    end

    def unknown_incident(incident_id)
      sessions.command_refusal(
        feedback_code: :dispatch_unknown_incident,
        session_id: nil,
        incident_id: incident_id.to_s,
        event_id: nil,
        team: nil,
        status: :unknown_incident
      )
    end

    def unknown_team(session_id, team)
      sessions.command_refusal(
        feedback_code: :dispatch_unknown_team,
        session_id: session_id,
        incident_id: snapshot.incident_id,
        event_id: nil,
        team: team.to_s,
        status: :unknown_team
      )
    end
  end
end
