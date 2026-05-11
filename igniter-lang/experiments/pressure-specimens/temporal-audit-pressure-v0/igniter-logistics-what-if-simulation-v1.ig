module IgniterLogisticsWhatIf

store SupplyChainHistory : BiHistory[ShipmentState]

contract SimulateWhatIfScenario(base_date: Timestamp, changes: List[WhatIfChange])
  -> SimulationResult
{
  let original = SupplyChainHistory.query_as_of(base_date)

  let forked = ForkSimulationAt(base_date)   -- time-travel forking
    .apply_changes(changes)

  let outcome = RunSimulation(forked)

  return SimulationResult {
    original_outcome: RunSimulation(original),
    what_if_outcome: outcome,
    delta: calculate_impact(...),
    audit_trail: forked.receipts
  }
}