# frozen_string_literal: true

require "igniter/app"
require "igniter/core"
require "igniter/agent"
require_relative "support/notes_api"
require_relative "support/playground_ops_api"
require_relative "web/handlers/status_handler"
require_relative "web/handlers/notes_list_handler"
require_relative "web/handlers/notes_create_handler"

module Companion
  class MainApp < Igniter::App
    root_dir __dir__
    config_file "app.yml"

    tools_path "tools"
    skills_path "skills"
    executors_path "executors"
    contracts_path "contracts"
    agents_path "agents"

    route "GET", "/v1/home/status", with: Companion::Main::StatusHandler
    route "GET", "/v1/notes", with: Companion::Main::NotesListHandler
    route "POST", "/v1/notes", with: Companion::Main::NotesCreateHandler

    provide :notes_api, Companion::Main::Support::NotesAPI
    provide :playground_ops_api, Companion::Main::Support::PlaygroundOpsAPI

    on_boot do
      register "GreetContract", Companion::GreetContract
    end
  end
end
