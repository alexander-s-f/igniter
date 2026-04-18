# frozen_string_literal: true

module Igniter
  module Server
    class Registry
      class RegistryError < Igniter::Server::Error; end

      def initialize
        @contracts = {}
        @mutex = Mutex.new
      end

      def register(name, contract_class)
        unless contract_class.is_a?(Class) && contract_class <= Igniter::Contract
          raise RegistryError, "'#{name}' must be an Igniter::Contract subclass"
        end

        @mutex.synchronize { @contracts[name.to_s] = contract_class }
        self
      end

      def fetch(name)
        @mutex.synchronize do
          @contracts.fetch(name.to_s) do
            raise RegistryError, "Contract '#{name}' is not registered. " \
                                 "Available: #{@contracts.keys.inspect}"
          end
        end
      end

      def all
        @mutex.synchronize { @contracts.dup }
      end

      def names
        @mutex.synchronize { @contracts.keys }
      end

      def registered?(name)
        @mutex.synchronize { @contracts.key?(name.to_s) }
      end

      # Returns a description of each registered contract for introspection.
      def introspect
        all.map do |name, klass|
          graph = klass.compiled_graph
          {
            name: name,
            inputs: graph.nodes.select { |n| n.kind == :input }.map(&:name),
            outputs: graph.outputs.map(&:name)
          }
        end
      end
    end
  end
end
