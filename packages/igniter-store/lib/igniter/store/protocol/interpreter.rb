# frozen_string_literal: true

require "digest"

module Igniter
  module Store
    module Protocol
      class Interpreter
        HANDLERS = {
          store:        Handlers::StoreHandler,
          history:      Handlers::HistoryHandler,
          access_path:  Handlers::AccessPathHandler,
          relation:     Handlers::RelationHandler,
          projection:   Handlers::ProjectionHandler,
          derivation:   Handlers::DerivationHandler,
          subscription: Handlers::SubscriptionHandler,
        }.freeze

        def initialize(store)
          @store    = store
          @registry = {}  # content fingerprint → Receipt (dedup)
        end

        # Generic descriptor registration — dispatches by kind:.
        # Returns a Receipt with status :accepted, :rejected, or :deduplicated.
        def register(descriptor)
          descriptor = descriptor.transform_keys(&:to_sym)
          kind = descriptor[:kind]&.to_sym

          return Receipt.rejection("Missing required field: kind") unless kind

          handler_class = HANDLERS[kind]
          return Receipt.rejection("Unknown descriptor kind: #{kind.inspect}", kind: kind) unless handler_class

          fp = fingerprint(descriptor)
          return Receipt.deduplicated(kind: kind, name: descriptor[:name]&.to_sym) if @registry.key?(fp)

          receipt = handler_class.new(@store).call(descriptor)
          @registry[fp] = receipt if receipt.accepted?
          receipt
        end

        # Named registration helpers — vocabulary aliases for register.
        def register_store(descriptor)        = register(descriptor)
        def register_history(descriptor)      = register(descriptor)
        def register_access_path(descriptor)  = register(descriptor)
        def register_relation(descriptor)     = register(descriptor)
        def register_projection(descriptor)   = register(descriptor)
        def register_derivation(descriptor)   = register(descriptor)
        def register_subscription(descriptor) = register(descriptor)

        # Write a fact. Returns a write Receipt carrying fact_id and value_hash.
        def write(store:, key:, value:, causation: nil, producer: nil)
          fact = @store.write(store: store.to_sym, key: key, value: value, producer: producer)
          Receipt.write_accepted(store: store.to_sym, key: key, fact: fact)
        end

        # Read the current value for a key (or nil).
        def read(store:, key:, as_of: nil)
          @store.read(store: store.to_sym, key: key, as_of: as_of)
        end

        # Query facts matching all where: conditions.
        # Performs a latest-per-key scan; access paths provide introspection metadata
        # but index-accelerated query planning is a future engine concern.
        def query(store:, where: {}, order: nil, limit: nil, as_of: nil)
          store_sym = store.to_sym
          facts = @store.history(store: store_sym, as_of: as_of)

          # Reduce to latest fact per key.
          latest = {}
          facts.each do |f|
            existing = latest[f.key]
            latest[f.key] = f if existing.nil? || f.timestamp > existing.timestamp
          end

          results = latest.values.map(&:value)

          where.each do |field, val|
            sym = field.to_sym
            results = results.select { |v| v[sym] == val }
          end

          results = results.sort_by { |v| v[order.to_sym] } if order
          results = results.first(limit)                      if limit
          results
        end

        # Resolve a named relation (delegates to IgniterStore#resolve).
        def resolve(relation_name, from:, as_of: nil)
          @store.resolve(relation_name, from: from, as_of: as_of)
        end

        # OP2: compact metadata snapshot of all registered descriptors + schema graph.
        def metadata_snapshot
          @store.schema_graph.metadata_snapshot
        end

        # OP2: raw protocol descriptor snapshot (store/history/subscription descriptors).
        def descriptor_snapshot
          @store.schema_graph.descriptor_snapshot
        end

        private

        def fingerprint(descriptor)
          Digest::SHA256.hexdigest(descriptor.to_a.sort_by { |k, _| k.to_s }.inspect)
        end
      end
    end
  end
end
