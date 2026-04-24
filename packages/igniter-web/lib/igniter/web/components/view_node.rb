# frozen_string_literal: true

module Igniter
  module Web
    module Components
      class ViewNode < Component
        builder_method :view_node

        def build(node, &block)
          super(
            class: class_names("ig-node", token_class("ig-node", node.kind), token_class("ig-role", node.role)),
            "data-ig-node-kind": node.kind,
            "data-ig-node-name": node.name,
            "data-ig-node-role": node.role
          )

          h2 node_label(node)
          render_props(node)
          render_build_block(block, self)
        end

        private

        def tag_name
          "article"
        end

        def node_label(node)
          humanize([node.kind, node.name].compact.join(": "))
        end

        def render_props(node)
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
      end
    end
  end
end
