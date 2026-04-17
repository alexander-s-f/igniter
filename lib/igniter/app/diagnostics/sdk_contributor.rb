# frozen_string_literal: true

module Igniter
  class App
    module Diagnostics
      module SdkContributor
        INTRINSIC_EXECUTOR_CAPABILITIES = %i[pure].freeze

        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            app = report[:app]
            return report unless app

            requested = Array(app[:sdk_capabilities]).map(&:to_sym).sort
            available = Igniter::SDK.capabilities(layer: :app).map { |capability| serialize_capability(capability) }
            requested_details = requested.map { |name| requested_detail(name) }
            activated_capabilities = requested.select { |name| Igniter::SDK.activated?(name) }
            coverage = coverage_summary(
              requested_details: requested_details,
              activated_capabilities: activated_capabilities,
              required_capabilities: report.dig(:capabilities, :unique_capabilities)
            )

            report[:app_sdk] = {
              requested_capabilities: requested,
              requested_details: requested_details,
              activated_capabilities: activated_capabilities,
              available_capabilities: available,
              available_count: available.size,
              coverage: coverage,
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
            lines << "- Coverage: #{coverage_summary_text(sdk[:coverage])}"
            sdk[:coverage][:entries].each do |entry|
              lines << "- Executor Capability `#{entry[:capability]}` status=#{entry[:status]} providers=#{list_or_none(entry[:providers])} suggestions=#{list_or_none(entry[:suggested_sdk_capabilities])}"
            end
            lines << "- Coverage Remediation: #{coverage_remediation_text(sdk[:coverage])}"
            lines << "- Packs: hosts=#{list_or_none(sdk.dig(:packs, :hosts))}; loaders=#{list_or_none(sdk.dig(:packs, :loaders))}; schedulers=#{list_or_none(sdk.dig(:packs, :schedulers))}"
          end

          private

          def coverage_summary(requested_details:, activated_capabilities:, required_capabilities:)
            activated_details = requested_details.select { |detail| activated_capabilities.include?(detail[:name]) }
            requested_coverage = requested_details.each_with_object({}) do |detail, memo|
              Array(detail[:provides_capabilities]).each do |capability|
                memo[capability] ||= []
                memo[capability] << detail[:name]
              end
            end
            active_coverage = activated_details.each_with_object({}) do |detail, memo|
              Array(detail[:provides_capabilities]).each do |capability|
                memo[capability] ||= []
                memo[capability] << detail[:name]
              end
            end
            available_coverage = Igniter::SDK.capabilities(layer: :app).each_with_object({}) do |detail, memo|
              Array(detail.provides_capabilities).each do |capability|
                memo[capability] ||= []
                memo[capability] << detail.name
              end
            end

            entries = Array(required_capabilities).map(&:to_sym).uniq.sort.map do |capability|
              providers = Array(active_coverage[capability]).map(&:to_sym).sort
              requested_providers = Array(requested_coverage[capability]).map(&:to_sym).sort
              suggested_sdk_capabilities = Array(available_coverage[capability]).map(&:to_sym).sort - providers
              status = if INTRINSIC_EXECUTOR_CAPABILITIES.include?(capability)
                         :intrinsic
                       elsif providers.empty?
                         :uncovered
                       else
                         :covered
                       end

              {
                capability: capability,
                status: status,
                providers: providers,
                requested_providers: requested_providers,
                suggested_sdk_capabilities: suggested_sdk_capabilities,
                remediation: remediation_for(
                  capability: capability,
                  status: status,
                  providers: providers,
                  suggested_sdk_capabilities: suggested_sdk_capabilities
                )
              }
            end

            {
              required_capabilities: Array(required_capabilities).map(&:to_sym).uniq.sort,
              covered_capabilities: entries.filter_map { |entry| entry[:capability] if entry[:status] == :covered },
              uncovered_capabilities: entries.filter_map { |entry| entry[:capability] if entry[:status] == :uncovered },
              intrinsic_capabilities: entries.filter_map { |entry| entry[:capability] if entry[:status] == :intrinsic },
              entries: entries,
              remediation: entries.filter_map { |entry| entry[:remediation] if entry[:remediation] }
            }
          end

          def requested_detail(name)
            capability = Igniter::SDK.fetch(name)
            serialize_capability(capability)
          rescue Igniter::SDK::UnknownCapabilityError
            {
              name: name.to_sym,
              entrypoint: nil,
              allowed_layers: [],
              provides_capabilities: [],
              unknown: true
            }
          end

          def serialize_capability(capability)
            {
              name: capability.name,
              entrypoint: capability.entrypoint,
              allowed_layers: capability.allowed_layers,
              provides_capabilities: capability.provides_capabilities
            }
          end

          def summary(sdk)
            [
              "requested=#{sdk[:requested_capabilities].size}",
              "activated=#{sdk[:activated_capabilities].size}",
              "available=#{sdk[:available_count]}",
              "coverage=#{coverage_summary_text(sdk[:coverage])}",
              "remediation=#{coverage_remediation_text(sdk[:coverage])}",
              "packs=hosts(#{list_or_none(sdk.dig(:packs, :hosts))})/loaders(#{list_or_none(sdk.dig(:packs, :loaders))})/schedulers(#{list_or_none(sdk.dig(:packs, :schedulers))})"
            ].join(", ")
          end

          def coverage_summary_text(coverage)
            return "required=none" if coverage[:required_capabilities].empty?

            [
              "required=#{list_or_none(coverage[:required_capabilities])}",
              "covered=#{list_or_none(coverage[:covered_capabilities])}",
              "uncovered=#{list_or_none(coverage[:uncovered_capabilities])}",
              "intrinsic=#{list_or_none(coverage[:intrinsic_capabilities])}"
            ].join(", ")
          end

          def coverage_remediation_text(coverage)
            remediations = Array(coverage[:remediation])
            return "none" if remediations.empty?

            remediations.map do |remediation|
              "#{remediation[:capability]}->#{list_or_none(remediation[:suggested_sdk_capabilities])}"
            end.join("; ")
          end

          def remediation_for(capability:, status:, providers:, suggested_sdk_capabilities:)
            return nil unless status == :uncovered
            return nil unless providers.empty?
            return nil if suggested_sdk_capabilities.empty?

            {
              code: :activate_sdk_capability,
              capability: capability,
              suggested_sdk_capabilities: suggested_sdk_capabilities,
              message: "Activate an SDK capability that provides #{capability}."
            }
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
