# frozen_string_literal: true

require_relative "durable_model"

module Igniter
  module Companion
    Record = DurableModel::Record
    History = DurableModel::History
    Store = DurableModel::Store
    WriteReceipt = DurableModel::WriteReceipt
    AppendReceipt = DurableModel::AppendReceipt
    CommandIntent = DurableModel::CommandIntent
    CommandOperationPlan = DurableModel::CommandOperationPlan

    def self.from_manifest(manifest, store: nil)
      DurableModel.from_manifest(manifest, store: store)
    end
  end
end
