module Fixture.TypedEmissionParity

observed contract SparkCRMBiHistorySourceParity {
  input technician_id: String
  input valid_time: DateTime
  input transaction_time: DateTime

  escape bihistory_read

  read availability_history: BiHistory[String]
    from "sparkcrm/{technician_id}/availability"
    lifecycle :durable

  compute availability_at = bihistory_at(availability_history, valid_time, transaction_time)

  output availability_at: Option[String] lifecycle :session
}
