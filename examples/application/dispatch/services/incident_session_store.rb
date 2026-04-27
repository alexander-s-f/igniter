# frozen_string_literal: true

require "fileutils"
require "json"

require_relative "../reports/incident_receipt"

module Dispatch
  module Services
    class IncidentSessionStore
      Session = Struct.new(:id, :incident_id, :analysis, :checkpoint, :receipt_id, keyword_init: true)
      Action = Struct.new(:index, :kind, :session_id, :incident_id, :event_id, :team, :status, :metadata, keyword_init: true)
      CommandResult = Struct.new(:kind, :feedback_code, :session_id, :incident_id, :event_id, :team, :receipt_id, :action, keyword_init: true) do
        def success?
          kind == :success
        end

        def to_h
          {
            kind: kind,
            feedback_code: feedback_code,
            session_id: session_id,
            incident_id: incident_id,
            event_id: event_id,
            team: team,
            receipt_id: receipt_id,
            action: action&.to_h
          }
        end
      end
      DispatchSnapshot = Struct.new(
        :session_id,
        :incident_id,
        :title,
        :service,
        :status,
        :severity,
        :suspected_cause,
        :event_count,
        :route_options,
        :assigned_team,
        :escalated_team,
        :handoff_ready,
        :top_events,
        :routing_evidence,
        :receipt_id,
        :action_count,
        :recent_events,
        keyword_init: true
      ) do
        def to_h
          {
            session_id: session_id,
            incident_id: incident_id,
            title: title,
            service: service,
            status: status,
            severity: severity,
            suspected_cause: suspected_cause,
            event_count: event_count,
            route_options: route_options.map(&:dup),
            assigned_team: assigned_team,
            escalated_team: escalated_team,
            handoff_ready: handoff_ready,
            top_events: top_events.map(&:dup),
            routing_evidence: routing_evidence.map(&:dup),
            receipt_id: receipt_id,
            action_count: action_count,
            recent_events: recent_events.map(&:dup)
          }
        end
      end

      attr_reader :workdir

      def initialize(workdir:)
        @workdir = File.expand_path(workdir)
        @sessions = []
        @actions = []
        @next_action_index = 0
        FileUtils.mkdir_p([sessions_dir, actions_dir, receipts_dir])
      end

      def open_incident(bundle:)
        incident = bundle.fetch(:incident)
        session = Session.new(
          id: "dispatch-session-#{incident.fetch(:id).downcase}",
          incident_id: incident.fetch(:id),
          analysis: empty_analysis(bundle),
          checkpoint: {},
          receipt_id: nil
        )
        replace_session(session)
        action = record_action(kind: :incident_opened, session_id: session.id, incident_id: session.incident_id, event_id: nil, team: nil, status: :open)
        bundle.fetch(:events).each do |event|
          record_action(kind: :event_ingested, session_id: session.id, incident_id: session.incident_id, event_id: event.fetch(:id), team: nil, status: :seeded)
        end
        persist_session(session)
        command_result(:success, :dispatch_incident_opened, session.id, session.incident_id, nil, nil, session.receipt_id, action)
      end

      def triage_incident(session_id:, bundle:, analyzer:)
        session = find_session(session_id)
        return refusal(:dispatch_unknown_session, session_id, nil, nil, nil, :unknown_session) unless session

        refresh_analysis(session, bundle: bundle, analyzer: analyzer)
        action = record_action(kind: :triage_completed, session_id: session.id, incident_id: session.incident_id, event_id: nil, team: nil, status: session.analysis.fetch(:severity).to_sym)
        session.analysis.fetch(:routing_options).each do |option|
          record_action(kind: :route_proposed, session_id: session.id, incident_id: session.incident_id, event_id: nil, team: option.fetch(:team), status: option.fetch(:role).to_sym)
        end
        persist_session(session)
        command_result(:success, :dispatch_triage_completed, session.id, session.incident_id, nil, nil, session.receipt_id, action)
      end

      def assign_owner(session_id:, team:, bundle:, analyzer:)
        checkpoint_session(
          session_id: session_id,
          checkpoint: { type: :assignment, team: team.to_s },
          feedback_code: :dispatch_owner_assigned,
          action_kind: :assignment_recorded,
          bundle: bundle,
          analyzer: analyzer
        )
      end

      def escalate_incident(session_id:, team:, reason:, bundle:, analyzer:)
        normalized_reason = reason.to_s.strip
        session = find_session(session_id)
        incident_id = session&.incident_id
        return refusal(:dispatch_blank_escalation_reason, session_id, incident_id, nil, team.to_s, :blank_escalation_reason) if normalized_reason.empty?

        checkpoint_session(
          session_id: session_id,
          checkpoint: { type: :escalation, team: team.to_s, reason: normalized_reason },
          feedback_code: :dispatch_incident_escalated,
          action_kind: :escalation_recorded,
          bundle: bundle,
          analyzer: analyzer
        )
      end

      def emit_receipt(session_id:, metadata: {})
        session = find_session(session_id)
        return refusal(:dispatch_unknown_session, session_id, nil, nil, nil, :unknown_session) unless session

        readiness = session.analysis.fetch(:handoff_readiness)
        return refusal(:dispatch_receipt_not_ready, session.id, session.incident_id, nil, nil, :receipt_not_ready) unless readiness.fetch(:ready)

        receipt = Reports::IncidentReceipt.build(
          session_id: session.id,
          payload: session.analysis.fetch(:incident_receipt_payload),
          events: events,
          metadata: metadata
        )
        path = File.join(receipts_dir, "#{safe_id(session.id)}.md")
        File.write(path, receipt.to_markdown)
        session.receipt_id = receipt.receipt_id
        action = record_action(kind: :receipt_emitted, session_id: session.id, incident_id: session.incident_id, event_id: nil, team: checkpoint_team(session), status: :ready, metadata: { path: path })
        persist_session(session)
        command_result(:success, :dispatch_receipt_emitted, session.id, session.incident_id, nil, checkpoint_team(session), session.receipt_id, action)
      end

      def snapshot(recent_limit: 8)
        session = @sessions.last
        return empty_snapshot(recent_limit: recent_limit) unless session

        analysis = session.analysis
        incident = analysis.fetch(:incident)
        DispatchSnapshot.new(
          session_id: session.id,
          incident_id: session.incident_id,
          title: incident.fetch(:title),
          service: incident.fetch(:service),
          status: status_for(session),
          severity: analysis.fetch(:severity),
          suspected_cause: analysis.fetch(:suspected_cause),
          event_count: analysis.fetch(:event_facts).length,
          route_options: analysis.fetch(:routing_options).map(&:dup).freeze,
          assigned_team: assigned_team(session),
          escalated_team: escalated_team(session),
          handoff_ready: analysis.fetch(:handoff_readiness).fetch(:ready),
          top_events: analysis.fetch(:event_facts).first(4).map(&:dup).freeze,
          routing_evidence: analysis.fetch(:incident_receipt_payload).fetch(:evidence_refs, []).map(&:dup).freeze,
          receipt_id: session.receipt_id,
          action_count: @actions.length,
          recent_events: @actions.last(recent_limit).map { |action| action.to_h.freeze }.freeze
        ).freeze
      end

      def events
        @actions.map { |action| action.to_h.dup }
      end

      def latest_receipt_path
        Dir.glob(File.join(receipts_dir, "*.md")).max
      end

      def command_refusal(feedback_code:, session_id:, incident_id:, event_id:, team:, status:)
        refusal(feedback_code, session_id, incident_id, event_id, team, status)
      end

      private

      def checkpoint_session(session_id:, checkpoint:, feedback_code:, action_kind:, bundle:, analyzer:)
        session = find_session(session_id)
        return refusal(:dispatch_unknown_session, session_id, nil, nil, checkpoint.fetch(:team), :unknown_session) unless session
        return refusal(:dispatch_triage_not_ready, session.id, session.incident_id, nil, checkpoint.fetch(:team), :triage_not_ready) if session.analysis.fetch(:event_facts).empty?

        session.checkpoint = checkpoint
        refresh_analysis(session, bundle: bundle, analyzer: analyzer)
        readiness = session.analysis.fetch(:assignment_readiness)
        return refusal(feedback_for_missing(readiness.fetch(:missing)), session.id, session.incident_id, nil, checkpoint.fetch(:team), readiness.fetch(:missing)) unless readiness.fetch(:ready)

        action = record_action(kind: action_kind, session_id: session.id, incident_id: session.incident_id, event_id: nil, team: checkpoint.fetch(:team), status: checkpoint.fetch(:type))
        persist_session(session)
        command_result(:success, feedback_code, session.id, session.incident_id, nil, checkpoint.fetch(:team), session.receipt_id, action)
      end

      def refresh_analysis(session, bundle:, analyzer:)
        session.analysis = analyzer.analyze(
          incident: bundle.fetch(:incident),
          events: bundle.fetch(:events),
          runbooks: bundle.fetch(:runbooks),
          teams: bundle.fetch(:teams),
          checkpoint: session.checkpoint
        )
      end

      def empty_analysis(bundle)
        {
          incident: bundle.fetch(:incident),
          events: bundle.fetch(:events),
          runbooks: bundle.fetch(:runbooks),
          teams: bundle.fetch(:teams),
          event_facts: [],
          severity: "unknown",
          suspected_cause: "unknown",
          routing_options: [],
          assignment_readiness: { ready: false, type: nil, team: nil, missing: :no_events },
          handoff_readiness: { ready: false, checkpoint: {}, missing: :no_events },
          incident_receipt_payload: { evidence_refs: [], valid: false }
        }.freeze
      end

      def replace_session(session)
        @sessions.reject! { |entry| entry.id == session.id }
        @sessions << session
      end

      def find_session(session_id)
        @sessions.find { |session| session.id == session_id.to_s }
      end

      def status_for(session)
        return :complete if session.receipt_id
        return :escalated if escalated_team(session)
        return :assigned if assigned_team(session)
        return :triaged if session.analysis.fetch(:event_facts).any?

        :open
      end

      def assigned_team(session)
        return nil unless session.checkpoint.fetch(:type, nil) == :assignment

        session.checkpoint.fetch(:team)
      end

      def escalated_team(session)
        return nil unless session.checkpoint.fetch(:type, nil) == :escalation

        session.checkpoint.fetch(:team)
      end

      def checkpoint_team(session)
        session.checkpoint.fetch(:team, nil)
      end

      def feedback_for_missing(reason)
        {
          invalid_assignment: :dispatch_invalid_assignment,
          invalid_checkpoint: :dispatch_invalid_assignment,
          blank_escalation_reason: :dispatch_blank_escalation_reason
        }.fetch(reason, :dispatch_invalid_assignment)
      end

      def empty_snapshot(recent_limit:)
        DispatchSnapshot.new(
          session_id: nil,
          incident_id: nil,
          title: nil,
          service: nil,
          status: :empty,
          severity: "unknown",
          suspected_cause: "unknown",
          event_count: 0,
          route_options: [],
          assigned_team: nil,
          escalated_team: nil,
          handoff_ready: false,
          top_events: [],
          routing_evidence: [],
          receipt_id: nil,
          action_count: @actions.length,
          recent_events: @actions.last(recent_limit).map { |action| action.to_h.freeze }.freeze
        ).freeze
      end

      def refusal(feedback_code, session_id, incident_id, event_id, team, status)
        action = record_action(
          kind: :command_refused,
          session_id: session_id,
          incident_id: incident_id,
          event_id: event_id,
          team: team,
          status: status
        )
        command_result(:failure, feedback_code, session_id, incident_id, event_id, team, nil, action)
      end

      def record_action(kind:, session_id:, incident_id:, event_id:, team:, status:, metadata: {})
        action = Action.new(
          index: @next_action_index,
          kind: kind.to_sym,
          session_id: session_id,
          incident_id: incident_id,
          event_id: event_id,
          team: team,
          status: status.to_sym,
          metadata: metadata.dup.freeze
        )
        @actions << action
        @next_action_index += 1
        append_action(action)
        action
      end

      def command_result(kind, feedback_code, session_id, incident_id, event_id, team, receipt_id, action)
        CommandResult.new(
          kind: kind,
          feedback_code: feedback_code,
          session_id: session_id,
          incident_id: incident_id,
          event_id: event_id,
          team: team,
          receipt_id: receipt_id,
          action: action
        )
      end

      def persist_session(session)
        File.write(
          File.join(sessions_dir, "#{safe_id(session.id)}.json"),
          JSON.pretty_generate(
            id: session.id,
            incident_id: session.incident_id,
            checkpoint: session.checkpoint,
            receipt_id: session.receipt_id
          )
        )
      end

      def append_action(action)
        FileUtils.mkdir_p(actions_dir)
        File.open(File.join(actions_dir, "actions.jsonl"), "a") do |file|
          file.puts(JSON.generate(action.to_h))
        end
      end

      def sessions_dir
        File.join(workdir, "sessions")
      end

      def actions_dir
        File.join(workdir, "actions")
      end

      def receipts_dir
        File.join(workdir, "receipts")
      end

      def safe_id(id)
        id.to_s.gsub(/[^a-zA-Z0-9_.-]+/, "-")
      end
    end
  end
end
