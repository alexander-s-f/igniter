module IgniterPoliticalSimulationEngine

include IgniterPoliticalSimulationPrimitives

profile audited_political_mesh
  time: bitemporal
  lifecycle: service
  backend: distributed_mesh
  consistency: causal
  evidence: required
  trust: system
  effects: privileged
  receipts: immutable
  loop: service_progression
  authority: explicit

# ====================== EXTERNAL PROGRESSION + OVER TON ======================
service contract PoliticalSimulationOrchestrator
  progression driven_by clock.every(1.political_cycle)
  authority simulation_authority: AuthorityRef
{
  # 1. Observe real-world events
  observed contract IngestPoliticalEvents
    input raw_events: List[MeshPacket]
    output actors: List[PoliticalActor]
    evidence [raw_events]

  # 2. Compute current Overton state
  pure contract UpdateOvertonSpectrum
    input actors: List[PoliticalActor]
    input proposals: List[PolicyProposal]
    output spectrum: OvertonSpectrum evidence [actors, proposals]

  # 3. Simulate shifts + debates
  pure contract SimulateDailyOvertonDynamics
    input spectrum: OvertonSpectrum
    uses assumptions overton_dynamics
    uses constraints overton_simulation
    output shifts: List[OvertonShiftEvent]
    output debate: DebateRound
    evidence [spectrum, assumptions, constraints]

  # 4. Detect manipulation (Postulate 23 + 28)
  pure contract RunManipulationCheck
    input before: OvertonSpectrum
    input after: OvertonSpectrum
    output risk: Decimal[2] evidence [before, after]

  # 5. Act — publish simulation results (privileged)
  privileged contract PublishOvertonForecast
    input shifts: List[OvertonShiftEvent]
    escape public_narrative
    output receipt: OvertonForecastReceipt
    compensation RevertOvertonPublication
    authority simulation_authority

  # 6. PostAudit — closed loop (Postulate 26)
  audit contract PostCycleOvertonAudit
    input forecast_receipt: OvertonForecastReceipt
    input real_world_spectrum: OvertonSpectrum
    output audit_receipt: PostAuditReceipt
}

# ====================== INVARIANTS (reinforced) ======================
invariant no_silent_overton_shift            { severity: critical }
invariant every_shift_has_evidence           { severity: critical }
invariant no_synthetic_as_observed           { severity: critical }
invariant manipulation_transparency          { severity: legal }
invariant rejected_alternatives_visible      { severity: critical }

# ====================== RECEIPTS ======================
receipt OvertonForecastReceipt {
  spectrum_before: OvertonSpectrum
  spectrum_after: OvertonSpectrum
  shifts: List[OvertonShiftEvent]
  epistemic_transition: :simulated → :published
  assumptions_hash: Hash
  audit_reference: Optional[PostAuditReceipt]
}

receipt PostAuditReceipt {
  predicted_vs_actual_delta: Decimal[2]
  manipulation_risk_detected: Decimal[2]
  closed_loop: Boolean
  honesty_statement: String
}

# ====================== WHAT THIS PROVES (V3 — Overton focus) ======================
# 1. A fully detailed Overton Window model as a multi-dimensional, auditable spectrum
# 2. Explicit Assumptions + Constraints specifically for Overton dynamics (Postulate 22, 25)
# 3. OvertonShiftEvent with cause, evidence_bundle, and rejected_alternatives (Postulate 24)
# 4. Prohibition of silent manipulation + synthetic-as-observed (Postulate 23 + 28)
# 5. PostAudit specifically for Overton forecasts (Postulate 26)
# 6. External Progression manages political cycles
# 7. Multi-module architecture + include + .iform-ready forms
# 8. A political scientist can read the code and understand the Overton model without knowledge of Igniter

end module