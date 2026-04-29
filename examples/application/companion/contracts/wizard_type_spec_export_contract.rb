# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :WizardTypeSpecExportContract, outputs: %i[schema_versions dev_config prod_config summary] do
      input :specs
      input :spec_history

      compute :schema_versions, depends_on: [:specs] do |specs:|
        specs.map { |entry| entry.fetch(:spec).fetch(:schema_version, 0) }.uniq
      end

      compute :dev_config, depends_on: %i[specs spec_history] do |specs:, spec_history:|
        {
          mode: :dev,
          compressed: false,
          specs: specs,
          history: spec_history
        }
      end

      compute :prod_config, depends_on: [:specs] do |specs:|
        {
          mode: :prod,
          compressed: true,
          specs: specs,
          history: []
        }
      end

      compute :summary, depends_on: %i[schema_versions specs spec_history] do |schema_versions:, specs:, spec_history:|
        "schema v#{schema_versions.join(",")} #{specs.length} latest specs, #{spec_history.length} history entries; prod export is latest-only."
      end

      output :schema_versions
      output :dev_config
      output :prod_config
      output :summary
    end
  end
end
