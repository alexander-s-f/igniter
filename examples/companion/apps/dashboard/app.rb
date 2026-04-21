# frozen_string_literal: true

require "igniter/app"
require "igniter/core"
require_relative "../../lib/companion/shared/runtime_profile"
require_relative "web/handlers/home_handler"
require_relative "web/handlers/overview_handler"
require_relative "web/handlers/notes_create_handler"
require_relative "web/handlers/assistant_request_create_handler"
require_relative "web/handlers/assistant_followup_approve_handler"

module Companion
  class DashboardApp < Igniter::App
    root_dir __dir__
    config_file "app.yml"
    mount_operator_surface

    configure do |c|
      c.store = Companion::Shared::RuntimeProfile.execution_store(:dashboard)
    end

    route "GET", "/", with: Companion::Dashboard::HomeHandler
    route "GET", "/api/overview", with: Companion::Dashboard::OverviewHandler
    route "POST", "/notes", with: Companion::Dashboard::NotesCreateHandler
    route "POST", "/assistant/requests", with: Companion::Dashboard::AssistantRequestCreateHandler
    route "POST", "/assistant/followups/approve", with: Companion::Dashboard::AssistantFollowupApproveHandler
  end
end
