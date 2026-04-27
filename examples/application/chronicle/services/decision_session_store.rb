# frozen_string_literal: true

require "fileutils"
require "json"

require_relative "../reports/decision_receipt"

module Chronicle
  module Services
    class DecisionSessionStore
      Session = Struct.new(:id, :proposal_id, :analysis, :signoffs, :refusals, :acknowledged_conflicts, :receipt_id, keyword_init: true)
      Action = Struct.new(:index, :kind, :session_id, :proposal_id, :decision_id, :status, :metadata, keyword_init: true)
      CommandResult = Struct.new(:kind, :feedback_code, :session_id, :proposal_id, :decision_id, :receipt_id, :action, keyword_init: true) do
        def success?
          kind == :success
        end

        def to_h
          {
            kind: kind,
            feedback_code: feedback_code,
            session_id: session_id,
            proposal_id: proposal_id,
            decision_id: decision_id,
            receipt_id: receipt_id,
            action: action&.to_h
          }
        end
      end
      ChronicleSnapshot = Struct.new(
        :proposal_id,
        :proposal_title,
        :session_id,
        :status,
        :conflict_count,
        :open_conflict_count,
        :required_signoffs,
        :signed_by,
        :refused_by,
        :top_conflicts,
        :related_decisions,
        :receipt_id,
        :action_count,
        :recent_events,
        keyword_init: true
      ) do
        def to_h
          {
            proposal_id: proposal_id,
            proposal_title: proposal_title,
            session_id: session_id,
            status: status,
            conflict_count: conflict_count,
            open_conflict_count: open_conflict_count,
            required_signoffs: required_signoffs.dup,
            signed_by: signed_by.dup,
            refused_by: refused_by.dup,
            top_conflicts: top_conflicts.map(&:dup),
            related_decisions: related_decisions.map(&:dup),
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

      def create_scan(proposal:, decisions:, scanner:)
        session = Session.new(
          id: next_session_id(proposal),
          proposal_id: proposal.fetch(:id),
          signoffs: [],
          refusals: [],
          acknowledged_conflicts: [],
          receipt_id: nil
        )
        session.analysis = scanner.analyze(proposal: proposal, decisions: decisions)
        replace_session(session)
        action = record_action(kind: :proposal_scanned, session_id: session.id, proposal_id: session.proposal_id, decision_id: nil, status: :ok)
        session.analysis.fetch(:conflicts).each do |conflict|
          record_action(
            kind: :conflict_detected,
            session_id: session.id,
            proposal_id: session.proposal_id,
            decision_id: conflict.fetch(:decision_id),
            status: :open
          )
        end
        persist_session(session)
        command_result(:success, :chronicle_scan_created, session.id, session.proposal_id, nil, session.receipt_id, action)
      end

      def acknowledge_conflict(session_id:, decision_id:, decisions:, scanner:, proposal:)
        session = find_session(session_id)
        return refusal(:chronicle_unknown_session, session_id, nil, decision_id, :unknown_session) unless session

        conflict = session.analysis.fetch(:conflicts).find { |entry| entry.fetch(:decision_id) == decision_id.to_s }
        return refusal(:chronicle_unknown_decision, session.id, session.proposal_id, decision_id, :unknown_decision) unless conflict

        session.acknowledged_conflicts |= [conflict.fetch(:decision_id)]
        refresh_analysis(session, proposal: proposal, decisions: decisions, scanner: scanner)
        action = record_action(
          kind: :conflict_acknowledged,
          session_id: session.id,
          proposal_id: session.proposal_id,
          decision_id: conflict.fetch(:decision_id),
          status: :acknowledged
        )
        persist_session(session)
        command_result(:success, :chronicle_conflict_acknowledged, session.id, session.proposal_id, conflict.fetch(:decision_id), session.receipt_id, action)
      end

      def sign_off(session_id:, signer:, decisions:, scanner:, proposal:)
        session = find_session(session_id)
        return refusal(:chronicle_unknown_session, session_id, nil, nil, :unknown_session) unless session

        normalized = signer.to_s.strip
        return refusal(:chronicle_blank_signer, session.id, session.proposal_id, nil, :blank_signer) if normalized.empty?

        session.signoffs |= [normalized]
        refresh_analysis(session, proposal: proposal, decisions: decisions, scanner: scanner)
        action = record_action(kind: :signoff_recorded, session_id: session.id, proposal_id: session.proposal_id, decision_id: nil, status: :signed, metadata: { signer: normalized })
        persist_session(session)
        command_result(:success, :chronicle_signoff_recorded, session.id, session.proposal_id, nil, session.receipt_id, action)
      end

      def refuse_signoff(session_id:, signer:, reason:, decisions:, scanner:, proposal:)
        session = find_session(session_id)
        return refusal(:chronicle_unknown_session, session_id, nil, nil, :unknown_session) unless session

        normalized = signer.to_s.strip
        return refusal(:chronicle_blank_signer, session.id, session.proposal_id, nil, :blank_signer) if normalized.empty?

        normalized_reason = reason.to_s.strip
        return refusal(:chronicle_blank_reason, session.id, session.proposal_id, nil, :blank_reason) if normalized_reason.empty?

        session.refusals << { signer: normalized, reason: normalized_reason }.freeze
        refresh_analysis(session, proposal: proposal, decisions: decisions, scanner: scanner)
        action = record_action(kind: :signoff_refused, session_id: session.id, proposal_id: session.proposal_id, decision_id: nil, status: :refused, metadata: { signer: normalized })
        persist_session(session)
        command_result(:success, :chronicle_signoff_refused, session.id, session.proposal_id, nil, session.receipt_id, action)
      end

      def emit_receipt(session_id:, metadata: {})
        session = find_session(session_id)
        return refusal(:chronicle_unknown_session, session_id, nil, nil, :unknown_session) unless session

        readiness = session.analysis.fetch(:readiness)
        return refusal(:chronicle_receipt_not_ready, session.id, session.proposal_id, nil, :receipt_not_ready) if readiness.fetch(:state) == :needs_review

        receipt = Reports::DecisionReceipt.build(
          session_id: session.id,
          payload: session.analysis.fetch(:receipt_payload),
          events: events,
          metadata: metadata
        )
        path = File.join(receipts_dir, "#{safe_id(session.id)}.md")
        File.write(path, receipt.to_markdown)
        session.receipt_id = receipt.receipt_id
        action = record_action(kind: :receipt_emitted, session_id: session.id, proposal_id: session.proposal_id, decision_id: nil, status: readiness.fetch(:state), metadata: { path: path })
        persist_session(session)
        command_result(:success, :chronicle_receipt_emitted, session.id, session.proposal_id, nil, session.receipt_id, action)
      end

      def snapshot(recent_limit: 8)
        session = @sessions.last
        return empty_snapshot(recent_limit: recent_limit) unless session

        conflicts = session.analysis.fetch(:conflicts)
        readiness = session.analysis.fetch(:readiness)
        ChronicleSnapshot.new(
          proposal_id: session.proposal_id,
          proposal_title: session.analysis.fetch(:proposal).fetch(:title),
          session_id: session.id,
          status: readiness.fetch(:state),
          conflict_count: conflicts.length,
          open_conflict_count: readiness.fetch(:open_conflict_count),
          required_signoffs: session.analysis.fetch(:required_signoffs),
          signed_by: readiness.fetch(:signed_by),
          refused_by: readiness.fetch(:refused_by),
          top_conflicts: conflicts.first(5).map(&:dup).freeze,
          related_decisions: conflicts.map { |entry| { decision_id: entry.fetch(:decision_id), title: entry.fetch(:title) }.freeze }.freeze,
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

      def command_refusal(feedback_code:, session_id:, proposal_id:, decision_id:, status:)
        refusal(feedback_code, session_id, proposal_id, decision_id, status)
      end

      private

      def refresh_analysis(session, proposal:, decisions:, scanner:)
        session.analysis = scanner.analyze(
          proposal: proposal,
          decisions: decisions,
          signoffs: session.signoffs,
          refusals: session.refusals,
          acknowledged_conflicts: session.acknowledged_conflicts
        )
      end

      def replace_session(session)
        @sessions.reject! { |entry| entry.id == session.id }
        @sessions << session
      end

      def find_session(session_id)
        @sessions.find { |session| session.id == session_id.to_s }
      end

      def next_session_id(proposal)
        "chronicle-session-#{proposal.fetch(:id).downcase}"
      end

      def empty_snapshot(recent_limit:)
        ChronicleSnapshot.new(
          proposal_id: nil,
          proposal_title: nil,
          session_id: nil,
          status: :empty,
          conflict_count: 0,
          open_conflict_count: 0,
          required_signoffs: [],
          signed_by: [],
          refused_by: [],
          top_conflicts: [],
          related_decisions: [],
          receipt_id: nil,
          action_count: @actions.length,
          recent_events: @actions.last(recent_limit).map { |action| action.to_h.freeze }.freeze
        ).freeze
      end

      def refusal(feedback_code, session_id, proposal_id, decision_id, status)
        action = record_action(
          kind: :command_refused,
          session_id: session_id,
          proposal_id: proposal_id,
          decision_id: decision_id,
          status: status
        )
        command_result(:failure, feedback_code, session_id, proposal_id, decision_id, nil, action)
      end

      def record_action(kind:, session_id:, proposal_id:, decision_id:, status:, metadata: {})
        action = Action.new(
          index: @next_action_index,
          kind: kind.to_sym,
          session_id: session_id,
          proposal_id: proposal_id,
          decision_id: decision_id,
          status: status.to_sym,
          metadata: metadata.dup.freeze
        )
        @actions << action
        @next_action_index += 1
        append_action(action)
        action
      end

      def command_result(kind, feedback_code, session_id, proposal_id, decision_id, receipt_id, action)
        CommandResult.new(
          kind: kind,
          feedback_code: feedback_code,
          session_id: session_id,
          proposal_id: proposal_id,
          decision_id: decision_id,
          receipt_id: receipt_id,
          action: action
        )
      end

      def persist_session(session)
        File.write(
          File.join(sessions_dir, "#{safe_id(session.id)}.json"),
          JSON.pretty_generate(
            id: session.id,
            proposal_id: session.proposal_id,
            signoffs: session.signoffs,
            refusals: session.refusals,
            acknowledged_conflicts: session.acknowledged_conflicts,
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
