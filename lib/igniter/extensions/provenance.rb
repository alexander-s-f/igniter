# frozen_string_literal: true

require "igniter/core/provenance"

module Igniter
  module Extensions
    # Adds runtime provenance (data lineage) methods to Igniter::Contract.
    #
    # After requiring this file, every resolved contract gains two new methods:
    #
    #   contract.resolve_all
    #
    #   # Full Lineage object — query API
    #   lin = contract.lineage(:grand_total)
    #   lin.contributing_inputs        # => { base_price: 100.0, quantity: 2 }
    #   lin.sensitive_to?(:base_price) # => true
    #   lin.path_to(:base_price)       # => [:grand_total, :subtotal, :base_price]
    #   lin.to_h                        # serialisable Hash
    #
    #   # Shorthand: human-readable ASCII tree printed to stdout
    #   contract.explain(:grand_total)
    #
    module Provenance
      # Return a Lineage object for the named output.
      # Raises ProvenanceError if the output is unknown or the contract has not
      # been executed (resolve_all has not been called).
      def lineage(output_name)
        unless execution
          raise Igniter::Provenance::ProvenanceError,
                "Contract has not been executed — call resolve_all first"
        end

        Igniter::Provenance::Builder.build(output_name, execution)
      end

      # Return a human-readable ASCII tree explaining how +output_name+ was derived.
      def explain(output_name)
        lineage(output_name).explain
      end
    end
  end
end

# Patch Igniter::Contract so every contract instance gains the methods.
Igniter::Contract.include(Igniter::Extensions::Provenance)
