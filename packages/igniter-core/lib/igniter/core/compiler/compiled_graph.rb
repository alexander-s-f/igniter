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

      def await_nodes
        @nodes.select { |n| n.kind == :await }
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
            if node.kind == :agent
              base[:via] = node.agent_name
              base[:message] = node.message_name
              base[:inputs] = node.input_mapping
              base[:timeout] = node.timeout
              base[:mode] = node.mode
              base[:routing_mode] = node.routing_mode
              base[:node] = node.node_url if node.routing_mode == :static
              base[:capability] = node.capability if node.capability
              base[:query] = node.capability_query if node.capability_query
              base[:pinned_to] = node.pinned_to if node.pinned_to
              base[:reply] = node.reply_mode
              base[:finalizer] = serialized_agent_finalizer(node.finalizer)
              base[:tool_loop_policy] = node.tool_loop_policy
              base[:session_policy] = node.session_policy
            end
            if node.kind == :branch
              base[:selector] = node.selector_dependency
              base[:depends_on] = node.context_dependencies if node.context_dependencies.any?
              base[:cases] = node.cases.map { |entry| serialized_branch_case(entry, contract_name: true) }
              base[:default_contract] = node.default_contract.name
              base[:inputs] = node.input_mapping
              base[:mapper] = node.input_mapper.to_s if node.input_mapper?
            end
            if node.kind == :collection
              base[:with] = node.source_dependency
              base[:depends_on] = node.context_dependencies if node.context_dependencies.any?
              base[:each] = node.contract_class.name
              base[:key] = node.key_name
              base[:mode] = node.mode
              base[:mapper] = node.input_mapper.to_s if node.input_mapper?
            end
            base[:event] = node.event_name if node.kind == :await
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

      def to_schema
        {
          name: name,
          inputs: nodes.select { |node| node.kind == :input }.map do |node|
            {
              name: node.name,
              type: node.type,
              required: node.required?,
              default: (node.default if node.default?),
              metadata: node.metadata.reject { |key, _| key == :source_location || key == :type || key == :required || key == :default }
            }.compact
          end,
          compositions: nodes.select { |node| node.kind == :composition }.map do |node|
            {
              name: node.name,
              contract: node.contract_class,
              inputs: node.input_mapping,
              metadata: node.metadata.reject { |key, _| key == :source_location }
            }
          end,
          awaits: nodes.select { |node| node.kind == :await }.map do |node|
            {
              name: node.name,
              event: node.event_name,
              metadata: node.metadata.reject { |key, _| key == :source_location }
            }
          end,
          agents: nodes.select { |node| node.kind == :agent }.map do |node|
            {
              name: node.name,
              via: node.agent_name,
              message: node.message_name,
              inputs: node.input_mapping,
              timeout: node.timeout,
              mode: node.mode,
              routing_mode: node.routing_mode,
              node: (node.node_url if node.routing_mode == :static),
              capability: node.capability,
              query: node.capability_query,
              pinned_to: node.pinned_to,
              reply: node.reply_mode,
              finalizer: serialized_agent_finalizer(node.finalizer),
              tool_loop_policy: node.tool_loop_policy,
              session_policy: node.session_policy,
              metadata: node.metadata.reject { |key, _| key == :source_location }
            }
          end,
          branches: nodes.select { |node| node.kind == :branch }.map do |node|
            {
              name: node.name,
              with: node.selector_dependency,
              depends_on: node.context_dependencies,
              inputs: node.input_mapping,
              map_inputs: (node.input_mapper if node.input_mapper?),
              cases: node.cases.map { |entry| serialized_branch_case(entry, contract_name: false) },
              default: node.default_contract,
              metadata: node.metadata.reject { |key, _| key == :source_location }
            }
          end,
          collections: nodes.select { |node| node.kind == :collection }.map do |node|
            {
              name: node.name,
              with: node.source_dependency,
              depends_on: node.context_dependencies,
              each: node.contract_class,
              key: node.key_name,
              mode: node.mode,
              map_inputs: (node.input_mapper if node.input_mapper?),
              metadata: node.metadata.reject { |key, _| key == :source_location }
            }
          end,
          computes: nodes.select { |node| node.kind == :compute }.map do |node|
            {
              name: node.name,
              depends_on: node.dependencies,
              executor: node.executor_key,
              call: (node.callable unless node.executor_key),
              metadata: node.metadata.reject { |key, _| %i[source_location executor_key].include?(key) }
            }.compact
          end,
          outputs: outputs.map do |output|
            {
              name: output.name,
              from: output.source,
              metadata: output.metadata.reject { |key, _| %i[source_location type].include?(key) }
            }.compact
          end
        }
      end

      def to_mermaid
        Extensions::Introspection::GraphFormatter.to_mermaid(self)
      end

      private

      def serialized_branch_case(entry, contract_name:)
        contract_value = contract_name ? entry[:contract].name : entry[:contract]

        case entry[:matcher]
        when :eq
          { on: entry[:value], contract: contract_value }
        when :in
          { in: entry[:value], contract: contract_value }
        when :matches
          value = contract_name ? entry[:value].inspect : entry[:value]
          { matches: value, contract: contract_value }
        else
          { matcher: entry[:matcher], value: entry[:value], contract: contract_value }
        end
      end

      def serialized_agent_finalizer(finalizer)
        return nil if finalizer.nil?
        return finalizer if finalizer.is_a?(Symbol)

        :proc
      end
    end
  end
end
