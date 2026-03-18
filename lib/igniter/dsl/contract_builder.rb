# frozen_string_literal: true

module Igniter
  module DSL
    class ContractBuilder
      def self.compile(name: "AnonymousContract", &block)
        new(name: name).tap { |builder| builder.instance_eval(&block) }.compile
      end

      def initialize(name:)
        @name = name
        @nodes = []
        @sequence = 0
      end

      def input(name, type: nil, required: nil, default: :__arbor_undefined__, **metadata)
        input_metadata = with_source_location(metadata)
        input_metadata[:type] = type if type
        input_metadata[:required] = required unless required.nil?
        input_metadata[:default] = default unless default == :__arbor_undefined__

        add_node(
          Model::InputNode.new(
            id: next_id,
            name: name,
            metadata: input_metadata
          )
        )
      end

      def compute(name, depends_on:, call: nil, **metadata, &block)
        callable = call || block
        raise CompileError, "compute :#{name} requires a callable" unless callable
        raise CompileError, "compute :#{name} cannot accept both `call:` and a block" if call && block

        add_node(
          Model::ComputeNode.new(
            id: next_id,
            name: name,
            dependencies: Array(depends_on),
            callable: callable,
            metadata: with_source_location(metadata)
          )
        )
      end

      def output(name, from: nil, **metadata)
        add_node(
          Model::OutputNode.new(
            id: next_id,
            name: name,
            source: (from || name),
            metadata: with_source_location(metadata)
          )
        )
      end

      def compose(name, contract:, inputs:, **metadata)
        raise CompileError, "compose :#{name} requires an `inputs:` hash" unless inputs.is_a?(Hash)

        add_node(
          Model::CompositionNode.new(
            id: next_id,
            name: name,
            contract_class: contract,
            input_mapping: inputs,
            metadata: with_source_location(metadata)
          )
        )
      end

      def compile
        Compiler::GraphCompiler.call(Model::Graph.new(name: @name, nodes: @nodes))
      end

      private

      def add_node(node)
        @nodes << node
        node
      end

      def next_id
        @sequence += 1
        "#{@name}:#{@sequence}"
      end

      def with_source_location(metadata)
        metadata.merge(source_location: caller_locations(2, 1).first&.to_s)
      end
    end
  end
end
