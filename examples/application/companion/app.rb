# frozen_string_literal: true

require "uri"

require "igniter/application"

require_relative "contracts/daily_summary_contract"
require_relative "services/companion_store"
require_relative "web/companion_dashboard"

module Companion
  APP_ROOT = File.expand_path(__dir__)

  def self.feedback_path(params)
    "/?#{URI.encode_www_form(params)}"
  end

  def self.build
    Igniter::Application.rack_app(:companion, root: APP_ROOT, env: :test) do
      credential :openai_api_key, env: "OPENAI_API_KEY", required: false, description: "OpenAI API key for live mode"

      service(:companion) do
        Services::CompanionStore.new(
          credentials: Igniter::Application::CredentialStore.new(
            definitions: [
              Igniter::Application::CredentialDefinition.new(
                name: :openai_api_key,
                env: "OPENAI_API_KEY",
                required: false,
                description: "OpenAI API key for live mode"
              )
            ]
          )
        )
      end

      mount_web(
        :companion_dashboard,
        Web.companion_dashboard_mount,
        at: "/",
        capabilities: %i[screen command],
        metadata: { ready_to_go: true, capsules: %i[reminders trackers countdowns daily_summary] }
      )

      get "/events" do
        text service(:companion).events_read_model
      end

      get "/setup" do
        text service(:companion).snapshot.credential_status.inspect
      end

      post "/reminders/create" do |params|
        result = service(:companion).create_reminder(params.fetch("title", ""))
        redirect Companion.feedback_path((result.success? ? :notice : :error) => result.feedback_code, subject: result.subject_id)
      end

      post "/reminders/:id/complete" do |params|
        result = service(:companion).complete_reminder(params.fetch("id", ""))
        redirect Companion.feedback_path((result.success? ? :notice : :error) => result.feedback_code, subject: result.subject_id)
      end

      post "/trackers/:id/log" do |params|
        result = service(:companion).log_tracker(params.fetch("id", ""), params.fetch("value", ""))
        redirect Companion.feedback_path((result.success? ? :notice : :error) => result.feedback_code, subject: result.subject_id)
      end
    end
  end
end
