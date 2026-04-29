# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :Comment do
      history key: :index, adapter: :sqlite

      field :index
      field :article_id
      field :body, type: :string
      field :created_at, type: :datetime
    end
  end
end
