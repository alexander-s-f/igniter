# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :WizardTypeSpec do
      persist key: :id, adapter: :sqlite

      field :id
      field :contract, type: :string
      field :spec, type: :json
    end
  end
end
