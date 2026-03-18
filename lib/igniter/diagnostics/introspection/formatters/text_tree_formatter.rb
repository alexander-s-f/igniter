# frozen_string_literal: true

module Igniter
  module Diagnostics
    module Introspection
      module Formatters
        class TextTreeFormatter
          def self.call(structure)
            new(structure).call
          end

          def initialize(structure)
            @structure = structure
            @output = StringIO.new
          end

          def call
            @structure.each_with_index do |node, index|
              is_last = index == @structure.size - 1
              print_node(node, "", is_last)
            end
            @output.string
          end

          private

          def print_node(node, prefix, is_last)
            connector = is_last ? "└── " : "├── "
            @output << "#{prefix}#{connector}#{node[:name]} [#{node[:type]}] #{node[:details]}\n"

            children_prefix = prefix + (is_last ? "    " : "│   ")
            if node[:dependencies].any?
              @output << "#{children_prefix}  └─ depends_on: [#{node[:dependencies].join(', ')}]\n"
            end

            node[:children].each_with_index do |child, index|
              print_node(child, children_prefix, index == node[:children].size - 1)
            end
          end
        end
      end
    end
  end
end
