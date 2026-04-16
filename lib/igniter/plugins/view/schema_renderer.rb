# frozen_string_literal: true

module Igniter
  module Plugins
    module View
      class SchemaRenderer < Component
        require_relative "tailwind"

        TAILWIND_CONFIG = {
          theme: {
            extend: {
              fontFamily: {
                display: ["Fraunces", "Iowan Old Style", "Palatino Linotype", "serif"],
                body: ["IBM Plex Sans", "Avenir Next", "system-ui", "sans-serif"],
                mono: ["IBM Plex Mono", "SFMono-Regular", "Menlo", "monospace"]
              }
            }
          }
        }.freeze

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
              body_class: "min-h-screen bg-stone-950 text-stone-100 antialiased selection:bg-orange-300/30 selection:text-white",
              main_class: "mx-auto flex min-h-screen w-full max-w-4xl flex-col gap-5 px-4 py-6 sm:px-6 lg:px-8",
              tailwind_config: TAILWIND_CONFIG
            ) do |main|
              main.tag(:section,
                       class: "overflow-hidden rounded-[34px] border border-orange-200/15 bg-[radial-gradient(circle_at_top_left,_rgba(194,107,61,0.22),_transparent_18rem),linear-gradient(145deg,rgba(60,33,21,0.96),rgba(22,15,13,0.98))] px-6 py-8 shadow-2xl shadow-black/25 sm:px-8") do |hero|
                hero.tag(:p, "Schema Page", class: "text-[11px] font-semibold uppercase tracking-[0.34em] text-orange-200/75")
                hero.tag(:h1, schema.title, class: "mt-3 font-display text-4xl leading-tight text-white sm:text-5xl")
                meta_hint = schema.meta["description"] || schema.meta["subtitle"]
                hero.tag(:p, meta_hint, class: "mt-4 max-w-3xl text-base leading-7 text-stone-300") if meta_hint
              end

              main.component(Tailwind::UI::Banner.new(message: notice, tone: :notice, tag: :div)) if notice
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
          when "heading"
            level = [[node.fetch("level", 1).to_i, 1].max, 6].min
            view.tag(:"h#{level}", node.fetch("text"), class: heading_classes(level))
          when "text"
            view.tag(:p, node.fetch("text"), class: text_classes(node.fetch("tone", nil)))
          when "form"
            render_form(view, node)
          when "input", "textarea", "select", "checkbox", "submit"
            raise ArgumentError, "field node #{node["type"]} must be nested inside a form"
          else
            raise ArgumentError, "unsupported node type: #{node["type"]}"
          end
        end

        def render_container(view, tag_name, node, class_name:)
          view.tag(tag_name, class: container_classes(class_name)) do |container|
            Array(node["children"]).each { |child| render_node(container, child) }
          end
        end

        def render_form(view, node)
          action = resolve_action(node.fetch("action"))
          method = action.fetch("method", "post")
          path = action.fetch("path")

          view.form(action: path, method: method, class: "view-form grid gap-3") do |form|
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
            form.view.component(
              Tailwind::UI::Field.new(id: dom_id(node), label: node.fetch("label"), error: field_error) do |field|
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
            form.view.component(
              Tailwind::UI::Field.new(id: dom_id(node), label: node.fetch("label"), error: field_error) do |field|
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
            form.view.component(
              Tailwind::UI::Field.new(id: dom_id(node), label: node.fetch("label"), error: field_error) do |field|
                FormBuilder.new(field).select(
                  node.fetch("name"),
                  id: dom_id(node),
                  selected: value_for(node, fallback: node["selected"]),
                  options: Array(node["options"]).map { |option| [option.fetch("label"), option.fetch("value")] },
                  class: [field_classes, error_class]
                )
              end
            )
          when "checkbox"
            form.view.component(
              Tailwind::UI::Field.new(id: dom_id(node), error: field_error) do |field|
                field.tag(:label, class: checkbox_label_classes, for: dom_id(node)) do |label|
                  label.raw(
                    View.render do |view|
                      FormBuilder.new(view).checkbox(
                        node.fetch("name"),
                        value: node.fetch("value", "1"),
                        checked: checked_for(node),
                        id: dom_id(node),
                        class: checkbox_classes
                      )
                    end
                  )
                  label.text(" #{node.fetch("label")}")
                end
              end
            )
          when "submit"
            form.view.component(
              Tailwind::UI::InlineActions.new do |actions|
                FormBuilder.new(actions).submit(node.fetch("label"), class: submit_classes)
              end
            )
          when "text"
            form.view.tag(:p, node.fetch("text"), class: "view-muted text-sm leading-6 text-stone-400")
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
          "flex items-center gap-3 rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-stone-200"
        end

        def checkbox_classes
          "h-4 w-4 rounded border-white/20 bg-stone-950 text-orange-300"
        end

        def field_classes
          "w-full rounded-2xl border border-white/10 bg-[#160f0d] px-4 py-3 text-sm text-white placeholder:text-stone-500 focus:border-orange-300/50 focus:outline-none"
        end

        def submit_classes
          "inline-flex rounded-full border border-orange-300/20 bg-orange-300/90 px-5 py-3 text-sm font-semibold uppercase tracking-[0.18em] text-stone-950 transition hover:bg-orange-200"
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

        def text_classes(tone)
          base = "text-base leading-7 text-stone-200"
          return "#{base} view-muted text-stone-400" if tone == "muted"

          base
        end

        def container_classes(class_name)
          case class_name
          when "view-stack"
            "view-stack grid gap-5"
          when "view-grid"
            "view-grid grid gap-5 sm:grid-cols-2"
          when "view-section"
            "view-section rounded-[28px] border border-white/10 bg-[#2a1914]/90 p-6 shadow-2xl shadow-black/20 backdrop-blur"
          when "view-card"
            "view-card rounded-[28px] border border-orange-200/15 bg-[linear-gradient(145deg,rgba(60,33,21,0.92),rgba(30,18,14,0.96))] p-6 shadow-2xl shadow-black/25"
          else
            class_name
          end
        end
      end
    end
  end
end
