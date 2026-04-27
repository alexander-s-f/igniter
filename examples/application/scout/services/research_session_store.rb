# frozen_string_literal: true

require "fileutils"
require "json"

require_relative "../reports/research_receipt"

module Scout
  module Services
    class ResearchSessionStore
      Session = Struct.new(:id, :topic, :source_ids, :analysis, :checkpoint_choice, :receipt_id, keyword_init: true)
      Action = Struct.new(:index, :kind, :session_id, :source_id, :finding_id, :status, :metadata, keyword_init: true)
      CommandResult = Struct.new(:kind, :feedback_code, :session_id, :source_id, :finding_id, :receipt_id, :action, keyword_init: true) do
        def success?
          kind == :success
        end

        def to_h
          {
            kind: kind,
            feedback_code: feedback_code,
            session_id: session_id,
            source_id: source_id,
            finding_id: finding_id,
            receipt_id: receipt_id,
            action: action&.to_h
          }
        end
      end
      ScoutSnapshot = Struct.new(
        :session_id,
        :topic,
        :status,
        :source_count,
        :finding_count,
        :contradiction_count,
        :checkpoint_choice,
        :top_findings,
        :contradictions,
        :source_refs,
        :receipt_id,
        :action_count,
        :recent_events,
        keyword_init: true
      ) do
        def to_h
          {
            session_id: session_id,
            topic: topic,
            status: status,
            source_count: source_count,
            finding_count: finding_count,
            contradiction_count: contradiction_count,
            checkpoint_choice: checkpoint_choice,
            top_findings: top_findings.map(&:dup),
            contradictions: contradictions.map(&:dup),
            source_refs: source_refs.map(&:dup),
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

      def start_session(topic:, sources:)
        normalized_topic = topic.to_s.strip
        return refusal(:scout_blank_topic, nil, nil, nil, :blank_topic) if normalized_topic.empty?
        return refusal(:scout_no_sources, nil, nil, nil, :no_sources) if sources.empty?

        session = Session.new(
          id: next_session_id(normalized_topic),
          topic: normalized_topic,
          source_ids: sources.map { |source| source.fetch(:id) },
          analysis: empty_analysis(normalized_topic, sources),
          checkpoint_choice: nil,
          receipt_id: nil
        )
        replace_session(session)
        action = record_action(kind: :session_started, session_id: session.id, source_id: nil, finding_id: nil, status: :open)
        sources.each do |source|
          record_action(kind: :source_selected, session_id: session.id, source_id: source.fetch(:id), finding_id: nil, status: :selected)
        end
        persist_session(session)
        command_result(:success, :scout_session_started, session.id, nil, nil, session.receipt_id, action)
      end

      def extract_findings(session_id:, sources:, extractor:)
        session = find_session(session_id)
        return refusal(:scout_unknown_session, session_id, nil, nil, :unknown_session) unless session

        refresh_analysis(session, sources: sources, extractor: extractor)
        action = record_action(kind: :findings_extracted, session_id: session.id, source_id: nil, finding_id: nil, status: :extracted)
        session.analysis.fetch(:contradictions).each do |contradiction|
          record_action(kind: :contradiction_detected, session_id: session.id, source_id: nil, finding_id: contradiction.fetch(:id), status: :open)
        end
        persist_session(session)
        command_result(:success, :scout_findings_extracted, session.id, nil, nil, session.receipt_id, action)
      end

      def add_local_source(session_id:, source:, sources:, extractor:)
        session = find_session(session_id)
        return refusal(:scout_unknown_session, session_id, source&.fetch(:id), nil, :unknown_session) unless session

        session.source_ids |= [source.fetch(:id)]
        refresh_analysis(session, sources: sources, extractor: extractor) if session.analysis.fetch(:findings).any?
        action = record_action(kind: :source_added, session_id: session.id, source_id: source.fetch(:id), finding_id: nil, status: :added)
        persist_session(session)
        command_result(:success, :scout_local_source_added, session.id, source.fetch(:id), nil, session.receipt_id, action)
      end

      def choose_checkpoint(session_id:, direction:, sources:, extractor:)
        session = find_session(session_id)
        return refusal(:scout_unknown_session, session_id, nil, nil, :unknown_session) unless session

        normalized = direction.to_s.strip
        return refusal(:scout_invalid_checkpoint, session.id, nil, nil, :invalid_checkpoint) unless session.analysis.fetch(:direction_options).include?(normalized)

        session.checkpoint_choice = normalized
        refresh_analysis(session, sources: sources, extractor: extractor)
        action = record_action(kind: :checkpoint_chosen, session_id: session.id, source_id: nil, finding_id: nil, status: normalized.to_sym)
        persist_session(session)
        command_result(:success, :scout_checkpoint_chosen, session.id, nil, nil, session.receipt_id, action)
      end

      def emit_receipt(session_id:, metadata: {})
        session = find_session(session_id)
        return refusal(:scout_unknown_session, session_id, nil, nil, :unknown_session) unless session

        readiness = session.analysis.fetch(:checkpoint_readiness)
        return refusal(:scout_receipt_not_ready, session.id, nil, nil, :receipt_not_ready) unless readiness.fetch(:ready)

        receipt = Reports::ResearchReceipt.build(
          session_id: session.id,
          payload: session.analysis.fetch(:synthesis_payload),
          events: events,
          metadata: metadata
        )
        path = File.join(receipts_dir, "#{safe_id(session.id)}.md")
        File.write(path, receipt.to_markdown)
        session.receipt_id = receipt.receipt_id
        action = record_action(kind: :receipt_emitted, session_id: session.id, source_id: nil, finding_id: nil, status: :ready, metadata: { path: path })
        persist_session(session)
        command_result(:success, :scout_receipt_emitted, session.id, nil, nil, session.receipt_id, action)
      end

      def snapshot(recent_limit: 8)
        session = @sessions.last
        return empty_snapshot(recent_limit: recent_limit) unless session

        analysis = session.analysis
        ScoutSnapshot.new(
          session_id: session.id,
          topic: session.topic,
          status: status_for(session),
          source_count: session.source_ids.length,
          finding_count: analysis.fetch(:findings).length,
          contradiction_count: analysis.fetch(:contradictions).length,
          checkpoint_choice: session.checkpoint_choice,
          top_findings: analysis.fetch(:findings).first(5).map(&:dup).freeze,
          contradictions: analysis.fetch(:contradictions).map(&:dup).freeze,
          source_refs: analysis.fetch(:sources).map { |source| source_ref(source) }.freeze,
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

      def command_refusal(feedback_code:, session_id:, source_id:, finding_id:, status:)
        refusal(feedback_code, session_id, source_id, finding_id, status)
      end

      private

      def refresh_analysis(session, sources:, extractor:)
        session.analysis = extractor.analyze(
          topic: session.topic,
          sources: sources,
          checkpoint_choice: session.checkpoint_choice
        )
      end

      def replace_session(session)
        @sessions.reject! { |entry| entry.id == session.id }
        @sessions << session
      end

      def find_session(session_id)
        @sessions.find { |session| session.id == session_id.to_s }
      end

      def next_session_id(topic)
        "scout-session-#{topic.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")}"
      end

      def empty_analysis(topic, sources)
        {
          topic: topic,
          sources: sources,
          source_claims: [],
          findings: [],
          contradictions: [],
          direction_options: [],
          checkpoint_readiness: { ready: false, choice: nil, options: [], missing: :no_findings },
          synthesis_payload: { valid: false }
        }.freeze
      end

      def status_for(session)
        return :complete if session.receipt_id
        return :checkpointed if session.checkpoint_choice
        return :findings_ready if session.analysis.fetch(:findings).any?

        :open
      end

      def source_ref(source)
        {
          source_id: source.fetch(:id),
          title: source.fetch(:title),
          source_type: source.fetch(:source_type),
          source_path: source.fetch(:source_path),
          tags: source.fetch(:tags)
        }.freeze
      end

      def empty_snapshot(recent_limit:)
        ScoutSnapshot.new(
          session_id: nil,
          topic: nil,
          status: :empty,
          source_count: 0,
          finding_count: 0,
          contradiction_count: 0,
          checkpoint_choice: nil,
          top_findings: [],
          contradictions: [],
          source_refs: [],
          receipt_id: nil,
          action_count: @actions.length,
          recent_events: @actions.last(recent_limit).map { |action| action.to_h.freeze }.freeze
        ).freeze
      end

      def refusal(feedback_code, session_id, source_id, finding_id, status)
        action = record_action(
          kind: :command_refused,
          session_id: session_id,
          source_id: source_id,
          finding_id: finding_id,
          status: status
        )
        command_result(:failure, feedback_code, session_id, source_id, finding_id, nil, action)
      end

      def record_action(kind:, session_id:, source_id:, finding_id:, status:, metadata: {})
        action = Action.new(
          index: @next_action_index,
          kind: kind.to_sym,
          session_id: session_id,
          source_id: source_id,
          finding_id: finding_id,
          status: status.to_sym,
          metadata: metadata.dup.freeze
        )
        @actions << action
        @next_action_index += 1
        append_action(action)
        action
      end

      def command_result(kind, feedback_code, session_id, source_id, finding_id, receipt_id, action)
        CommandResult.new(
          kind: kind,
          feedback_code: feedback_code,
          session_id: session_id,
          source_id: source_id,
          finding_id: finding_id,
          receipt_id: receipt_id,
          action: action
        )
      end

      def persist_session(session)
        File.write(
          File.join(sessions_dir, "#{safe_id(session.id)}.json"),
          JSON.pretty_generate(
            id: session.id,
            topic: session.topic,
            source_ids: session.source_ids,
            checkpoint_choice: session.checkpoint_choice,
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
