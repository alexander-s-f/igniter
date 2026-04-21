# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class Indicator < Arbre::Component
          builder_method :indicator

          TONE_CLASS = {
            neutral: "bg-stone-500",
            healthy: "bg-emerald-300",
            warning: "bg-amber-300",
            danger: "bg-rose-300",
            info: "bg-cyan-300",
            accent: "bg-orange-300"
          }.freeze

          def build(label, *args)
            options = extract_options!(args)
            tone = options.delete(:tone)&.to_sym || infer_tone(label)
            class_name = options.delete(:class_name)
            titleize = options.key?(:titleize) ? options.delete(:titleize) : true
            normalized = titleize ? humanize_label(label) : label.to_s

            super(options.merge(class: merge_classes("inline-flex items-center gap-2 text-sm text-stone-200", class_name)))
            span(class: merge_classes("inline-flex h-2.5 w-2.5 rounded-full", TONE_CLASS.fetch(tone, TONE_CLASS[:neutral])))
            span(normalized, class: "font-medium")
          end

          private

          def infer_tone(value)
            token = value.to_s.downcase.strip.gsub(/\s+/, "_")

            case token
            when "ready", "healthy", "online", "running", "joined", "active"
              :healthy
            when "pending", "queued", "awaiting", "degraded", "warming"
              :warning
            when "failed", "blocked", "offline", "error"
              :danger
            when "detached", "idle", "neutral"
              :info
            else
              :neutral
            end
          end

          def tag_name
            "span"
          end
        end
      end
    end
  end
end
