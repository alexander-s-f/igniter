# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Plugins
    module View
      module Arbre
        module Components
          class ScenarioCard < Arbre::Component
            builder_method :scenario_card

            def build(*args, &block)
              options = extract_options!(args)
              title = options.delete(:title)
              severity = options.delete(:severity)
              summary = options.delete(:summary)
              span = options.delete(:span)
              class_name = options.delete(:class_name)
              span_class = span ? "span-#{span}" : nil

              super(options.merge(class: merge_classes("panel", span_class, class_name)))
              h3(title) if title
              badge(severity, tone: badge_tone(severity)) if severity
              div(summary) if summary
              render_build_block(block)
            end

            private

            def badge_tone(status)
              case status.to_s
              when "healthy"
                :healthy
              when "warning"
                :warning
              else
                :danger
              end
            end

            def tag_name
              "article"
            end
          end
        end
      end
    end
  end
end
