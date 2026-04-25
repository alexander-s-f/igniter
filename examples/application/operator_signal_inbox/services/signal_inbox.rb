# frozen_string_literal: true

module OperatorSignalInbox
  module Services
    class SignalInbox
      Signal = Struct.new(:id, :source, :summary, :severity, :status, :note, keyword_init: true)
      Action = Struct.new(:index, :kind, :signal_id, :status, keyword_init: true)
      SignalSnapshot = Struct.new(:signals, :open_count, :critical_count, :action_count, :recent_events,
                                  keyword_init: true) do
        def to_h
          {
            signals: signals.map { |signal| signal.to_h.dup },
            open_count: open_count,
            critical_count: critical_count,
            action_count: action_count,
            recent_events: recent_events.map(&:dup)
          }
        end
      end
      CommandResult = Struct.new(:kind, :feedback_code, :signal_id, :action, keyword_init: true) do
        def success?
          kind == :success
        end

        def failure?
          !success?
        end

        def to_h
          {
            kind: kind,
            feedback_code: feedback_code,
            signal_id: signal_id,
            action: action&.to_h
          }
        end
      end

      attr_reader :name

      def initialize
        @name = :operator_signal_inbox
        @actions = []
        @next_action_index = 0
        @signals = []
        seed_signal(
          id: "cpu-spike",
          source: "sensor.alpha",
          summary: "CPU spike above threshold",
          severity: :critical
        )
        seed_signal(
          id: "deploy-drift",
          source: "deploy.bot",
          summary: "Deploy drift detected",
          severity: :warning
        )
      end

      def snapshot(recent_limit: 7)
        snapshot_signals = @signals.map(&:dup).freeze
        snapshot_events = @actions.last(recent_limit).map { |action| action.to_h.freeze }.freeze

        SignalSnapshot.new(
          signals: snapshot_signals,
          open_count: snapshot_signals.count { |signal| signal.status == :open },
          critical_count: snapshot_signals.count { |signal| signal.status == :open && signal.severity == :critical },
          action_count: @actions.length,
          recent_events: snapshot_events
        ).freeze
      end

      def acknowledge(id)
        signal = find_signal(id)
        return refusal(:signal_acknowledge_refused, id, :signal_not_found) unless signal
        return refusal(:signal_acknowledge_refused, signal.id, :signal_closed) unless signal.status == :open

        signal.status = :acknowledged
        action = record_action(kind: :signal_acknowledged, signal_id: signal.id, status: signal.status)
        command_result(:success, feedback_code: :signal_acknowledged, signal_id: signal.id, action: action)
      end

      def escalate(id, note:)
        normalized_note = note.to_s.strip
        return refusal(:signal_escalate_refused, id, :blank_escalation_note) if normalized_note.empty?

        signal = find_signal(id)
        return refusal(:signal_escalate_refused, id, :signal_not_found) unless signal
        return refusal(:signal_escalate_refused, signal.id, :signal_closed) unless signal.status == :open

        signal.status = :escalated
        signal.note = normalized_note
        action = record_action(kind: :signal_escalated, signal_id: signal.id, status: signal.status)
        command_result(:success, feedback_code: :signal_escalated, signal_id: signal.id, action: action)
      end

      def acknowledged?(id)
        @signals.any? { |signal| signal.id == id.to_s && signal.status == :acknowledged }
      end

      def escalated?(id)
        @signals.any? { |signal| signal.id == id.to_s && signal.status == :escalated }
      end

      private

      def seed_signal(id:, source:, summary:, severity:)
        signal = Signal.new(
          id: id,
          source: source,
          summary: summary,
          severity: severity.to_sym,
          status: :open,
          note: nil
        )
        @signals << signal
        record_action(kind: :signal_seeded, signal_id: signal.id, status: signal.status)
      end

      def find_signal(id)
        @signals.find { |signal| signal.id == id.to_s }
      end

      def refusal(kind, signal_id, feedback_code)
        action = record_action(kind: kind, signal_id: signal_id.to_s, status: :refused)
        command_result(:failure, feedback_code: feedback_code, signal_id: signal_id.to_s, action: action)
      end

      def record_action(kind:, signal_id:, status:)
        action = Action.new(
          index: @next_action_index,
          kind: kind.to_sym,
          signal_id: signal_id,
          status: status.to_sym
        )
        @actions << action
        @next_action_index += 1
        action
      end

      def command_result(kind, feedback_code:, signal_id:, action:)
        CommandResult.new(
          kind: kind.to_sym,
          feedback_code: feedback_code.to_sym,
          signal_id: signal_id,
          action: action
        )
      end
    end
  end
end
