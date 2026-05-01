# frozen_string_literal: true

module Igniter
  module Store
    # Engine routing descriptor: how the store routes scope queries for a given store/scope pair.
    AccessPath = Struct.new(
      :store,
      :lookup,
      :scope,
      :filters,
      :cache_ttl,
      :consumers,
      keyword_init: true
    )

    # Read-model descriptor: which stores and relations a cross-record projection reads.
    # Metadata-only — no execution happens inside the store engine.
    # Registered in SchemaGraph so the engine knows which projections depend on which stores.
    ProjectionPath = Struct.new(
      :name,           # Symbol — projection name, e.g. :tracker_read_model
      :reads,          # Array<Symbol> — store names this projection reads from
      :relations,      # Array<Symbol> — relation names used when composing sources
      :consumer_hint,  # Symbol — which layer executes this projection (:contract_node, etc.)
      :reactive,       # Boolean — whether push-reactive delivery is expected
      keyword_init: true
    )
  end
end
