# frozen_string_literal: true

module Igniter
  module Extensions
    module Introspection
      class GraphFormatter
        def self.to_text(graph)
          new(graph).to_text
        end

        def self.to_mermaid(graph)
          new(graph).to_mermaid
        end

        def initialize(graph)
          @graph = graph
        end

        def to_text
          lines = []
          lines << "Graph #{@graph.name}"
          lines << "Nodes:"
          @graph.nodes.each do |node|
            line = "- #{node.kind} #{node.path}"
            line += " depends_on=#{node.dependencies.join(',')}" if node.dependencies.any?
            if node.kind == :compute
              line += " callable=#{node.callable_name}"
              line += " guard=true" if node.guard?
              line += " const=true" if node.const?
              line += " executor_key=#{node.executor_key}" if node.executor_key
              line += " label=#{node.executor_label}" if node.executor_label
              line += " category=#{node.executor_category}" if node.executor_category
              line += " tags=#{node.executor_tags.join(',')}" if node.executor_tags.any?
              line += " summary=#{node.executor_summary}" if node.executor_summary
            end
            if node.kind == :composition
              line += " contract=#{node.contract_class.name || 'AnonymousContract'}"
            end
            if node.kind == :agent
              line += " via=#{node.agent_name.inspect}"
              line += " message=#{node.message_name.inspect}"
              line += " timeout=#{node.timeout}"
              line += " mode=#{node.mode}"
            end
            if node.kind == :branch
              cases = node.cases.map do |entry|
                "#{format_branch_case(entry)}:#{entry[:contract].name || 'AnonymousContract'}"
              end
              line += " selector=#{node.selector_dependency}"
              line += " depends_on=#{node.context_dependencies.join(',')}" if node.context_dependencies.any?
              line += " cases=#{cases.join('|')}"
              line += " default=#{node.default_contract.name || 'AnonymousContract'}"
              line += " mapper=#{node.input_mapper}" if node.input_mapper?
            end
            if node.kind == :collection
              line += " with=#{node.source_dependency}"
              line += " depends_on=#{node.context_dependencies.join(',')}" if node.context_dependencies.any?
              line += " each=#{node.contract_class.name || 'AnonymousContract'}"
              line += " key=#{node.key_name}"
              line += " mode=#{node.mode}"
              line += " mapper=#{node.input_mapper}" if node.input_mapper?
            end
            lines << line
          end
          lines << "Outputs:"
          @graph.outputs.each do |output|
            lines << "- #{output.path} -> #{output.source}"
          end
          lines.join("\n")
        end

        def to_mermaid
          lines = []
          lines << "graph TD"
          @graph.nodes.each do |node|
            lines << %(  #{node_id(node)}["#{node_label(node)}"])
          end
          @graph.outputs.each do |output|
            lines << %(  #{output_id(output)}["output: #{output.name}"])
            lines << %(  #{node_id(@graph.fetch_node(output.source_root))} --> #{output_id(output)})
          end
          @graph.nodes.each do |node|
            node.dependencies.each do |dependency_name|
              dependency_node = @graph.fetch_dependency(dependency_name)
              lines << %(  #{node_id(dependency_node)} --> #{node_id(node)})
            end
          end
          lines.join("\n")
        end

        private

        def node_id(node)
          return "output_#{node.name}" if node.kind == :output

          "node_#{node.name}"
        end

        def output_id(output)
          "output_#{output.name}"
        end

        def node_label(node)
          return "#{node.kind}: #{node.path}" unless node.kind == :compute

          "#{node.kind}: #{node.path}\\n#{node.callable_name}"
        end

        def format_branch_case(entry)
          case entry[:matcher]
          when :eq
            entry[:value].inspect
          when :in
            "in=#{entry[:value].inspect}"
          when :matches
            "matches=#{entry[:value].inspect}"
          else
            "#{entry[:matcher]}=#{entry[:value].inspect}"
          end
        end
      end
    end
  end
end
