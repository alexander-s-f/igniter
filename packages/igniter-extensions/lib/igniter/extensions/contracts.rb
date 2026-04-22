# frozen_string_literal: true

require "igniter/contracts"
require_relative "contracts/execution_report_pack"
require_relative "contracts/lookup_pack"

module Igniter
  module Extensions
    module Contracts
      AVAILABLE_PACKS = [
        ExecutionReportPack,
        LookupPack
      ].freeze

      class << self
        def available_packs
          AVAILABLE_PACKS
        end

        def build_profile(*packs)
          Igniter::Contracts.build_profile(*normalize_packs(packs))
        end

        def with(*packs)
          Igniter::Contracts.with(*normalize_packs(packs))
        end

        private

        def normalize_packs(packs)
          normalized = packs.flatten.compact
          normalized.empty? ? available_packs : normalized
        end
      end
    end
  end
end
