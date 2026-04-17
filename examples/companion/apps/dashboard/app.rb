# frozen_string_literal: true

require "igniter/app"
require "igniter/core"
require_relative "../../lib/companion/dashboard/home_handler"
require_relative "../../lib/companion/dashboard/overview_handler"
require_relative "../../lib/companion/dashboard/notes_create_handler"

module Companion
  class DashboardApp < Igniter::App
    root_dir __dir__
    config_file "app.yml"

    route "GET", "/", with: Companion::Dashboard::HomeHandler
    route "GET", "/api/overview", with: Companion::Dashboard::OverviewHandler
    route "POST", "/notes", with: Companion::Dashboard::NotesCreateHandler
  end
end
