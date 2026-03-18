# frozen_string_literal: true

module Igniter
  module Compiler
    class CompiledGraph
      attr_reader :name, :nodes, :nodes_by_id, :nodes_by_name, :nodes_by_path, :outputs, :outputs_by_name, :resolution_order, :dependents

      def initialize(name:, nodes:, outputs:, resolution_order:, dependents:)
        @name = name
        @nodes = nodes.freeze
        @nodes_by_id = nodes.each_with_object({}) { |node, memo| memo[node.id] = node }.freeze
        @nodes_by_name = nodes.each_with_object({}) { |node, memo| memo[node.name] = node }.freeze
        @nodes_by_path = nodes.each_with_object({}) { |node, memo| memo[node.path] = node }.freeze
        @outputs = outputs.freeze
        @outputs_by_name = outputs.each_with_object({}) { |node, memo| memo[node.name] = node }.freeze
        @resolution_order = resolution_order.freeze
        @dependents = dependents.transform_values(&:freeze).freeze
        freeze
      end

      def fetch_node_by_id(id)
        @nodes_by_id.fetch(id)
      end

      def fetch_node(name)
        @nodes_by_name.fetch(name.to_sym)
      end

      def node?(name)
        @nodes_by_name.key?(name.to_sym)
      end

      def fetch_node_by_path(path)
        @nodes_by_path.fetch(path.to_s)
      end

      def fetch_output(name)
        @outputs_by_name.fetch(name.to_sym)
      end

      def output?(name)
        @outputs_by_name.key?(name.to_sym)
      end

      def fetch_dependency(name)
        return fetch_node(name) if node?(name)
        return fetch_output(name) if output?(name)

        raise KeyError, "Unknown dependency '#{name}'"
      end

      def to_h
        {
          name: name,
          nodes: nodes.map do |node|
            base = {
              id: node.id,
              kind: node.kind,
              name: node.name,
              path: node.path,
              dependencies: node.dependencies
            }
            if node.kind == :composition
              base[:contract] = node.contract_class.name
              base[:inputs] = node.input_mapping
            end
            base
          end,
          outputs: outputs.map do |output|
            {
              name: output.name,
              path: output.path,
              source: output.source
            }
          end,
          resolution_order: resolution_order.map(&:name)
        }
      end

      def to_text
        Extensions::Introspection::GraphFormatter.to_text(self)
      end

      def to_mermaid
        Extensions::Introspection::GraphFormatter.to_mermaid(self)
      end
    end
  end
end
