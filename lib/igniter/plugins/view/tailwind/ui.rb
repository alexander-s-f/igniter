# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      module Tailwind
        module UI
          class ActionBar < View::Component
            DEFAULT_CLASS = "flex flex-wrap gap-3".freeze

            def initialize(tag: :div, class_name: DEFAULT_CLASS, &block)
              @tag = tag
              @class_name = class_name
              @block = block
            end

            def call(view)
              view.tag(@tag, class: @class_name) do |container|
                @block&.call(container)
              end
            end
          end

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

          class FormSection < View::Component
            DEFAULT_FORM_CLASS = "grid gap-3".freeze

            def initialize(title:, action:, subtitle: nil, method: "post", tag: :section, wrapper_class: Panel::DEFAULT_WRAPPER_CLASS,
                           head_class: Panel::DEFAULT_HEAD_CLASS, title_class: Panel::DEFAULT_TITLE_CLASS,
                           subtitle_class: Panel::DEFAULT_SUBTITLE_CLASS, form_class: DEFAULT_FORM_CLASS, &block)
              @title = title
              @action = action
              @subtitle = subtitle
              @method = method
              @tag = tag
              @wrapper_class = wrapper_class
              @head_class = head_class
              @title_class = title_class
              @subtitle_class = subtitle_class
              @form_class = form_class
              @block = block
            end

            def call(view)
              view.component(
                Panel.new(
                  title: @title,
                  subtitle: @subtitle,
                  tag: @tag,
                  wrapper_class: @wrapper_class,
                  head_class: @head_class,
                  title_class: @title_class,
                  subtitle_class: @subtitle_class
                ) do |panel|
                  panel.form(action: @action, method: @method, class: @form_class) do |form|
                    yield_form(form, panel)
                  end
                end
              )
            end

            private

            def yield_form(form, panel)
              return if @block.nil?

              if @block.arity >= 2
                @block.call(form, panel)
              else
                @block.call(form)
              end
            end
          end

          class KeyValueList < View::Component
            DEFAULT_WRAPPER_CLASS = "kv-list mt-1 grid grid-cols-1 gap-x-6 gap-y-4 sm:grid-cols-[minmax(140px,190px)_1fr]".freeze
            DEFAULT_KEY_CLASS = "text-sm font-semibold uppercase tracking-[0.18em] text-stone-400".freeze
            DEFAULT_VALUE_CLASS = "break-words text-sm leading-6 text-stone-200".freeze

            def initialize(rows:, wrapper_class: DEFAULT_WRAPPER_CLASS, key_class: DEFAULT_KEY_CLASS, value_class: DEFAULT_VALUE_CLASS)
              @rows = rows
              @wrapper_class = wrapper_class
              @key_class = key_class
              @value_class = value_class
            end

            def call(view)
              view.tag(:dl, class: @wrapper_class) do |list|
                @rows.each do |key, value|
                  list.tag(:dt, key.to_s, class: @key_class)
                  list.tag(:dd, value.to_s, class: @value_class)
                end
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
