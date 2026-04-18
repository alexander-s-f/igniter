# frozen_string_literal: true

module Igniter
  class App
    module Diagnostics
      module LoaderContributor
        class << self
          def augment(report:, execution:) # rubocop:disable Lint/UnusedMethodArgument
            app = report[:app]
            return report unless app

            loader_runtime = Hash(app[:loader_runtime] || {})
            code_paths = Hash(loader_runtime[:code_paths] || {})

            report[:app_loader] = {
              mode: app[:loader],
              adapter_class: loader_runtime[:adapter_class],
              root_dir: app[:root_dir],
              path_groups: Array(loader_runtime[:path_groups]).map(&:to_sym).sort,
              total_paths: loader_runtime[:total_paths].to_i,
              code_paths: code_paths.transform_values { |paths| Array(paths) }
            }
            report
          end

          def append_text(report:, lines:)
            loader = report[:app_loader]
            return unless loader

            lines << "Loader: #{summary(loader)}"
          end

          def append_markdown_summary(report:, lines:)
            loader = report[:app_loader]
            return unless loader

            lines << "- Loader: #{summary(loader)}"
          end

          def append_markdown_sections(report:, lines:)
            loader = report[:app_loader]
            return unless loader

            lines << ""
            lines << "## Loader"
            lines << "- Mode: `#{loader[:mode]}` adapter=`#{loader[:adapter_class] || "unknown"}`"
            lines << "- Root Dir: `#{loader[:root_dir]}`"
            lines << "- Paths: total=#{loader[:total_paths]}, groups=#{loader[:path_groups].join(", ")}"
            loader[:code_paths].each do |group, paths|
              lines << "- `#{group}`: #{paths.empty? ? "none" : paths.join(", ")}"
            end
          end

          private

          def summary(loader)
            [
              "mode=#{loader[:mode]}",
              "paths=#{loader[:total_paths]}",
              "groups=#{loader[:path_groups].join("|")}",
              "adapter=#{loader[:adapter_class] || "unknown"}"
            ].join(", ")
          end
        end
      end
    end
  end
end
