# frozen_string_literal: true

module Igniter
  # Mixin for time-aware contracts.
  #
  # Including Igniter::Temporal in a Contract automatically injects an `as_of`
  # input (default: Time.now) and provides the `temporal_compute` DSL helper,
  # which adds `:as_of` to a node's dependencies automatically.
  #
  # The key property of a temporal contract: if ALL time-varying nodes depend on
  # `as_of`, any historical execution is fully reproducible — just supply the
  # original timestamp as the `as_of` input.
  #
  # == Usage
  #
  #   require "igniter/temporal"
  #
  #   class TaxRateContract < Igniter::Contract
  #     include Igniter::Temporal
  #
  #     define do
  #       input :country
  #       # `as_of` is injected automatically (default: Time.now)
  #
  #       temporal_compute :tax_rate, depends_on: :country do |country:, as_of:|
  #         HistoricalTaxRates.lookup(country: country, date: as_of.to_date)
  #       end
  #
  #       output :tax_rate
  #     end
  #   end
  #
  #   # Current rates:
  #   TaxRateContract.new(country: "UA").result.tax_rate
  #
  #   # Reproduce a historical result:
  #   TaxRateContract.new(country: "UA", as_of: Time.new(2024, 1, 1)).result.tax_rate
  #
  # == TemporalExecutor
  #
  # For class-based executors in temporal contracts, inherit from
  # Igniter::Temporal::Executor. It ensures `as_of:` is always passed as
  # a keyword argument by the resolver.
  #
  #   class TaxRateExecutor < Igniter::Temporal::Executor
  #     def call(country:, as_of:)
  #       HistoricalTaxRates.lookup(country: country, date: as_of.to_date)
  #     end
  #   end
  module Temporal
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Returns true for contracts that include Temporal.
      def temporal? = true

      # Override define to inject `as_of` and the `temporal_compute` builder helper
      # before the user's block runs.
      def define(&user_block)
        super do
          # Inject temporal input first so it can be used as a dependency.
          input :as_of, default: -> { Time.now }

          # Add `temporal_compute` as a convenience method on this builder instance.
          # It behaves like `compute` but automatically adds `:as_of` to depends_on.
          define_singleton_method(:temporal_compute) do |name, depends_on: [], **opts, &blk|
            deps = (Array(depends_on) | [:as_of])
            compute(name, depends_on: deps, **opts, &blk)
          end

          instance_eval(&user_block)
        end
      end
    end

    # Base executor for temporal compute nodes.
    # Inheriting from this signals that the executor expects `as_of:` among its kwargs.
    class Executor < Igniter::Executor
      # Subclasses must implement: def call(**deps_including_as_of)
    end
  end
end
