module Fixture.HistoryTypeProof

observed contract TechnicianJobCountAt {
  input technician_id: String
  input as_of: DateTime

  escape history_read

  read job_count_history: History[Integer]
    from "technicians/{technician_id}/job_count"
    lifecycle :durable

  compute current_count = history_at(job_count_history, as_of)

  output current_count: Option[Integer] lifecycle :session
}
