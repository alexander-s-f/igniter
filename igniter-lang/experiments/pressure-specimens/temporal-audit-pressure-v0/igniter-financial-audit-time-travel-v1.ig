module IgniterFinancialAuditTimeTravel

profile audited_financial_system
  time: bitemporal
  evidence: required
  trust: system
  effects: privileged

-- ====================== TEMPORAL CORE ======================
type Transaction {
  id: UUID
  valid_time: Timestamp          -- when the fact became true
  transaction_time: Timestamp    -- when we recorded it
  account: String
  amount: Decimal[4]
  description: String
  correction_of: Optional[UUID]  -- link to the transaction being corrected
}

-- BiHistory stores all versions automatically
store FinancialHistory : BiHistory[Transaction]

-- ====================== TIME-TRAVEL OPERATIONS ======================
pure contract AsOf(account: String, date: Timestamp) -> List[Transaction]
  -- view status on any date in the past

pure contract WhatIfCorrection(original_tx: Transaction, corrected_amount: Decimal[4], reason: String)
  -> CorrectionReceipt
{
  let corrected = Transaction {
    id: new_uuid(),
    valid_time: original_tx.valid_time,
    transaction_time: now(),
    account: original_tx.account,
    amount: corrected_amount,
    description: "CORRECTION: " + reason,
    correction_of: original_tx.id
  }

  -- We record the correction as a new version
  let receipt = StoreTransaction(corrected)

  -- PostAudit automatically compares "was / became"
  return PostAuditCorrection(original_tx, corrected, receipt)
}

-- ====================== AUDIT & TIME-TRAVEL SCENARIOS ======================
contract ReconstructAccountBalanceAsOf(account: String, as_of_date: Timestamp)
  -> BalanceReconstruction
{
  let history = FinancialHistory.query_as_of(as_of_date, account)
  let balance = history.sum(transaction => transaction.amount)

  return BalanceReconstruction {
    balance: balance,
    transactions_used: history,
    audit_trail: history.map(t => t.receipt)
  }
}

-- ====================== WHAT THIS PROVES ======================

-- 1. Temporality is not a theory. Without bitemporality, it is impossible to correctly correct errors in financial systems.
-- 2. Time-travel (AsOf) allows you to instantly see the state at any date in the past.
-- 3. Each correction leaves a full auditable trace (correction_of + PostAudit).
-- 4. BiHistory + receipts solve the real business problem of compliance and audit.
-- 5. The user can ask, "What was the balance 3 months ago?" and get a precise answer.

end module