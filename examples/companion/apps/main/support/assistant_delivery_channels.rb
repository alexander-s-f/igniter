# frozen_string_literal: true

require "igniter/ai"

module Companion
  module Main
    module Support
      module AssistantDeliveryChannels
        DELIVERY_STRATEGIES = %i[auto prefer_openai prefer_anthropic manual_only].freeze

        class << self
          def overview(config:, runtime_status:)
            ai_config = Igniter::AI::Config.new

            channels = {
              manual_completion: manual_channel,
              ollama_prep: ollama_prep_channel(config, runtime_status),
              openai_api: external_channel(
                key: :openai_api,
                label: "OpenAI API",
                provider: :openai,
                model: config.fetch(:openai_model),
                credentials_ready: api_key_present?(ai_config.openai.api_key)
              ),
              anthropic_api: external_channel(
                key: :anthropic_api,
                label: "Anthropic API",
                provider: :anthropic,
                model: config.fetch(:anthropic_model),
                credentials_ready: api_key_present?(ai_config.anthropic.api_key)
              )
            }

            {
              channels: channels.values,
              routing: {
                strategy: config.fetch(:delivery_strategy),
                prep_channel: select_prep_channel(channels, config),
                delivery_channel: select_delivery_channel(channels, config),
                prep_ready: channels.fetch(:ollama_prep).fetch(:available),
                external_delivery_ready: select_delivery_channel(channels, config).fetch(:available)
              }
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

          def external_channel(key:, label:, provider:, model:, credentials_ready:)
            {
              key: key,
              label: label,
              kind: :delivery,
              provider: provider,
              model: model,
              available: credentials_ready && !model.to_s.strip.empty?,
              credentials_ready: credentials_ready,
              reason: credentials_ready ? :ready : :credentials_missing
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
        end
      end
    end
  end
end
