# frozen_string_literal: true

require_relative "durable_model"

module Igniter
  module Companion
    Record = DurableModel::Record
    History = DurableModel::History
    CommandActivity = DurableModel::CommandActivity
    Store = DurableModel::Store
    WriteReceipt = DurableModel::WriteReceipt
    AppendReceipt = DurableModel::AppendReceipt
    CommandActivityReceipt = DurableModel::CommandActivityReceipt
    CommandApplyReceipt = DurableModel::CommandApplyReceipt
    CommandIntent = DurableModel::CommandIntent
    CommandOperationPlan = DurableModel::CommandOperationPlan
    CommandActivityEvent = DurableModel::CommandActivityEvent

    def self.from_manifest(manifest, store: nil)
      DurableModel.from_manifest(manifest, store: store)
    end
  end
end
