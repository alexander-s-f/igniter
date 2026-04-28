# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :Reminder do
      persist key: :id, adapter: :sqlite

      field :id
      field :title
      field :due
      field :status, default: :open
    end
  end
end
