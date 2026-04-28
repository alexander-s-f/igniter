# frozen_string_literal: true

require "uri"

require "igniter/application"

require_relative "app_dsl"
require_relative "configuration"
require_relative "contracts/body_battery_contract"
require_relative "contracts/daily_summary_contract"
require_relative "contracts/daily_plan_contract"
require_relative "contracts/reminder_record_contract"
require_relative "contracts/reminder_contract"
require_relative "contracts/tracker_log_contract"
require_relative "services/contract_record_set"
require_relative "services/companion_store"
require_relative "services/hub_installer"
require_relative "web/companion_dashboard"

module Companion
  APP_ROOT = File.expand_path(__dir__)

  def self.feedback_path(params)
    "/?#{URI.encode_www_form(params)}"
  end

  def self.build(config: default_configuration)
    Igniter::Application.rack_app(:companion, root: APP_ROOT, env: :test) do
      extend AppDSL

      companion_credentials config
      companion_ai config
      companion_store config
      companion_dashboard
      companion_routes
    end
  end
end
