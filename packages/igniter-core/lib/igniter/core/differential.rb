# frozen_string_literal: true

require_relative "legacy"
Igniter::Core::Legacy.require!("igniter/core/differential")
require_relative "errors"
require_relative "differential/divergence"
require_relative "differential/report"
require_relative "differential/formatter"
require_relative "differential/runner"

module Igniter
  # Differential Execution — compare two contract implementations output-by-output.
  #
  # Usage:
  #
  #   require "igniter/extensions/differential"
  #
  #   # Standalone comparison
  #   report = Igniter::Differential.compare(
  #     primary:   PricingV1,
  #     candidate: PricingV2,
  #     inputs:    { price: 50.0, quantity: 3 }
  #   )
  #   puts report.explain
  #   puts report.match?          # => false
  #   puts report.divergences     # => [#<Divergence ...>]
  #
  #   # Per-instance diff (primary already resolved)
  #   contract = PricingV1.new(price: 50.0, quantity: 3)
  #   contract.resolve_all
  #   report = contract.diff_against(PricingV2)
  #
  #   # Shadow mode (runs candidate alongside primary automatically)
  #   class PricingContract < Igniter::Contract
  #     shadow_with PricingV2, on_divergence: ->(r) { Rails.logger.warn(r.summary) }
  #     define { ... }
  #   end
  #
  module Differential
    class DifferentialError < Igniter::Error; end

    # Compare +primary+ and +candidate+ contract classes on the given +inputs+.
    #
    # @param primary   [Class<Igniter::Contract>]
    # @param candidate [Class<Igniter::Contract>]
    # @param inputs    [Hash]
    # @param tolerance [Numeric, nil] optional allowable numeric difference
    # @return [Report]
    def self.compare(primary:, candidate:, inputs:, tolerance: nil)
      Runner.new(primary, candidate, tolerance: tolerance).run(inputs)
    end
  end
end
