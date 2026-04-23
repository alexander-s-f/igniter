# frozen_string_literal: true

require_relative "../component"

module Igniter
  module Frontend
    module Arbre
      module Components
        class KeyValueList < Arbre::Component
          builder_method :key_value_list

          def build(*args, &block)
            options = extract_options!(args)
            class_name = options.delete(:class_name)

            super(options.merge(class: merge_classes("kv-list", class_name)))
            render_build_block(block)
          end

          def item(label, value = nil, &block)
            dt(humanize_label(label), class: "kv-term")
            dd(class: "kv-value") do
              if block
                render_build_block(block)
              else
                text_node(value.to_s)
              end
            end
          end

          private

          def tag_name
            "dl"
          end
        end
      end
    end
  end
end
