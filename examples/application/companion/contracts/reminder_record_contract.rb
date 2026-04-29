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

      index :status
      scope :open, where: { status: :open }
      command :complete, operation: :record_update, changes: { status: :done }
    end
  end
end
