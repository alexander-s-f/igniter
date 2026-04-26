# frozen_string_literal: true

module Lense
  module Services
    class IssueSessionStore
      Session = Struct.new(:id, :finding_id, :status, :steps, :notes, keyword_init: true)
      Step = Struct.new(:id, :title, :status, :note, keyword_init: true)
      Action = Struct.new(:index, :kind, :session_id, :finding_id, :status, keyword_init: true)
      CommandResult = Struct.new(:kind, :feedback_code, :session_id, :finding_id, :action, keyword_init: true) do
        def success?
          kind == :success
        end

        def to_h
          {
            kind: kind,
            feedback_code: feedback_code,
            session_id: session_id,
            finding_id: finding_id,
            action: action&.to_h
          }
        end
      end
      CodebaseSnapshot = Struct.new(
        :scan_id,
        :project_label,
        :target_root_label,
        :ruby_file_count,
        :line_count,
        :health_score,
        :finding_count,
        :top_findings,
        :active_session,
        :action_count,
        :recent_events,
        keyword_init: true
      ) do
        def to_h
          {
            scan_id: scan_id,
            project_label: project_label,
            target_root_label: target_root_label,
            ruby_file_count: ruby_file_count,
            line_count: line_count,
            health_score: health_score,
            finding_count: finding_count,
            top_findings: top_findings.map(&:dup),
            active_session: active_session&.dup,
            action_count: action_count,
            recent_events: recent_events.map(&:dup)
          }
        end
      end

      attr_reader :name

      def initialize
        @name = :lense_issue_sessions
        @analysis = nil
        @sessions = []
        @actions = []
        @next_action_index = 0
      end

      def load_analysis(analysis)
        @analysis = analysis
        record_action(kind: :scan_refreshed, session_id: nil, finding_id: nil, status: :ok)
      end

      def start_session(finding_id)
        finding = find_finding(finding_id)
        return refusal(:session_start_refused, nil, finding_id, :finding_not_found) unless finding

        session = Session.new(
          id: next_session_id(finding),
          finding_id: finding.fetch(:id),
          status: :open,
          steps: default_steps(finding),
          notes: []
        )
        @sessions << session
        action = record_action(kind: :session_started, session_id: session.id, finding_id: finding.fetch(:id), status: :open)
        command_result(:success, :session_started, session.id, finding.fetch(:id), action)
      end

      def record_step(session_id, action:, step_id: nil, note: nil)
        session = find_session(session_id)
        return refusal(:step_action_refused, session_id, nil, :session_not_found) unless session

        case action.to_s
        when "done"
          update_step(session, step_id, :done, :step_marked_done)
        when "skip"
          update_step(session, step_id, :skipped, :step_skipped)
        when "note"
          record_note(session, note)
        else
          refusal(:step_action_refused, session.id, session.finding_id, :invalid_step_action)
        end
      end

      def snapshot(recent_limit: 8)
        counts = analysis.fetch(:counts)
        CodebaseSnapshot.new(
          scan_id: analysis.fetch(:scan).fetch(:scan_id),
          project_label: analysis.fetch(:scan).fetch(:project_label),
          target_root_label: analysis.fetch(:scan).fetch(:target_root_label),
          ruby_file_count: counts.fetch(:ruby_files),
          line_count: counts.fetch(:lines),
          health_score: analysis.fetch(:health_score),
          finding_count: analysis.fetch(:findings).length,
          top_findings: analysis.fetch(:findings).first(5).map(&:dup).freeze,
          active_session: active_session_hash,
          action_count: @actions.length,
          recent_events: @actions.last(recent_limit).map { |action| action.to_h.freeze }.freeze
        ).freeze
      end

      def events
        @actions.map { |action| action.to_h.dup }
      end

      private

      def analysis
        @analysis || {
          scan: { scan_id: nil, project_label: nil, target_root_label: nil },
          counts: { ruby_files: 0, lines: 0 },
          findings: [],
          health_score: 0
        }
      end

      def find_finding(finding_id)
        analysis.fetch(:findings).find { |finding| finding.fetch(:id) == finding_id.to_s }
      end

      def find_session(session_id)
        @sessions.find { |session| session.id == session_id.to_s }
      end

      def active_session
        @sessions.reverse.find { |session| session.status == :open }
      end

      def active_session_hash
        session = active_session
        return nil unless session

        {
          id: session.id,
          finding_id: session.finding_id,
          status: session.status,
          steps: session.steps.map { |step| step.to_h.dup },
          notes: session.notes.dup
        }
      end

      def next_session_id(finding)
        "session-#{finding.fetch(:id).gsub(/[^a-zA-Z0-9]+/, "-").downcase}"
      end

      def default_steps(finding)
        [
          Step.new(id: "inspect_evidence", title: "Inspect #{finding.fetch(:subject)}", status: :open),
          Step.new(id: "plan_change", title: "Plan a safe local refactor", status: :open),
          Step.new(id: "verify_safely", title: "Verify with existing tests or review", status: :open)
        ]
      end

      def update_step(session, step_id, status, feedback_code)
        step = session.steps.find { |entry| entry.id == step_id.to_s } || session.steps.find { |entry| entry.status == :open }
        return refusal(:step_action_refused, session.id, session.finding_id, :invalid_step_action) unless step

        step.status = status
        session.status = :closed if session.steps.all? { |entry| entry.status != :open }
        action = record_action(kind: feedback_code, session_id: session.id, finding_id: session.finding_id, status: status)
        command_result(:success, feedback_code, session.id, session.finding_id, action)
      end

      def record_note(session, note)
        normalized_note = note.to_s.strip
        return refusal(:step_action_refused, session.id, session.finding_id, :blank_note) if normalized_note.empty?

        session.notes << normalized_note
        action = record_action(kind: :note_added, session_id: session.id, finding_id: session.finding_id, status: :noted)
        command_result(:success, :note_added, session.id, session.finding_id, action)
      end

      def refusal(kind, session_id, finding_id, feedback_code)
        action = record_action(kind: kind, session_id: session_id, finding_id: finding_id, status: :refused)
        command_result(:failure, feedback_code, session_id, finding_id, action)
      end

      def record_action(kind:, session_id:, finding_id:, status:)
        action = Action.new(
          index: @next_action_index,
          kind: kind.to_sym,
          session_id: session_id,
          finding_id: finding_id,
          status: status.to_sym
        )
        @actions << action
        @next_action_index += 1
        action
      end

      def command_result(kind, feedback_code, session_id, finding_id, action)
        CommandResult.new(
          kind: kind,
          feedback_code: feedback_code,
          session_id: session_id,
          finding_id: finding_id,
          action: action
        )
      end
    end
  end
end
