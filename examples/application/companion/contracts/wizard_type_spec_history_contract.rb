# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :WizardTypeSpecChange do
      history key: :index, adapter: :sqlite

      field :index
      field :spec_id
      field :contract, type: :string
      field :change_kind
      field :spec, type: :json
      field :created_at, type: :datetime
    end
  end
end
