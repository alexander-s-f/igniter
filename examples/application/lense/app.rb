# frozen_string_literal: true

require_relative "contracts/codebase_health_contract"
require_relative "reports/lense_analysis_receipt"
require_relative "services/codebase_analyzer"
require_relative "services/issue_session_store"

module Lense
  APP_ROOT = File.expand_path(__dir__)

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
