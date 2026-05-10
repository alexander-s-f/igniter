module Proof.ContractModifiers.Variants

effect contract NotifyUser {
  input user_id: String
  input body: String
  escape notification_send
  output user_id: String
}

privileged contract ApproveExpense {
  input expense_id: String
  input amount: Integer
  escape approval_write
  output expense_id: String
}

irreversible contract ArchiveRecord {
  input record_id: String
  escape archive_write
  output record_id: String
}
