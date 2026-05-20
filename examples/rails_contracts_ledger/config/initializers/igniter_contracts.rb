# frozen_string_literal: true

require "igniter-embed"
require "igniter-ledger"

require Rails.root.join("app/services/availability_slot_map_primary").to_s
require Rails.root.join("app/services/availability_slot_map_normalizer").to_s
require Rails.root.join("app/services/spark_contractable_notifications").to_s
require Rails.root.join("app/services/spark_contractable_receipt_store").to_s

Rails.application.config.x.availability_observer = Igniter::Embed.contractable(:availability_slot_map) do
  observe AvailabilitySlotMapPrimary
  shadow async: false, sample: 1.0
  use :normalizer, AvailabilitySlotMapNormalizer
  use :redaction, only: %i[request_ref company_ref service_area_ref trade_ref window_ref]
  use :store, SparkContractableReceiptStore.instance

  on :observation, SparkContractableNotifications
  on :failure, SparkContractableNotifications
end
