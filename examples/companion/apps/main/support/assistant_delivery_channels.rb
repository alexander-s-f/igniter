# frozen_string_literal: true

require "igniter/ai"
require "igniter/app"
require_relative "assistant_credential_policy"

module Companion
  module Main
    module Support
      module AssistantDeliveryChannels
        DELIVERY_STRATEGIES = %i[auto prefer_openai prefer_anthropic manual_only].freeze

        class << self
          def overview(config:, runtime_status:)
            ai_config = Igniter::AI::Config.new
            credential_policy = Companion::Main::Support::AssistantCredentialPolicy.current

            channels = {
              manual_completion: manual_channel,
              ollama_prep: ollama_prep_channel(config, runtime_status),
              openai_api: external_channel(
                credential: external_credential(
                  key: :openai_api,
                  label: "OpenAI API",
                  provider: :openai,
                  model: config.fetch(:openai_model),
                  policy: credential_policy
                ),
                credentials_ready: api_key_present?(ai_config.openai.api_key)
              ),
              anthropic_api: external_channel(
                credential: external_credential(
                  key: :anthropic_api,
                  label: "Anthropic API",
                  provider: :anthropic,
                  model: config.fetch(:anthropic_model),
                  policy: credential_policy
                ),
                credentials_ready: api_key_present?(ai_config.anthropic.api_key)
              )
            }

            {
              credential_policy: Companion::Main::Support::AssistantCredentialPolicy.serialize(credential_policy),
              channels: channels.values,
              routing: {
                strategy: config.fetch(:delivery_strategy),
                prep_channel: select_prep_channel(channels, config),
                delivery_channel: select_delivery_channel(channels, config),
                prep_ready: channels.fetch(:ollama_prep).fetch(:available),
                external_delivery_ready: select_delivery_channel(channels, config).fetch(:available)
              },
              recommendation: build_recommendation(
                channels: channels,
                config: config,
                runtime_status: runtime_status
              )
            }
          end

          def delivery_target(config:, runtime_status:)
            overview(config: config, runtime_status: runtime_status).dig(:routing, :delivery_channel)
          end

          private

          def manual_channel
            {
              key: :manual_completion,
              label: "Manual Completion",
              kind: :manual,
              provider: :operator,
              model: nil,
              available: true,
              credentials_ready: true,
              reason: :operator_lane
            }
          end

          def ollama_prep_channel(config, runtime_status)
            {
              key: :ollama_prep,
              label: "Ollama Prep",
              kind: :prep,
              provider: :ollama,
              model: config.fetch(:model),
              available: runtime_status.fetch(:auto_draft_ready, false),
              credentials_ready: true,
              reason: runtime_status.fetch(:reason, :unknown)
            }
          end

          def external_credential(key:, label:, provider:, model:, policy:)
            Igniter::App::Credentials::Credential.new(
              key: key,
              label: label,
              provider: provider,
              scope: :local,
              node: "current",
              policy: policy,
              metadata: { model: model }
            )
          end

          def external_channel(credential:, credentials_ready:)
            policy_allowed = credential.allowed_in_scope?(:local)

            {
              key: credential.key,
              label: credential.label,
              kind: :delivery,
              provider: credential.provider,
              model: credential.metadata[:model],
              available: credentials_ready && !credential.metadata[:model].to_s.strip.empty? && policy_allowed,
              credentials_ready: credentials_ready,
              credential: credential.to_h,
              credential_policy: credential.policy.name,
              policy_allowed: policy_allowed,
              reason: if !policy_allowed
                        :policy_denied
                      elsif credentials_ready
                        :ready
                      else
                        :credentials_missing
                      end
            }
          end

          def select_prep_channel(channels, config)
            return channels.fetch(:manual_completion) unless config.fetch(:mode) == :ollama

            channels.fetch(:ollama_prep)
          end

          def select_delivery_channel(channels, config)
            strategy = config.fetch(:delivery_strategy)

            case strategy
            when :prefer_openai
              first_available(channels, :openai_api, :anthropic_api, :manual_completion)
            when :prefer_anthropic
              first_available(channels, :anthropic_api, :openai_api, :manual_completion)
            when :manual_only
              channels.fetch(:manual_completion)
            else
              first_available(channels, :openai_api, :anthropic_api, :manual_completion)
            end
          end

          def first_available(channels, *keys)
            keys.each do |key|
              channel = channels.fetch(key)
              return channel if channel.fetch(:available)
            end

            channels.fetch(:manual_completion)
          end

          def api_key_present?(value)
            !value.to_s.strip.empty?
          end

          def build_recommendation(channels:, config:, runtime_status:)
            prep_channel = select_prep_channel(channels, config)
            delivery_channel = select_delivery_channel(channels, config)
            available_models = Array(runtime_status[:available_models]).map(&:to_s)
            selected_model = config.fetch(:model).to_s

            prep_summary =
              if prep_channel[:key] == :manual_completion
                "Use the operator lane directly while local prep is disabled."
              elsif prep_channel[:available]
                "Use #{selected_model} for prompt prep."
              else
                "Local prep is configured but not ready yet."
              end

            delivery_summary =
              if delivery_channel[:key] == :manual_completion
                "Keep final delivery in the manual operator lane."
              else
                "Send outward through #{delivery_channel[:label]} using #{delivery_channel[:model]}."
              end

            notes = []
            if available_models.any? { |name| name.match?(/gpt-oss/i) }
              notes << "gpt-oss looks usable for lightweight local prompt prep."
            end
            if available_models.any? { |name| name.match?(/qwen2\.?5-coder/i) }
              notes << "qwen2.5-coder remains the strongest default for practical technical prep."
            end
            if delivery_channel[:key] == :manual_completion && config.fetch(:delivery_strategy) != :manual_only
              notes << "External delivery is not ready yet, so Companion is falling back to manual completion."
            end
            notes << "Live external delivery is enabled." if config.fetch(:delivery_mode) == :live
            notes << "Credential policy is local-only: route work before considering any secret sharing."

            {
              title: "Best Current Lane",
              prep: prep_channel[:label],
              prep_model: prep_channel[:model],
              delivery: delivery_channel[:label],
              delivery_model: delivery_channel[:model],
              summary: "#{prep_summary} #{delivery_summary}",
              notes: notes.uniq
            }
          end
        end
      end
    end
  end
end
