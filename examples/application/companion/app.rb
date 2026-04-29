# frozen_string_literal: true

require "uri"

require "igniter/application"

require_relative "app_dsl"
require_relative "configuration"
require_relative "contracts/article_record_contract"
require_relative "contracts/activity_feed_contract"
require_relative "contracts/body_battery_contract"
require_relative "contracts/comment_history_contract"
require_relative "contracts/companion_action_history_contract"
require_relative "contracts/countdown_contract"
require_relative "contracts/countdown_read_model_contract"
require_relative "contracts/countdown_record_contract"
require_relative "contracts/daily_focus_record_contract"
require_relative "contracts/daily_summary_contract"
require_relative "contracts/daily_plan_contract"
require_relative "contracts/durable_type_materialization_contract"
require_relative "contracts/infrastructure_loop_health_contract"
require_relative "contracts/materializer_approval_contract"
require_relative "contracts/materializer_approval_audit_trail_contract"
require_relative "contracts/materializer_approval_history_contract"
require_relative "contracts/materializer_approval_policy_contract"
require_relative "contracts/materializer_approval_receipt_contract"
require_relative "contracts/materializer_audit_trail_contract"
require_relative "contracts/materializer_attempt_contract"
require_relative "contracts/materializer_attempt_history_contract"
require_relative "contracts/materializer_gate_contract"
require_relative "contracts/materializer_preflight_contract"
require_relative "contracts/materializer_receipt_contract"
require_relative "contracts/materializer_runbook_contract"
require_relative "contracts/materializer_supervision_contract"
require_relative "contracts/persistence_manifest_contract"
require_relative "contracts/persistence_relation_health_contract"
require_relative "contracts/persistence_readiness_contract"
require_relative "contracts/reminder_record_contract"
require_relative "contracts/reminder_contract"
require_relative "contracts/static_materialization_parity_contract"
require_relative "contracts/tracker_record_contract"
require_relative "contracts/tracker_log_history_contract"
require_relative "contracts/tracker_log_contract"
require_relative "contracts/tracker_read_model_contract"
require_relative "contracts/wizard_type_spec_export_contract"
require_relative "contracts/wizard_type_spec_history_contract"
require_relative "contracts/wizard_type_spec_migration_plan_contract"
require_relative "contracts/wizard_type_spec_record_contract"
require_relative "services/contract_record_set"
require_relative "services/contract_history"
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
