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
            @theme_name = theme
            @theme = ui_theme(theme)
            wrapper_class = merge_classes(@theme.surface(:schema_card_class), class_name)

            super(options.merge(class: wrapper_class))
            render_header(title, subtitle)
            @lines = dl(class: DEFAULT_LINE_LIST_CLASS)
            render_build_block(block)
          end

          def line(label, value = nil, as_code: false, as: nil, placeholder: nil,
                   label_class: nil, value_class: nil, badge: nil, &block)
            value = block.call if block_given?
            rendered_label = humanize_label(label)
            field_label_class = @theme.field_label_class
            body_text_class = @theme.body_text_class
            content = normalize_value(value, placeholder: placeholder)

            @lines.dt(rendered_label, class: merge_classes(field_label_class, label_class))
            @lines.dd(class: merge_classes(body_text_class, value_class)) do
              render_value(content, as: (as_code ? :code : as), badge_options: badge)
            end
          end

          def subcard(*args, &block)
            options = extract_options!(args)
            title = args.shift || options.delete(:title)
            subtitle = options.delete(:subtitle)
            class_name = options.delete(:class_name)

            card(title: title, subtitle: subtitle, theme: @theme_name, class_name: class_name, **options, &block)
          end

          private

          def normalize_value(value, placeholder:)
            if value.nil? || (value.respond_to?(:empty?) && value.empty?)
              return placeholder unless placeholder.nil?
            end

            value
          end

          def render_value(value, as:, badge_options:)
            case value
            when Array
              render_array(value, as: as, badge_options: badge_options)
            else
              render_scalar(value, as: as, badge_options: badge_options)
            end
          end

          def render_array(values, as:, badge_options:)
            compact_values = values.compact
            return if compact_values.empty?

            if as == :badge
              div(class: "flex flex-wrap gap-2") do |container|
                compact_values.each do |entry|
                  container.badge(entry, **(badge_options || {}))
                end
              end
            else
              text_node(compact_values.map(&:to_s).join(", "))
            end
          end

          def render_scalar(value, as:, badge_options:)
            return if value.nil?

            case as
            when :badge
              badge(value, **(badge_options || {}))
            when :code
              code(value.to_s, class: @theme.code_class)
            else
              display = value.is_a?(Symbol) ? humanize_label(value) : value.to_s
              text_node(display)
            end
          end

          def render_header(title, subtitle)
            return if title.nil? && subtitle.nil?

            title_class = @theme.section_heading_class(extra: "mt-0")
            subtitle_class = @theme.muted_text_class

            div(class: "mb-5 grid gap-2") do
              h2(title, class: title_class) if title
              div(subtitle, class: subtitle_class) if subtitle
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
