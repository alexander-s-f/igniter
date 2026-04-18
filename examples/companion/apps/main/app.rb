# frozen_string_literal: true

require "igniter/app"
require "igniter/cluster"
require "igniter/core"
require_relative "app/handlers/status_handler"
require_relative "app/handlers/notes_list_handler"
require_relative "app/handlers/notes_create_handler"
require_relative "app/handlers/rag_search_handler"
require_relative "../../lib/companion/shared/capability_profile"
require_relative "../../lib/companion/shared/note_store"

module Companion
  class MainApp < Igniter::App
    root_dir __dir__
    config_file "app.yml"
    host :cluster_app

    tools_path     "app/tools"
    skills_path    "app/skills"
    executors_path "app/executors"
    contracts_path "app/contracts"
    agents_path    "app/agents"

    expose :notes_api, Companion::Shared::NoteStore

    route "GET",  "/v1/home/status", with: Companion::Main::StatusHandler
    route "GET",  "/v1/notes",       with: Companion::Main::NotesListHandler
    route "POST", "/v1/notes",       with: Companion::Main::NotesCreateHandler
    route "POST", "/v1/rag/search",  with: Companion::Main::RagSearchHandler

    on_boot do
      register "GreetContract", Companion::GreetContract
    end

    configure do |c|
      c.app_host.host = "0.0.0.0"
      c.app_host.port = Integer(ENV.fetch("PORT", "4667"))
      c.app_host.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
      Companion::Shared::CapabilityProfile.configure_cluster!(c.cluster_app_host)
    end
  end
end
