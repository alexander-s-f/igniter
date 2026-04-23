# frozen_string_literal: true

require "igniter/app"
require "igniter/core"
require_relative "../../lib/companion/shared/runtime_profile"
require_relative "web/handlers/home_handler"
require_relative "web/handlers/assistant_handler"
require_relative "web/handlers/cluster_handler"
require_relative "web/handlers/overview_handler"
require_relative "web/handlers/notes_create_handler"
require_relative "web/handlers/assistant_request_create_handler"
require_relative "web/handlers/assistant_followup_approve_handler"
require_relative "web/handlers/assistant_redeliver_handler"
require_relative "web/handlers/assistant_note_create_handler"
require_relative "web/handlers/assistant_reopen_handler"
require_relative "web/handlers/assistant_feedback_handler"
require_relative "web/handlers/assistant_runtime_update_handler"
require_relative "web/handlers/assistant_compare_handler"

class NilClass
  def empty?
    true
  end
end

module Companion
  class DashboardApp < Igniter::App
    include Igniter::Frontend::App

    root_dir __dir__
    config_file "app.yml"
    frontend_assets
    mount_operator_surface

    configure do |c|
      c.store = Companion::Shared::RuntimeProfile.execution_store(:dashboard)
    end

    route "GET", "/", with: Companion::Dashboard::HomeHandler
    route "GET", "/assistant", with: Companion::Dashboard::AssistantHandler
    route "GET", "/cluster", with: Companion::Dashboard::ClusterHandler
    route "GET", "/api/overview", with: Companion::Dashboard::OverviewHandler
    route "POST", "/notes", with: Companion::Dashboard::NotesCreateHandler
    route "POST", "/assistant/runtime", with: Companion::Dashboard::AssistantRuntimeUpdateHandler
    route "POST", "/assistant/compare", with: Companion::Dashboard::AssistantCompareHandler
    route "POST", "/assistant/requests", with: Companion::Dashboard::AssistantRequestCreateHandler
    route "POST", "/assistant/requests/redeliver", with: Companion::Dashboard::AssistantRedeliverHandler
    route "POST", "/assistant/requests/note", with: Companion::Dashboard::AssistantNoteCreateHandler
    route "POST", "/assistant/requests/reopen", with: Companion::Dashboard::AssistantReopenHandler
    route "POST", "/assistant/requests/feedback", with: Companion::Dashboard::AssistantFeedbackHandler
    route "POST", "/assistant/followups/approve", with: Companion::Dashboard::AssistantFollowupApproveHandler
  end
end
