# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class Filters < Arbre::Component
          builder_method :filters

          Field = ::Data.define(:kind, :name, :label, :placeholder, :value, :options, :include_blank, :input_id)
          Action = ::Data.define(:kind, :label, :href)

          def build(*args, &block)
            options = extract_options!(args)
            action = options.delete(:action) || "#"
            method = options.delete(:method) || "get"
            title = options.delete(:title)
            subtitle = options.delete(:subtitle)
            values = stringify_values(options.delete(:values) || {})
            class_name = options.delete(:class_name)
            compact = options.delete(:compact)

            @theme = ui_theme(:companion)
            @action = action
            @method = method
            @title = title
            @subtitle = subtitle
            @values = values
            @compact = compact
            @fields = []
            @actions = []

            super(options.merge(class: merge_classes("filters-panel rounded-[28px] border border-white/10 bg-white/[0.04] p-4", class_name)))
            render_build_block(block) if block&.arity.to_i <= 0
            render_component
          end

          def search(name, label: nil, placeholder: nil, value: nil, input_id: nil)
            @fields << Field.new(:search, name.to_s, label, placeholder, resolve_value(name, value), nil, nil, input_id)
            nil
          end

          def select(name, options:, label: nil, selected: nil, include_blank: "Any", input_id: nil)
            @fields << Field.new(:select, name.to_s, label, nil, resolve_value(name, selected), options, include_blank, input_id)
            nil
          end

          def hidden(name, value)
            @fields << Field.new(:hidden, name.to_s, nil, nil, value, nil, nil, nil)
            nil
          end

          def submit(label = "Apply Filters")
            @actions << Action.new(:submit, label, nil)
            nil
          end

          def clear(label = "Clear", href: @action)
            @actions << Action.new(:clear, label, href)
            nil
          end

          private

          def render_component
            render_header
            form(action: @action, method: @method, class: "grid gap-4") do |form_view|
              render_hidden_fields(form_view)
              render_fields(form_view)
              render_actions(form_view)
            end
          end

          def render_header
            return if @title.nil? && @subtitle.nil?

            div(class: "mb-4 grid gap-1") do
              h3(@title, class: @theme.section_heading_class(extra: "mt-0")) if @title
              div(@subtitle, class: @theme.muted_text_class) if @subtitle
            end
          end

          def render_hidden_fields(form_view)
            @fields.select { |field| field.kind == :hidden }.each do |field|
              form_view.input(type: "hidden", name: field.name, value: field.value)
            end
          end

          def render_fields(form_view)
            visible_fields = @fields.reject { |field| field.kind == :hidden }
            return if visible_fields.empty?

            grid_class = @compact ? "grid gap-3 md:grid-cols-[minmax(0,1.2fr)_minmax(180px,220px)]" : "grid gap-3 md:grid-cols-2"

            form_view.div(class: grid_class) do |grid|
              visible_fields.each do |field|
                grid.div(class: "grid gap-2") do |container|
                  render_label(container, field)
                  render_field(container, field)
                end
              end
            end
          end

          def render_actions(form_view)
            actions = @actions.dup
            actions << Action.new(:submit, "Apply Filters", nil) if actions.none? { |item| item.kind == :submit }

            form_view.div(class: "flex flex-wrap items-center gap-3") do |bar|
              actions.each do |action|
                case action.kind
                when :submit
                  bar.button(
                    action.label,
                    type: "submit",
                    class: Igniter::Frontend::Tailwind::UI::Tokens.action(variant: :soft, theme: :orange, size: :sm)
                  )
                when :clear
                  bar.a(action.label, href: action.href, class: Igniter::Frontend::Tailwind::UI::Tokens.underline_link(theme: :orange))
                end
              end
            end
          end

          def render_label(container, field)
            return unless field.label

            container.label(field.label, for: field.input_id || field.name, class: @theme.field_label_class)
          end

          def render_field(container, field)
            case field.kind
            when :search
              container.input(
                id: field.input_id || field.name,
                type: "text",
                name: field.name,
                value: field.value,
                placeholder: field.placeholder || "Search",
                class: @theme.input_class
              )
            when :select
              options = build_select_options(field)
              container.select(id: field.input_id || field.name, name: field.name, class: @theme.input_class) do |select|
                options.each do |label, value|
                  option_attrs = { value: value }
                  option_attrs[:selected] = true if field.value.to_s == value.to_s
                  select.option(label, **option_attrs)
                end
              end
            end
          end

          def build_select_options(field)
            options = Array(field.options).map do |entry|
              entry.is_a?(Array) ? entry : [entry.to_s, entry.to_s]
            end

            return options if field.include_blank.nil?

            [[field.include_blank.to_s, ""]] + options
          end

          def resolve_value(name, explicit)
            return explicit unless explicit.nil?

            @values.fetch(name.to_s, nil)
          end

          def stringify_values(values)
            values.each_with_object({}) { |(key, value), memo| memo[key.to_s] = value }
          end

          def tag_name
            "section"
          end
        end
      end
    end
  end
end
