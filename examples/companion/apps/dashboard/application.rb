# frozen_string_literal: true

require "igniter/application"
require "igniter/core"
require_relative "../../lib/companion/boot"
require_relative "../../lib/companion/dashboard/home_handler"
require_relative "../../lib/companion/dashboard/overview_handler"
require_relative "../../lib/companion/dashboard/reminder_action_handler"
require_relative "../../lib/companion/dashboard/telegram_preference_handler"

module Companion
  class DashboardApp < Igniter::Application
    root_dir __dir__
    config_file "application.yml"

    route "GET", "/", with: Companion::Dashboard::HomeHandler
    route "GET", "/api/overview", with: Companion::Dashboard::OverviewHandler
    route "POST", "/api/telegram/preferences", with: Companion::Dashboard::TelegramPreferenceHandler
    route "POST", %r{\A/api/reminders/(?<id>[^/]+)/complete\z}, with: Companion::Dashboard::ReminderActionHandler

    on_boot do
      Companion::Boot.configure_persistence!(app_name: :dashboard)
    end

    configure do |c|
      c.host = "0.0.0.0"
      c.port = ENV.fetch("DASHBOARD_PORT", "4569").to_i
      c.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
      c.drain_timeout = 30
      c.store = Companion::Boot.default_execution_store(app_name: :dashboard)
    end
  end
end
