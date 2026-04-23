# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class Viz < Arbre::Component
          builder_method :viz

          DEFAULT_MAX_ITEMS = 20

          def build(value, *args)
            options = extract_options!(args)
            title = options.delete(:title)
            name = options.delete(:name)
            open = options.key?(:open) ? options.delete(:open) : true
            compact = options.delete(:compact)
            max_items = options.delete(:max_items) || DEFAULT_MAX_ITEMS
            class_name = options.delete(:class_name)

            @theme = ui_theme(:companion)
            @compact = compact
            @max_items = max_items

            super(options.merge(class: merge_classes("viz-panel grid gap-3", class_name)))
            render_header(title)
            render_value(self, normalize(value), label: name, open: open, depth: 0, root: true)
          end

          private

          def render_header(title)
            return unless title

            h3(title, class: @theme.section_heading_class(extra: "mt-0"))
          end

          def render_value(view, value, label:, open:, depth:, root: false)
            case value
            when Hash
              render_hash(view, value, label: label, open: open, depth: depth, root: root)
            when Array
              render_array(view, value, label: label, open: open, depth: depth, root: root)
            else
              render_leaf(view, value, label: label)
            end
          end

          def render_hash(view, hash, label:, open:, depth:, root:)
            entries = hash.to_a.first(@max_items)

            if root
              container = view.div(class: block_class(depth))
              entries.each do |key, value|
                render_value(container, normalize(value), label: key.to_s, open: false, depth: depth + 1)
              end
              render_omitted_notice(container, hash.size - entries.size)
              return
            end

            view.details(open: open ? true : nil, class: block_class(depth)) do |details|
              details.summary(class: summary_class) do |summary|
                summary.strong(label.to_s, class: "font-semibold text-stone-100") if label
                summary.span("Hash · #{hash.size} entr#{hash.size == 1 ? "y" : "ies"}", class: "caption")
              end

              details.div(class: merge_classes("mt-3 grid gap-3", nested_class(depth))) do |body|
                if entries.empty?
                  body.div("Empty Hash", class: empty_class)
                else
                  entries.each do |key, value|
                    render_value(body, normalize(value), label: key.to_s, open: false, depth: depth + 1)
                  end
                  render_omitted_notice(body, hash.size - entries.size)
                end
              end
            end
          end

          def render_array(view, array, label:, open:, depth:, root: false)
            items = array.first(@max_items)

            if root
              container = view.div(class: block_class(depth))
              items.each_with_index do |item, index|
                render_value(container, normalize(item), label: "[#{index}]", open: false, depth: depth + 1)
              end
              render_omitted_notice(container, array.size - items.size)
              return
            end

            view.details(open: open ? true : nil, class: block_class(depth)) do |details|
              details.summary(class: summary_class) do |summary|
                summary.strong(label.to_s, class: "font-semibold text-stone-100") if label
                summary.span("Array · #{array.size} item#{array.size == 1 ? "" : "s"}", class: "caption")
              end

              details.div(class: merge_classes("mt-3 grid gap-3", nested_class(depth))) do |body|
                if items.empty?
                  body.div("Empty Array", class: empty_class)
                else
                  items.each_with_index do |item, index|
                    render_value(body, normalize(item), label: "[#{index}]", open: false, depth: depth + 1)
                  end
                  render_omitted_notice(body, array.size - items.size)
                end
              end
            end
          end

          def render_leaf(view, value, label:)
            view.div(class: row_class) do |row|
              row.div(label.to_s, class: @theme.field_label_class) if label

              case value
              when true, false
                row.badge(value, size: :sm)
              when nil
                row.div("nil", class: empty_class)
              else
                row.code(display_text(value), class: @theme.code_class)
              end
            end
          end

          def render_omitted_notice(view, omitted_count)
            return unless omitted_count.positive?

            view.div("… #{omitted_count} more item#{omitted_count == 1 ? "" : "s"}", class: empty_class)
          end

          def normalize(value)
            return value if value.is_a?(Hash) || value.is_a?(Array)
            return value unless value.respond_to?(:to_h)

            value.to_h
          rescue StandardError
            value
          end

          def display_text(value)
            case value
            when Symbol
              humanize_label(value)
            else
              value.to_s
            end
          end

          def block_class(depth)
            merge_classes(
              "rounded-2xl border border-white/10 bg-white/[0.03] p-4",
              depth.zero? && @compact ? "p-3" : nil
            )
          end

          def nested_class(depth)
            depth.positive? ? "pl-3 border-l border-white/5" : nil
          end

          def row_class
            merge_classes(
              "grid gap-2",
              @compact ? "grid-cols-[minmax(110px,160px)_1fr]" : "grid-cols-[minmax(140px,190px)_1fr]"
            )
          end

          def summary_class
            "flex flex-wrap items-center gap-3 cursor-pointer"
          end

          def empty_class
            "text-sm italic text-stone-400"
          end

          def tag_name
            "div"
          end
        end
      end
    end
  end
end
