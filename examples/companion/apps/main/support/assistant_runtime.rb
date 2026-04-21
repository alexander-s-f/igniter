# frozen_string_literal: true

require "json"
require "net/http"
require "time"
require "timeout"
require "uri"
require "igniter/ai"
require_relative "../../../lib/companion/shared/assistant_runtime_store"
require_relative "assistant_delivery_channels"
require_relative "assistant_prompt_profiles"
require_relative "assistant_prompt_package"

module Companion
  module Main
    module Support
      module AssistantRuntime
        class << self
          def configuration
            raw = Companion::Shared::AssistantRuntimeStore.fetch
            profile = Companion::Main::Support::AssistantPromptProfiles.resolve(model: raw.fetch("model", "qwen2.5-coder:latest"))
            {
              mode: raw.fetch("mode", "manual").to_sym,
              provider: raw.fetch("provider", "ollama").to_sym,
              model: raw.fetch("model", "qwen2.5-coder:latest").to_s,
              base_url: raw.fetch("base_url", "http://127.0.0.1:11434").to_s,
              timeout_seconds: raw.fetch("timeout_seconds", 20).to_i,
              delivery_mode: raw.fetch("delivery_mode", "simulate").to_sym,
              delivery_strategy: raw.fetch("delivery_strategy", "prefer_openai").to_sym,
              openai_model: raw.fetch("openai_model", Igniter::AI::Config.new.openai.default_model).to_s,
              anthropic_model: raw.fetch("anthropic_model", Igniter::AI::Config.new.anthropic.default_model).to_s,
              profile: profile
            }
          end

          def configure(mode:, model:, base_url:, provider: "ollama", timeout_seconds: 20,
                        delivery_mode: "simulate", delivery_strategy: "prefer_openai",
                        openai_model: nil, anthropic_model: nil)
            normalized_mode = mode.to_s.strip
            normalized_model = model.to_s.strip
            normalized_base_url = base_url.to_s.strip
            normalized_provider = provider.to_s.strip
            normalized_timeout = timeout_seconds.to_i
            normalized_delivery_mode = delivery_mode.to_s.strip
            normalized_delivery_strategy = delivery_strategy.to_s.strip
            normalized_openai_model = openai_model.to_s.strip
            normalized_anthropic_model = anthropic_model.to_s.strip

            raise ArgumentError, "mode must be manual or ollama" unless %w[manual ollama].include?(normalized_mode)
            raise ArgumentError, "provider must be ollama" unless normalized_provider == "ollama"
            raise ArgumentError, "model is required" if normalized_model.empty?
            raise ArgumentError, "base_url is required" if normalized_base_url.empty?
            raise ArgumentError, "timeout_seconds must be between 5 and 300" unless normalized_timeout.between?(5, 300)
            raise ArgumentError, "delivery_mode must be simulate or live" unless %w[simulate live].include?(normalized_delivery_mode)
            unless Companion::Main::Support::AssistantDeliveryChannels::DELIVERY_STRATEGIES
                     .map(&:to_s).include?(normalized_delivery_strategy)
              raise ArgumentError, "delivery_strategy is invalid"
            end

            uri = URI.parse(normalized_base_url)
            unless uri.is_a?(URI::HTTP) && uri.host
              raise ArgumentError, "base_url must be a valid http(s) URL"
            end

            defaults = Companion::Shared::AssistantRuntimeStore.fetch
            normalized_openai_model = defaults.fetch("openai_model") if normalized_openai_model.empty?
            normalized_anthropic_model = defaults.fetch("anthropic_model") if normalized_anthropic_model.empty?

            Companion::Shared::AssistantRuntimeStore.save(
              mode: normalized_mode,
              provider: normalized_provider,
              model: normalized_model,
              base_url: normalized_base_url,
              timeout_seconds: normalized_timeout,
              delivery_mode: normalized_delivery_mode,
              delivery_strategy: normalized_delivery_strategy,
              openai_model: normalized_openai_model,
              anthropic_model: normalized_anthropic_model
            )

            overview
          rescue URI::InvalidURIError
            raise ArgumentError, "base_url must be a valid http(s) URL"
          end

          def overview
            config = configuration
            status = runtime_status(config)
            delivery = Companion::Main::Support::AssistantDeliveryChannels.overview(
              config: config,
              runtime_status: status
            )

            {
              config: {
                mode: config.fetch(:mode),
                provider: config.fetch(:provider),
                model: config.fetch(:model),
                base_url: config.fetch(:base_url),
                timeout_seconds: config.fetch(:timeout_seconds),
                delivery_mode: config.fetch(:delivery_mode),
                delivery_strategy: config.fetch(:delivery_strategy),
                openai_model: config.fetch(:openai_model),
                anthropic_model: config.fetch(:anthropic_model),
                profile: config.fetch(:profile).reject { |key, _| key == :system_prompt }
              },
              status: status,
              channels: delivery.fetch(:channels),
              routing: delivery.fetch(:routing),
              recommendation: delivery.fetch(:recommendation)
            }
          end

          def auto_draft(requester:, request:)
            config = configuration
            status = runtime_status(config)

            if config.fetch(:mode) != :ollama
              return { status: :manual, reason: :manual_mode, config: config, runtime: status }
            end

            unless status.fetch(:auto_draft_ready)
              return {
                status: :unavailable,
                reason: status.fetch(:reason),
                config: config,
                runtime: status
              }
            end

            provider = Igniter::AI::Providers::Ollama.new(
              base_url: config.fetch(:base_url),
              timeout: config.fetch(:timeout_seconds)
            )
            response = Timeout.timeout(config.fetch(:timeout_seconds)) do
              provider.chat(
                model: config.fetch(:model),
                messages: [
                  { role: :system, content: config.dig(:profile, :system_prompt) },
                  { role: :user, content: draft_prompt(config.fetch(:profile), requester: requester, request: request) }
                ],
                num_predict: config.dig(:profile, :num_predict)
              )
            end

            content = response.fetch(:content, "").to_s.strip
            raise Igniter::AI::ProviderError, "Ollama returned an empty briefing" if content.empty?

            {
              status: :succeeded,
              briefing: content,
              prompt_package: Companion::Main::Support::AssistantPromptPackage.build(
                requester: requester,
                request: request,
                runtime_config: config,
                profile: config.fetch(:profile),
                delivery_target: Companion::Main::Support::AssistantDeliveryChannels.delivery_target(
                  config: config,
                  runtime_status: status
                ),
                local_draft: content
              ),
              config: config,
              runtime: status.merge(
                checked_at: Time.now.utc.iso8601,
                outcome: :auto_drafted,
                profile: config.dig(:profile, :key)
              )
            }
          rescue Timeout::Error
            {
              status: :unavailable,
              reason: :timeout,
              error: "Draft exceeded timeout budget of #{config.fetch(:timeout_seconds)}s",
              config: config,
              runtime: status.merge(
                checked_at: Time.now.utc.iso8601,
                outcome: :timeout,
                profile: config.dig(:profile, :key),
                timeout_seconds: config.fetch(:timeout_seconds)
              )
            }
          rescue StandardError => e
            {
              status: :unavailable,
              reason: :draft_failed,
              error: e.message,
              config: config,
              runtime: status.merge(
                checked_at: Time.now.utc.iso8601,
                outcome: :draft_failed,
                error: e.message,
                profile: config.dig(:profile, :key)
              )
            }
          end

          def compare_drafts(requester:, request:, models:)
            normalized_models = Array(models).map(&:to_s).map(&:strip).reject(&:empty?).uniq
            normalized_models = [configuration.fetch(:model)] if normalized_models.empty?

            results = normalized_models.map do |model_name|
              config = configuration.merge(
                mode: :ollama,
                model: model_name,
                profile: Companion::Main::Support::AssistantPromptProfiles.resolve(model: model_name)
              )
              status = runtime_status(config)

              if status.fetch(:auto_draft_ready)
                begin
                  provider = Igniter::AI::Providers::Ollama.new(
                    base_url: config.fetch(:base_url),
                    timeout: config.fetch(:timeout_seconds)
                  )
                  response = Timeout.timeout(config.fetch(:timeout_seconds)) do
                    provider.chat(
                      model: model_name,
                      messages: [
                        { role: :system, content: config.dig(:profile, :system_prompt) },
                        { role: :user, content: draft_prompt(config.fetch(:profile), requester: requester, request: request) }
                      ],
                      num_predict: config.dig(:profile, :num_predict)
                    )
                  end
                  briefing = response.fetch(:content, "").to_s.strip
                  raise Igniter::AI::ProviderError, "Ollama returned an empty briefing" if briefing.empty?

                  {
                    model: model_name,
                    profile_key: config.dig(:profile, :key),
                    profile_label: config.dig(:profile, :label),
                    status: :completed,
                    reason: :ready,
                    ready: true,
                    briefing: briefing,
                    prompt_package: Companion::Main::Support::AssistantPromptPackage.build(
                      requester: requester,
                      request: request,
                      runtime_config: config,
                      profile: config.fetch(:profile),
                      delivery_target: Companion::Main::Support::AssistantDeliveryChannels.delivery_target(
                        config: config,
                        runtime_status: status
                      ),
                      local_draft: briefing
                    ),
                    checked_at: Time.now.utc.iso8601
                  }
                rescue Timeout::Error
                  {
                    model: model_name,
                    profile_key: config.dig(:profile, :key),
                    profile_label: config.dig(:profile, :label),
                    status: :unavailable,
                    reason: :timeout,
                    ready: false,
                    briefing: "Draft exceeded timeout budget of #{config.fetch(:timeout_seconds)}s.",
                    checked_at: Time.now.utc.iso8601
                  }
                rescue StandardError => e
                  {
                    model: model_name,
                    profile_key: config.dig(:profile, :key),
                    profile_label: config.dig(:profile, :label),
                    status: :unavailable,
                    reason: :draft_failed,
                    ready: false,
                    briefing: e.message,
                    checked_at: Time.now.utc.iso8601
                  }
                end
              else
                {
                  model: model_name,
                  profile_key: config.dig(:profile, :key),
                  profile_label: config.dig(:profile, :label),
                  status: :unavailable,
                  reason: status.fetch(:reason),
                  ready: false,
                  briefing: "Model not ready for drafting yet.",
                  checked_at: status.fetch(:checked_at)
                }
              end
            end

            {
              generated_at: Time.now.utc.iso8601,
              summary: {
                requested_models: normalized_models.size,
                completed: results.count { |entry| entry[:status] == :completed },
                unavailable: results.count { |entry| entry[:status] == :unavailable }
              },
              results: results
            }
          end

          private

          def runtime_status(config)
            checked_at = Time.now.utc.iso8601
            available_models = fetch_ollama_models(config.fetch(:base_url))
            selected_model = config.fetch(:model)
            model_available = available_models.include?(selected_model)

            if config.fetch(:mode) == :manual
              return {
                state: :manual,
                reason: :manual_mode,
                checked_at: checked_at,
                auto_draft_ready: false,
                timeout_seconds: config.fetch(:timeout_seconds),
                available_models: available_models.first(12),
                available_model_count: available_models.size,
                selected_model_available: model_available
              }
            end

            if available_models.empty?
              return {
                state: :unreachable,
                reason: :ollama_unreachable,
                checked_at: checked_at,
                auto_draft_ready: false,
                timeout_seconds: config.fetch(:timeout_seconds),
                available_models: [],
                available_model_count: 0,
                selected_model_available: false
              }
            end

            unless model_available
              return {
                state: :model_missing,
                reason: :model_missing,
                checked_at: checked_at,
                auto_draft_ready: false,
                timeout_seconds: config.fetch(:timeout_seconds),
                available_models: available_models.first(12),
                available_model_count: available_models.size,
                selected_model_available: false
              }
            end

            {
              state: :ready,
              reason: :ready,
              checked_at: checked_at,
              auto_draft_ready: true,
              timeout_seconds: config.fetch(:timeout_seconds),
              available_models: available_models.first(12),
              available_model_count: available_models.size,
              selected_model_available: true
            }
          rescue StandardError => e
            {
              state: :unreachable,
              reason: :ollama_unreachable,
              checked_at: checked_at,
              auto_draft_ready: false,
              timeout_seconds: config.fetch(:timeout_seconds),
              available_models: [],
              available_model_count: 0,
              selected_model_available: false,
              error: e.message
            }
          end

          def fetch_ollama_models(base_url)
            uri = URI.parse("#{base_url.sub(%r{/+\z}, "")}/api/tags")
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = uri.scheme == "https"
            http.open_timeout = 1
            http.read_timeout = 2

            response = http.get(uri.request_uri)
            return [] unless response.is_a?(Net::HTTPSuccess)

            JSON.parse(response.body).fetch("models", []).map { |entry| entry["name"].to_s }.reject(&:empty?)
          rescue StandardError
            []
          end

          def draft_prompt(profile, requester:, request:)
            <<~PROMPT
              Draft Style: #{profile.fetch(:label)}
              Guidance: #{profile.fetch(:guidance)}
              Output Budget: Keep the briefing short, scannable, and under #{profile.fetch(:num_predict)} tokens.

              Requester: #{requester}
              Request: #{request}

              Draft an operator-ready assistant briefing with short sections and no filler.
            PROMPT
          end
        end
      end
    end
  end
end
