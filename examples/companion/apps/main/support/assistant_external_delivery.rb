# frozen_string_literal: true

require "igniter/ai"

module Companion
  module Main
    module Support
      module AssistantExternalDelivery
        module_function

        def deliver(prompt_package:, runtime_overview:)
          routing = runtime_overview.fetch(:routing, {})
          target = routing.fetch(:delivery_channel, {})
          config = runtime_overview.fetch(:config, {})
          mode = config.fetch(:delivery_mode, :simulate).to_sym

          return skipped_result(target, :manual_channel_selected) if target.fetch(:kind, nil) == :manual
          return unavailable_result(target, :channel_unavailable) unless target.fetch(:available, false)

          case target.fetch(:provider)
          when :openai
            mode == :live ? deliver_openai_live(prompt_package, config, target) : simulate_result(prompt_package, config, target)
          when :anthropic
            mode == :live ? unavailable_result(target, :not_implemented) : simulate_result(prompt_package, config, target)
          else
            skipped_result(target, :unsupported_channel)
          end
        end

        def simulate_result(prompt_package, config, target)
          briefing = prompt_package[:local_draft].to_s.strip
          briefing = "Simulated delivery prepared for #{target.fetch(:label)} using #{target[:model]}." if briefing.empty?

          {
            status: :simulated,
            channel: target.fetch(:key),
            channel_label: target.fetch(:label),
            provider: target.fetch(:provider),
            model: target[:model],
            mode: config.fetch(:delivery_mode),
            output: briefing,
            reason: :simulation_mode
          }
        end

        def deliver_openai_live(prompt_package, config, target)
          provider = Igniter::AI::Providers::OpenAI.new(timeout: config.fetch(:timeout_seconds))
          response = provider.chat(
            model: target.fetch(:model),
            messages: [
              { role: :system, content: prompt_package.fetch(:system_prompt) },
              { role: :user, content: prompt_package.fetch(:user_prompt) }
            ],
            max_tokens: 700
          )

          content = response.fetch(:content, "").to_s.strip
          raise Igniter::AI::ProviderError, "OpenAI delivery returned empty content" if content.empty?

          {
            status: :succeeded,
            channel: target.fetch(:key),
            channel_label: target.fetch(:label),
            provider: target.fetch(:provider),
            model: target.fetch(:model),
            mode: config.fetch(:delivery_mode),
            output: content,
            reason: :delivered
          }
        rescue StandardError => e
          unavailable_result(target, :delivery_failed, error: e.message)
        end

        def unavailable_result(target, reason, error: nil)
          {
            status: :unavailable,
            channel: target.fetch(:key, :unknown),
            channel_label: target.fetch(:label, "Unknown"),
            provider: target.fetch(:provider, :unknown),
            model: target[:model],
            reason: reason,
            error: error
          }.compact
        end

        def skipped_result(target, reason)
          {
            status: :skipped,
            channel: target.fetch(:key, :manual_completion),
            channel_label: target.fetch(:label, "Manual Completion"),
            provider: target.fetch(:provider, :operator),
            model: target[:model],
            reason: reason
          }
        end
      end
    end
  end
end
