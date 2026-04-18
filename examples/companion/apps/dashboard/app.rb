# frozen_string_literal: true

require "igniter/app"
require "igniter/core"
require_relative "app/handlers/home_handler"
require_relative "app/handlers/overview_handler"
require_relative "app/handlers/notes_create_handler"
require_relative "app/handlers/self_heal_demo_handler"
require_relative "app/handlers/admission_action_handler"

module Companion
  class DashboardApp < Igniter::App
    root_dir __dir__
    config_file "app.yml"

    route "GET", "/", with: Companion::Dashboard::HomeHandler
    route "GET", "/api/overview", with: Companion::Dashboard::OverviewHandler
    route "POST", "/notes", with: Companion::Dashboard::NotesCreateHandler
    route "POST", "/demo/self-heal", with: Companion::Dashboard::SelfHealDemoHandler
    route "POST", "/admin/admission", with: Companion::Dashboard::AdmissionActionHandler
  end
end
