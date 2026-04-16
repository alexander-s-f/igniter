# frozen_string_literal: true

require "json"

module Igniter
  module Plugins
    module View
      module Tailwind
        module UI
          module Tokens
            THEMES = {
              orange: {
                strong_border: "border-orange-300/20",
                strong_bg: "bg-orange-300/90",
                strong_hover: "hover:bg-orange-200",
                soft_border: "border-orange-300/20",
                soft_bg: "bg-orange-300/10",
                soft_text: "text-orange-100",
                soft_hover: "hover:bg-orange-300/20",
                ghost_hover_border: "hover:border-orange-200/35",
                ghost_hover_bg: "hover:bg-orange-300/10",
                ghost_hover_text: "hover:text-orange-100",
                underline_text: "text-orange-200",
                underline_decoration: "decoration-orange-200/30"
              },
              amber: {
                strong_border: "border-amber-300/20",
                strong_bg: "bg-amber-300/90",
                strong_hover: "hover:bg-amber-200",
                soft_border: "border-amber-200/15",
                soft_bg: "bg-amber-300/10",
                soft_text: "text-amber-100",
                soft_hover: "hover:bg-amber-300/20",
                ghost_hover_border: "hover:border-amber-200/35",
                ghost_hover_bg: "hover:bg-amber-300/10",
                ghost_hover_text: "hover:text-amber-100",
                underline_text: "text-amber-200",
                underline_decoration: "decoration-amber-200/30"
              },
              cyan: {
                strong_border: "border-cyan-300/20",
                strong_bg: "bg-cyan-300/10",
                strong_hover: "hover:bg-cyan-300/20",
                soft_border: "border-cyan-300/20",
                soft_bg: "bg-cyan-300/10",
                soft_text: "text-cyan-100",
                soft_hover: "hover:bg-cyan-300/20",
                ghost_hover_border: "hover:border-cyan-200/30",
                ghost_hover_bg: "hover:bg-cyan-300/10",
                ghost_hover_text: "hover:text-cyan-100",
                underline_text: "text-cyan-200",
                underline_decoration: "decoration-cyan-200/30"
              }
            }.freeze

            module_function

            def action(variant: :primary, theme: :orange, size: :md, extra: nil)
              classes = [base_action(size), variant_classes(variant.to_sym, palette_for(theme)), extra]
              classes.compact.join(" ")
            end

            def underline_link(theme: :orange, extra: nil)
              palette = palette_for(theme)
              [palette.fetch(:underline_text), "underline", palette.fetch(:underline_decoration), "underline-offset-4", extra].compact.join(" ")
            end

            def badge(theme: :orange, extra: nil)
              palette = palette_for(theme)
              [
                "inline-flex rounded-full border px-3 py-1 text-xs font-mono uppercase tracking-[0.18em]",
                palette.fetch(:soft_border),
                palette.fetch(:soft_bg),
                palette.fetch(:soft_text),
                extra
              ].compact.join(" ")
            end

            private_class_method def palette_for(theme)
              THEMES.fetch(theme.to_sym)
            end

            private_class_method def base_action(size)
              case size.to_sym
              when :sm
                "inline-flex items-center justify-center rounded-full border px-4 py-2 text-sm transition"
              else
                "inline-flex items-center justify-center rounded-full border px-5 py-3 text-sm font-semibold uppercase tracking-[0.18em] transition"
              end
            end

            private_class_method def variant_classes(variant, palette)
              case variant
              when :primary
                [palette.fetch(:strong_border), palette.fetch(:strong_bg), "text-stone-950", palette.fetch(:strong_hover)].join(" ")
              when :secondary
                "border-white/10 bg-white/10 text-stone-100 hover:bg-white/15"
              when :soft
                [palette.fetch(:soft_border), palette.fetch(:soft_bg), palette.fetch(:soft_text), palette.fetch(:soft_hover)].join(" ")
              when :ghost
                ["border-white/10", "bg-white/5", "text-stone-200", palette.fetch(:ghost_hover_border), palette.fetch(:ghost_hover_bg), palette.fetch(:ghost_hover_text)].join(" ")
              else
                raise ArgumentError, "unsupported action variant: #{variant}"
              end
            end
          end

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

          class InlineActions < ActionBar
            DEFAULT_CLASS = "mt-4 flex flex-wrap gap-3".freeze

            def initialize(tag: :div, class_name: DEFAULT_CLASS, &block)
              super(tag: tag, class_name: class_name, &block)
            end
          end

          class Banner < View::Component
            DEFAULT_BASE_CLASS = "rounded-2xl border px-4 py-3 text-sm".freeze

            def initialize(message:, tone: :notice, tag: :div, base_class: DEFAULT_BASE_CLASS, tone_class: nil)
              @message = message
              @tone = tone.to_sym
              @tag = tag
              @base_class = base_class
              @tone_class = tone_class
            end

            def call(view)
              view.tag(@tag, @message, class: [@base_class, resolved_tone_class])
            end

            private

            def resolved_tone_class
              return @tone_class if @tone_class

              case @tone
              when :success
                "border-emerald-300/20 bg-emerald-300/10 text-emerald-100"
              when :warning
                "border-amber-300/20 bg-amber-300/10 text-amber-100"
              when :error
                "border-rose-300/20 bg-rose-300/10 text-rose-100"
              when :info
                "border-cyan-300/20 bg-cyan-300/10 text-cyan-100"
              else
                "border-orange-300/20 bg-orange-300/10 text-orange-100"
              end
            end
          end

          class Field < View::Component
            DEFAULT_WRAPPER_CLASS = "field".freeze
            DEFAULT_LABEL_CLASS = "mb-2 block text-sm font-semibold uppercase tracking-[0.18em] text-stone-300".freeze
            DEFAULT_HINT_CLASS = "mt-2 text-sm text-stone-400".freeze
            DEFAULT_ERROR_CLASS = "mt-2 text-sm text-rose-200".freeze

            def initialize(id:, label: nil, error: nil, hint: nil, wrapper_class: DEFAULT_WRAPPER_CLASS,
                           label_class: DEFAULT_LABEL_CLASS, hint_class: DEFAULT_HINT_CLASS,
                           error_class: DEFAULT_ERROR_CLASS, &block)
              @id = id
              @label = label
              @error = error
              @hint = hint
              @wrapper_class = wrapper_class
              @label_class = label_class
              @hint_class = hint_class
              @error_class = error_class
              @block = block
            end

            def call(view)
              view.tag(:div, class: @wrapper_class) do |container|
                container.tag(:label, @label, for: @id, class: @label_class) if @label
                @block&.call(container)
                container.tag(:p, @hint, class: @hint_class) if @hint
                container.tag(:p, @error, class: @error_class) if @error
              end
            end
          end

          class SubmissionNotice < View::Component
            def initialize(message:, tone: :notice, tag: :div, **banner_options)
              @message = message
              @tone = tone
              @tag = tag
              @banner_options = banner_options
            end

            def call(view)
              view.component(Banner.new(message: @message, tone: @tone, tag: @tag, **@banner_options))
            end
          end

          class FieldGroup < View::Component
            def initialize(id:, label:, error: nil, hint: nil, **field_options, &block)
              @id = id
              @label = label
              @error = error
              @hint = hint
              @field_options = field_options
              @block = block
            end

            def call(view)
              view.component(
                Field.new(
                  id: @id,
                  label: @label,
                  error: @error,
                  hint: @hint,
                  **@field_options,
                  &@block
                )
              )
            end
          end

          class ChoiceField < View::Component
            def initialize(kind:, name:, id:, label:, error: nil, hint: nil, options: nil, selected: nil,
                           checked: nil, value: "1", input_class: nil, checkbox_label_class: nil,
                           checkbox_class: nil)
              @kind = kind.to_sym
              @name = name
              @id = id
              @label = label
              @error = error
              @hint = hint
              @options = options
              @selected = selected
              @checked = checked
              @value = value
              @input_class = input_class
              @checkbox_label_class = checkbox_label_class
              @checkbox_class = checkbox_class
            end

            def call(view)
              case @kind
              when :select
                view.component(
                  FieldGroup.new(id: @id, label: @label, error: @error, hint: @hint) do |field|
                    FormBuilder.new(field).select(
                      @name,
                      id: @id,
                      selected: @selected,
                      options: @options,
                      class: @input_class
                    )
                  end
                )
              when :checkbox
                view.component(
                  Field.new(id: @id, error: @error, hint: @hint) do |field|
                    field.tag(:label, class: @checkbox_label_class, for: @id) do |label|
                      label.raw(
                        View.render do |nested|
                          FormBuilder.new(nested).checkbox(
                            @name,
                            value: @value,
                            checked: @checked,
                            id: @id,
                            class: @checkbox_class
                          )
                        end
                      )
                      label.text(" #{@label}")
                    end
                  end
                )
              else
                raise ArgumentError, "unsupported choice field kind: #{@kind}"
              end
            end
          end

          class SchemaHero < View::Component
            def initialize(title:, description: nil, eyebrow: "Schema Page",
                           wrapper_class:, eyebrow_class:, title_class:, body_class:)
              @title = title
              @description = description
              @eyebrow = eyebrow
              @wrapper_class = wrapper_class
              @eyebrow_class = eyebrow_class
              @title_class = title_class
              @body_class = body_class
            end

            def call(view)
              view.tag(:section, class: @wrapper_class) do |hero|
                hero.tag(:p, @eyebrow, class: @eyebrow_class)
                hero.tag(:h1, @title, class: @title_class)
                hero.tag(:p, @description, class: @body_class) if @description
              end
            end
          end

          class SchemaStack < View::Component
            DEFAULT_CLASS = "view-stack grid gap-5".freeze

            def initialize(class_name: DEFAULT_CLASS, &block)
              @class_name = class_name
              @block = block
            end

            def call(view)
              view.tag(:section, class: @class_name) do |container|
                @block&.call(container)
              end
            end
          end

          class SchemaGrid < View::Component
            DEFAULT_CLASS = "view-grid grid gap-5 sm:grid-cols-2".freeze

            def initialize(class_name: DEFAULT_CLASS, &block)
              @class_name = class_name
              @block = block
            end

            def call(view)
              view.tag(:section, class: @class_name) do |container|
                @block&.call(container)
              end
            end
          end

          class SchemaSection < View::Component
            DEFAULT_CLASS = "view-section rounded-[28px] border border-white/10 bg-[#2a1914]/90 p-6 shadow-2xl shadow-black/20 backdrop-blur".freeze

            def initialize(tag: :section, class_name: DEFAULT_CLASS, &block)
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

          class SchemaCard < View::Component
            DEFAULT_CLASS = "view-card rounded-[28px] border border-orange-200/15 bg-[linear-gradient(145deg,rgba(60,33,21,0.92),rgba(30,18,14,0.96))] p-6 shadow-2xl shadow-black/25".freeze

            def initialize(class_name: DEFAULT_CLASS, &block)
              @class_name = class_name
              @block = block
            end

            def call(view)
              view.tag(:article, class: @class_name) do |container|
                @block&.call(container)
              end
            end
          end

          class SchemaIntro < View::Component
            def initialize(text:, tone: nil, tag: :p, class_name:, muted_class:)
              @text = text
              @tone = tone
              @tag = tag
              @class_name = class_name
              @muted_class = muted_class
            end

            def call(view)
              view.tag(@tag, @text, class: @tone.to_s == "muted" ? @muted_class : @class_name)
            end
          end

          class SchemaFieldset < View::Component
            def initialize(legend: nil, description: nil, class_name:, legend_class:, description_class:, &block)
              @legend = legend
              @description = description
              @class_name = class_name
              @legend_class = legend_class
              @description_class = description_class
              @block = block
            end

            def call(view)
              view.tag(:fieldset, class: @class_name) do |fieldset|
                fieldset.tag(:legend, @legend, class: @legend_class) if @legend
                fieldset.tag(:p, @description, class: @description_class) if @description
                @block&.call(fieldset)
              end
            end
          end

          class SchemaForm < View::Component
            def initialize(action:, method: "post", hidden_action: nil, class_name:, fieldset:, &block)
              @action = action
              @method = method
              @hidden_action = hidden_action
              @class_name = class_name
              @fieldset = fieldset
              @block = block
            end

            def call(view)
              view.form(action: @action, method: @method, class: @class_name) do |form|
                form.hidden("_action", @hidden_action) if @hidden_action
                form.view.component(
                  SchemaFieldset.new(**@fieldset) do |fieldset|
                    @block&.call(form, fieldset)
                  end
                )
              end
            end
          end

          class MessagePage < View::Component
            DEFAULT_WRAPPER_CLASS = "relative overflow-hidden rounded-[34px] border border-orange-200/15 bg-[radial-gradient(circle_at_top_left,_rgba(194,107,61,0.24),_transparent_18rem),linear-gradient(145deg,rgba(60,33,21,0.96),rgba(22,15,13,0.98))] px-6 py-8 shadow-2xl shadow-black/25 sm:px-8 lg:px-10".freeze
            DEFAULT_GLOW_CLASS = "absolute inset-y-0 right-0 hidden w-72 bg-[radial-gradient(circle_at_center,_rgba(251,146,60,0.14),_transparent_65%)] lg:block".freeze
            DEFAULT_CONTENT_CLASS = "relative z-10 max-w-3xl".freeze
            DEFAULT_EYEBROW_CLASS = "text-[11px] font-semibold uppercase tracking-[0.34em] text-orange-200/75".freeze
            DEFAULT_TITLE_CLASS = "mt-3 font-display text-4xl leading-tight text-white sm:text-5xl".freeze
            DEFAULT_MESSAGE_CLASS = "mt-4 text-base leading-7 text-stone-300 sm:text-lg".freeze
            DEFAULT_DETAIL_WRAPPER_CLASS = "mt-4".freeze
            DEFAULT_DETAIL_CLASS = "rounded-xl bg-black/30 px-3 py-2 font-mono text-xs leading-6 text-orange-100".freeze
            DEFAULT_ACTION_BAR_CLASS = "mt-6 flex flex-wrap gap-3".freeze
            DEFAULT_ACTION_CLASS = Tokens.action(variant: :primary, theme: :orange).freeze

            def initialize(title:, eyebrow:, message:, back_label:, back_path:, detail: nil,
                           wrapper_class: DEFAULT_WRAPPER_CLASS, glow_class: DEFAULT_GLOW_CLASS,
                           content_class: DEFAULT_CONTENT_CLASS, eyebrow_class: DEFAULT_EYEBROW_CLASS,
                           title_class: DEFAULT_TITLE_CLASS, message_class: DEFAULT_MESSAGE_CLASS,
                           detail_wrapper_class: DEFAULT_DETAIL_WRAPPER_CLASS, detail_class: DEFAULT_DETAIL_CLASS,
                           action_bar_class: DEFAULT_ACTION_BAR_CLASS, action_class: DEFAULT_ACTION_CLASS)
              @title = title
              @eyebrow = eyebrow
              @message = message
              @back_label = back_label
              @back_path = back_path
              @detail = detail
              @wrapper_class = wrapper_class
              @glow_class = glow_class
              @content_class = content_class
              @eyebrow_class = eyebrow_class
              @title_class = title_class
              @message_class = message_class
              @detail_wrapper_class = detail_wrapper_class
              @detail_class = detail_class
              @action_bar_class = action_bar_class
              @action_class = action_class
            end

            def call(view)
              view.tag(:section, class: @wrapper_class) do |hero|
                hero.tag(:div, class: @glow_class) unless @glow_class.to_s.empty?
                hero.tag(:div, class: @content_class) do |content|
                  content.tag(:p, @eyebrow, class: @eyebrow_class)
                  content.tag(:h1, @title, class: @title_class)
                  content.tag(:p, @message, class: @message_class)
                  if @detail
                    content.tag(:p, class: @detail_wrapper_class) do |paragraph|
                      paragraph.tag(:code, @detail, class: @detail_class)
                    end
                  end
                  content.component(
                    ActionBar.new(class_name: @action_bar_class) do |actions|
                      actions.tag(:a, @back_label, href: @back_path, class: @action_class)
                    end
                  )
                end
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

          class PropertyCard < View::Component
            def initialize(title:, href: nil, body: nil, meta: nil, code: nil, action_label: nil, action_href: nil,
                           wrapper_class:, title_class:, body_class:, meta_class:, code_class:, link_class: nil,
                           action_class: nil)
              @title = title
              @href = href
              @body = body
              @meta = meta
              @code = code
              @action_label = action_label
              @action_href = action_href
              @wrapper_class = wrapper_class
              @title_class = title_class
              @body_class = body_class
              @meta_class = meta_class
              @code_class = code_class
              @link_class = link_class
              @action_class = action_class
            end

            def call(view)
              view.tag(:li, class: @wrapper_class) do |item|
                render_title(item)
                item.tag(:div, @body, class: "#{@body_class} mt-2") if @body
                item.tag(:div, @meta, class: "#{@meta_class} mt-2") if @meta
                item.tag(:code, @code, class: "#{@code_class} mt-2 block") if @code
                return unless @action_label && @action_href

                item.tag(:a, @action_label, href: @action_href, class: @action_class)
              end
            end

            private

            def render_title(view)
              if @href
                view.tag(:strong, class: @title_class) do |heading|
                  heading.tag(:a, @title, href: @href, class: @link_class)
                end
              else
                view.tag(:strong, @title, class: @title_class)
              end
            end
          end

          class ResourceList < View::Component
            def initialize(items:, theme:, empty_message: nil, compact: false)
              @items = items
              @theme = theme
              @empty_message = empty_message
              @compact = compact
            end

            def call(view)
              if @items.empty?
                view.tag(:p, @empty_message, class: @theme.empty_state_class) if @empty_message
                return
              end

              view.tag(:ul, class: list_class) do |list|
                @items.each do |item|
                  list.component(
                    PropertyCard.new(
                      title: item.fetch(:title),
                      body: item[:body],
                      meta: item[:meta],
                      code: item[:code],
                      wrapper_class: card_class,
                      title_class: @theme.item_title_class,
                      body_class: @theme.body_text_class,
                      meta_class: @theme.muted_text_class,
                      code_class: @theme.code_class
                    )
                  )
                end
              end
            end

            private

            def list_class
              @compact ? @theme.compact_list_class : @theme.list_class
            end

            def card_class
              @compact ? @theme.compact_card_class : @theme.list_item_class
            end
          end

          class EndpointList < View::Component
            def initialize(items:, theme:, empty_message: nil, compact: false, link_class:)
              @items = items
              @theme = theme
              @empty_message = empty_message
              @compact = compact
              @link_class = link_class
            end

            def call(view)
              if @items.empty?
                view.tag(:p, @empty_message, class: @theme.empty_state_class) if @empty_message
                return
              end

              view.tag(:ul, class: list_class) do |list|
                @items.each do |item|
                  list.component(
                    PropertyCard.new(
                      title: item.fetch(:title),
                      body: item[:body],
                      meta: item[:meta],
                      href: item[:href],
                      wrapper_class: card_class,
                      title_class: @theme.item_title_class,
                      body_class: @theme.body_text_class,
                      meta_class: @theme.muted_text_class,
                      code_class: @theme.code_class,
                      link_class: @link_class
                    )
                  )
                end
              end
            end

            private

            def list_class
              @compact ? @theme.compact_list_class : @theme.list_class
            end

            def card_class
              @compact ? @theme.compact_card_class : @theme.list_item_class
            end
          end

          class TimelineList < View::Component
            def initialize(items:, theme:, empty_message: nil, title_link_class:, action_link_class:)
              @items = items
              @theme = theme
              @empty_message = empty_message
              @title_link_class = title_link_class
              @action_link_class = action_link_class
            end

            def call(view)
              if @items.empty?
                view.tag(:p, @empty_message, class: @theme.empty_state_class) if @empty_message
                return
              end

              view.tag(:ul, class: @theme.list_class) do |list|
                @items.each do |item|
                  list.component(
                    PropertyCard.new(
                      title: item.fetch(:title),
                      href: item.fetch(:href),
                      body: item[:body],
                      meta: item[:meta],
                      action_label: item[:action_label],
                      action_href: item[:action_href],
                      wrapper_class: @theme.list_item_class,
                      title_class: @theme.item_title_class,
                      body_class: @theme.muted_text_class,
                      meta_class: @theme.muted_text_class,
                      code_class: @theme.code_class,
                      link_class: @title_link_class,
                      action_class: @action_link_class
                    )
                  )
                end
              end
            end
          end

          class PayloadDiff < View::Component
            def initialize(raw_payload:, normalized_payload:, theme:, empty_message: nil)
              @raw_payload = raw_payload
              @normalized_payload = normalized_payload
              @theme = theme
              @empty_message = empty_message || "No payload differences detected."
            end

            def call(view)
              entries = diff_entries

              if entries.empty?
                view.tag(:p, @empty_message, class: @theme.empty_state_class)
                return
              end

              view.tag(:ul, class: @theme.list_class) do |list|
                entries.each do |entry|
                  list.tag(:li, class: @theme.list_item_class) do |item|
                    item.tag(:strong, entry.fetch(:path), class: @theme.item_title_class)
                    item.tag(:div, diff_summary(entry), class: @theme.body_text_class(extra: "mt-2"))
                    item.tag(:div, class: "mt-3 grid gap-3 lg:grid-cols-2") do |grid|
                      grid.tag(:div) do |column|
                        column.tag(:div, "raw", class: @theme.muted_text_class)
                        column.tag(:code, entry.fetch(:raw_label), class: "#{@theme.code_class} mt-2 block")
                      end
                      grid.tag(:div) do |column|
                        column.tag(:div, "normalized", class: @theme.muted_text_class)
                        column.tag(:code, entry.fetch(:normalized_label), class: "#{@theme.code_class} mt-2 block")
                      end
                    end
                  end
                end
              end
            end

            private

            def diff_entries
              raw_index = flatten_payload(@raw_payload)
              normalized_index = flatten_payload(@normalized_payload)
              paths = (raw_index.keys + normalized_index.keys).uniq.sort

              paths.filter_map do |path|
                raw_value = raw_index[path]
                normalized_value = normalized_index[path]
                status = diff_status(raw_value, normalized_value)
                next if status == :unchanged

                {
                  path: path,
                  status: status,
                  raw_label: value_label(raw_value),
                  normalized_label: value_label(normalized_value)
                }
              end
            end

            def flatten_payload(payload, prefix = nil, result = {})
              case payload
              when Hash
                payload.each do |key, value|
                  next if key.to_s == "_action"

                  path = [prefix, key.to_s].compact.join(".")
                  flatten_payload(value, path, result)
                end
              when Array
                payload.each_with_index do |value, index|
                  path = [prefix, index].compact.join(".")
                  flatten_payload(value, path, result)
                end
              else
                result[prefix.to_s] = payload
              end

              result
            end

            def diff_status(raw_value, normalized_value)
              return :added if raw_value.nil? && !normalized_value.nil?
              return :removed if !raw_value.nil? && normalized_value.nil?
              return :unchanged if raw_value == normalized_value && raw_value.class == normalized_value.class
              return :type_changed if raw_value.to_s == normalized_value.to_s && raw_value.class != normalized_value.class

              :changed
            end

            def diff_summary(entry)
              case entry.fetch(:status)
              when :type_changed
                "Type changed during normalization."
              when :added
                "Field was added by normalization."
              when :removed
                "Field was removed during normalization."
              else
                "Field value changed during normalization."
              end
            end

            def value_label(value)
              return "(missing)" if value.nil?

              JSON.generate(value)
            end
          end

          class BarChart < View::Component
            def initialize(items:, theme:, chart_id:, empty_message: nil, value_suffix: "", max_value: nil)
              @items = items
              @theme = theme
              @chart_id = chart_id
              @empty_message = empty_message || "No chart data yet."
              @value_suffix = value_suffix
              @max_value = max_value
            end

            def call(view)
              if @items.empty?
                view.tag(:p, @empty_message, class: @theme.empty_state_class)
                return
              end

              view.tag(:ul, class: "grid gap-3", "data-chart-id": @chart_id) do |list|
                @items.each do |item|
                  render_item(list, item)
                end
              end
            end

            private

            def render_item(view, item)
              key = item.fetch(:key, item.fetch(:label).to_s.downcase.gsub(/[^a-z0-9]+/, "_"))
              value = item.fetch(:value).to_f
              max = @max_value || @items.map { |entry| entry.fetch(:value).to_f }.max || 0
              percent = max <= 0 ? 0 : ((value / max) * 100.0).round(1)

              view.tag(:li, class: "rounded-2xl border border-white/10 bg-white/5 p-4", "data-chart-key": key) do |row|
                row.tag(:div, class: "flex items-center justify-between gap-4") do |meta|
                  meta.tag(:strong, item.fetch(:label), class: @theme.item_title_class)
                  meta.tag(:span, value_label(item.fetch(:value)), class: @theme.muted_text_class, "data-chart-value": key)
                end
                row.tag(:div, class: "mt-3 h-2.5 overflow-hidden rounded-full bg-white/10") do |bar|
                  bar.tag(:div,
                          "",
                          class: "h-full rounded-full bg-gradient-to-r from-amber-300 via-orange-300 to-cyan-300 transition-all",
                          style: "width: #{percent}%",
                          "data-chart-fill": key)
                end
                row.tag(:p, item.fetch(:hint), class: @theme.muted_text_class(extra: "mt-2")) if item[:hint]
              end
            end

            def value_label(value)
              "#{value}#{@value_suffix}"
            end
          end

          class MermaidDiagram < View::Component
            def initialize(diagram:, title: nil, description: nil, wrapper_class: "grid gap-3")
              @diagram = diagram
              @title = title
              @description = description
              @wrapper_class = wrapper_class
            end

            def call(view)
              view.tag(:div, class: @wrapper_class) do |container|
                container.tag(:div, @title, class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300") if @title
                container.tag(:p, @description, class: "text-sm leading-6 text-stone-400") if @description
                container.tag(:pre,
                              @diagram,
                              class: "mermaid overflow-x-auto whitespace-pre rounded-3xl border border-white/10 bg-black/20 p-4 font-mono text-xs leading-6 text-stone-200")
              end
            end
          end

          class LiveBadge < View::Component
            def initialize(label:, value:, interval_seconds:)
              @label = label
              @value = value
              @interval_seconds = interval_seconds
            end

            def call(view)
              view.tag(:div,
                       class: "inline-flex flex-wrap items-center gap-3 rounded-full border border-cyan-300/20 bg-cyan-300/10 px-4 py-2 text-sm text-cyan-100",
                       "data-live-badge": "true") do |badge|
                badge.tag(:span, @label, class: "text-[11px] font-semibold uppercase tracking-[0.24em] text-cyan-100/80")
                badge.tag(:strong, @value, class: "font-mono text-sm text-white", "data-live-generated-at": "true")
                badge.tag(:span, "poll #{@interval_seconds}s", class: "text-xs text-stone-400")
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

          class Theme
            PRESETS = {
              default: {
                panel: {},
                form_section: {},
                message_page: {},
                heroes: {},
                surfaces: {
                  field_label_class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300",
                  input_class: "w-full rounded-2xl border border-white/10 bg-stone-950 px-4 py-3 text-sm text-white placeholder:text-stone-500 focus:border-orange-300/50 focus:outline-none",
                  checkbox_label_class: "flex items-center gap-3 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-stone-200",
                  checkbox_class: "h-4 w-4 rounded border-white/20 bg-stone-950 text-orange-300",
                  code_class: "rounded-xl bg-black/30 px-3 py-2 font-mono text-xs leading-6 text-orange-100",
                  empty_state_class: "text-sm leading-6 text-stone-400",
                  muted_text_class: "text-sm leading-6 text-stone-400",
                  body_text_class: "text-sm leading-6 text-stone-300",
                  item_title_class: "font-semibold text-white",
                  list_class: "space-y-4",
                  compact_list_class: "mt-3 space-y-3",
                  list_item_class: "rounded-3xl border border-white/10 bg-white/5 p-4",
                  compact_card_class: "rounded-2xl border border-white/10 bg-white/5 p-4",
                  compact_item_class: "text-sm leading-6 text-stone-300",
                  section_heading_class: "mt-5 text-sm font-semibold uppercase tracking-[0.22em] text-stone-300",
                  schema_intro_class: "text-base leading-7 text-stone-200",
                  schema_intro_muted_class: "view-muted text-sm leading-6 text-stone-400",
                  schema_form_class: "view-form grid gap-3",
                  schema_fieldset_class: "grid gap-3",
                  schema_fieldset_legend_class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300",
                  schema_fieldset_description_class: "text-sm leading-6 text-stone-400",
                  schema_stack_class: SchemaStack::DEFAULT_CLASS,
                  schema_grid_class: SchemaGrid::DEFAULT_CLASS,
                  schema_section_class: SchemaSection::DEFAULT_CLASS,
                  schema_card_class: SchemaCard::DEFAULT_CLASS
                }
              },
              companion: {
                panel: {
                  wrapper_class: "rounded-[28px] border border-white/10 bg-[#2a1914]/90 p-6 shadow-2xl shadow-black/20 backdrop-blur",
                  subtitle_class: "text-sm leading-6 text-stone-400"
                },
                form_section: {
                  wrapper_class: "rounded-[28px] border border-white/10 bg-[#2a1914]/90 p-6 shadow-2xl shadow-black/20 backdrop-blur"
                },
                message_page: {
                  wrapper_class: "relative overflow-hidden rounded-[34px] border border-orange-200/15 bg-[radial-gradient(circle_at_top_left,_rgba(194,107,61,0.24),_transparent_18rem),linear-gradient(145deg,rgba(60,33,21,0.96),rgba(22,15,13,0.98))] px-6 py-8 shadow-2xl shadow-black/25 sm:px-8 lg:px-10",
                  glow_class: "absolute inset-y-0 right-0 hidden w-72 bg-[radial-gradient(circle_at_center,_rgba(251,146,60,0.14),_transparent_65%)] lg:block",
                  content_class: "relative z-10 max-w-3xl",
                  eyebrow_class: "text-[11px] font-semibold uppercase tracking-[0.34em] text-orange-200/75",
                  title_class: "mt-3 font-display text-4xl leading-tight text-white sm:text-5xl",
                  message_class: "mt-4 text-base leading-7 text-stone-300 sm:text-lg",
                  detail_class: "rounded-xl bg-black/30 px-3 py-2 font-mono text-xs leading-6 text-orange-100",
                  action_class: Tokens.action(variant: :primary, theme: :orange)
                },
                heroes: {
                  dashboard: {
                    wrapper_class: "relative overflow-hidden rounded-[34px] border border-orange-200/15 bg-[radial-gradient(circle_at_top_left,_rgba(194,107,61,0.24),_transparent_18rem),linear-gradient(145deg,rgba(60,33,21,0.96),rgba(22,15,13,0.98))] px-6 py-8 shadow-2xl shadow-black/25 sm:px-8 lg:px-10",
                    glow_class: "absolute inset-y-0 right-0 hidden w-72 bg-[radial-gradient(circle_at_center,_rgba(251,146,60,0.14),_transparent_65%)] lg:block",
                    content_class: "relative z-10 max-w-4xl",
                    eyebrow_class: "text-[11px] font-semibold uppercase tracking-[0.34em] text-orange-200/75",
                    title_class: "mt-3 font-display text-4xl leading-tight text-white sm:text-5xl",
                    body_class: "mt-4 max-w-3xl text-base leading-7 text-stone-300 sm:text-lg",
                    meta_class: "mt-5 flex flex-wrap gap-x-4 gap-y-2 font-mono text-xs text-stone-400"
                  }
                },
                surfaces: {
                  footer_bar_class: "rounded-3xl border border-white/10 bg-white/5 px-5 py-4 font-mono text-xs text-stone-300",
                  field_label_class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300",
                  input_class: "w-full rounded-2xl border border-white/10 bg-[#160f0d] px-4 py-3 text-sm text-white placeholder:text-stone-500 focus:border-orange-300/50 focus:outline-none",
                  checkbox_label_class: "flex items-center gap-3 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-stone-200",
                  checkbox_class: "h-4 w-4 rounded border-white/20 bg-stone-950 text-orange-300",
                  code_class: "rounded-xl bg-black/30 px-3 py-2 font-mono text-xs leading-6 text-orange-100",
                  empty_state_class: "text-sm leading-6 text-stone-400",
                  muted_text_class: "text-sm leading-6 text-stone-400",
                  body_text_class: "text-sm leading-6 text-stone-300",
                  item_title_class: "font-semibold text-white",
                  list_class: "space-y-4",
                  compact_list_class: "mt-3 space-y-3",
                  list_item_class: "rounded-3xl border border-white/10 bg-white/5 p-4",
                  compact_card_class: "rounded-2xl border border-white/10 bg-white/5 p-4",
                  compact_item_class: "text-sm leading-6 text-stone-300",
                  section_heading_class: "mt-5 text-sm font-semibold uppercase tracking-[0.22em] text-stone-300",
                  schema_intro_class: "text-base leading-7 text-stone-200",
                  schema_intro_muted_class: "view-muted text-sm leading-6 text-stone-400",
                  schema_form_class: "view-form grid gap-3",
                  schema_fieldset_class: "grid gap-3",
                  schema_fieldset_legend_class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300",
                  schema_fieldset_description_class: "text-sm leading-6 text-stone-400",
                  schema_stack_class: SchemaStack::DEFAULT_CLASS,
                  schema_grid_class: SchemaGrid::DEFAULT_CLASS,
                  schema_section_class: SchemaSection::DEFAULT_CLASS,
                  schema_card_class: SchemaCard::DEFAULT_CLASS
                }
              },
              ops: {
                panel: {},
                form_section: {},
                message_page: {},
                heroes: {
                  dashboard: {
                    wrapper_class: "hero relative overflow-hidden rounded-[36px] border border-amber-200/15 bg-[radial-gradient(circle_at_top_left,_rgba(245,158,11,0.22),_transparent_24rem),linear-gradient(145deg,rgba(41,37,36,0.96),rgba(12,10,9,0.98))] px-6 py-8 shadow-glow sm:px-8 lg:px-10",
                    glow_class: "absolute inset-y-0 right-0 hidden w-72 bg-[radial-gradient(circle_at_center,_rgba(251,191,36,0.16),_transparent_65%)] lg:block",
                    content_class: "relative z-10 max-w-4xl",
                    eyebrow_class: "eyebrow text-[11px] font-semibold uppercase tracking-[0.34em] text-amber-200/75",
                    title_class: "mt-3 font-display text-4xl leading-tight text-white sm:text-5xl",
                    body_class: "mt-4 max-w-3xl text-base leading-7 text-stone-300 sm:text-lg",
                    meta_class: "meta mt-5 flex flex-wrap gap-x-4 gap-y-2 text-sm text-stone-400",
                    action_bar_class: "hero-links mt-6 flex flex-wrap gap-3"
                  },
                  detail: {
                    wrapper_class: "hero rounded-[34px] border border-white/10 bg-[radial-gradient(circle_at_top_left,_rgba(45,212,191,0.16),_transparent_18rem),linear-gradient(145deg,rgba(28,25,23,0.96),rgba(12,10,9,0.98))] px-6 py-8 shadow-2xl shadow-black/20 sm:px-8",
                    eyebrow_class: "eyebrow text-[11px] font-semibold uppercase tracking-[0.34em] text-cyan-200/75",
                    title_class: "mt-3 font-display text-4xl leading-tight text-white sm:text-5xl",
                    body_class: "mt-4 max-w-3xl text-base leading-7 text-stone-300",
                    action_bar_class: "mt-6"
                  }
                },
                surfaces: {
                  field_label_class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300",
                  input_class: "w-full rounded-2xl border border-white/10 bg-stone-950/90 px-4 py-3 text-sm text-white placeholder:text-stone-500 focus:border-amber-300/50 focus:outline-none",
                  checkbox_label_class: "flex items-center gap-3 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-stone-200",
                  checkbox_class: "h-4 w-4 rounded border-white/20 bg-stone-950 text-amber-300",
                  code_class: "rounded-xl bg-black/30 px-3 py-2 font-mono text-xs leading-6 text-amber-100",
                  empty_state_class: "text-sm leading-6 text-stone-400",
                  muted_text_class: "text-sm leading-6 text-stone-400",
                  body_text_class: "text-sm leading-6 text-stone-300",
                  item_title_class: "font-semibold text-white",
                  list_class: "item-list space-y-4",
                  compact_list_class: "item-list compact mt-3 space-y-3",
                  list_item_class: "rounded-3xl border border-white/10 bg-white/5 p-4",
                  compact_card_class: "rounded-2xl border border-white/10 bg-white/5 p-4",
                  compact_item_class: "text-sm leading-6 text-stone-300",
                  section_heading_class: "mt-5 text-sm font-semibold uppercase tracking-[0.22em] text-stone-300",
                  schema_intro_class: "text-base leading-7 text-stone-200",
                  schema_intro_muted_class: "view-muted text-sm leading-6 text-stone-400",
                  schema_form_class: "view-form grid gap-3",
                  schema_fieldset_class: "grid gap-3",
                  schema_fieldset_legend_class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300",
                  schema_fieldset_description_class: "text-sm leading-6 text-stone-400",
                  schema_stack_class: SchemaStack::DEFAULT_CLASS,
                  schema_grid_class: SchemaGrid::DEFAULT_CLASS,
                  schema_section_class: SchemaSection::DEFAULT_CLASS,
                  schema_card_class: SchemaCard::DEFAULT_CLASS
                }
              },
              schema: {
                panel: {
                  wrapper_class: "rounded-[28px] border border-white/10 bg-[#2a1914]/90 p-6 shadow-2xl shadow-black/20 backdrop-blur",
                  subtitle_class: "text-sm leading-6 text-stone-400"
                },
                form_section: {},
                message_page: {},
                heroes: {
                  page: {
                    wrapper_class: "overflow-hidden rounded-[34px] border border-orange-200/15 bg-[radial-gradient(circle_at_top_left,_rgba(194,107,61,0.22),_transparent_18rem),linear-gradient(145deg,rgba(60,33,21,0.96),rgba(22,15,13,0.98))] px-6 py-8 shadow-2xl shadow-black/25 sm:px-8",
                    eyebrow_class: "text-[11px] font-semibold uppercase tracking-[0.34em] text-orange-200/75",
                    title_class: "mt-3 font-display text-4xl leading-tight text-white sm:text-5xl",
                    body_class: "mt-4 max-w-3xl text-base leading-7 text-stone-300"
                  }
                },
                surfaces: {
                  field_label_class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300",
                  input_class: "w-full rounded-2xl border border-white/10 bg-[#160f0d] px-4 py-3 text-sm text-white placeholder:text-stone-500 focus:border-orange-300/50 focus:outline-none",
                  checkbox_label_class: "flex items-center gap-3 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-stone-200",
                  checkbox_class: "h-4 w-4 rounded border-white/20 bg-stone-950 text-orange-300",
                  code_class: "rounded-xl bg-black/30 px-3 py-2 font-mono text-xs leading-6 text-orange-100",
                  empty_state_class: "text-sm leading-6 text-stone-400",
                  muted_text_class: "text-sm leading-6 text-stone-400",
                  body_text_class: "text-sm leading-6 text-stone-300",
                  item_title_class: "font-semibold text-white",
                  list_class: "space-y-4",
                  compact_list_class: "mt-3 space-y-3",
                  list_item_class: "rounded-3xl border border-white/10 bg-white/5 p-4",
                  compact_card_class: "rounded-2xl border border-white/10 bg-white/5 p-4",
                  compact_item_class: "text-sm leading-6 text-stone-300",
                  section_heading_class: "mt-5 text-sm font-semibold uppercase tracking-[0.22em] text-stone-300",
                  schema_intro_class: "text-base leading-7 text-stone-200",
                  schema_intro_muted_class: "view-muted text-sm leading-6 text-stone-400",
                  schema_form_class: "view-form grid gap-3",
                  schema_fieldset_class: "grid gap-3",
                  schema_fieldset_legend_class: "text-sm font-semibold uppercase tracking-[0.18em] text-stone-300",
                  schema_fieldset_description_class: "text-sm leading-6 text-stone-400",
                  schema_stack_class: SchemaStack::DEFAULT_CLASS,
                  schema_grid_class: SchemaGrid::DEFAULT_CLASS,
                  schema_section_class: SchemaSection::DEFAULT_CLASS,
                  schema_card_class: SchemaCard::DEFAULT_CLASS
                }
              }
            }.freeze

            def self.fetch(name)
              new(PRESETS.fetch(name.to_sym))
            end

            def self.deep_merge(base, override)
              return override unless base.is_a?(Hash) && override.is_a?(Hash)

              base.merge(override) do |_key, left, right|
                left.is_a?(Hash) && right.is_a?(Hash) ? deep_merge(left, right) : right
              end
            end

            def initialize(definition)
              @definition = definition
            end

            def panel(title:, subtitle: nil, tag: :section, **overrides, &block)
              Panel.new(title: title, subtitle: subtitle, tag: tag, **component_options(:panel, overrides), &block)
            end

            def resource_list(items:, empty_message: nil, compact: false)
              ResourceList.new(items: items, theme: self, empty_message: empty_message, compact: compact)
            end

            def bar_chart(items:, chart_id:, empty_message: nil, value_suffix: "", max_value: nil)
              BarChart.new(
                items: items,
                chart_id: chart_id,
                theme: self,
                empty_message: empty_message,
                value_suffix: value_suffix,
                max_value: max_value
              )
            end

            def mermaid_diagram(diagram:, title: nil, description: nil)
              MermaidDiagram.new(diagram: diagram, title: title, description: description)
            end

            def live_badge(label:, value:, interval_seconds:)
              LiveBadge.new(label: label, value: value, interval_seconds: interval_seconds)
            end

            def schema_hero(title:, description: nil, eyebrow: "Schema Page", **overrides)
              hero_options = self.class.deep_merge(hero(:page), overrides)
              SchemaHero.new(title: title, description: description, eyebrow: eyebrow, **hero_options)
            end

            def schema_intro(text:, tone: nil, tag: :p)
              SchemaIntro.new(
                text: text,
                tone: tone,
                tag: tag,
                class_name: surface(:schema_intro_class),
                muted_class: surface(:schema_intro_muted_class)
              )
            end

            def schema_form(action:, method: "post", hidden_action: nil, legend: nil, description: nil, &block)
              SchemaForm.new(
                action: action,
                method: method,
                hidden_action: hidden_action,
                class_name: surface(:schema_form_class),
                fieldset: {
                  legend: legend,
                  description: description,
                  class_name: surface(:schema_fieldset_class),
                  legend_class: surface(:schema_fieldset_legend_class),
                  description_class: surface(:schema_fieldset_description_class)
                },
                &block
              )
            end

            def schema_stack(class_name: nil, &block)
              SchemaStack.new(class_name: class_name || surface(:schema_stack_class), &block)
            end

            def schema_grid(class_name: nil, &block)
              SchemaGrid.new(class_name: class_name || surface(:schema_grid_class), &block)
            end

            def schema_section(tag: :section, class_name: nil, &block)
              SchemaSection.new(tag: tag, class_name: class_name || surface(:schema_section_class), &block)
            end

            def schema_card(class_name: nil, &block)
              SchemaCard.new(class_name: class_name || surface(:schema_card_class), &block)
            end

            def schema_fieldset(legend: nil, description: nil, class_name: nil, &block)
              SchemaFieldset.new(
                legend: legend,
                description: description,
                class_name: class_name || surface(:schema_fieldset_class),
                legend_class: surface(:schema_fieldset_legend_class),
                description_class: surface(:schema_fieldset_description_class),
                &block
              )
            end

            def endpoint_list(items:, empty_message: nil, compact: false, link_class:)
              EndpointList.new(
                items: items,
                theme: self,
                empty_message: empty_message,
                compact: compact,
                link_class: link_class
              )
            end

            def timeline_list(items:, empty_message: nil, title_link_class:, action_link_class:)
              TimelineList.new(
                items: items,
                theme: self,
                empty_message: empty_message,
                title_link_class: title_link_class,
                action_link_class: action_link_class
              )
            end

            def payload_diff(raw_payload:, normalized_payload:, empty_message: nil)
              PayloadDiff.new(
                raw_payload: raw_payload,
                normalized_payload: normalized_payload,
                theme: self,
                empty_message: empty_message
              )
            end

            def form_section(title:, action:, subtitle: nil, method: "post", tag: :section, **overrides, &block)
              FormSection.new(
                title: title,
                action: action,
                subtitle: subtitle,
                method: method,
                tag: tag,
                **component_options(:form_section, overrides),
                &block
              )
            end

            def message_page_options(**overrides)
              component_options(:message_page, overrides)
            end

            def hero(name, **overrides)
              preset = @definition.fetch(:heroes, {}).fetch(name.to_sym)
              self.class.deep_merge(preset, overrides)
            end

            def surface(name)
              @definition.fetch(:surfaces, {}).fetch(name.to_sym)
            end

            def field_label_class(extra: nil)
              merge_classes(surface(:field_label_class), extra)
            end

            def input_class(extra: nil)
              merge_classes(surface(:input_class), extra)
            end

            def checkbox_label_class(extra: nil)
              merge_classes(surface(:checkbox_label_class), extra)
            end

            def checkbox_class(extra: nil)
              merge_classes(surface(:checkbox_class), extra)
            end

            def code_class(extra: nil)
              merge_classes(surface(:code_class), extra)
            end

            def empty_state_class(extra: nil)
              merge_classes(surface(:empty_state_class), extra)
            end

            def muted_text_class(extra: nil)
              merge_classes(surface(:muted_text_class), extra)
            end

            def body_text_class(extra: nil)
              merge_classes(surface(:body_text_class), extra)
            end

            def item_title_class(extra: nil)
              merge_classes(surface(:item_title_class), extra)
            end

            def list_class(extra: nil)
              merge_classes(surface(:list_class), extra)
            end

            def compact_list_class(extra: nil)
              merge_classes(surface(:compact_list_class), extra)
            end

            def list_item_class(extra: nil)
              merge_classes(surface(:list_item_class), extra)
            end

            def compact_card_class(extra: nil)
              merge_classes(surface(:compact_card_class), extra)
            end

            def compact_item_class(extra: nil)
              merge_classes(surface(:compact_item_class), extra)
            end

            def section_heading_class(extra: nil)
              merge_classes(surface(:section_heading_class), extra)
            end

            private

            def component_options(name, overrides)
              self.class.deep_merge(@definition.fetch(name, {}), overrides)
            end

            def merge_classes(base, extra)
              [base, extra].compact.join(" ")
            end
          end
        end
      end
    end
  end
end
