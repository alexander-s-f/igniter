# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :TrackerLog do
      history key: :tracker_id, adapter: :sqlite

      field :tracker_id
      field :date
      field :value
    end
  end
end
