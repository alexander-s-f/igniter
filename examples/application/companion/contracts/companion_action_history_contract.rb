# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :CompanionAction do
      history key: :index, adapter: :sqlite

      field :index
      field :kind
      field :subject_id
      field :status
    end
  end
end
