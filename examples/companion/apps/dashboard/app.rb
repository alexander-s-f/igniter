# frozen_string_literal: true

require "igniter/app"
require "igniter/core"
require_relative "../../lib/companion"
require_relative "../../lib/companion/dashboard/home_handler"
require_relative "../../lib/companion/dashboard/overview_handler"
require_relative "../../lib/companion/dashboard/reminder_action_handler"
require_relative "../../lib/companion/dashboard/reminder_create_handler"
require_relative "../../lib/companion/dashboard/schema_page_handler"
require_relative "../../lib/companion/dashboard/schema_submission_handler"
require_relative "../../lib/companion/dashboard/telegram_preference_handler"
require_relative "../../lib/companion/dashboard/training_checkin_store"
require_relative "../../lib/companion/dashboard/training_checkin_submission_contract"
require_relative "../../lib/companion/dashboard/view_shell"
require_relative "../../lib/companion/dashboard/view_schema_delete_handler"
require_relative "../../lib/companion/dashboard/view_schema_handler"
require_relative "../../lib/companion/dashboard/view_schema_patch_handler"
require_relative "../../lib/companion/dashboard/view_schemas_handler"
require_relative "../../lib/companion/dashboard/view_schema_catalog"
require_relative "../../lib/companion/dashboard/view_submission_handler"
require_relative "../../lib/companion/dashboard/view_submission_store"

module Companion
  class DashboardApp < Igniter::App
    root_dir __dir__
    config_file "app.yml"

    route "GET", "/", with: Companion::Dashboard::HomeHandler
    route "GET", "/api/overview", with: Companion::Dashboard::OverviewHandler
    route "GET", "/api/views", with: Companion::Dashboard::ViewSchemasHandler
    route "POST", "/api/views", with: Companion::Dashboard::ViewSchemasHandler
    route "GET", %r{\A/api/views/(?<id>[^/]+)\z}, with: Companion::Dashboard::ViewSchemaHandler
    route "PATCH", %r{\A/api/views/(?<id>[^/]+)\z}, with: Companion::Dashboard::ViewSchemaPatchHandler
    route "DELETE", %r{\A/api/views/(?<id>[^/]+)\z}, with: Companion::Dashboard::ViewSchemaDeleteHandler
    route "GET", %r{\A/submissions/(?<id>[^/]+)\z}, with: Companion::Dashboard::ViewSubmissionHandler
    route "GET", %r{\A/views/(?<id>[^/]+)\z}, with: Companion::Dashboard::SchemaPageHandler
    route "POST", "/reminders", with: Companion::Dashboard::ReminderCreateHandler
    route "POST", %r{\A/views/(?<id>[^/]+)/submissions\z}, with: Companion::Dashboard::SchemaSubmissionHandler
    route "POST", "/api/telegram/preferences", with: Companion::Dashboard::TelegramPreferenceHandler
    route "POST", %r{\A/api/reminders/(?<id>[^/]+)/complete\z}, with: Companion::Dashboard::ReminderActionHandler

    on_boot do
      Companion::Boot.configure_persistence!(app_name: :dashboard)
      Companion::Dashboard::ViewSchemaCatalog.seed!
    end

    configure do |c|
      c.app_host.host = "0.0.0.0"
      c.app_host.port = ENV.fetch("DASHBOARD_PORT", "4569").to_i
      c.app_host.log_format = ENV.fetch("LOG_FORMAT", "text").to_sym
      c.app_host.drain_timeout = 30
      c.store = Companion::Boot.default_execution_store(app_name: :dashboard)
    end
  end
end
