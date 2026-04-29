# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :Countdown do
      persist key: :id, adapter: :sqlite

      field :id
      field :title
      field :target_date
    end
  end
end
