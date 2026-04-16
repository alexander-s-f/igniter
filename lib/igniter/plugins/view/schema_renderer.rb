# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      class SchemaRenderer < Component
        require_relative "tailwind"

        def self.render(schema:, **kwargs)
          new(schema: schema, **kwargs).render
        end

        def initialize(schema:, action_resolver: nil, values: {}, errors: {}, notice: nil)
          @schema = schema.is_a?(Schema) ? schema : Schema.load(schema)
          @action_resolver = action_resolver
          @values = stringify_keys(values)
          @errors = stringify_keys(errors)
          @notice = notice
        end

        def call(view)
          view.raw(
            Tailwind.render_page(
              title: schema.title,
              lang: schema.meta.fetch("lang", "en"),
              theme: :schema
            ) do |main|
              meta_hint = schema.meta["description"] || schema.meta["subtitle"]
              main.component(ui_theme.schema_hero(title: schema.title, description: meta_hint))

              main.component(Tailwind::UI::SubmissionNotice.new(message: notice, tone: :notice, tag: :div)) if notice
              render_node(main, schema.layout)
            end
          )
        end

        private

        attr_reader :schema, :action_resolver, :values, :errors, :notice

        def render_node(view, node) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
          case node.fetch("type")
          when "stack"
            render_container(view, :section, node, class_name: "view-stack")
          when "grid"
            render_container(view, :section, node, class_name: "view-grid")
          when "section"
            render_container(view, :section, node, class_name: "view-section")
          when "card"
            render_container(view, :article, node, class_name: "view-card")
          when "notice"
            view.component(Tailwind::UI::SubmissionNotice.new(message: node.fetch("message"), tone: notice_tone(node["tone"]), tag: :div))
          when "heading"
            level = [[node.fetch("level", 1).to_i, 1].max, 6].min
            view.tag(:"h#{level}", node.fetch("text"), class: heading_classes(level))
          when "text"
            view.component(ui_theme.schema_intro(text: node.fetch("text"), tone: node.fetch("tone", nil)))
          when "form"
            render_form(view, node)
          when "input", "textarea", "select", "checkbox", "submit"
            raise ArgumentError, "field node #{node["type"]} must be nested inside a form"
          else
            raise ArgumentError, "unsupported node type: #{node["type"]}"
          end
        end

        def render_container(view, tag_name, node, class_name:)
          case class_name
          when "view-stack"
            view.component(ui_theme.schema_stack { |container| render_children(container, node) })
          when "view-grid"
            view.component(ui_theme.schema_grid { |container| render_children(container, node) })
          when "view-section"
            view.component(ui_theme.schema_section(tag: tag_name) { |container| render_children(container, node) })
          when "view-card"
            view.component(ui_theme.schema_card { |container| render_children(container, node) })
          else
            view.tag(tag_name, class: class_name) { |container| render_children(container, node) }
          end
        end

        def render_children(container, node)
          Array(node["children"]).each { |child| render_node(container, child) }
        end

        def render_form(view, node)
          action = resolve_action(node.fetch("action"))
          method = action.fetch("method", "post")
          path = action.fetch("path")

          view.component(
            ui_theme.schema_form(action: path, method: method, hidden_action: node.fetch("action")) do |form, fieldset|
              Array(node["children"]).each { |child| render_form_child(form, fieldset, child, inline_actions: false) }
            end
          )
        end

        def render_form_child(form, target, node, inline_actions:)
          field_name = node["name"]
          field_error = field_name ? errors[field_name] : nil
          error_class = field_error ? "view-input-error" : nil

          case node.fetch("type")
          when "fieldset"
            target.component(
              ui_theme.schema_fieldset(legend: node["legend"], description: node["description"]) do |fieldset|
                Array(node["children"]).each do |child|
                  render_form_child(form, fieldset, child, inline_actions: false)
                end
              end
            )
          when "notice"
            target.component(
              Tailwind::UI::SubmissionNotice.new(message: node.fetch("message"), tone: notice_tone(node["tone"]), tag: :div)
            )
          when "actions"
            target.component(
              Tailwind::UI::InlineActions.new do |actions|
                Array(node["children"]).each do |child|
                  render_form_child(form, actions, child, inline_actions: true)
                end
              end
            )
          when "input"
            target.component(
              Tailwind::UI::FieldGroup.new(id: dom_id(node), label: node.fetch("label"), error: field_error) do |field|
                FormBuilder.new(field).input(
                  node.fetch("name"),
                  id: dom_id(node),
                  placeholder: node["placeholder"],
                  value: value_for(node),
                  required: node["required"],
                  class: [field_classes, error_class]
                )
              end
            )
          when "textarea"
            target.component(
              Tailwind::UI::FieldGroup.new(id: dom_id(node), label: node.fetch("label"), error: field_error) do |field|
                FormBuilder.new(field).textarea(
                  node.fetch("name"),
                  id: dom_id(node),
                  value: value_for(node),
                  placeholder: node["placeholder"],
                  rows: node.fetch("rows", nil),
                  class: [field_classes, "min-h-28", error_class]
                )
              end
            )
          when "select"
            target.component(
              Tailwind::UI::ChoiceField.new(
                kind: :select,
                name: node.fetch("name"),
                id: dom_id(node),
                label: node.fetch("label"),
                error: field_error,
                selected: value_for(node, fallback: node["selected"]),
                options: Array(node["options"]).map { |option| [option.fetch("label"), option.fetch("value")] },
                input_class: [field_classes, error_class]
              )
            )
          when "checkbox"
            target.component(
              Tailwind::UI::ChoiceField.new(
                kind: :checkbox,
                name: node.fetch("name"),
                id: dom_id(node),
                label: node.fetch("label"),
                error: field_error,
                checked: checked_for(node),
                value: node.fetch("value", "1"),
                checkbox_label_class: checkbox_label_classes,
                checkbox_class: checkbox_classes
              )
            )
          when "submit"
            if inline_actions
              FormBuilder.new(target).submit(node.fetch("label"), class: submit_classes)
            else
              target.component(
                Tailwind::UI::InlineActions.new do |actions|
                  FormBuilder.new(actions).submit(node.fetch("label"), class: submit_classes)
                end
              )
            end
          when "text"
            target.component(ui_theme.schema_intro(text: node.fetch("text"), tone: :muted))
          else
            raise ArgumentError, "unsupported form child: #{node["type"]}"
          end
        end

        def resolve_action(action_id)
          resolved = if action_resolver
                       action_resolver.call(action_id.to_s)
                     else
                       schema.action(action_id)
                     end

          raise ArgumentError, "unknown schema action: #{action_id}" unless resolved.is_a?(Hash)

          resolved.transform_keys(&:to_s)
        end

        def dom_id(node)
          node.fetch("id", "view-#{node.fetch("name").tr("_", "-")}")
        end

        def value_for(node, fallback: node["value"])
          values.key?(node.fetch("name")) ? values[node.fetch("name")] : fallback
        end

        def checked_for(node)
          return values[node.fetch("name")] if values.key?(node.fetch("name"))

          node.fetch("checked", false)
        end

        def stringify_keys(value)
          case value
          when Hash
            value.each_with_object({}) { |(key, entry), memo| memo[key.to_s] = stringify_keys(entry) }
          when Array
            value.map { |entry| stringify_keys(entry) }
          else
            value
          end
        end

        def checkbox_label_classes
          ui_theme.checkbox_label_class
        end

        def checkbox_classes
          ui_theme.checkbox_class
        end

        def field_classes
          ui_theme.input_class
        end

        def submit_classes
          Tailwind::UI::Tokens.action(variant: :primary, theme: :orange)
        end

        def notice_tone(value)
          candidate = value.to_s.strip
          candidate.empty? ? :notice : candidate.to_sym
        end

        def ui_theme
          Tailwind::UI::Theme.fetch(:schema)
        end

        def heading_classes(level)
          case level
          when 1
            "font-display text-3xl leading-tight text-white sm:text-4xl"
          when 2
            "font-display text-2xl text-white"
          else
            "font-display text-xl text-white"
          end
        end

      end
    end
  end
end
