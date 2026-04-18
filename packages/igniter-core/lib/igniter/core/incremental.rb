# frozen_string_literal: true

require_relative "errors"
require_relative "incremental/result"
require_relative "incremental/tracker"
require_relative "incremental/formatter"

module Igniter
  # Incremental computation for Igniter contracts.
  #
  # Implements the Salsa/Adapton incremental model:
  #   - Each compute node tracks a dep_snapshot: the value_versions of its
  #     dependencies at last compute time.
  #   - On re-resolution of a stale node, if all dep value_versions are
  #     unchanged, the compute is skipped entirely (memoization).
  #   - If a node recomputes but produces the same output value, its own
  #     value_version is not incremented (backdating), preventing unnecessary
  #     downstream recomputation.
  #
  # These optimizations are built into the core runtime (NodeState, Cache,
  # Resolver) and are always active. This module adds the reporting API:
  #   - contract.resolve_incrementally → Incremental::Result
  #
  # Usage:
  #   require "igniter/extensions/incremental"
  #
  #   class PricingContract < Igniter::Contract
  #     define do
  #       input :base_price
  #       input :user_tier
  #       input :exchange_rate
  #       compute :tier_discount,   depends_on: :user_tier,   call: -> (user_tier:) { ... }
  #       compute :adjusted_price,  depends_on: %i[base_price tier_discount], call: -> (**) { ... }
  #       compute :converted_price, depends_on: %i[adjusted_price exchange_rate], call: -> (**) { ... }
  #       output :converted_price
  #     end
  #   end
  #
  #   contract = PricingContract.new(base_price: 100, user_tier: "gold", exchange_rate: 1.0)
  #   contract.resolve_all
  #
  #   result = contract.resolve_incrementally(exchange_rate: 1.12)
  #   result.skipped_nodes    # => [:tier_discount, :adjusted_price]
  #   result.changed_outputs  # => { converted_price: { from: 100.0, to: 112.0 } }
  #   result.explain
  #
  module Incremental
    class IncrementalError < Igniter::Error; end
  end
end
