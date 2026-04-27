# frozen_string_literal: true

module Companion
  module AppDSL
    def companion_credentials(config)
      config.credentials.each do |definition|
        credential(
          definition.fetch(:name),
          env: definition.fetch(:env),
          required: definition.fetch(:required),
          description: definition.fetch(:description)
        )
      end
    end

    def companion_ai(config)
      ai do
        provider :openai, credential: :openai_api_key, model: config.llm_model
      end

      agents do
        assistant :daily_companion,
                  ai: :openai,
                  instructions: "Give one concise practical next action for the Companion user.",
                  capsule: :daily_summary
      end
    end

    def companion_store(config)
      service(:companion) do |environment|
        Services::CompanionStore.new(
          credentials: config.credential_store,
          backend: config.store_adapter,
          llm_provider: environment.credentials.configured?(:openai_api_key) ? environment.ai_client(:openai) : nil
        )
      end
    end

    def companion_dashboard
      mount_web(
        :companion_dashboard,
        Web.companion_dashboard_mount,
        at: "/",
        capabilities: %i[screen command],
        metadata: { ready_to_go: true, capsules: %i[reminders trackers countdowns daily_summary] }
      )
    end

    def companion_routes
      get "/events" do
        text service(:companion).events_read_model
      end

      get "/setup" do
        text service(:companion).snapshot.credential_status.inspect
      end

      post "/summary/live" do
        result = service(:companion).generate_live_summary
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end

      post "/reminders/create" do |params|
        result = service(:companion).create_reminder(params.fetch("title", ""))
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end

      post "/reminders/:id/complete" do |params|
        result = service(:companion).complete_reminder(params.fetch("id", ""))
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end

      post "/trackers/:id/log" do |params|
        result = service(:companion).log_tracker(params.fetch("id", ""), params.fetch("value", ""))
        redirect Companion.feedback_path(
          (result.success? ? :notice : :error) => result.feedback_code,
          subject: result.subject_id
        )
      end
    end
  end
end
