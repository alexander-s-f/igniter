# frozen_string_literal: true

module InteractiveOperator
  module Services
    class TaskBoard
      Task = Struct.new(:id, :title, :status, keyword_init: true)
      Action = Struct.new(:index, :kind, :task_id, :status, keyword_init: true)
      CommandResult = Struct.new(:kind, :feedback_code, :task_id, :action, keyword_init: true) do
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
            task_id: task_id,
            action: action&.to_h
          }
        end
      end

      attr_reader :name

      def initialize
        @name = :operator_task_board
        @actions = []
        @next_action_index = 0
        @tasks = []
        seed_task(id: "triage-sensor", title: "Triage sensor drift")
        seed_task(id: "ack-runbook", title: "Acknowledge runbook update")
      end

      def tasks
        @tasks.map(&:dup)
      end

      def events
        @actions.map { |action| action.to_h.dup }
      end

      def recent_events(limit: 5)
        events.last(limit)
      end

      def action_count
        @actions.length
      end

      def open_count
        @tasks.count { |task| task.status == :open }
      end

      def create(title)
        normalized_title = title.to_s.strip
        if normalized_title.empty?
          action = record_action(kind: :task_create_refused, task_id: nil, status: :refused)
          return command_result(:failure, feedback_code: :blank_title, task_id: nil, action: action)
        end

        task = Task.new(id: next_id_for(normalized_title), title: normalized_title, status: :open)
        @tasks << task
        action = record_action(kind: :task_created, task_id: task.id, status: :open)
        command_result(:success, feedback_code: :task_created, task_id: task.id, action: action)
      end

      def resolve(id)
        task = @tasks.find { |entry| entry.id == id.to_s }
        unless task
          action = record_action(kind: :task_resolve_refused, task_id: id.to_s, status: :refused)
          return command_result(:failure, feedback_code: :task_not_found, task_id: id.to_s, action: action)
        end

        task.status = :resolved
        action = record_action(kind: :task_resolved, task_id: task.id, status: :resolved)
        command_result(:success, feedback_code: :task_resolved, task_id: task.id, action: action)
      end

      def resolved?(id)
        @tasks.any? { |task| task.id == id.to_s && task.status == :resolved }
      end

      private

      def seed_task(id:, title:)
        task = Task.new(id: id, title: title, status: :open)
        @tasks << task
        record_action(kind: :task_seeded, task_id: task.id, status: :open)
      end

      def record_action(kind:, task_id:, status:)
        action = Action.new(
          index: @next_action_index,
          kind: kind.to_sym,
          task_id: task_id,
          status: status.to_sym
        )
        @actions << action
        @next_action_index += 1
        action
      end

      def command_result(kind, feedback_code:, task_id:, action:)
        CommandResult.new(
          kind: kind.to_sym,
          feedback_code: feedback_code.to_sym,
          task_id: task_id,
          action: action
        )
      end

      def next_id_for(title)
        base = title.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-+\z/, "")
        base = "task" if base.empty?
        candidate = base
        suffix = 2
        while @tasks.any? { |task| task.id == candidate }
          candidate = "#{base}-#{suffix}"
          suffix += 1
        end
        candidate
      end
    end
  end
end
