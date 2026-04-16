# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      module Tailwind
        module UI
          class MetricCard < View::Component
            DEFAULT_WRAPPER_CLASS = "rounded-[28px] border border-white/10 bg-white/5 p-5 shadow-2xl shadow-black/20 backdrop-blur".freeze
            DEFAULT_LABEL_CLASS = "text-[11px] font-semibold uppercase tracking-[0.28em] text-amber-200/70".freeze
            DEFAULT_VALUE_CLASS = "mt-3 block font-display text-4xl text-white".freeze
            DEFAULT_HINT_CLASS = "mt-2 block text-sm text-stone-400".freeze

            def initialize(label:, value:, hint: nil, wrapper_class: DEFAULT_WRAPPER_CLASS, label_class: DEFAULT_LABEL_CLASS,
                           value_class: DEFAULT_VALUE_CLASS, hint_class: DEFAULT_HINT_CLASS)
              @label = label
              @value = value
              @hint = hint
              @wrapper_class = wrapper_class
              @label_class = label_class
              @value_class = value_class
              @hint_class = hint_class
            end

            def call(view)
              view.tag(:article, class: @wrapper_class) do |card|
                card.tag(:span, @label, class: @label_class)
                card.tag(:strong, @value.to_s, class: @value_class)
                card.tag(:span, @hint, class: @hint_class) if @hint
              end
            end
          end

          class Panel < View::Component
            DEFAULT_WRAPPER_CLASS = "rounded-[30px] border border-white/10 bg-stone-900/80 p-6 shadow-2xl shadow-black/20 backdrop-blur".freeze
            DEFAULT_HEAD_CLASS = "mb-5 flex flex-col gap-2".freeze
            DEFAULT_TITLE_CLASS = "font-display text-2xl text-white".freeze
            DEFAULT_SUBTITLE_CLASS = "text-sm leading-6 text-stone-400".freeze

            def initialize(title:, subtitle: nil, tag: :section, wrapper_class: DEFAULT_WRAPPER_CLASS,
                           head_class: DEFAULT_HEAD_CLASS, title_class: DEFAULT_TITLE_CLASS,
                           subtitle_class: DEFAULT_SUBTITLE_CLASS, &block)
              @title = title
              @subtitle = subtitle
              @tag = tag
              @wrapper_class = wrapper_class
              @head_class = head_class
              @title_class = title_class
              @subtitle_class = subtitle_class
              @block = block
            end

            def call(view)
              view.tag(@tag, class: @wrapper_class) do |panel|
                panel.tag(:div, class: @head_class) do |head|
                  head.tag(:h2, @title, class: @title_class)
                  head.tag(:p, @subtitle, class: @subtitle_class) if @subtitle
                end
                @block.call(panel)
              end
            end
          end

          class StatusBadge < View::Component
            DEFAULT_BASE_CLASS = "status-badge inline-flex items-center rounded-full border px-2.5 py-1 text-[11px] font-semibold uppercase tracking-[0.18em]".freeze

            def initialize(label:, tone: nil, base_class: DEFAULT_BASE_CLASS)
              @label = label.to_s
              @tone = tone
              @base_class = base_class
            end

            def call(view)
              view.tag(:span, @label, class: [@base_class, tone_classes])
            end

            private

            def tone_classes
              return @tone if @tone

              case @label.downcase
              when "ready", "configured", "online", "healthy"
                "border-emerald-400/30 bg-emerald-400/10 text-emerald-200"
              when "warning", "stale"
                "border-amber-300/30 bg-amber-300/10 text-amber-100"
              when "degraded", "offline"
                "border-rose-300/30 bg-rose-300/10 text-rose-100"
              else
                "border-cyan-300/30 bg-cyan-300/10 text-cyan-100"
              end
            end
          end
        end
      end
    end
  end
end
