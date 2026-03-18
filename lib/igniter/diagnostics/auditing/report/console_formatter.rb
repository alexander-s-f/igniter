# frozen_string_literal: true

require "stringio"

module Igniter
  module Diagnostics
    module Auditing
      module Report
        # Generates a human-readable text tree of an audition step.
        class ConsoleFormatter
          def self.call(player)
            new(player).call
          end

          def initialize(player)
            @player = player
            @buffer = StringIO.new
            @definition_graph = player.definition_graph
            @audited_graph = player.current_graph
          end

          def call
            print_header

            @definition_graph.root_nodes.each do |node_def|
              build_node_tree(node_def, prefix: "")
            end

            @buffer.string
          end

          private

          def print_header
            trigger = @audited_graph.triggering_event
            @buffer.puts "--- Audition for #{@player.record.contract_class_name} ---"
            @buffer.puts "Step: #{@audited_graph.version} / #{@player.versions_count}"
            @buffer.puts "Trigger: #{trigger[:type]} on '#{trigger[:path]}'" if trigger
            @buffer.puts "-------------------------------------------------"
          end

          def build_node_tree(node_def, prefix:)
            children_defs = @definition_graph.children_of(node_def)
            is_last = (node_def.parent ? @definition_graph.children_of(node_def.parent) : @definition_graph.root_nodes).last == node_def

            @buffer << prefix
            @buffer << (is_last ? "└── " : "├── ")
            @buffer << "#{node_def.name} [#{node_def.class.name.split('::').last}]"

            append_node_details(node_def)

            @buffer << "\n"

            new_prefix = prefix + (is_last ? "    " : "│   ")
            children_defs.each do |child_def|
              build_node_tree(child_def, prefix: new_prefix)
            end
          end

          def append_node_details(node_def)
            audited_node = @audited_graph.find(node_def.path)
            if audited_node
              status_icon = case audited_node.status.to_sym
                            when :success then "✓"
                            when :failure then "✗"
                            when :invalidated then "~"
                            else "?"
                            end
              @buffer << " [#{status_icon}]"
              @buffer << " => <#{audited_node.value_class}> #{audited_node.value.to_s.truncate(100)}"
              @buffer << " (Errors: #{audited_node.errors.join(', ')})" if audited_node.status.to_sym == :failure
            else
              @buffer << " [Not Present in History]"
            end
          end
        end
      end
    end
  end
end
