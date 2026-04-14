# frozen_string_literal: true

module Igniter
  module Runtime
    class Resolver
      def initialize(execution)
        @execution = execution
      end

      def resolve(node_name)
        node = @execution.compiled_graph.fetch_node(node_name)
        resolution_status, cached = @execution.cache.begin_resolution(node)
        return cached if resolution_status == :cached

        @execution.events.emit(:node_started, node: node, status: :running)

        state = case node.kind
                when :input
                  resolve_input(node)
                when :compute
                  resolve_compute(node)
                when :composition
                  resolve_composition(node)
                when :branch
                  resolve_branch(node)
                when :collection
                  resolve_collection(node)
                when :effect
                  resolve_effect(node)
                when :await
                  resolve_await(node)
                when :aggregate
                  resolve_aggregate(node)
                when :remote
                  resolve_remote(node)
                else
                  raise ResolutionError, "Unsupported node kind: #{node.kind}"
                end

        @execution.cache.write(state)
        emit_resolution_event(node, state)
        state
      rescue PendingDependencyError => e
        state = NodeState.new(
          node: node,
          status: :pending,
          value: Runtime::DeferredResult.build(
            token: e.deferred_result.token,
            payload: e.deferred_result.payload,
            source_node: e.deferred_result.source_node,
            waiting_on: e.deferred_result.waiting_on || node.name
          )
        )
        @execution.cache.write(state)
        @execution.events.emit(:node_pending, node: node, status: :pending, payload: pending_payload(state))
        state
      rescue StandardError => e
        state = NodeState.new(node: node, status: :failed, error: normalize_error(e, node))
        @execution.cache.write(state)
        @execution.events.emit(:node_failed, node: node, status: :failed, payload: { error: state.error.message })
        state
      end

      private

      def resolve_input(node)
        NodeState.new(node: node, status: :succeeded, value: @execution.fetch_input!(node.name))
      end

      def resolve_aggregate(node)
        unless defined?(Igniter::Dataflow)
          raise ResolutionError,
                "Aggregate nodes require the dataflow extension. " \
                "Add: require 'igniter/extensions/dataflow'"
        end

        collection_result = resolve_dependency_value(node.source_collection)
        unless collection_result.respond_to?(:diff)
          raise ResolutionError,
                "Aggregate '#{node.name}' requires an incremental collection. " \
                "Ensure '#{node.source_collection}' uses mode: :incremental"
        end

        agg_state = @execution.aggregate_state_for(node.name)
        agg_state.apply_diff!(collection_result.diff, collection_result)

        NodeState.new(node: node, status: :succeeded, value: agg_state.value)
      end

      def resolve_effect(node)
        dependencies = node.dependencies.each_with_object({}) do |dep, memo|
          memo[dep] = resolve_dependency_value(dep)
        end

        value = node.adapter_class.new(
          execution: @execution,
          contract: @execution.contract_instance
        ).call(**dependencies)

        NodeState.new(node: node, status: :succeeded, value: value)
      end

      def resolve_await(node)
        deferred = Runtime::DeferredResult.build(
          payload: { event: node.event_name },
          source_node: node.name,
          waiting_on: node.name
        )
        raise PendingDependencyError.new(deferred, "Waiting for external event '#{node.event_name}'")
      end

      def resolve_remote(node)
        inputs = node.input_mapping.each_with_object({}) do |(child_input, dep_name), memo|
          memo[child_input] = resolve_dependency_value(dep_name)
        end

        response = @execution.remote_adapter.call(
          node: node,
          inputs: inputs,
          execution: @execution
        )

        case response[:status]
        when :succeeded
          NodeState.new(node: node, status: :succeeded, value: response[:outputs])
        when :failed
          error_message = response.dig(:error, :message) || response.dig(:error, "message")
          raise ResolutionError, "Remote #{node.contract_name}: #{error_message}"
        else
          raise ResolutionError, "Remote #{node.contract_name}: unexpected status '#{response[:status]}'"
        end
      end

      def resolve_compute(node) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        # Capability policy check — raises CapabilityViolationError if denied.
        check_capability_policy!(node)

        # Running state preserves dep_snapshot + value_version from the stale state.
        # These are used for memoization (skip recompute) and value backdating.
        running_state = @execution.cache.fetch(node.name)
        old_dep_snapshot = running_state&.dep_snapshot
        old_value = running_state&.value
        old_value_version = running_state&.value_version || 0

        # Resolve all dependencies (may recursively recompute upstream nodes).
        dependencies = node.dependencies.each_with_object({}) do |dependency_name, memo|
          memo[dependency_name] = resolve_dependency_value(dependency_name)
        end

        # Build snapshot of current dep value_versions (only regular nodes, not outputs).
        current_dep_snapshot = build_dep_snapshot(node)

        # Memoization: if all dep value_versions are unchanged, skip the compute entirely.
        if old_dep_snapshot && old_value && old_value_version.positive? &&
           dep_snapshot_match?(current_dep_snapshot, old_dep_snapshot)
          @execution.events.emit(:node_skipped, node: node, status: :succeeded,
                                                payload: { reason: :deps_unchanged })
          return NodeState.new(node: node, status: :succeeded, value: old_value,
                               value_version: old_value_version,
                               dep_snapshot: current_dep_snapshot)
        end

        # Content-addressed cache: pure executor + same dep values → reuse across executions.
        if (content_key = build_content_key(node, dependencies))
          cached_value = Igniter::ContentAddressing.cache.fetch(content_key)
          if cached_value
            @execution.events.emit(:node_content_cache_hit, node: node, status: :succeeded,
                                                            payload: { key: content_key.to_s })
            return NodeState.new(node: node, status: :succeeded, value: cached_value,
                                 dep_snapshot: current_dep_snapshot)
          end
        end

        # TTL cache: any compute node + same dep fingerprint → reuse across executions.
        ttl_key             = build_ttl_cache_key(node, dependencies)
        is_coalescing_leader = false

        if ttl_key
          if (cached_value = Igniter::NodeCache.cache.fetch(ttl_key))
            @execution.events.emit(:node_ttl_cache_hit, node: node, status: :succeeded,
                                                        payload: { key: ttl_key.to_s })
            return NodeState.new(node: node, status: :succeeded, value: cached_value,
                                 dep_snapshot: current_dep_snapshot)
          end

          # Coalescing: if another execution is already computing this node for the same
          # inputs, join as a follower instead of duplicating the work.
          if node.coalesce? && (lock = Igniter::NodeCache.coalescing_lock)
            role, flight = lock.acquire(ttl_key.hex)
            if role == :follower
              coalesced_value, coalesced_error = lock.wait(flight)
              raise coalesced_error if coalesced_error

              # Follower timed out — coalesced_value is nil, fall through to compute independently
              unless coalesced_value.nil? && coalesced_error.nil? && !flight.done
                @execution.events.emit(:node_coalesced, node: node, status: :succeeded,
                                                        payload: { key: ttl_key.to_s })
                return NodeState.new(node: node, status: :succeeded, value: coalesced_value,
                                     dep_snapshot: current_dep_snapshot)
              end
            else
              is_coalescing_leader = true
            end
          end
        end

        value = call_compute(node.callable, dependencies)
        if deferred_result?(value)
          return NodeState.new(node: node, status: :pending,
                               value: normalize_deferred_result(value, node))
        end

        value = normalize_guard_value(node, value)

        # Value backdating: if the output is unchanged, preserve value_version so that
        # downstream nodes whose dep_snapshots reference this node won't see it as changed.
        if old_value && old_value_version.positive? && value == old_value
          @execution.events.emit(:node_backdated, node: node, status: :succeeded,
                                                  payload: { reason: :value_unchanged })
          store_ttl_result(ttl_key, value, node, is_coalescing_leader)
          return NodeState.new(node: node, status: :succeeded, value: value,
                               value_version: old_value_version,
                               dep_snapshot: current_dep_snapshot)
        end

        # Store in content cache for future executions.
        Igniter::ContentAddressing.cache.store(content_key, value) if content_key

        # Store in TTL cache and notify any coalescing followers.
        store_ttl_result(ttl_key, value, node, is_coalescing_leader)

        NodeState.new(node: node, status: :succeeded, value: value,
                      dep_snapshot: current_dep_snapshot)
      rescue StandardError => e
        # If this execution was the coalescing leader, notify followers of the failure
        # so they are unblocked (they will re-raise the error through their own path).
        Igniter::NodeCache.coalescing_lock&.finish!(ttl_key&.hex, error: e) if is_coalescing_leader
        raise
      end

      def call_compute(callable, dependencies)
        case callable
        when Proc
          callable.call(**dependencies)
        when Class
          call_compute_class(callable, dependencies)
        when Symbol, String
          @execution.contract_instance.public_send(callable.to_sym, **dependencies)
        else
          call_compute_object(callable, dependencies)
        end
      end

      def call_compute_class(callable, dependencies)
        if callable <= Igniter::Executor
          callable.new(execution: @execution, contract: @execution.contract_instance).call(**dependencies)
        elsif callable.respond_to?(:call)
          callable.call(**dependencies)
        else
          raise ResolutionError, "Unsupported callable: #{callable}"
        end
      end

      def call_compute_object(callable, dependencies)
        raise ResolutionError, "Unsupported callable: #{callable.class}" unless callable.respond_to?(:call)

        callable.call(**dependencies)
      end

      def resolve_composition(node)
        child_inputs = node.input_mapping.each_with_object({}) do |(child_input_name, dependency_name), memo|
          memo[child_input_name] = resolve_dependency_value(dependency_name)
        end

        child_contract = node.contract_class.new(child_inputs)
        child_contract.resolve_all
        child_error = child_contract.result.errors.values.first
        raise child_error if child_error

        NodeState.new(node: node, status: :succeeded, value: child_contract.result)
      end

      def resolve_branch(node)
        selector_value = resolve_dependency_value(node.selector_dependency)
        selected_case = node.match_case(selector_value)
        selected_contract = selected_case ? selected_case[:contract] : node.default_contract
        matched_case = selected_case ? node.case_payload(selected_case) : :default

        raise BranchSelectionError, "Branch '#{node.name}' has no matching case and no default" unless selected_contract

        context_values = node.context_dependencies.each_with_object({}) do |dependency_name, memo|
          memo[dependency_name] = resolve_dependency_value(dependency_name)
        end

        child_inputs = if node.input_mapper?
                         map_branch_inputs(node, selector_value, context_values)
                       else
                         node.input_mapping.each_with_object({}) do |(child_input_name, dependency_name), memo|
                           memo[child_input_name] = resolve_dependency_value(dependency_name)
                         end
                       end

        @execution.events.emit(
          :branch_selected,
          node: node,
          status: :succeeded,
          payload: {
            selector: node.selector_dependency,
            selector_value: selector_value,
            matcher: selected_case ? selected_case[:matcher] : :default,
            matched_case: matched_case,
            selected_contract: selected_contract.name || "AnonymousContract"
          }
        )

        child_contract = selected_contract.new(child_inputs)
        child_contract.resolve_all
        child_error = child_contract.result.errors.values.first
        raise child_error if child_error

        NodeState.new(node: node, status: :succeeded, value: child_contract.result)
      end

      def map_branch_inputs(node, selector_value, context_values)
        mapper = node.input_mapper

        if mapper.is_a?(Symbol) || mapper.is_a?(String)
          return @execution.contract_instance.public_send(mapper, selector: selector_value, **context_values)
        end

        mapper.call(selector: selector_value, **context_values)
      end

      def resolve_collection(node)
        return resolve_incremental_collection(node) if node.mode == :incremental

        items = resolve_dependency_value(node.source_dependency)
        context_values = node.context_dependencies.each_with_object({}) do |dependency_name, memo|
          memo[dependency_name] = resolve_dependency_value(dependency_name)
        end
        normalized_items = normalize_collection_items(node, items, context_values)
        collection_items = {}

        normalized_items.each do |item_inputs|
          item_key = extract_collection_key(node, item_inputs)
          emit_collection_item_event(:collection_item_started, node, item_key, item_inputs: item_inputs)
          child_contract = node.contract_class.new(item_inputs)
          begin
            child_contract.resolve_all
          rescue Igniter::Error
            nil
          end
          child_error = child_contract.execution.cache.values.find(&:failed?)&.error

          if child_error
            collection_items[item_key] = Runtime::CollectionResult::Item.new(
              key: item_key,
              status: :failed,
              error: child_error
            )
            emit_collection_item_event(
              :collection_item_failed,
              node,
              item_key,
              error: child_error.message,
              error_type: child_error.class.name,
              child_execution_id: child_contract.execution.events.execution_id
            )
            raise child_error if node.mode == :fail_fast
          else
            collection_items[item_key] = Runtime::CollectionResult::Item.new(
              key: item_key,
              status: :succeeded,
              result: child_contract.result
            )
            emit_collection_item_event(
              :collection_item_succeeded,
              node,
              item_key,
              child_execution_id: child_contract.execution.events.execution_id
            )
          end
        end

        NodeState.new(
          node: node,
          status: :succeeded,
          value: Runtime::CollectionResult.new(items: collection_items, mode: node.mode)
        )
      end

      def resolve_incremental_collection(node) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        unless defined?(Igniter::Dataflow)
          raise ResolutionError.new(
            "Collection '#{node.name}' uses mode: :incremental — " \
            "add `require 'igniter/extensions/dataflow'` to activate it",
            context: collection_context(node)
          )
        end

        items = resolve_dependency_value(node.source_dependency)
        context_values = node.context_dependencies.each_with_object({}) do |dep_name, memo|
          memo[dep_name] = resolve_dependency_value(dep_name)
        end

        normalized_items = normalize_collection_items(node, items, context_values)
        normalized_items = Igniter::Dataflow::WindowFilter.new(node.window).apply(normalized_items) if node.window

        diff_state = @execution.diff_state_for(node.name)
        key_fn     = ->(item) { extract_collection_key(node, item) }
        diff       = diff_state.compute_diff(normalized_items, key_fn)

        collection_items = {}

        # Reuse cached results for unchanged items (no child contract re-run)
        diff.unchanged.each do |key|
          cached = diff_state.cached_item_for(key)
          collection_items[key] = cached if cached
          emit_collection_item_event(:collection_item_reused, node, key)
        end

        # Retract removed items from the diff state
        diff.removed.each { |key| diff_state.retract!(key) }

        # Run child contracts only for added + changed items
        to_process = normalized_items.select { |item| diff.added.include?(key_fn.call(item)) || diff.changed.include?(key_fn.call(item)) }

        to_process.each do |item_inputs|
          item_key = key_fn.call(item_inputs)
          emit_collection_item_event(:collection_item_started, node, item_key, item_inputs: item_inputs)
          child_contract = node.contract_class.new(item_inputs)
          begin
            child_contract.resolve_all
          rescue Igniter::Error
            nil
          end
          child_error = child_contract.execution.cache.values.find(&:failed?)&.error

          result_item = if child_error
            emit_collection_item_event(:collection_item_failed, node, item_key, error: child_error.message, error_type: child_error.class.name, child_execution_id: child_contract.execution.events.execution_id)
            Runtime::CollectionResult::Item.new(key: item_key, status: :failed, error: child_error)
          else
            emit_collection_item_event(:collection_item_succeeded, node, item_key, child_execution_id: child_contract.execution.events.execution_id)
            Runtime::CollectionResult::Item.new(key: item_key, status: :succeeded, result: child_contract.result)
          end

          collection_items[item_key] = result_item
          diff_state.update!(item_key, item_inputs, result_item)
        end

        # Preserve the input array ordering in the result
        ordered_items = normalized_items.each_with_object({}) do |item_inputs, memo|
          key = key_fn.call(item_inputs)
          memo[key] = collection_items[key] if collection_items.key?(key)
        end

        NodeState.new(
          node: node,
          status: :succeeded,
          value: Igniter::Dataflow::IncrementalCollectionResult.new(items: ordered_items, diff: diff)
        )
      end

      def resolve_dependency_value(dependency_name)
        if @execution.compiled_graph.node?(dependency_name)
          dependency_state = resolve(dependency_name)
          raise dependency_state.error if dependency_state.failed?

          if dependency_state.pending?
            raise PendingDependencyError.new(dependency_state.value,
                                             context: pending_context(dependency_state.node))
          end

          dependency_state.value
        elsif @execution.compiled_graph.outputs_by_name.key?(dependency_name.to_sym)
          output = @execution.compiled_graph.fetch_output(dependency_name)
          value = @execution.send(:resolve_exported_output, output)
          raise PendingDependencyError, value if deferred_result?(value)

          value
        else
          raise ResolutionError, "Unknown dependency: #{dependency_name}"
        end
      end

      def deferred_result?(value)
        value.is_a?(Runtime::DeferredResult)
      end

      def normalize_deferred_result(value, node)
        Runtime::DeferredResult.build(
          token: value.token,
          payload: value.payload,
          source_node: value.source_node || node.name,
          waiting_on: value.waiting_on
        )
      end

      def emit_resolution_event(node, state)
        event_type =
          if state.failed?
            :node_failed
          elsif state.pending?
            :node_pending
          else
            :node_succeeded
          end

        payload = state.pending? ? pending_payload(state) : success_payload(node, state)
        @execution.events.emit(event_type, node: node, status: state.status, payload: payload)
      end

      def emit_collection_item_event(type, node, item_key, payload = {})
        @execution.events.emit(
          type,
          node: node,
          payload: payload.merge(item_key: item_key)
        )
      end

      def pending_payload(state)
        return {} unless state.value.is_a?(Runtime::DeferredResult)

        state.value.to_h
      end

      def pending_context(node)
        {
          graph: @execution.compiled_graph.name,
          node_id: node.id,
          node_name: node.name,
          node_path: node.path,
          source_location: node.source_location
        }
      end

      def success_payload(node, state)
        return {} unless %i[composition branch].include?(node.kind)
        return {} unless state.value.is_a?(Igniter::Runtime::Result)

        {
          child_execution_id: state.value.execution.events.execution_id,
          child_graph: state.value.execution.compiled_graph.name
        }
      end

      def normalize_error(error, node)
        # Trust any Igniter::Error that already carries node context.
        return error if error.is_a?(Igniter::Error) && error.node_name

        # Domain-specific subclasses (IncidentError, DeferredCapabilityError,
        # InvariantError, …) carry semantics the caller depends on — preserve
        # their type unchanged. Only bare Igniter::ResolutionError instances
        # (raised with just a message inside an executor) get enriched.
        return error if error.is_a?(Igniter::Error) && !error.instance_of?(Igniter::ResolutionError)

        node_context = {
          graph: @execution.compiled_graph.name,
          node_id: node.id,
          node_name: node.name,
          node_path: node.path,
          source_location: node.source_location,
          execution_id: @execution.events.execution_id
        }

        ResolutionError.new(error.message, context: node_context)
      end

      # ─── Capabilities ──────────────────────────────────────────────────────────

      def check_capability_policy!(node)
        return unless defined?(Igniter::Capabilities) && Igniter::Capabilities.policy
        return unless node.callable.is_a?(Class) && node.callable <= Igniter::Executor

        Igniter::Capabilities.policy.check!(node.name, node.callable)
      end

      # ─── Content addressing ────────────────────────────────────────────────────

      # Returns a ContentKey for pure executors when content addressing is loaded.
      # Returns nil for non-pure executors, Procs, or when the extension is absent.
      def build_content_key(node, dep_values)
        return unless defined?(Igniter::ContentAddressing)
        return unless node.callable.is_a?(Class) && node.callable <= Igniter::Executor
        return unless node.callable.pure?

        Igniter::ContentAddressing::ContentKey.compute(node.callable, dep_values)
      end

      # ─── TTL cache ─────────────────────────────────────────────────────────────

      # Returns a NodeCache::CacheKey when TTL caching is active for this node.
      # Returns nil when NodeCache is not loaded, no backend is configured,
      # or the node has no cache_ttl declared.
      def build_ttl_cache_key(node, dep_values)
        return unless defined?(Igniter::NodeCache)
        return unless Igniter::NodeCache.cache
        return unless node.respond_to?(:cache_ttl) && node.cache_ttl

        dep_hex = Igniter::NodeCache::Fingerprinter.call(dep_values)
        Igniter::NodeCache::CacheKey.new(
          @execution.compiled_graph.name,
          node.name,
          dep_hex
        )
      end

      # Stores a computed value in the TTL cache and signals any coalescing followers.
      def store_ttl_result(ttl_key, value, node, is_leader)
        return unless ttl_key

        Igniter::NodeCache.cache.store(ttl_key, value, ttl: node.cache_ttl)
        Igniter::NodeCache.coalescing_lock&.finish!(ttl_key.hex, value: value) if is_leader
      end

      def build_dep_snapshot(node)
        node.dependencies.each_with_object({}) do |dep_name, memo|
          next unless @execution.compiled_graph.node?(dep_name)

          dep_state = @execution.cache.fetch(dep_name.to_sym)
          memo[dep_name] = dep_state&.value_version
        end
      end

      def dep_snapshot_match?(current, old)
        return false if current.size != old.size

        current.all? { |name, vv| old[name] == vv }
      end

      def normalize_guard_value(node, value)
        return value unless node.respond_to?(:guard?) && node.guard?
        return true if value

        raise ResolutionError.new(
          node.metadata[:guard_message] || "Guard '#{node.name}' failed",
          context: {
            graph: @execution.compiled_graph.name,
            node_id: node.id,
            node_name: node.name,
            node_path: node.path,
            source_location: node.source_location
          }
        )
      end

      def normalize_collection_items(node, items, context_values = {})
        items = items.to_a if node.input_mapper? && items.is_a?(Hash)

        unless items.is_a?(Array)
          raise CollectionInputError.new(
            "Collection '#{node.name}' expects an array, got #{items.class}",
            context: collection_context(node)
          )
        end

        mapped_items = if node.input_mapper?
                         items.map { |item| map_collection_item_inputs(node, item, context_values) }
                       else
                         items
                       end

        mapped_items.each do |item|
          next if item.is_a?(Hash)

          raise CollectionInputError.new(
            "Collection '#{node.name}' expects item hashes, got #{item.class}",
            context: collection_context(node)
          )
        end

        ensure_unique_collection_keys!(node, mapped_items)
        mapped_items.map { |item| item.transform_keys(&:to_sym) }
      end

      def map_collection_item_inputs(node, item, context_values)
        mapper = node.input_mapper

        if mapper.is_a?(Symbol) || mapper.is_a?(String)
          return @execution.contract_instance.public_send(mapper, item: item, **context_values)
        end

        mapper.call(item: item, **context_values)
      end

      def extract_collection_key(node, item_inputs)
        item_inputs.fetch(node.key_name)
      rescue KeyError
        raise CollectionKeyError.new(
          "Collection '#{node.name}' item is missing key '#{node.key_name}'",
          context: collection_context(node)
        )
      end

      def ensure_unique_collection_keys!(node, items)
        keys = items.map do |item|
          item.fetch(node.key_name) do
            raise CollectionKeyError.new("Collection '#{node.name}' item is missing key '#{node.key_name}'",
                                         context: collection_context(node))
          end
        end

        duplicates = keys.group_by(&:itself).select { |_key, entries| entries.size > 1 }.keys
        return if duplicates.empty?

        raise CollectionKeyError.new(
          "Collection '#{node.name}' has duplicate keys: #{duplicates.join(", ")}",
          context: collection_context(node)
        )
      end

      def collection_context(node)
        {
          graph: @execution.compiled_graph.name,
          node_id: node.id,
          node_name: node.name,
          node_path: node.path,
          source_location: node.source_location
        }
      end
    end
  end
end
