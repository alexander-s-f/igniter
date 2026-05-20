# frozen_string_literal: true

class SparkContractableNotifications
  def self.call(event)
    receipt = event.fetch(:receipt)
    ActiveSupport::Notifications.instrument(
      "spark.contractable.#{event.fetch(:event)}",
      observation_id: receipt[:observation_id],
      event_id: receipt[:event_id],
      name: event[:name],
      role: event[:role],
      stage: event[:stage],
      severity: receipt[:severity]
    )
  end
end
