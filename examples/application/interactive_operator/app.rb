# frozen_string_literal: true

require "igniter/application"

require_relative "services/task_board"
require_relative "server/rack_app"
require_relative "web/operator_board"

module InteractiveOperator
  APP_ROOT = File.expand_path(__dir__)

  App = Struct.new(:board, :environment, :mount, :rack_app, keyword_init: true) do
    def call(env)
      rack_app.call(env)
    end
  end

  def self.build
    board = Services::TaskBoard.new
    kernel = Igniter::Application.build_kernel
    kernel.manifest(:interactive_operator, root: APP_ROOT, env: :test)
    kernel.provide(:task_board, -> { board })

    mount = Web.operator_board_mount
    kernel.mount_web(:operator_board, mount, at: "/", capabilities: %i[screen command], metadata: { poc: true })

    environment = Igniter::Application::Environment.new(profile: kernel.finalize)
    rack_app = Server::RackApp.new(environment: environment, mount: mount)

    App.new(board: board, environment: environment, mount: mount, rack_app: rack_app)
  end
end
