# frozen_string_literal: true

require "igniter/contracts"
require_relative "contracts/aggregate_pack"
require_relative "contracts/commerce_pack"
require_relative "contracts/execution_report_pack"
require_relative "contracts/journal_pack"
require_relative "contracts/lookup_pack"

module Igniter
  module Extensions
    module Contracts
      DEFAULT_PACKS = [
        ExecutionReportPack,
        LookupPack
      ].freeze

      AVAILABLE_PACKS = (
        DEFAULT_PACKS +
        [AggregatePack, CommercePack, JournalPack]
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

        private

        def normalize_packs(packs)
          normalized = packs.flatten.compact
          normalized.empty? ? default_packs : normalized
        end
      end
    end
  end
end
