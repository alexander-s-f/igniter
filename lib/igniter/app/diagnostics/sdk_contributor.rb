# frozen_string_literal: true

module Igniter
  class App
    module Diagnostics
      module SdkContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            app = report[:app]
            return report unless app

            requested = Array(app[:sdk_capabilities]).map(&:to_sym).sort
            available = Igniter::SDK.capabilities(layer: :app).map { |capability| serialize_capability(capability) }

            report[:app_sdk] = {
              requested_capabilities: requested,
              requested_details: requested.map { |name| requested_detail(name) },
              activated_capabilities: requested.select { |name| Igniter::SDK.activated?(name) },
              available_capabilities: available,
              available_count: available.size,
              packs: {
                hosts: Igniter::App::HostRegistry.names.map(&:to_sym).sort,
                loaders: Igniter::App::LoaderRegistry.names.map(&:to_sym).sort,
                schedulers: Igniter::App::SchedulerRegistry.names.map(&:to_sym).sort
              }
            }
            report
          end

          def append_text(report:, lines:)
            sdk = report[:app_sdk]
            return unless sdk

            lines << "SDK: #{summary(sdk)}"
          end

          def append_markdown_summary(report:, lines:)
            sdk = report[:app_sdk]
            return unless sdk

            lines << "- SDK: #{summary(sdk)}"
          end

          def append_markdown_sections(report:, lines:)
            sdk = report[:app_sdk]
            return unless sdk

            lines << ""
            lines << "## SDK"
            lines << "- Requested: total=#{sdk[:requested_capabilities].size}, names=#{list_or_none(sdk[:requested_capabilities])}"
            lines << "- Activated: total=#{sdk[:activated_capabilities].size}, names=#{list_or_none(sdk[:activated_capabilities])}"
            lines << "- Available For App: total=#{sdk[:available_count]}"
            sdk[:requested_details].each do |detail|
              lines << "- Capability `#{detail[:name]}` entrypoint=`#{detail[:entrypoint]}` layers=#{detail[:allowed_layers].join(", ")}"
            end
            lines << "- Packs: hosts=#{list_or_none(sdk.dig(:packs, :hosts))}; loaders=#{list_or_none(sdk.dig(:packs, :loaders))}; schedulers=#{list_or_none(sdk.dig(:packs, :schedulers))}"
          end

          private

          def requested_detail(name)
            capability = Igniter::SDK.fetch(name)
            serialize_capability(capability)
          rescue Igniter::SDK::UnknownCapabilityError
            {
              name: name.to_sym,
              entrypoint: nil,
              allowed_layers: [],
              unknown: true
            }
          end

          def serialize_capability(capability)
            {
              name: capability.name,
              entrypoint: capability.entrypoint,
              allowed_layers: capability.allowed_layers
            }
          end

          def summary(sdk)
            [
              "requested=#{sdk[:requested_capabilities].size}",
              "activated=#{sdk[:activated_capabilities].size}",
              "available=#{sdk[:available_count]}",
              "packs=hosts(#{list_or_none(sdk.dig(:packs, :hosts))})/loaders(#{list_or_none(sdk.dig(:packs, :loaders))})/schedulers(#{list_or_none(sdk.dig(:packs, :schedulers))})"
            ].join(", ")
          end

          def list_or_none(values)
            array = Array(values)
            return "none" if array.empty?

            array.join(", ")
          end
        end
      end
    end
  end
end
