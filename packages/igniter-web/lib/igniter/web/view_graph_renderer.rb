# frozen_string_literal: true

module Igniter
  module Web
    class ViewGraphRenderer
      class << self
        def render(...)
          new.render(...)
        end
      end

      def render(graph)
        Arbre.ensure_available!
        context = Arbre.context_class.new(graph: graph)
        context.extend(RenderingHelpers)
        context.instance_exec(graph) do |view_graph|
          html do
            head do
              meta charset: "utf-8"
              title screen_title(view_graph.root)
            end

            body do
              main(**screen_attributes(view_graph.root)) do
                header class: "ig-screen-header" do
                  h1 screen_title(view_graph.root)
                end

                view_graph.zones.each { |zone| render_zone(zone) }
              end
            end
          end
        end
        context.to_s
      end

      module RenderingHelpers
        def screen_title(root)
          root.props[:title] || humanize(root.name || :screen)
        end

        def screen_attributes(root)
          preset = root.props.fetch(:preset, {})
          {
            class: class_names("ig-screen", token_class("ig-screen", root.role), token_class("ig-preset", preset[:name])),
            "data-ig-screen": root.name,
            "data-ig-intent": root.role,
            "data-ig-preset": preset[:name]
          }.compact
        end

        def render_zone(zone)
          section class: class_names("ig-zone", token_class("ig-zone", zone.name)), "data-ig-zone": zone.name do
            zone.children.each { |child| render_node(child) }
          end
        end

        def render_node(node)
          article(**node_attributes(node)) do
            h2 node_label(node)
            render_node_detail(node)
            node.children.each { |child| render_node(child) }
          end
        end

        def node_attributes(node)
          {
            class: class_names("ig-node", token_class("ig-node", node.kind), token_class("ig-role", node.role)),
            "data-ig-node-kind": node.kind,
            "data-ig-node-name": node.name,
            "data-ig-node-role": node.role
          }.compact
        end

        def render_node_detail(node)
          return if node.props.empty?

          dl class: "ig-node-props" do
            node.props.each do |name, value|
              next if value.nil?

              div class: "ig-node-prop", "data-ig-prop": name do
                dt humanize(name)
                dd format_value(value)
              end
            end
          end
        end

        def node_label(node)
          label = [node.kind, node.name].compact.join(": ")
          humanize(label)
        end

        def class_names(*values)
          values.flatten.compact.reject(&:empty?).join(" ")
        end

        def token_class(prefix, value)
          return nil if value.nil?

          "#{prefix}--#{dasherize(value)}"
        end

        def humanize(value)
          value.to_s.tr("_", " ").tr("-", " ").split.map(&:capitalize).join(" ")
        end

        def dasherize(value)
          value.to_s.tr("_", "-").downcase
        end

        def format_value(value)
          case value
          when Symbol
            value.to_s
          when Array
            value.map { |item| format_value(item) }.join(", ")
          when Hash
            value.map { |key, item| "#{humanize(key)}: #{format_value(item)}" }.join(", ")
          else
            value.to_s
          end
        end
      end
    end
  end
end
