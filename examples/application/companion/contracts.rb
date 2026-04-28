# frozen_string_literal: true

require "igniter/contracts"
require "igniter/extensions/contracts"

module Companion
  module Contracts
    def self.contracts(name, outputs:, &block)
      contract_class = Class.new(Igniter::Contract)
      contract_class.profile = Igniter::Contracts.build_profile(
        Igniter::Extensions::Contracts::Language::FormulaPack,
        Igniter::Extensions::Contracts::Language::PiecewisePack,
        Igniter::Extensions::Contracts::Language::ScalePack
      )
      contract_class.define(&block)
      contract_class.define_singleton_method(:evaluate) do |**inputs|
        contract = new(**inputs)
        outputs.to_h { |output_name| [output_name, contract.output(output_name)] }
      end
      const_set(name, contract_class)
    end
  end
end
