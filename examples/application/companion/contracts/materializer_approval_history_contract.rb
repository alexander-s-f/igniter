# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :MaterializerApproval do
      history key: :index, adapter: :sqlite

      field :index
      field :kind
      field :status
      field :approved
      field :approved_by
      field :contract
      field :requested_capabilities, type: :json
      field :granted_capabilities, type: :json
      field :rejected_capabilities, type: :json
      field :unknown_capabilities, type: :json
      field :reasons, type: :json
      field :applies_capabilities
      field :review_only
    end
  end
end
