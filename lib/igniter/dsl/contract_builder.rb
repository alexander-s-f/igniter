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

      UNDEFINED_INPUT_DEFAULT = :__igniter_undefined__
      UNDEFINED_CONST_VALUE = :__igniter_const_undefined__
      UNDEFINED_GUARD_MATCHER = :__igniter_guard_matcher_undefined__

      def input(name, type: nil, required: nil, default: UNDEFINED_INPUT_DEFAULT, **metadata)
        input_metadata = with_source_location(metadata)
        input_metadata[:type] = type if type
        input_metadata[:required] = required unless required.nil?
        input_metadata[:default] = default unless default == UNDEFINED_INPUT_DEFAULT

        add_node(
          Model::InputNode.new(
            id: next_id,
            name: name,
            metadata: input_metadata
          )
        )
      end

      def compute(name, depends_on: nil, with: nil, call: nil, executor: nil, **metadata, &block)
        callable, resolved_metadata = resolve_compute_callable(call: call, executor: executor, metadata: metadata, block: block)
        raise CompileError, "compute :#{name} requires a callable" unless callable

        add_node(
          Model::ComputeNode.new(
            id: next_id,
            name: name,
            dependencies: normalize_dependencies(depends_on: depends_on, with: with),
            callable: callable,
            metadata: with_source_location(resolved_metadata)
          )
        )
      end

      def const(name, value = UNDEFINED_CONST_VALUE, **metadata, &block)
        raise CompileError, "const :#{name} cannot accept both a value and a block" if !block.nil? && value != UNDEFINED_CONST_VALUE
        raise CompileError, "const :#{name} requires a value or a block" if block.nil? && value == UNDEFINED_CONST_VALUE

        callable = if block
                     block
                   else
                     proc { value }
                   end

        compute(name, with: [], call: callable, **metadata.merge(kind: :const))
      end

      def lookup(name, depends_on: nil, with: nil, call: nil, executor: nil, **metadata, &block)
        compute(name, depends_on: depends_on, with: with, call: call, executor: executor, **{ category: :lookup }.merge(metadata), &block)
      end

      def map(name, from:, call: nil, executor: nil, **metadata, &block)
        compute(name, with: from, call: call, executor: executor, **{ category: :map }.merge(metadata), &block)
      end

      def guard(name, depends_on: nil, with: nil, call: nil, executor: nil, message: nil, eq: UNDEFINED_GUARD_MATCHER, **metadata, &block)
        if eq != UNDEFINED_GUARD_MATCHER
          raise CompileError, "guard :#{name} cannot combine `eq:` with `call:`, `executor:`, or a block" if call || executor || block

          dependencies = normalize_dependencies(depends_on: depends_on, with: with)
          raise CompileError, "guard :#{name} with `eq:` requires exactly one dependency" unless dependencies.size == 1

          call = proc do |**values|
            values.fetch(dependencies.first) == eq
          end
        end

        compute(
          name,
          depends_on: depends_on,
          with: with,
          call: call,
          executor: executor,
          **metadata.merge(kind: :guard, guard: true, guard_message: message || "Guard '#{name}' failed"),
          &block
        )
      end

      def export(*names, from:, **metadata)
        names.each do |name|
          output(name, from: "#{from}.#{name}", **metadata)
        end
      end

      def expose(*sources, as: nil, **metadata)
        raise CompileError, "expose cannot use `as:` with multiple sources" if as && sources.size != 1

        sources.each do |source|
          output(as || source, from: source, **metadata)
        end
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

      def resolve_compute_callable(call:, executor:, metadata:, block:)
        raise CompileError, "compute cannot accept both `call:` and `executor:`" if call && executor
        raise CompileError, "compute cannot accept both `call:` and a block" if call && block
        raise CompileError, "compute cannot accept both `executor:` and a block" if executor && block

        if executor
          definition = Igniter.executor_registry.fetch(executor)
          return [definition.executor_class, definition.metadata.merge(metadata).merge(executor_key: definition.key)]
        end

        [call || block, metadata]
      end

      def normalize_dependencies(depends_on:, with:)
        raise CompileError, "Use either `depends_on:` or `with:`, not both" if depends_on && with

        dependencies = depends_on || with
        Array(dependencies)
      end
    end
  end
end
