# frozen_string_literal: true

require_relative "provenance/node_trace"
require_relative "provenance/text_formatter"
require_relative "provenance/lineage"
require_relative "provenance/builder"

module Igniter
  # Provenance — runtime data lineage for Igniter contracts.
  #
  # After a contract has been resolved, provenance lets you ask:
  #   "How was this output value computed, and which inputs influenced it?"
  #
  # Usage:
  #   require "igniter/extensions/provenance"
  #
  #   contract.resolve_all
  #   lin = contract.lineage(:grand_total)
  #
  #   lin.value                        # => 229.95
  #   lin.contributing_inputs          # => { base_price: 100.0, quantity: 2 }
  #   lin.sensitive_to?(:base_price)   # => true
  #   lin.path_to(:base_price)         # => [:grand_total, :subtotal, :base_price]
  #   puts lin                          # ASCII tree
  #
  module Provenance
    class ProvenanceError < Igniter::Error; end
  end
end
