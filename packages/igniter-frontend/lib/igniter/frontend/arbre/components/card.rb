# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class Card < Arbre::Component
          builder_method :card

          DEFAULT_LINE_LIST_CLASS = "mt-4 grid grid-cols-1 gap-x-6 gap-y-4 sm:grid-cols-[minmax(140px,190px)_1fr]".freeze

          def build(*args, &block)
            options = extract_options!(args)
            title = options.delete(:title)
            subtitle = options.delete(:subtitle)
            theme = options.delete(:theme) || :companion
            class_name = options.delete(:class_name)
            @theme = ui_theme(theme)
            wrapper_class = merge_classes(@theme.surface(:schema_card_class), class_name)

            super(options.merge(class: wrapper_class))
            render_header(title, subtitle)
            @lines = dl(class: DEFAULT_LINE_LIST_CLASS)
            render_build_block(block)
          end

          def line(label, value = nil, as_code: false)
            rendered_label = humanize_label(label)
            field_label_class = @theme.field_label_class
            body_text_class = @theme.body_text_class
            code_class = @theme.code_class

            @lines.dt(rendered_label, class: field_label_class)
            @lines.dd(class: body_text_class) do
              if as_code
                code(value.to_s, class: code_class)
              else
                text_node(value.to_s)
              end
            end
          end

          private

          def render_header(title, subtitle)
            return if title.nil? && subtitle.nil?

            title_class = @theme.section_heading_class(extra: "mt-0")
            subtitle_class = @theme.muted_text_class

            div(class: "mb-5 grid gap-2") do
              h2(title, class: title_class) if title
              tag(:p, subtitle, class: subtitle_class) if subtitle
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
