# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Plugins
    module View
      module Arbre
        module Components
          class Card < Arbre::Component
            builder_method :card

            DEFAULT_LINE_LIST_CLASS = "mt-4 grid grid-cols-1 gap-x-6 gap-y-4 sm:grid-cols-[minmax(140px,190px)_1fr]".freeze

            def build(title: nil, subtitle: nil, theme: :companion, class_name: nil, **attributes, &block)
              @theme = ui_theme(theme)
              wrapper_class = merge_classes(@theme.surface(:schema_card_class), class_name)

              super(attributes.merge(class: wrapper_class))
              render_header(title, subtitle)
              @lines = dl(class: DEFAULT_LINE_LIST_CLASS)
              instance_exec(&block) if block
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
end
