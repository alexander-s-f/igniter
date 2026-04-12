# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      class SchemaRenderer < Component
        DEFAULT_STYLESHEET = <<~CSS
          body {
            margin: 0;
            padding: 32px 20px 56px;
            background: #f6f1e8;
            color: #1f2a2e;
            font-family: "Iowan Old Style", "Palatino Linotype", serif;
          }
          .view-page {
            max-width: 860px;
            margin: 0 auto;
          }
          .view-stack {
            display: grid;
            gap: 16px;
          }
          .view-grid {
            display: grid;
            gap: 16px;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
          }
          .view-section, .view-card {
            background: #fffaf2;
            border: 1px solid #d9c8aa;
            border-radius: 18px;
            padding: 18px;
          }
          .view-card {
            box-shadow: 0 12px 28px rgba(62, 39, 17, 0.06);
          }
          .view-form {
            display: grid;
            gap: 12px;
          }
          .view-form label {
            display: grid;
            gap: 4px;
            color: #5c6b70;
            font-size: 14px;
          }
          .view-form input,
          .view-form select,
          .view-form textarea {
            width: 100%;
            border: 1px solid #d9c8aa;
            border-radius: 12px;
            padding: 10px 12px;
            background: #fffdf8;
            color: #1f2a2e;
            font: inherit;
          }
          .view-form button {
            border: 0;
            border-radius: 999px;
            padding: 10px 14px;
            background: #c26b3d;
            color: white;
            font: inherit;
            cursor: pointer;
          }
          .view-error {
            color: #a33d29;
            font-size: 13px;
          }
          .view-input-error {
            border-color: #a33d29 !important;
            background: #fff5f3 !important;
          }
          .view-notice {
            margin: 0 0 16px;
            padding: 12px 14px;
            border: 1px solid #d9c8aa;
            border-radius: 14px;
            background: #fffaf2;
          }
          .view-muted {
            color: #5c6b70;
          }
        CSS

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
          view.doctype
          view.tag(:html, lang: schema.meta.fetch("lang", "en")) do |html|
            html.tag(:head) do |head|
              head.tag(:meta, charset: "utf-8")
              head.tag(:meta, name: "viewport", content: "width=device-width, initial-scale=1")
              head.tag(:title, schema.title)
              head.tag(:style) { |style| style.raw(DEFAULT_STYLESHEET) }
            end
            html.tag(:body) do |body|
              body.tag(:main, class: "view-page") do |main|
                main.tag(:div, notice, class: "view-notice") if notice
                render_node(main, schema.layout)
              end
            end
          end
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
          when "heading"
            level = [[node.fetch("level", 1).to_i, 1].max, 6].min
            view.tag(:"h#{level}", node.fetch("text"))
          when "text"
            view.tag(:p, node.fetch("text"), class: node.fetch("tone", nil) == "muted" ? "view-muted" : nil)
          when "form"
            render_form(view, node)
          when "input", "textarea", "select", "checkbox", "submit"
            raise ArgumentError, "field node #{node["type"]} must be nested inside a form"
          else
            raise ArgumentError, "unsupported node type: #{node["type"]}"
          end
        end

        def render_container(view, tag_name, node, class_name:)
          view.tag(tag_name, class: class_name) do |container|
            Array(node["children"]).each { |child| render_node(container, child) }
          end
        end

        def render_form(view, node)
          action = resolve_action(node.fetch("action"))
          method = action.fetch("method", "post")
          path = action.fetch("path")

          view.form(action: path, method: method, class: "view-form") do |form|
            form.hidden("_action", node.fetch("action"))
            Array(node["children"]).each { |child| render_form_child(form, child) }
          end
        end

        def render_form_child(form, node)
          field_name = node["name"]
          field_error = field_name ? errors[field_name] : nil
          error_class = field_error ? "view-input-error" : nil

          case node.fetch("type")
          when "input"
            form.label(dom_id(node), node.fetch("label"))
            form.input(node.fetch("name"),
                       id: dom_id(node),
                       placeholder: node["placeholder"],
                       value: value_for(node),
                       required: node["required"],
                       class: error_class)
            render_field_error(form, field_error)
          when "textarea"
            form.label(dom_id(node), node.fetch("label"))
            form.textarea(node.fetch("name"),
                          id: dom_id(node),
                          value: value_for(node),
                          placeholder: node["placeholder"],
                          rows: node.fetch("rows", nil),
                          class: error_class)
            render_field_error(form, field_error)
          when "select"
            form.label(dom_id(node), node.fetch("label"))
            form.select(node.fetch("name"),
                        id: dom_id(node),
                        selected: value_for(node, fallback: node["selected"]),
                        options: Array(node["options"]).map { |option| [option.fetch("label"), option.fetch("value")] },
                        class: error_class)
            render_field_error(form, field_error)
          when "checkbox"
            form.label(dom_id(node)) do |label|
              label.raw(
                View.render do |view|
                  FormBuilder.new(view).checkbox(
                    node.fetch("name"),
                    value: node.fetch("value", "1"),
                    checked: checked_for(node)
                  )
                end
              )
              label.text(" #{node.fetch("label")}")
            end
            render_field_error(form, field_error)
          when "submit"
            form.submit(node.fetch("label"))
          when "text"
            form.view.tag(:p, node.fetch("text"), class: "view-muted")
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

        def render_field_error(form, message)
          return unless message

          form.view.tag(:p, message, class: "view-error")
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
      end
    end
  end
end
