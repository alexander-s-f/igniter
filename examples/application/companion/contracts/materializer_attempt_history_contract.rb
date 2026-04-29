# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :MaterializerAttempt do
      history key: :index, adapter: :sqlite

      field :index
      field :kind
      field :status
      field :approval_request, type: :json
      field :blocked_capabilities, type: :json
      field :blocked_step_count
      field :executed
      field :review_only
    end
  end
end
