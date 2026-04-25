# frozen_string_literal: true

require "igniter/application"

require_relative "services/task_board"
require_relative "web/operator_board"

module InteractiveOperator
  APP_ROOT = File.expand_path(__dir__)

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
        text "open=#{service(:task_board).open_count}"
      end

      post "/tasks" do |params|
        service(:task_board).resolve(params.fetch("id", ""))
        redirect "/"
      end
    end
  end
end
