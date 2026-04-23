# frozen_string_literal: true

require "igniter/contracts"
require_relative "contracts/aggregate_pack"
require_relative "contracts/commerce_pack"
require_relative "contracts/execution_report_pack"
require_relative "contracts/journal_pack"
require_relative "contracts/lookup_pack"
require_relative "contracts/provenance_pack"
require_relative "contracts/saga_pack"

module Igniter
  module Extensions
    module Contracts
      DEFAULT_PACKS = [
        ExecutionReportPack,
        LookupPack
      ].freeze

      AVAILABLE_PACKS = (
        DEFAULT_PACKS +
        [AggregatePack, CommercePack, JournalPack, ProvenancePack, SagaPack]
      ).freeze

      PRESETS = {
        default: DEFAULT_PACKS,
        commerce: [ExecutionReportPack, CommercePack]
      }.freeze

      class << self
        def default_packs
          DEFAULT_PACKS
        end

        def available_packs
          AVAILABLE_PACKS
        end

        def presets
          PRESETS
        end

        def packs_for(name)
          presets.fetch(name.to_sym)
        rescue KeyError
          raise ArgumentError, "unknown contracts preset #{name}"
        end

        def build_profile(*packs)
          Igniter::Contracts.build_profile(*normalize_packs(packs))
        end

        def with(*packs)
          Igniter::Contracts.with(*normalize_packs(packs))
        end

        def build_preset_profile(name)
          build_profile(*packs_for(name))
        end

        def with_preset(name)
          with(*packs_for(name))
        end

        def lineage(result, output_name)
          ProvenancePack.lineage(result, output_name)
        end

        def explain(result, output_name)
          ProvenancePack.explain(result, output_name)
        end

        def build_compensations(&block)
          SagaPack.build(&block)
        end

        def run_saga(environment, inputs:, compensations:, compiled_graph: nil, &block)
          SagaPack.run(
            environment,
            inputs: inputs,
            compensations: compensations,
            compiled_graph: compiled_graph,
            &block
          )
        end

        private

        def normalize_packs(packs)
          normalized = packs.flatten.compact
          normalized.empty? ? default_packs : normalized
        end
      end
    end
  end
end
