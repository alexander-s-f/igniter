# frozen_string_literal: true

module Igniter
  module Runtime
    class InputValidator
      def initialize(compiled_graph)
        @compiled_graph = compiled_graph
      end

      def normalize_initial_inputs(raw_inputs)
        inputs = symbolize_keys(raw_inputs)

        validate_unknown_inputs!(inputs)
        apply_defaults(inputs)
        validate_known_inputs!(inputs)

        inputs
      end

      def validate_update!(name, value)
        input_node = fetch_input_node(name)
        validate_required!(input_node, value)
        validate_type!(input_node, value)
      end

      def fetch_value!(name, inputs)
        input_node = fetch_input_node(name)
        value = inputs.fetch(name.to_sym) { missing_value!(input_node) }

        validate_required!(input_node, value)
        validate_type!(input_node, value)
        value
      end

      private

      def input_nodes
        @input_nodes ||= @compiled_graph.nodes.select { |node| node.kind == :input }
      end

      def input_nodes_by_name
        @input_nodes_by_name ||= input_nodes.each_with_object({}) { |node, memo| memo[node.name] = node }
      end

      def fetch_input_node(name)
        input_nodes_by_name.fetch(name.to_sym)
      rescue KeyError
        raise InputError.new("Unknown input: #{name}", context: { graph: @compiled_graph.name, node_name: name.to_sym })
      end

      def validate_unknown_inputs!(inputs)
        unknown = inputs.keys - input_nodes_by_name.keys
        return if unknown.empty?

        raise InputError.new(
          "Unknown inputs: #{unknown.sort.join(', ')}",
          context: { graph: @compiled_graph.name }
        )
      end

      def apply_defaults(inputs)
        input_nodes.each do |node|
          next if inputs.key?(node.name)
          next unless node.default?

          inputs[node.name] = node.default
        end
      end

      def validate_known_inputs!(inputs)
        inputs.each do |name, value|
          input_node = fetch_input_node(name)
          validate_required!(input_node, value)
          validate_type!(input_node, value)
        end
      end

      def missing_value!(input_node)
        return input_node.default if input_node.default?
        return nil unless input_node.required?

        raise input_error(input_node, "Missing required input: #{input_node.name}")
      end

      def validate_required!(input_node, value)
        return unless input_node.required?
        return unless value.nil?

        raise input_error(input_node, "Input '#{input_node.name}' is required")
      end

      def validate_type!(input_node, value)
        return if value.nil?
        return unless input_node.type

        unless TypeSystem.supported?(input_node.type)
          raise input_error(input_node, "Unsupported input type '#{input_node.type}' for '#{input_node.name}'")
        end

        return if TypeSystem.match?(input_node.type, value)

        raise input_error(input_node, "Input '#{input_node.name}' must be of type #{input_node.type}, got #{value.class}")
      end

      def symbolize_keys(hash)
        hash.each_with_object({}) { |(key, value), memo| memo[key.to_sym] = value }
      end

      def input_error(input_node, message)
        InputError.new(
          message,
          context: {
            graph: @compiled_graph.name,
            node_id: input_node.id,
            node_name: input_node.name,
            node_path: input_node.path,
            source_location: input_node.source_location
          }
        )
      end
    end
  end
end
