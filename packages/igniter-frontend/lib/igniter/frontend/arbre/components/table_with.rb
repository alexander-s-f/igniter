# frozen_string_literal: true

require_relative "../component"
require_relative "display_value_support"

module Igniter
  module Frontend
    module Arbre
      module Components
        class TableWith < Arbre::Component
          builder_method :table_with
          include DisplayValueSupport

          Column = ::Data.define(
            :title,
            :key,
            :as,
            :placeholder,
            :badge_options,
            :header_class,
            :cell_class,
            :block,
            :kind
          )

          def build(collection, *args, &block)
            options = extract_options!(args)
            title = options.delete(:title)
            subtitle = options.delete(:subtitle)
            theme = options.delete(:theme) || :companion
            empty_message = options.delete(:empty_message) || "Nothing to show yet."
            compact = options.delete(:compact)
            class_name = options.delete(:class_name)
            span = options.delete(:span)
            span_class = span ? "span-#{span}" : nil

            @rows = normalize_rows(collection)
            @columns = []
            @theme = ui_theme(theme)
            @empty_message = empty_message
            @compact = compact

            super(options.merge(class: merge_classes("table-shell overflow-x-auto", span_class, class_name)))
            render_header(title, subtitle)
            render_build_block(block) if block&.arity.to_i <= 0
            render_table
          end

          def column(title, key = nil, as: nil, placeholder: nil, badge: nil, header_class: nil, cell_class: nil, &block)
            @columns << Column.new(title, key || title, as, placeholder, badge, header_class, cell_class, block, :value)
            nil
          end

          def actions(title = "Actions", header_class: nil, cell_class: nil, &block)
            @columns << Column.new(title, nil, nil, nil, nil, header_class, cell_class, block, :actions)
            nil
          end

          private

          def render_header(title, subtitle)
            return if title.nil? && subtitle.nil?

            div(class: "mb-5 grid gap-2") do
              h2(title, class: @theme.section_heading_class(extra: "mt-0")) if title
              div(subtitle, class: @theme.muted_text_class) if subtitle
            end
          end

          def render_table
            table(class: merge_classes("min-w-full border-separate border-spacing-0", @compact ? "text-sm" : nil)) do |root|
              render_head(root)
              render_body(root)
            end
          end

          def render_head(root)
            header_class = merge_classes(
              @theme.field_label_class(extra: @compact ? "px-3 py-2 text-left align-bottom border-b border-white/10" : "px-4 py-3 text-left align-bottom border-b border-white/10")
            )

            root.thead do |thead|
              thead.tr do |row|
                @columns.each do |col|
                  row.th(humanize_label(col.title), class: merge_classes(header_class, col.header_class))
                end
              end
            end
          end

          def render_body(root)
            root.tbody do |tbody|
              if @rows.empty?
                render_empty_row(tbody)
              else
                @rows.each_with_index do |entry, index|
                  row_class = merge_classes(index.even? ? "bg-white/[0.02]" : nil, "transition hover:bg-white/[0.04]")
                  tbody.tr(class: row_class) do |row|
                    @columns.each do |col|
                      render_cell(row, entry, col)
                    end
                  end
                end
              end
            end
          end

          def render_empty_row(tbody)
            tbody.tr do |row|
              row.td(@empty_message, colspan: @columns.size, class: merge_classes(cell_base_class, "text-stone-400 italic"))
            end
          end

          def render_cell(row, entry, column)
            row.td(class: merge_classes(cell_base_class, column.cell_class)) do |cell|
              if column.kind == :actions
                render_actions_cell(cell, entry, column.block)
              else
                value = extract_value(entry, column)
                render_value(cell, value, as: column.as, placeholder: column.placeholder, badge_options: column.badge_options)
              end
            end
          end

          def render_actions_cell(cell, entry, block)
            return if block.nil?

            cell.action_group(class_name: "flex flex-wrap gap-2") do |actions|
              if block.arity >= 2
                block.call(entry, actions)
              else
                result = block.call(entry)
                actions.text_node(result.to_s) unless result.nil?
              end
            end
          end

          def render_value(cell, value, as:, placeholder:, badge_options:)
            content = if value.nil? || (value.respond_to?(:empty?) && value.empty?)
                        placeholder
                      else
                        value
                      end
            return if content.nil?

            case content
            when Array
              render_array_value(cell, content, as: as, badge_options: badge_options)
            else
              render_scalar_value(cell, content, as: as, badge_options: badge_options)
            end
          end

          def render_array_value(cell, values, as:, badge_options:)
            items = values.compact
            return if items.empty?

            if as == :badge
              cell.div(class: "flex flex-wrap gap-2") do |container|
                items.each { |item| container.badge(item, **(badge_options || {})) }
              end
            else
              cell.text_node(items.map { |item| display_text(item) }.join(", "))
            end
          end

          def render_scalar_value(cell, value, as:, badge_options:)
            render_semantic_scalar(cell, value, as: as, badge_options: badge_options, theme: @theme)
          end

          def extract_value(entry, column)
            return column.block.call(entry) if column.block

            key = column.key
            return unless key

            if entry.respond_to?(key)
              entry.public_send(key)
            elsif entry.respond_to?(:[])
              entry[key] || entry[key.to_s]
            end
          end

          def normalize_rows(collection)
            return [] if collection.nil?
            return collection.to_a if collection.respond_to?(:to_a) && !collection.is_a?(Hash)

            [collection]
          end

          def cell_base_class
            extra = @compact ? "px-3 py-2 align-top border-b border-white/5 text-sm" : "px-4 py-3 align-top border-b border-white/5"
            @theme.body_text_class(extra: extra)
          end

          def tag_name
            "div"
          end
        end
      end
    end
  end
end
