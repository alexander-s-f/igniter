# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :DailyFocus do
      persist key: :date, adapter: :sqlite

      field :date
      field :title
    end
  end
end
