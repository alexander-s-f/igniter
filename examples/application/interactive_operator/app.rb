# frozen_string_literal: true

require "uri"

require "igniter/application"

require_relative "services/task_board"
require_relative "web/operator_board"

module InteractiveOperator
  APP_ROOT = File.expand_path(__dir__)

  def self.feedback_path(params)
    "/?#{URI.encode_www_form(params)}"
  end

  def self.events_read_model(board)
    recent = board.recent_events(limit: 6).map do |event|
      task_id = event.fetch(:task_id) || "-"
      "#{event.fetch(:kind)}:#{task_id}:#{event.fetch(:status)}"
    end
    "open=#{board.open_count} actions=#{board.action_count} recent=#{recent.join("|")}"
  end

  def self.build
    Igniter::Application.rack_app(:interactive_operator, root: APP_ROOT, env: :test) do
      service(:task_board) { Services::TaskBoard.new }

      mount_web(
        :operator_board,
        Web.operator_board_mount,
        at: "/",
        capabilities: %i[screen command],
        metadata: { poc: true }
      )

      get "/events" do
        text InteractiveOperator.events_read_model(service(:task_board))
      end

      post "/tasks/create" do |params|
        task = service(:task_board).create(params.fetch("title", ""))
        if task
          redirect InteractiveOperator.feedback_path(notice: "task_created", task: task.id)
        else
          redirect InteractiveOperator.feedback_path(error: "blank_title")
        end
      end

      post "/tasks" do |params|
        task_id = params.fetch("id", "")
        if service(:task_board).resolve(task_id)
          redirect InteractiveOperator.feedback_path(notice: "task_resolved", task: task_id)
        else
          redirect InteractiveOperator.feedback_path(error: "task_not_found", task: task_id)
        end
      end
    end
  end
end
