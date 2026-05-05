# frozen_string_literal: true

require "igniter/ledger"
require "igniter-ledger-client"

module Igniter
  module DurableModel
    # Application-level store that wraps Igniter::Ledger::LedgerStore.
    #
    # Provides typed read/write/scope/append/replay via Record and History schema classes.
    # Acts as the "user side" pressure on igniter-ledger primitives.
    #
    # Usage:
    #   store = Igniter::DurableModel::Store.new                       # in-memory
    #   store = Igniter::DurableModel::Store.new(backend: :file, path: "/tmp/data.wal")
    #   store = Igniter::DurableModel::Store.new(                      # remote server
    #     backend:   :network,
    #     address:   "127.0.0.1:7400",
    #     transport: :tcp    # default; or :unix for Unix domain sockets
    #   )
    #   store = Igniter::DurableModel::Store.new(client: ledger_client) # preferred remote boundary
    #
    #   store.register(Reminder)
    #   store.write(Reminder, key: "r1", title: "Buy milk", status: :open)
    #   store.read(Reminder, key: "r1")
    #   store.scope(Reminder, :open)
    #   store.append(TrackerLog, tracker_id: "t1", value: 8.5)
    #   store.replay(TrackerLog)
    class Store
      def initialize(backend: :memory, path: nil, address: nil, transport: :tcp, client: nil)
        @registered     = Set.new
        @schema_by_store = {}
        @relations_by_name = {}
        @projections_by_name = {}
        if client
          raise ArgumentError, "client: cannot be combined with backend/path/address/transport options" if backend != :memory || path || address || transport != :tcp

          @inner = ClientAdapter.new(client)
          return
        end

        @inner = case backend
        when :memory
          Igniter::Ledger::LedgerStore.new
        when :file
          Igniter::Ledger::LedgerStore.open(path)
        when :network
          if Igniter::Store::NATIVE
            raise NotImplementedError,
                  ":network backend requires the pure-Ruby fallback (NATIVE=false). " \
                  "Rust-native wire deserialisation is planned for Phase 2."
          end
          raise ArgumentError, "address: is required for :network backend" unless address
          nb    = Igniter::Store::NetworkBackend.new(address: address, transport: transport)
          store = Igniter::Ledger::LedgerStore.new(backend: nb)
          nb.replay.each { |fact| store.__send__(:replay, fact) }
          store
        else
          raise ArgumentError, "Unknown backend: #{backend.inspect}. Use :memory, :file, or :network"
        end
      end

      # Register a Record schema — sets up AccessPaths for all declared scopes
      # and auto-wires one_to_many relations with a join key as materialized
      # scatter indexes.  Idempotent: calling register twice with the same class
      # is a no-op.
      #
      # Auto-wire criteria for a declared relation:
      #   cardinality: :one_to_many  AND  join present  AND
      #   kind: :event_owner or :ownership
      def register(schema_class)
        return self if @registered.include?(schema_class)

        @registered << schema_class
        @schema_by_store[schema_class.store_name] = schema_class

        if schema_class.respond_to?(:_scopes) && !client_backed?
          schema_class._scopes.each do |scope_name, opts|
            @inner.register_path(
              Igniter::Store::AccessPath.new(
                store:     schema_class.store_name,
                lookup:    :primary_key,
                scope:     scope_name,
                filters:   opts[:filters],
                cache_ttl: opts[:cache_ttl],
                consumers: []
              )
            )
          end
        end

        if schema_class.respond_to?(:_relations)
          schema_class._relations.each do |rel_name, attrs|
            next unless attrs[:cardinality] == :one_to_many
            next if attrs[:join].nil? || attrs[:join].empty?
            next unless %i[event_owner ownership].include?(attrs[:kind])

            partition = attrs[:join].values.first
            next unless partition

            register_relation(rel_name,
              source: attrs[:to],
              partition: partition,
              target: schema_class.store_name
            )
          end
        end

        # Emit protocol descriptor for OP1/OP2 visibility.
        # Access paths are registered via direct API (to preserve filter semantics);
        # store/history descriptors go through the protocol surface so that
        # metadata_snapshot[:stores] / metadata_snapshot[:histories] reflect all
        # durable-model-managed schemas.
        emit_companion_descriptor(schema_class)

        self
      end

      # Subscribe a callable to scope-level changes.
      # The callable receives (store_name, scope_name) when facts in the store change.
      def on_scope(schema_class, scope_name, &block)
        raise ArgumentError, "on_scope requires a block" unless block

        if client_backed?
          scope_opts = schema_class._scopes[scope_name]
          unless scope_opts
            raise ArgumentError,
                  "No registered scope=#{scope_name.inspect} for store=#{schema_class.store_name.inspect}"
          end

          return @inner.subscribe(stores: [schema_class.store_name]) do |_event|
            block.call(schema_class.store_name, scope(schema_class, scope_name))
          end
        end

        scope_opts = schema_class._scopes[scope_name] || {}
        @inner.register_path(
          Igniter::Store::AccessPath.new(
            store:     schema_class.store_name,
            lookup:    :primary_key,
            scope:     scope_name,
            filters:   scope_opts[:filters],
            cache_ttl: scope_opts[:cache_ttl],
            consumers: [block]
          )
        )
        self
      end

      # Write (upsert) a record. Returns a WriteReceipt wrapping the typed record.
      # Receipt delegates unknown methods to the record, so callers can use it
      # as if it were the record directly (e.g. receipt.title).
      # Also registers schema_class in the schema registry so that resolve
      # returns typed instances without requiring an explicit register call.
      def write(schema_class, key:, **fields)
        @schema_by_store[schema_class.store_name] ||= schema_class
        result = @inner.write(store: schema_class.store_name, key: key, value: fields)
        record = schema_class.new(key: key, **fields)
        WriteReceipt.new(
          mutation_intent: :record_write,
          fact_id:         result_fact_id(result),
          value_hash:      result_value_hash(result),
          causation:       result_causation(result),
          key:             result_key(result, fallback: key),
          record:          record
        )
      end

      # Read the latest value for a key. Returns nil if not found.
      def read(schema_class, key:, as_of: nil)
        result = @inner.read(store: schema_class.store_name, key: key, as_of: as_of)
        return nil if result.respond_to?(:found?) && !result.found?

        value = result.respond_to?(:value) ? result.value : result
        return nil unless value

        schema_class.new(key: key, **value)
      end

      # Query all records matching a registered scope.
      def scope(schema_class, scope_name, as_of: nil)
        if client_backed?
          scope_opts = schema_class._scopes[scope_name]
          unless scope_opts
            raise ArgumentError,
                  "No registered scope=#{scope_name.inspect} for store=#{schema_class.store_name.inspect}"
          end

          result = @inner.query(
            store: schema_class.store_name,
            where: scope_opts[:filters] || {},
            as_of: as_of
          )
          return result.items.map { |item| schema_class.new(key: item[:key], **item[:value]) }
        end

        facts = @inner.query(store: schema_class.store_name, scope: scope_name, as_of: as_of)
        facts.map { |f| schema_class.from_fact(f) }
      end

      # Append an event to a History stream. Returns an AppendReceipt.
      # Receipt delegates unknown methods to the event (e.g. receipt.value).
      def append(history_class, **fields)
        pk    = history_class._partition_key
        result = @inner.append(history: history_class.store_name, event: fields, partition_key: pk)
        event = history_class.new(fact_id: result_fact_id(result), timestamp: result_timestamp(result), **fields)
        AppendReceipt.new(
          mutation_intent: :history_append,
          fact_id:         result_fact_id(result),
          value_hash:      result_value_hash(result),
          timestamp:       result_timestamp(result),
          event:           event
        )
      end

      # Replay events from a History stream.
      # `partition:` filters by the declared partition_key value (e.g. tracker_id: "sleep").
      # `since:` / `as_of:` are timestamp boundaries.
      def replay(history_class, since: nil, as_of: nil, partition: nil)
        pk    = history_class._partition_key
        facts = if partition && pk
          @inner.history_partition(
            store:           history_class.store_name,
            partition_key:   pk,
            partition_value: partition,
            since:           since,
            as_of:           as_of
          )
        else
          @inner.history(store: history_class.store_name, since: since, as_of: as_of)
        end

        facts.map { |f| history_class.from_fact(f) }
      end

      # Declare a named cross-store relation at the Durable Model level.
      # +source+ may be a schema class (store_name is used) or a Symbol.
      # +target+ may be a schema class or Symbol — informational only.
      def register_relation(name, source:, partition:, target:)
        src = source.respond_to?(:store_name) ? source.store_name : source.to_sym
        tgt = target.respond_to?(:store_name) ? target.store_name : target.to_sym
        rel = {
          source: src,
          partition: partition.to_sym,
          target: tgt,
          index_store: :"__rel_#{name}"
        }
        @relations_by_name[name.to_sym] = rel

        if client_backed?
          @inner.register_descriptor(
            schema_version: 1,
            kind:           :relation,
            name:           name,
            from:           { store: tgt, key: :id },
            to:             { store: src, field: partition },
            cardinality:    :many
          )
          return self
        end

        @inner.register_relation(name, source: src, partition: partition, target: tgt)
        self
      end

      # Resolve a named relation for a given partition value.
      # Returns typed Record instances when the source schema class is known
      # (registered via register() or written via write()); otherwise returns
      # raw value Hashes (backward compatible).
      # Returns [] when nothing is indexed for the given partition value.
      #
      # as_of: Float timestamp — when given, reads the index state AND each
      # source value at that point in time (consistent point-in-time snapshot).
      def resolve(relation_name, from:, as_of: nil)
        if client_backed?
          relation = @relations_by_name[relation_name.to_sym]
          raise ArgumentError, "No relation registered: #{relation_name.inspect}" unless relation

          result = @inner.resolve(relation: relation_name, from: from, as_of: as_of)
          source_class = @schema_by_store[relation[:source]]
          return result.results unless source_class

          return result.items.map { |item| source_class.new(key: item[:key], **item[:value]) } if result.items.any?

          if result.results.any? && result.results.all? { |value| value.is_a?(Hash) && value.key?(:id) }
            return result.results.map { |value| source_class.new(key: value[:id], **value) }
          end

          return result.results
        end

        rule = @inner.schema_graph.relation_for(name: relation_name)
        raise ArgumentError, "No relation registered: #{relation_name.inspect}" unless rule

        index_entry = @inner.read(store: :"__rel_#{relation_name}", key: from.to_s, as_of: as_of)
        return [] unless index_entry

        source_class = @schema_by_store[rule.source]

        index_entry[:keys].filter_map do |key|
          value = @inner.read(store: rule.source, key: key, as_of: as_of)
          next unless value
          source_class ? source_class.new(key: key, **value) : value
        end
      end

      # Returns a compact snapshot of all registered relation rules.
      def _relations
        return @relations_by_name.dup if client_backed?

        @inner.schema_graph.relation_snapshot
      end

      # Register a scatter derivation rule at the Durable Model level.
      # Delegates to IgniterStore#register_scatter.  See that method for full semantics.
      # +source_schema+ may be a schema class (its store_name is used) or a Symbol.
      # +target_store+ is always a Symbol (the raw store name for the index).
      def register_scatter(source_schema, partition_by:, target_store:, rule:)
        raise unsupported_client_mode!("scatter registration") if client_backed?

        source = source_schema.respond_to?(:store_name) ? source_schema.store_name : source_schema.to_sym
        @inner.register_scatter(
          source_store: source,
          partition_by: partition_by,
          target_store: target_store,
          rule:         rule
        )
        self
      end

      # Returns a compact snapshot of all registered scatter rules.
      def _scatters
        return normalize_scatter_snapshot(metadata_snapshot[:scatters]) if client_backed?

        @inner.schema_graph.scatter_snapshot
      end

      # Returns command descriptors grouped by owning Record store.
      # Metadata-only: commands remain app-boundary behavior contracts.
      def _commands
        return normalize_command_snapshot(metadata_snapshot[:commands]) if client_backed?

        @inner.schema_graph.command_snapshot
      end

      # Returns derived persistence effect descriptors grouped by owning Record store.
      # Metadata-only: Ledger stores intent descriptors but does not execute app code.
      def _effects
        return normalize_effect_snapshot(metadata_snapshot[:effects]) if client_backed?

        @inner.schema_graph.effect_snapshot
      end

      # Build a pure app-boundary command intent from Record command metadata.
      # This does not execute commands, write facts, append history, or touch Ledger.
      def command_intent(schema_class, command_name, key: nil, params: {}, metadata: {})
        command_key = command_name.to_sym
        command_attrs = command_attrs_for(schema_class, command_key)
        effect_attrs = effect_attrs_for(schema_class, command_key)
        operation = token(command_attrs[:operation] || :none)

        if operation == :record_update && key.nil?
          raise ArgumentError,
                "command_intent requires key: for record_update command=#{command_key.inspect}"
        end

        CommandIntent.new(
          owner: schema_class.store_name,
          command: command_key,
          subject_key: key,
          operation: operation,
          target_shape: command_attrs[:target_shape] || target_shape_for(operation),
          effect: intent_effect(effect_attrs),
          boundary: command_attrs[:boundary] || effect_attrs[:boundary] || :app,
          changes: command_attrs[:changes] || {},
          event: command_attrs[:event],
          params: params,
          metadata: metadata
        )
      end

      # Build a dry-run operation plan for a CommandIntent.
      # Planning may read current state for previews, but never mutates storage.
      def command_operation_plan(intent)
        unless intent.is_a?(CommandIntent)
          raise ArgumentError, "command_operation_plan expects Igniter::DurableModel::CommandIntent"
        end

        case intent.operation
        when :record_update
          plan_record_update(intent)
        when :record_append
          plan_record_append(intent)
        when :history_append
          plan_history_append(intent)
        when :none
          build_command_plan(intent,
            status: :ready,
            target: { shape: :none },
            value: nil,
            event: nil)
        else
          build_command_plan(intent,
            status: :invalid,
            target: { shape: :none },
            errors: [plan_error(:unsupported_operation,
              "Unsupported command operation: #{intent.operation.inspect}")])
        end
      end

      # Project a command intent or plan into app-safe activity data.
      # This does not persist audit history or expose Ledger storage internals.
      def command_activity_event(source, status: nil, metadata: {})
        case source
        when CommandIntent
          activity_from_intent(source, status: status, metadata: metadata)
        when CommandOperationPlan
          activity_from_plan(source, status: status, metadata: metadata)
        else
          raise ArgumentError,
                "command_activity_event expects CommandIntent or CommandOperationPlan"
        end
      end

      # Explicitly persist app-safe command activity into an audit History.
      # This records the activity summary only; it does not apply command effects.
      def append_command_activity(event, history_class: CommandActivity)
        unless event.is_a?(CommandActivityEvent)
          raise ArgumentError, "append_command_activity expects Igniter::DurableModel::CommandActivityEvent"
        end

        register(history_class)
        append(history_class, **command_activity_payload(event))
        CommandActivityReceipt.new(
          history: history_class.store_name,
          owner: event.owner,
          command: event.command,
          subject_key: event.subject_key,
          activity_status: event.status,
          store_fact_exposed: event.store_fact_exposed,
          value_hash_exposed: event.value_hash_exposed,
          execution_allowed: event.execution_allowed
        )
      end

      # Explicit app-boundary command application.
      # Applies only ready CommandOperationPlan data through Durable Model APIs.
      def apply_command(plan, key: nil, history_class: nil, audit: false,
                        activity_history_class: CommandActivity)
        unless plan.is_a?(CommandOperationPlan)
          raise ArgumentError, "apply_command expects Igniter::DurableModel::CommandOperationPlan"
        end

        unless plan.ready?
          return rejected_command_apply_receipt(plan,
            audit: audit,
            activity_history_class: activity_history_class)
        end

        case plan.operation
        when :record_update
          apply_record_update_command(plan,
            audit: audit,
            activity_history_class: activity_history_class)
        when :record_append
          apply_record_append_command(plan,
            key: key,
            audit: audit,
            activity_history_class: activity_history_class)
        when :history_append
          apply_history_append_command(plan,
            history_class: history_class,
            audit: audit,
            activity_history_class: activity_history_class)
        when :none
          applied_command_receipt(plan,
            target: plan.target,
            mutation_intent: :none,
            activity_recorded: record_apply_activity(plan,
              status: :applied,
              audit: audit,
              activity_history_class: activity_history_class))
        else
          rejected_command_apply_receipt(plan,
            errors: [plan_error(:unsupported_operation,
              "Unsupported command operation: #{plan.operation.inspect}")],
            audit: audit,
            activity_history_class: activity_history_class)
        end
      end

      # Register a projection descriptor — metadata-only, no execution.
      # Records which stores and relations a cross-record projection reads,
      # making this visible to the store engine via SchemaGraph.
      def register_projection(name, reads:, relations: [], consumer_hint: :contract_node, reactive: false)
        projection = projection_snapshot_entry(
          name: name,
          reads: Array(reads).map(&:to_sym),
          relations: Array(relations).map(&:to_sym),
          consumer_hint: consumer_hint,
          reactive: reactive
        )
        @projections_by_name[name.to_sym] = projection

        if client_backed?
          @inner.register_descriptor(
            schema_version: 1,
            kind:           :projection,
            name:           name,
            reads:          projection[:reads],
            relations:      projection[:relations],
            consumer_hint:  projection[:consumer_hint],
            reactive:       projection[:reactive]
          )
          return self
        end

        @inner.register_projection(
          Igniter::Store::ProjectionPath.new(
            name:          name,
            reads:         projection[:reads],
            relations:     projection[:relations],
            consumer_hint: projection[:consumer_hint],
            reactive:      projection[:reactive]
          )
        )
        self
      end

      # Returns a compact snapshot of all registered projection descriptors.
      def _projections
        if client_backed?
          remote = normalize_projection_snapshot(metadata_snapshot[:projections])
          return remote unless remote.empty?

          return @projections_by_name.dup
        end

        @inner.schema_graph.projection_snapshot
      end

      # Causation chain for a Record key — useful for debugging mutations.
      def causation_chain(schema_class, key:)
        @inner.causation_chain(store: schema_class.store_name, key: key)
      end

      # Read-only provenance summary for a Record key.
      def lineage(schema_class, key:)
        @inner.lineage(store: schema_class.store_name, key: key)
      end

      # Returns the unified OP2 metadata snapshot including all schemas registered
      # through Durable Model (stores, histories, access_paths, relations, etc.).
      def metadata_snapshot
        @inner.protocol.metadata_snapshot
      end

      # Returns raw store/history/subscription descriptor packets registered
      # through the Durable Model protocol surface.
      def descriptor_snapshot
        @inner.protocol.descriptor_snapshot
      end

      def close
        @inner.close
      end

      private

      ClientFact = Struct.new(:id, :store, :key, :value, :transaction_time, :valid_time, :value_hash, keyword_init: true) do
        def timestamp = transaction_time
      end

      class ClientAdapter
        attr_reader :client

        def initialize(client)
          @client = Igniter::LedgerClient.wrap(client)
        end

        def register_descriptor(descriptor)
          client.register_descriptor(descriptor)
        end

        def write(...)
          client.write(...)
        end

        def read(...)
          client.read(...)
        end

        def query(...)
          client.query(...)
        end

        def append(...)
          client.append(...)
        end

        def resolve(...)
          client.resolve(...)
        end

        def causation_chain(store:, key:)
          client.causation_chain(store: store, key: key).chain
        end

        def lineage(store:, key:)
          client.lineage(store: store, key: key).to_h
        end

        def subscribe(...)
          client.subscribe(...)
        end

        def history(store:, key: nil, since: nil, as_of: nil)
          client.replay(store: store, key: key, from: since, to: as_of).facts.map { |fact| normalize_fact(fact) }
        end

        def history_partition(store:, partition_key:, partition_value:, since: nil, as_of: nil)
          client.replay(
            store: store,
            partition_key: partition_key,
            partition_value: partition_value,
            from: since,
            to: as_of
          ).facts.map { |fact| normalize_fact(fact) }
        end

        def metadata_snapshot
          client.metadata_snapshot
        end

        def descriptor_snapshot
          client.descriptor_snapshot
        end

        def protocol
          self
        end

        def close
          client.close
        end

        private

        def normalize_fact(fact)
          data = fact.to_h.transform_keys(&:to_sym)
          ClientFact.new(
            id: data[:id],
            store: token(data[:store]),
            key: data[:key],
            value: normalize_value(data[:value] || {}),
            transaction_time: data[:transaction_time] || data[:timestamp],
            valid_time: data[:valid_time],
            value_hash: data[:value_hash]
          )
        end

        def normalize_value(value)
          return value unless value.is_a?(Hash)

          value.each_with_object({}) { |(key, entry), acc| acc[key.to_sym] = entry }
        end

        def token(value)
          value.is_a?(String) ? value.to_sym : value
        end
      end

      def client_backed?
        @inner.is_a?(ClientAdapter)
      end

      def unsupported_client_mode!(feature)
        NotImplementedError.new("client-backed Durable Model store does not support #{feature} in v0")
      end

      def projection_snapshot_entry(name:, reads:, relations:, consumer_hint:, reactive:)
        {
          name: name.to_sym,
          reads: reads,
          relations: relations,
          consumer_hint: consumer_hint.to_sym,
          reactive: !!reactive,
          store_count: reads.size,
          relation_count: relations.size
        }
      end

      def normalize_projection_snapshot(snapshot)
        return {} unless snapshot

        snapshot.to_h.each_with_object({}) do |(name, raw), acc|
          data = raw.to_h.transform_keys(&:to_sym)
          reads = Array(data[:reads]).map(&:to_sym)
          relations = Array(data[:relations]).map(&:to_sym)
          acc[name.to_sym] = projection_snapshot_entry(
            name: data[:name] || name,
            reads: reads,
            relations: relations,
            consumer_hint: data[:consumer_hint] || :protocol_client,
            reactive: data[:reactive]
          )
        end
      end

      def normalize_scatter_snapshot(snapshot)
        Array(snapshot).map do |raw|
          data = raw.to_h.transform_keys(&:to_sym)
          {
            index: data[:index],
            source_store: token(data[:source_store]),
            partition_by: token(data[:partition_by]),
            target_store: token(data[:target_store]),
            has_rule: data.fetch(:has_rule, true)
          }.compact
        end
      end

      def normalize_value(value)
        return value unless value.is_a?(Hash)

        value.each_with_object({}) { |(key, entry), acc| acc[token(key)] = entry }
      end

      def token(value)
        value.is_a?(String) ? value.to_sym : value
      end

      def result_fact_id(result)
        result.respond_to?(:fact_id) ? result.fact_id : result.id
      end

      def result_value_hash(result)
        result.respond_to?(:value_hash) ? result.value_hash : result.value_hash
      end

      def result_causation(result)
        result.respond_to?(:causation) ? result.causation : nil
      end

      def result_key(result, fallback:)
        result.respond_to?(:key) && result.key ? result.key : fallback
      end

      def result_timestamp(result)
        if result.respond_to?(:timestamp)
          result.timestamp
        elsif result.respond_to?(:transaction_time)
          result.transaction_time
        end
      end

      def emit_companion_descriptor(schema_class)
        if schema_class.respond_to?(:_scopes)
          emit_store_descriptor(schema_class)
          emit_command_descriptors(schema_class)
          emit_effect_descriptors(schema_class)
        else
          emit_history_descriptor(schema_class)
        end
      end

      def emit_store_descriptor(schema_class)
        key = if schema_class.respond_to?(:_fields) && schema_class._fields.key?(:id)
          :id
        elsif schema_class.respond_to?(:_fields)
          schema_class._fields.keys.first || :id
        else
          :id
        end

        fields = if schema_class.respond_to?(:_fields)
          schema_class._fields.map do |name, attrs|
            h = { name: name }
            h[:type]    = attrs[:type]    if attrs[:type]
            h[:default] = attrs[:default] unless attrs[:default].nil?
            h[:values]  = attrs[:values]  if attrs[:values]
            h
          end
        else
          []
        end

        @inner.register_descriptor({
          schema_version: 1,
          kind:           :store,
          name:           schema_class.store_name,
          key:            key,
          fields:         fields,
          capabilities:   %i[write current_read as_of_read],
          producer:       { system: :igniter_companion, name: schema_class.name.to_s }
        })
      end

      def emit_history_descriptor(schema_class)
        pk = schema_class.respond_to?(:_partition_key) ? schema_class._partition_key : :id

        @inner.register_descriptor({
          schema_version: 1,
          kind:           :history,
          name:           schema_class.store_name,
          key:            pk || :id,
          producer:       { system: :igniter_companion, name: schema_class.name.to_s }
        })
      end

      def emit_command_descriptors(schema_class)
        return unless schema_class.respond_to?(:_commands)

        schema_class._commands.each do |command_name, attrs|
          descriptor = command_descriptor(schema_class, command_name, attrs)
          @inner.register_descriptor(descriptor)
        end
      end

      def emit_effect_descriptors(schema_class)
        return unless schema_class.respond_to?(:_effects)

        schema_class._effects.each do |command_name, attrs|
          descriptor = effect_descriptor(schema_class, command_name, attrs)
          @inner.register_descriptor(descriptor)
        end
      end

      def command_descriptor(schema_class, command_name, attrs)
        data = attrs.to_h.transform_keys(&:to_sym)
        operation = token(data[:operation] || :none)
        descriptor = data.merge(
          schema_version: 1,
          kind:           :command,
          name:           command_name,
          owner:          schema_class.store_name,
          operation:      operation,
          target_shape:   data[:target_shape] || target_shape_for(operation),
          boundary:       data[:boundary] || :app,
          mutation_intent: data[:mutation_intent] || operation
        )
        descriptor[:changes] = data[:changes] if data.key?(:changes)
        descriptor
      end

      def effect_descriptor(schema_class, command_name, attrs)
        data = attrs.to_h.transform_keys(&:to_sym)
        data.merge(
          schema_version: 1,
          kind:           :effect,
          name:           command_name,
          owner:          schema_class.store_name,
          store_op:       data[:store_op] || :none,
          write_kind:     data[:write_kind] || :none,
          lowers_to:      data[:lowers_to] || :none,
          boundary:       data[:boundary] || :app
        )
      end

      def target_shape_for(operation)
        case operation
        when :record_append, :record_update
          :store
        when :history_append
          :history
        else
          :none
        end
      end

      def normalize_command_snapshot(snapshot)
        normalize_descriptor_snapshot(snapshot) do |data|
          {
            name: token(data[:name]),
            owner: token(data[:owner]),
            operation: token(data[:operation]),
            target_shape: token(data[:target_shape]),
            boundary: token(data[:boundary]),
            mutation_intent: token(data[:mutation_intent]),
            changes: normalize_value(data[:changes] || {})
          }.compact
        end
      end

      def normalize_effect_snapshot(snapshot)
        normalize_descriptor_snapshot(snapshot) do |data|
          {
            name: token(data[:name]),
            owner: token(data[:owner]),
            store_op: token(data[:store_op]),
            write_kind: token(data[:write_kind]),
            lowers_to: token(data[:lowers_to]),
            boundary: token(data[:boundary]),
            source_operation: token(data[:source_operation])
          }.compact
        end
      end

      def normalize_descriptor_snapshot(snapshot)
        return {} unless snapshot

        snapshot.to_h.each_with_object({}) do |(owner, entries), acc|
          acc[token(owner)] = entries.to_h.each_with_object({}) do |(name, raw), owner_acc|
            data = raw.to_h.transform_keys(&:to_sym)
            owner_acc[token(name)] = yield(data)
          end
        end
      end

      def command_attrs_for(schema_class, command_key)
        unless schema_class.respond_to?(:_commands)
          raise ArgumentError, "#{schema_class} does not declare commands"
        end

        attrs = descriptor_entry(schema_class._commands, command_key)
        return attrs.to_h.transform_keys(&:to_sym) if attrs

        raise ArgumentError,
              "Unknown command #{command_key.inspect} for store=#{schema_class.store_name.inspect}"
      end

      def effect_attrs_for(schema_class, command_key)
        command_attrs = command_attrs_for(schema_class, command_key)
        return none_effect(command_attrs[:operation]) unless schema_class.respond_to?(:_effects)

        attrs = descriptor_entry(schema_class._effects, command_key)
        return attrs.to_h.transform_keys(&:to_sym) if attrs

        none_effect(command_attrs[:operation])
      end

      def none_effect(operation)
        {
          store_op: :none,
          write_kind: :none,
          lowers_to: :none,
          source_operation: token(operation || :none)
        }
      end

      def intent_effect(effect_attrs)
        {
          store_op: token(effect_attrs[:store_op] || :none),
          write_kind: token(effect_attrs[:write_kind] || :none),
          lowers_to: token(effect_attrs[:lowers_to] || :none),
          source_operation: token(effect_attrs[:source_operation])
        }.compact
      end

      def descriptor_entry(entries, key)
        entries[key] || entries[key.to_s]
      end

      def plan_record_update(intent)
        return plan_missing_key(intent) if intent.subject_key.nil?

        schema_class = schema_for_intent(intent)
        return plan_missing_schema(intent) unless schema_class

        record = read(schema_class, key: intent.subject_key)
        unless record
          return build_command_plan(intent,
            status: :invalid,
            target: store_target(intent),
            errors: [plan_error(:record_not_found,
              "No record found for owner=#{intent.owner.inspect} key=#{intent.subject_key.inspect}")])
        end

        value = record.to_h
          .merge(intent.changes)
          .merge(plan_hash_param(intent, :changes))
        build_command_plan(intent,
          status: :ready,
          target: store_target(intent),
          value: value)
      end

      def plan_record_append(intent)
        schema_class = schema_for_intent(intent)
        return plan_missing_schema(intent) unless schema_class

        value = intent.changes.merge(plan_hash_param(intent, :attributes))
        build_command_plan(intent,
          status: :ready,
          target: store_target(intent),
          value: value)
      end

      def plan_history_append(intent)
        history_name, warnings = history_target_for(intent)
        event = plan_event(intent)
        build_command_plan(intent,
          status: :ready,
          target: { shape: :history, name: history_name, key: nil },
          event: event,
          warnings: warnings)
      end

      def plan_missing_key(intent)
        build_command_plan(intent,
          status: :invalid,
          target: store_target(intent),
          errors: [plan_error(:missing_key,
            "record_update command plan requires subject_key")])
      end

      def plan_missing_schema(intent)
        build_command_plan(intent,
          status: :invalid,
          target: { shape: intent.target_shape, name: intent.owner, key: intent.subject_key },
          errors: [plan_error(:schema_not_registered,
            "No schema registered for owner=#{intent.owner.inspect}")])
      end

      def build_command_plan(intent, status:, target:, value: nil, event: nil,
                             errors: [], warnings: [])
        CommandOperationPlan.new(
          owner: intent.owner,
          command: intent.command,
          subject_key: intent.subject_key,
          operation: intent.operation,
          status: status,
          target: target,
          value: value,
          event: event,
          effect: intent.effect,
          errors: errors,
          warnings: warnings,
          metadata: intent.metadata
        )
      end

      def store_target(intent)
        { shape: :store, name: intent.owner, key: intent.subject_key }
      end

      def schema_for_intent(intent)
        @schema_by_store[token(intent.owner)]
      end

      def plan_hash_param(intent, key)
        value = intent.params[key]
        value.is_a?(Hash) ? value : {}
      end

      def history_target_for(intent)
        event = intent.event.is_a?(Hash) ? intent.event : {}
        explicit = intent.metadata[:history] || intent.metadata[:history_name] ||
                   intent.metadata[:target_history] || event[:history] ||
                   event[:history_name]
        return [token(explicit), []] if explicit

        [intent.owner, [plan_error(:history_target_inferred,
          "No explicit history target; using owner=#{intent.owner.inspect}")]]
      end

      def plan_event(intent)
        base = intent.event.is_a?(Hash) ? intent.event : {}
        base.merge(intent.params)
      end

      def plan_error(code, message)
        { code: code, message: message }
      end

      def activity_from_intent(intent, status:, metadata:)
        CommandActivityEvent.new(
          owner: intent.owner,
          command: intent.command,
          subject_key: intent.subject_key,
          operation: intent.operation,
          status: status || :intended,
          intent_status: :ready,
          plan_status: nil,
          target: nil,
          errors: [],
          warnings: [],
          metadata: merged_metadata(intent.metadata, metadata)
        )
      end

      def activity_from_plan(plan, status:, metadata:)
        CommandActivityEvent.new(
          owner: plan.owner,
          command: plan.command,
          subject_key: plan.subject_key,
          operation: plan.operation,
          status: status || (plan.ready? ? :planned : :rejected),
          intent_status: :ready,
          plan_status: plan.status,
          target: plan.target,
          errors: plan.errors,
          warnings: plan.warnings,
          metadata: merged_metadata(plan.metadata, metadata)
        )
      end

      def merged_metadata(source_metadata, explicit_metadata)
        normalize_value(source_metadata || {}).merge(normalize_value(explicit_metadata || {}))
      end

      def command_activity_payload(event)
        {
          owner: event.owner,
          command: event.command,
          subject_key: event.subject_key,
          operation: event.operation,
          status: event.status,
          intent_status: event.intent_status,
          plan_status: event.plan_status,
          target: event.target,
          errors: event.errors,
          warnings: event.warnings,
          metadata: event.metadata,
          store_fact_exposed: event.store_fact_exposed,
          value_hash_exposed: event.value_hash_exposed,
          execution_allowed: event.execution_allowed
        }
      end

      def apply_record_update_command(plan, audit:, activity_history_class:)
        schema_class = registered_record_schema_for(plan.owner)
        unless schema_class
          return rejected_command_apply_receipt(plan,
            errors: [plan_error(:schema_not_registered,
              "No Record schema registered for owner=#{plan.owner.inspect}")],
            audit: audit,
            activity_history_class: activity_history_class)
        end

        unless plan.subject_key
          return rejected_command_apply_receipt(plan,
            errors: [plan_error(:missing_key,
              "record_update command apply requires subject_key")],
            audit: audit,
            activity_history_class: activity_history_class)
        end

        write(schema_class, key: plan.subject_key, **apply_value(plan))
        applied_command_receipt(plan,
          target: command_target_with_key(plan, plan.subject_key),
          mutation_intent: :record_write,
          activity_recorded: record_apply_activity(plan,
            status: :applied,
            audit: audit,
            activity_history_class: activity_history_class))
      end

      def apply_record_append_command(plan, key:, audit:, activity_history_class:)
        schema_class = registered_record_schema_for(plan.owner)
        unless schema_class
          return rejected_command_apply_receipt(plan,
            errors: [plan_error(:schema_not_registered,
              "No Record schema registered for owner=#{plan.owner.inspect}")],
            audit: audit,
            activity_history_class: activity_history_class)
        end

        applied_key = key || plan.subject_key
        unless applied_key
          return rejected_command_apply_receipt(plan,
            errors: [plan_error(:missing_key,
              "record_append command apply requires explicit key")],
            audit: audit,
            activity_history_class: activity_history_class)
        end

        write(schema_class, key: applied_key, **apply_value(plan))
        applied_command_receipt(plan,
          target: command_target_with_key(plan, applied_key),
          mutation_intent: :record_write,
          activity_recorded: record_apply_activity(plan,
            status: :applied,
            audit: audit,
            activity_history_class: activity_history_class))
      end

      def apply_history_append_command(plan, history_class:, audit:,
                                       activity_history_class:)
        target_name = plan.target.is_a?(Hash) ? plan.target[:name] : nil
        resolved_history_class = history_class || registered_history_schema_for(target_name)
        unless resolved_history_class
          return rejected_command_apply_receipt(plan,
            errors: [plan_error(:history_not_registered,
              "No History schema registered for target=#{target_name.inspect}")],
            audit: audit,
            activity_history_class: activity_history_class)
        end

        register(resolved_history_class) if history_class
        append(resolved_history_class, **apply_event(plan))
        applied_command_receipt(plan,
          target: plan.target,
          mutation_intent: :history_append,
          activity_recorded: record_apply_activity(plan,
            status: :applied,
            audit: audit,
            activity_history_class: activity_history_class))
      end

      def registered_record_schema_for(store_name)
        schema_class = @schema_by_store[token(store_name)]
        return nil if schema_class&.respond_to?(:_partition_key)

        schema_class
      end

      def registered_history_schema_for(store_name)
        schema_class = @schema_by_store[token(store_name)]
        return schema_class if schema_class&.respond_to?(:_partition_key)

        nil
      end

      def apply_value(plan)
        plan.value.is_a?(Hash) ? plan.value : {}
      end

      def apply_event(plan)
        plan.event.is_a?(Hash) ? plan.event : {}
      end

      def command_target_with_key(plan, key)
        target = plan.target.is_a?(Hash) ? plan.target : {}
        target.merge(key: key)
      end

      def applied_command_receipt(plan, target:, mutation_intent:,
                                  activity_recorded:)
        CommandApplyReceipt.new(
          status: :applied,
          owner: plan.owner,
          command: plan.command,
          subject_key: plan.subject_key,
          operation: plan.operation,
          target: target,
          mutation_intent: mutation_intent,
          activity_recorded: activity_recorded,
          errors: [],
          warnings: plan.warnings
        )
      end

      def rejected_command_apply_receipt(plan, errors: [], audit:,
                                         activity_history_class:)
        all_errors = Array(plan.errors) + Array(errors)
        activity_recorded = record_apply_activity(plan,
          status: :rejected,
          errors: all_errors,
          audit: audit,
          activity_history_class: activity_history_class)
        CommandApplyReceipt.new(
          status: :rejected,
          owner: plan.owner,
          command: plan.command,
          subject_key: plan.subject_key,
          operation: plan.operation,
          target: plan.target,
          mutation_intent: :none,
          activity_recorded: activity_recorded,
          errors: all_errors,
          warnings: plan.warnings
        )
      end

      def record_apply_activity(plan, status:, audit:, activity_history_class:,
                                errors: plan.errors)
        return false unless audit

        event = CommandActivityEvent.new(
          owner: plan.owner,
          command: plan.command,
          subject_key: plan.subject_key,
          operation: plan.operation,
          status: status,
          intent_status: :ready,
          plan_status: plan.status,
          target: plan.target,
          errors: errors,
          warnings: plan.warnings,
          metadata: plan.metadata
        )
        append_command_activity(event, history_class: activity_history_class)
        true
      end
    end
  end
end
