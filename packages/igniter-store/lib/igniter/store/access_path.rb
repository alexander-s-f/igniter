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

    # Retention policy for a store — controls compaction behaviour.
    # strategy: :permanent   — never compact (default)
    #           :ephemeral   — keep only latest fact per key; drop all historical
    #           :rolling_window — drop historical facts older than duration seconds,
    #                             always preserving the latest per key
    # duration: Float seconds (required for :rolling_window)
    RetentionPolicy = Struct.new(
      :strategy,   # Symbol
      :duration,   # Float | nil
      keyword_init: true
    )

    # Derivation rule: when facts matching source_store/source_filters change, call
    # rule.(source_facts) and write the result to target_store at target_key.
    # source_filters: {} means all latest facts per key in that store.
    # rule returning nil skips the derived write.
    # target_key may be a String/Symbol or a callable(Array<Fact>) → String.
    DerivationRule = Struct.new(
      :source_store,    # Symbol
      :source_filters,  # Hash
      :target_store,    # Symbol
      :target_key,      # String | Symbol | callable
      :rule,            # callable(Array<Fact>) → Hash | nil
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
