# frozen_string_literal: true

module InteractiveOperator
  module Services
    class TaskBoard
      Task = Struct.new(:id, :title, :status, keyword_init: true)

      attr_reader :name

      def initialize
        @name = :operator_task_board
        @tasks = [
          Task.new(id: "triage-sensor", title: "Triage sensor drift", status: :open),
          Task.new(id: "ack-runbook", title: "Acknowledge runbook update", status: :open)
        ]
      end

      def tasks
        @tasks.map(&:dup)
      end

      def open_count
        @tasks.count { |task| task.status == :open }
      end

      def create(title)
        normalized_title = title.to_s.strip
        return nil if normalized_title.empty?

        task = Task.new(id: next_id_for(normalized_title), title: normalized_title, status: :open)
        @tasks << task
        task.dup
      end

      def resolve(id)
        task = @tasks.find { |entry| entry.id == id.to_s }
        return false unless task

        task.status = :resolved
        true
      end

      def resolved?(id)
        @tasks.any? { |task| task.id == id.to_s && task.status == :resolved }
      end

      private

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
