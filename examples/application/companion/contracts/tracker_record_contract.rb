# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :Tracker do
      persist key: :id, adapter: :sqlite

      field :id
      field :name
      field :template
      field :unit
    end
  end
end
