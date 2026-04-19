# frozen_string_literal: true

module Igniter
  module DSL
    class ContractBuilder
      def self.compile(name: "AnonymousContract", correlation_keys: [], &block)
        new(name: name, correlation_keys: correlation_keys).tap { |builder| builder.instance_eval(&block) }.compile
      end

      def initialize(name:, correlation_keys: [])
        @name = name
        @correlation_keys = correlation_keys
        @nodes = []
        @sequence = 0
        @scope_stack = []
      end

      UNDEFINED_INPUT_DEFAULT = :__igniter_undefined__
      UNDEFINED_CONST_VALUE = :__igniter_const_undefined__
      UNDEFINED_GUARD_MATCHER = :__igniter_guard_matcher_undefined__
      UNDEFINED_PROJECT_OPTION = :__igniter_project_undefined__

      def input(name, type: nil, required: nil, default: UNDEFINED_INPUT_DEFAULT, **metadata)
        input_metadata = with_source_location(metadata)
        input_metadata[:type] = type if type
        input_metadata[:required] = required unless required.nil?
        input_metadata[:default] = default unless default == UNDEFINED_INPUT_DEFAULT

        add_node(
          Model::InputNode.new(
            id: next_id,
            name: name,
            path: scoped_path(name),
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
            path: scoped_path(name),
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

      def project(name, from:, key: UNDEFINED_PROJECT_OPTION, dig: UNDEFINED_PROJECT_OPTION, default: UNDEFINED_PROJECT_OPTION, **metadata)
        if key != UNDEFINED_PROJECT_OPTION && dig != UNDEFINED_PROJECT_OPTION
          raise CompileError, "project :#{name} cannot use both `key:` and `dig:`"
        end

        if key == UNDEFINED_PROJECT_OPTION && dig == UNDEFINED_PROJECT_OPTION
          raise CompileError, "project :#{name} requires either `key:` or `dig:`"
        end

        callable = proc do |**values|
          source = values.fetch(from.to_sym)
          extract_projected_value(
            source,
            key: key,
            dig: dig,
            default: default,
            node_name: name
          )
        end

        compute(name, with: from, call: callable, **{ category: :project }.merge(metadata))
      end

      def guard(name, depends_on: nil, with: nil, call: nil, executor: nil, message: nil,
                eq: UNDEFINED_GUARD_MATCHER, in: UNDEFINED_GUARD_MATCHER, matches: UNDEFINED_GUARD_MATCHER,
                **metadata, &block)
        matcher_options = {
          eq: eq,
          in: binding.local_variable_get(:in),
          matches: matches
        }.reject { |_key, value| value == UNDEFINED_GUARD_MATCHER }

        if matcher_options.any?
          raise CompileError, "guard :#{name} cannot combine matcher options with `call:`, `executor:`, or a block" if call || executor || block
          raise CompileError, "guard :#{name} supports only one matcher option at a time" if matcher_options.size > 1

          dependencies = normalize_dependencies(depends_on: depends_on, with: with)
          raise CompileError, "guard :#{name} with matcher options requires exactly one dependency" unless dependencies.size == 1

          dependency = dependencies.first
          matcher_name, matcher_value = matcher_options.first

          call = build_guard_matcher(matcher_name, matcher_value, dependency)
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

      def scope(name, &block)
        raise CompileError, "scope requires a block" unless block

        @scope_stack << name.to_s
        instance_eval(&block)
      ensure
        @scope_stack.pop
      end

      alias namespace scope

      def output(name, from: nil, **metadata)
        add_node(
          Model::OutputNode.new(
            id: next_id,
            name: name,
            source: (from || name),
            path: scoped_output_path(name),
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
            path: scoped_path(name),
            metadata: with_source_location(metadata)
          )
        )
      end

      def branch(name, with:, inputs: nil, depends_on: nil, map_inputs: nil, using: nil, **metadata, &block)
        raise CompileError, "branch :#{name} requires a block" unless block
        raise CompileError, "branch :#{name} requires either `inputs:` or `map_inputs:`/`using:`" if inputs.nil? && map_inputs.nil? && using.nil?
        raise CompileError, "branch :#{name} cannot combine `inputs:` with `map_inputs:` or `using:`" if inputs && (map_inputs || using)
        raise CompileError, "branch :#{name} cannot use both `map_inputs:` and `using:`" if map_inputs && using
        raise CompileError, "branch :#{name} requires an `inputs:` hash" if inputs && !inputs.is_a?(Hash)

        definition = BranchBuilder.build(&block)

        add_node(
          Model::BranchNode.new(
            id: next_id,
            name: name,
            selector_dependency: with,
            cases: definition[:cases],
            default_contract: definition[:default_contract],
            input_mapping: inputs || {},
            context_dependencies: normalize_dependencies(depends_on: depends_on, with: nil),
            input_mapper: map_inputs || using,
            path: scoped_path(name),
            metadata: with_source_location(metadata)
          )
        )
      end

      def collection(name, with:, each:, key:, mode: :collect, window: nil, depends_on: nil, map_inputs: nil, using: nil, **metadata)
        raise CompileError, "collection :#{name} cannot use both `map_inputs:` and `using:`" if map_inputs && using

        add_node(
          Model::CollectionNode.new(
            id: next_id,
            name: name,
            source_dependency: with,
            contract_class: each,
            key_name: key,
            mode: mode,
            window: window,
            context_dependencies: normalize_dependencies(depends_on: depends_on, with: nil),
            input_mapper: map_inputs || using,
            path: scoped_path(name),
            metadata: with_source_location(metadata)
          )
        )
      end

      # Declares a maintained aggregate over an incremental collection node.
      #
      # The aggregate updates in O(change) time: only added/changed/removed items
      # affect the result; unchanged items contribute zero work.
      #
      # @param name        [Symbol]  output name
      # @param from        [Symbol]  name of an upstream incremental collection node
      # @param count       [Proc, nil]  ->(item) { bool } — count items matching predicate (nil = count all)
      # @param sum         [Proc, nil]  ->(item) { numeric }
      # @param avg         [Proc, nil]  ->(item) { numeric }
      # @param min         [Proc, nil]  ->(item) { numeric }  (O(n) on removal)
      # @param max         [Proc, nil]  ->(item) { numeric }  (O(n) on removal)
      # @param group_count [Proc, nil]  ->(item) { group_key } — Hash{key => count}
      # @param initial     [Object, nil]  initial accumulator for custom aggregates
      # @param add         [Proc, nil]  ->(acc, item) { new_acc } — custom add
      # @param remove      [Proc, nil]  ->(acc, item) { new_acc } — custom remove
      #
      # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
      def aggregate(name, from:, count: nil, sum: nil, avg: nil, min: nil, max: nil,
                    group_count: nil, initial: nil, add: nil, remove: nil, **metadata)
        # rubocop:enable Metrics/ParameterLists, Metrics/MethodLength
        operator = build_aggregate_operator(
          count: count, sum: sum, avg: avg, min: min, max: max,
          group_count: group_count, initial: initial, add: add, remove: remove
        )
        add_node(
          Model::AggregateNode.new(
            id: next_id,
            name: name,
            source_collection: from,
            operator: operator,
            path: scoped_path(name),
            metadata: with_source_location(metadata)
          )
        )
      end

      def remote(name, contract:, inputs:, node: nil, timeout: 30, # rubocop:disable Metrics/MethodLength,Metrics/ParameterLists,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
                 capability: nil, query: nil, trust: nil, governance: nil, policy: nil, decision: nil, pinned_to: nil, **metadata)
        raise CompileError, "remote :#{name} requires inputs: Hash" unless inputs.is_a?(Hash)
        raise CompileError, "remote :#{name} requires a contract: name" if contract.nil? || contract.to_s.strip.empty?

        if [capability, query, pinned_to].count { |value| !value.nil? } > 1
          raise CompileError, "remote :#{name}: capability:, query:, and pinned_to: are mutually exclusive"
        end

        if trust && pinned_to
          raise CompileError, "remote :#{name}: trust: cannot be combined with pinned_to:"
        end

        if governance && pinned_to
          raise CompileError, "remote :#{name}: governance: cannot be combined with pinned_to:"
        end

        if policy && pinned_to
          raise CompileError, "remote :#{name}: policy: cannot be combined with pinned_to:"
        end

        if decision && pinned_to
          raise CompileError, "remote :#{name}: decision: cannot be combined with pinned_to:"
        end

        if trust && capability.nil? && query.nil?
          raise CompileError, "remote :#{name}: trust: requires capability: or query:"
        end

        if governance && capability.nil? && query.nil?
          raise CompileError, "remote :#{name}: governance: requires capability: or query:"
        end

        if policy && capability.nil? && query.nil?
          raise CompileError, "remote :#{name}: policy: requires capability: or query:"
        end

        if decision && capability.nil? && query.nil?
          raise CompileError, "remote :#{name}: decision: requires capability: or query:"
        end

        if trust && query.is_a?(Hash) && query.key?(:trust)
          raise CompileError, "remote :#{name}: trust: duplicates query[:trust]"
        end

        if governance && query.is_a?(Hash) && query.key?(:governance)
          raise CompileError, "remote :#{name}: governance: duplicates query[:governance]"
        end

        if policy && query.is_a?(Hash) && query.key?(:policy)
          raise CompileError, "remote :#{name}: policy: duplicates query[:policy]"
        end

        if decision && query.is_a?(Hash) && query.key?(:decision)
          raise CompileError, "remote :#{name}: decision: duplicates query[:decision]"
        end

        if capability.nil? && query.nil? && pinned_to.nil? && (node.nil? || node.to_s.strip.empty?)
          raise CompileError, "remote :#{name} requires a node: URL"
        end

        capability_query =
          if trust || governance || policy || decision
            base_query = query ? query.dup : { all_of: [capability] }
            base_query[:trust] = trust if trust
            base_query[:governance] = governance if governance
            base_query[:policy] = policy if policy
            base_query[:decision] = decision if decision
            base_query
          else
            query
          end

        add_node(
          Model::RemoteNode.new(
            id: next_id,
            name: name.to_sym,
            contract_name: contract.to_s,
            node_url: node.to_s,
            input_mapping: inputs,
            timeout: timeout,
            capability: (trust || governance || policy || decision) ? nil : capability,
            capability_query: capability_query,
            pinned_to: pinned_to,
            path: scoped_path(name),
            metadata: with_source_location(metadata)
          )
        )
      end

      def agent(name, via:, message:, inputs:, timeout: 5, mode: :call, reply: nil, **metadata)
        normalized_mode = mode.respond_to?(:to_sym) ? mode.to_sym : mode
        normalized_reply = reply.respond_to?(:to_sym) ? reply.to_sym : reply

        raise CompileError, "agent :#{name} requires inputs: Hash" unless inputs.is_a?(Hash)
        raise CompileError, "agent :#{name} requires via:" if via.nil? || via.to_s.strip.empty?
        raise CompileError, "agent :#{name} requires message:" if message.nil? || message.to_s.strip.empty?
        raise CompileError, "agent :#{name} timeout must be positive" unless timeout.to_f.positive?
        raise CompileError, "agent :#{name} mode must be :call or :cast" unless %i[call cast].include?(normalized_mode)
        unless normalized_reply.nil? || %i[single deferred stream none].include?(normalized_reply)
          raise CompileError, "agent :#{name} reply must be :single, :deferred, :stream, or :none"
        end
        if normalized_mode == :cast && !normalized_reply.nil? && normalized_reply != :none
          raise CompileError, "agent :#{name} mode :cast only supports reply: :none"
        end
        if normalized_mode == :call && normalized_reply == :none
          raise CompileError, "agent :#{name} mode :call cannot use reply: :none"
        end

        add_node(
          Model::AgentNode.new(
            id: next_id,
            name: name.to_sym,
            agent_name: via,
            message_name: message,
            input_mapping: inputs,
            timeout: timeout,
            mode: normalized_mode,
            reply_mode: normalized_reply,
            path: scoped_path(name),
            metadata: with_source_location(metadata)
          )
        )
      end

      def effect(name, uses:, depends_on: nil, with: nil, **metadata)
        adapter_class = resolve_effect_adapter(name, uses)

        add_node(
          Model::EffectNode.new(
            id: next_id,
            name: name,
            dependencies: normalize_dependencies(depends_on: depends_on, with: with),
            adapter_class: adapter_class,
            path: scoped_path(name),
            metadata: with_source_location(metadata)
          )
        )
      end

      def await(name, event:, **metadata)
        add_node(
          Model::AwaitNode.new(
            id: next_id,
            name: name.to_sym,
            path: scoped_path(name),
            event_name: event,
            metadata: with_source_location(metadata)
          )
        )
      end

      def compile
        Compiler::GraphCompiler.call(
          Model::Graph.new(
            name: @name,
            nodes: @nodes,
            metadata: { correlation_keys: @correlation_keys || [] }
          )
        )
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

      def resolve_effect_adapter(name, uses)
        case uses
        when Symbol, String
          Igniter.effect_registry.fetch(uses.to_sym).adapter_class
        when Class
          unless uses <= Igniter::Effect
            raise CompileError,
                  "effect :#{name} `uses:` must be an Igniter::Effect subclass or a registered effect name"
          end

          uses
        else
          raise CompileError,
                "effect :#{name} `uses:` must be an Igniter::Effect subclass or a registered effect name"
        end
      end

      def build_guard_matcher(matcher_name, matcher_value, dependency)
        case matcher_name
        when :eq
          proc do |**values|
            values.fetch(dependency) == matcher_value
          end
        when :in
          allowed_values = Array(matcher_value)
          proc do |**values|
            allowed_values.include?(values.fetch(dependency))
          end
        when :matches
          matcher = matcher_value
          raise CompileError, "`matches:` expects a Regexp" unless matcher.is_a?(Regexp)

          proc do |**values|
            values.fetch(dependency).to_s.match?(matcher)
          end
        else
          raise CompileError, "Unsupported guard matcher: #{matcher_name}"
        end
      end

      def extract_projected_value(source, key:, dig:, default:, node_name:)
        if key != UNDEFINED_PROJECT_OPTION
          return fetch_project_value(source, key, default, node_name)
        end

        current = source
        Array(dig).each do |part|
          current = fetch_project_value(current, part, default, node_name)
        end
        current
      end

      def fetch_project_value(source, part, default, node_name)
        if source.is_a?(Hash)
          return source.fetch(part) if source.key?(part)
          return source.fetch(part.to_s) if source.key?(part.to_s)
          return source.fetch(part.to_sym) if source.key?(part.to_sym)
        elsif source.respond_to?(part)
          return source.public_send(part)
        end

        return default unless default == UNDEFINED_PROJECT_OPTION

        raise ResolutionError, "project :#{node_name} could not extract #{part.inspect}"
      end

      def scoped_path(name)
        return name.to_s if @scope_stack.empty?

        "#{@scope_stack.join('.')}.#{name}"
      end

      def scoped_output_path(name)
        return "output.#{name}" if @scope_stack.empty?

        "#{@scope_stack.join('.')}.output.#{name}"
      end

      # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def build_aggregate_operator(count:, sum:, avg:, min:, max:, group_count:, initial:, add:, remove:)
        if add && remove
          Dataflow::AggregateOperators.custom(initial: initial || 0, add: add, remove: remove)
        elsif sum
          Dataflow::AggregateOperators.sum(projection: sum)
        elsif avg
          Dataflow::AggregateOperators.avg(projection: avg)
        elsif min
          Dataflow::AggregateOperators.min(projection: min)
        elsif max
          Dataflow::AggregateOperators.max(projection: max)
        elsif group_count
          Dataflow::AggregateOperators.group_count(projection: group_count)
        else
          Dataflow::AggregateOperators.count(filter: count)
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      class BranchBuilder
        UNDEFINED_BRANCH_MATCHER = :__igniter_branch_matcher_undefined__

        def self.build(&block)
          new.tap { |builder| builder.instance_eval(&block) }.to_h
        end

        def initialize
          @cases = []
          @default_contract = nil
        end

        def on(match = UNDEFINED_BRANCH_MATCHER, contract:, eq: UNDEFINED_BRANCH_MATCHER, in: UNDEFINED_BRANCH_MATCHER, matches: UNDEFINED_BRANCH_MATCHER) # rubocop:disable Metrics/ParameterLists
          matcher_options = {
            eq: eq,
            in: binding.local_variable_get(:in),
            matches: matches
          }.reject { |_key, value| value == UNDEFINED_BRANCH_MATCHER }

          if match != UNDEFINED_BRANCH_MATCHER && matcher_options.any?
            raise CompileError, "branch `on` cannot combine a positional match with `eq:`, `in:`, or `matches:`"
          end

          if match == UNDEFINED_BRANCH_MATCHER && matcher_options.empty?
            raise CompileError, "branch `on` requires a positional match or one of `eq:`, `in:`, or `matches:`"
          end

          if matcher_options.size > 1
            raise CompileError, "branch `on` supports only one matcher option at a time"
          end

          matcher, value =
            if match != UNDEFINED_BRANCH_MATCHER
              [:eq, match]
            else
              matcher_options.first
            end

          @cases << { matcher: matcher, value: value, contract: contract }
        end

        def default(contract:)
          raise CompileError, "branch can define only one `default`" if @default_contract

          @default_contract = contract
        end

        def to_h
          {
            cases: @cases,
            default_contract: @default_contract
          }
        end
      end
    end
  end
end
