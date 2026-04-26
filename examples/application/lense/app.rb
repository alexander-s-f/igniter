# frozen_string_literal: true

require "uri"

require "igniter/application"

require_relative "contracts/codebase_health_contract"
require_relative "reports/lense_analysis_receipt"
require_relative "services/codebase_analyzer"
require_relative "services/issue_session_store"
require_relative "web/lense_dashboard"

module Lense
  APP_ROOT = File.expand_path(__dir__)

  def self.feedback_path(params)
    "/?#{URI.encode_www_form(params)}"
  end

  def self.events_read_model(snapshot)
    recent = snapshot.recent_events.map do |event|
      session_id = event.fetch(:session_id) || "-"
      finding_id = event.fetch(:finding_id) || "-"
      "#{event.fetch(:kind)}:#{session_id}:#{finding_id}:#{event.fetch(:status)}"
    end
    "scan=#{snapshot.scan_id} findings=#{snapshot.finding_count} session=#{snapshot.active_session&.fetch(:status) || "none"} actions=#{snapshot.action_count} recent=#{recent.join("|")}"
  end

  def self.build(target_root:, project_label: nil, thresholds: {})
    Igniter::Application.rack_app(:lense, root: APP_ROOT, env: :test) do
      service(:lense) { App.new(target_root: target_root, project_label: project_label, thresholds: thresholds) }

      mount_web(
        :lense_dashboard,
        Web.lense_dashboard_mount,
        at: "/",
        capabilities: %i[screen command],
        metadata: { poc: true }
      )

      get "/events" do
        text Lense.events_read_model(service(:lense).snapshot)
      end

      get "/report" do
        text service(:lense).receipt(metadata: { source: :lense_web }).to_h.inspect
      end

      post "/scan" do
        service(:lense).refresh_scan
        redirect Lense.feedback_path(notice: :scan_refreshed)
      end

      post "/sessions/start" do |params|
        result = service(:lense).start_session(params.fetch("finding_id", ""))
        if result.success?
          redirect Lense.feedback_path(notice: result.feedback_code, session: result.session_id, finding: result.finding_id)
        else
          redirect Lense.feedback_path(error: result.feedback_code, finding: result.finding_id)
        end
      end

      post "/sessions/:id/steps" do |params|
        result = service(:lense).record_step(
          params.fetch("id", ""),
          action: params.fetch("action", ""),
          step_id: params["step_id"],
          note: params["note"]
        )
        if result.success?
          redirect Lense.feedback_path(notice: result.feedback_code, session: result.session_id, finding: result.finding_id)
        else
          redirect Lense.feedback_path(error: result.feedback_code, session: result.session_id, finding: result.finding_id)
        end
      end
    end
  end

  class App
    attr_reader :target_root, :project_label, :analyzer, :sessions, :analysis

    def initialize(target_root:, project_label: nil, thresholds: {})
      @target_root = File.expand_path(target_root.to_s)
      @project_label = project_label || File.basename(@target_root)
      @thresholds = thresholds
      @analyzer = Services::CodebaseAnalyzer.new(target_root: @target_root, project_label: @project_label)
      @sessions = Services::IssueSessionStore.new
      @analysis = nil
    end

    def refresh_scan
      @analysis = Contracts::CodebaseHealthContract.evaluate(scan: analyzer.scan, thresholds: @thresholds)
      sessions.load_analysis(@analysis)
      @analysis
    end

    def snapshot
      refresh_scan unless analysis
      sessions.snapshot
    end

    def start_session(finding_id)
      refresh_scan unless analysis
      sessions.start_session(finding_id)
    end

    def record_step(session_id, action:, step_id: nil, note: nil)
      sessions.record_step(session_id, action: action, step_id: step_id, note: note)
    end

    def receipt(metadata: {})
      refresh_scan unless analysis
      Reports::LenseAnalysisReceipt.build(
        analysis: analysis,
        snapshot: snapshot,
        events: sessions.events,
        metadata: metadata
      )
    end
  end
end
