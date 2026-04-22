# frozen_string_literal: true

module Igniter
  module Contracts
    module ConstPack
      module_function

      def handle_const(operation:, **)
        operation.dig(:attributes, :value)
      end

      def install_into(kernel)
        kernel.nodes.register(:const, NodeType.new(kind: :const, metadata: { category: :value }))
        kernel.dsl_keywords.register(:const, DslKeyword.new(:const) do |name, value, builder:|
          builder.add_operation(kind: :const, name: name, value: value)
        end)
        kernel.runtime_handlers.register(:const, method(:handle_const))
        kernel
      end
    end
  end
end
