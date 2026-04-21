# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class Badge < Arbre::Component
          builder_method :badge

          TONE_CLASS = {
            neutral: "pill inline-flex items-center rounded-full border border-white/10 bg-white/5 text-stone-200",
            healthy: "pill inline-flex items-center rounded-full border border-emerald-300/20 bg-emerald-300/10 text-emerald-100",
            warning: "pill warn inline-flex items-center rounded-full border border-amber-300/20 bg-amber-300/10 text-amber-100",
            danger: "pill danger inline-flex items-center rounded-full border border-rose-300/20 bg-rose-300/10 text-rose-100",
            info: "pill info inline-flex items-center rounded-full border border-cyan-300/20 bg-cyan-300/10 text-cyan-100",
            accent: "pill accent inline-flex items-center rounded-full border border-orange-300/20 bg-orange-300/10 text-orange-100"
          }.freeze

          SIZE_CLASS = {
            xs: "px-2 py-0.5 text-[10px] font-mono uppercase tracking-[0.18em]",
            sm: "px-2.5 py-1 text-[11px] font-mono uppercase tracking-[0.18em]",
            md: "px-3 py-1 text-xs font-mono uppercase tracking-[0.18em]",
            lg: "px-4 py-1.5 text-sm font-semibold tracking-[0.12em]"
          }.freeze

          def build(label, *args)
            options = extract_options!(args)
            tone = options.delete(:tone) || options.delete(:state)
            size = (options.delete(:size) || :md).to_sym
            titleize = options.key?(:titleize) ? options.delete(:titleize) : true
            class_name = options.delete(:class_name)
            normalized = normalize_label(label, titleize: titleize)
            inferred_tone = tone ? tone.to_sym : infer_tone(label, normalized)
            badge_class = merge_classes(
              TONE_CLASS.fetch(inferred_tone, TONE_CLASS[:neutral]),
              SIZE_CLASS.fetch(size, SIZE_CLASS[:md]),
              class_name
            )
            super(options.merge(class: badge_class))
            text_node(normalized.to_s)
          end

          private

          def normalize_label(label, titleize:)
            value = label.respond_to?(:name) ? label.name : label

            case value
            when true, "true", 1, "1"
              "Yes"
            when false, "false", 0, "0"
              "No"
            when Symbol
              titleize ? humanize_label(value) : value.to_s
            when String
              titleize ? humanize_label(value) : value
            else
              value.to_s
            end
          end

          def infer_tone(original, normalized)
            return :healthy if [true, "true", 1, "1"].include?(original)
            return :danger if [false, "false", 0, "0"].include?(original)

            token = normalized.to_s.downcase.strip.gsub(/\s+/, "_")

            case token
            when "healthy", "active", "online", "running", "joined", "success", "resolved", "yes", "ready"
              :healthy
            when "warning", "stale", "pending", "queued", "awaiting", "paused", "degraded", "draft", "planned"
              :warning
            when "danger", "failed", "failure", "error", "offline", "blocked", "rejected", "dismissed", "no"
              :danger
            when "info", "detached", "idle", "neutral"
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
