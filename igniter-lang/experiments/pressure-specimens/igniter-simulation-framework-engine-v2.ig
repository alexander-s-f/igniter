module IgniterSimulationFrameworkEngine

include IgniterSimulationFrameworkPrimitives

profile audited_simulation_framework
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

# ====================== EXTERNAL PROGRESSION — simulation steps ======================
service contract SimulationFrameworkOrchestrator
  progression driven_by clock.every(1.simulation_step)
  authority simulation_authority: AuthorityRef
{
  # 1. Observe / Ingest user-defined models & interactions
  observed contract LoadUserModels
    input user_definitions: List[SimulationModel]
    output models: List[SimulationModel]
    evidence [user_definitions]

  # 2. Run one simulation step (user-defined logic)
  pure contract RunSimulationStep
    input current_states: Map[UUID, SimulationState]
    input interactions: List[Interaction]
    uses assumptions simulation_framework
    uses constraints simulation_framework
    output next_states: Map[UUID, SimulationState]
    evidence [current_states, interactions, assumptions, constraints]

  # 3. Step forking (the main feature of the framework)
  pure contract CreateFork
    input current_simulation: UUID
    input at_step: Integer
    input branch_name: String
    input reason: String
    output fork: SimulationFork evidence [current_simulation, at_step]

  # 4. Time-travel + replay from any fork
  pure contract TimeTravelAndReplay
    input simulation_id: UUID
    input target_version_or_fork: UUID | Integer
    output replayed_states: List[SimulationState] evidence [simulation_id, target_version_or_fork]

  # 5. Act — persist fork / publish results (privileged)
  privileged contract PersistFork
    input fork: SimulationFork
    escape persist_to_mesh
    output receipt: ForkReceipt
    compensation RevertFork
    authority simulation_authority

  # 6. PostAudit for each fork and step (Postulate 26)
  audit contract PostStepAudit
    input step_receipt: SimulationStepReceipt
    input fork_receipt: Optional[ForkReceipt]
    input later_observation: Map[UUID, SimulationState]
    output audit_receipt: PostAuditReceipt
}

# ====================== INVARIANTS (maximum pressure on the framework) ======================
invariant every_step_has_evidence             { severity: critical }
invariant every_fork_has_postaudit            { severity: critical }
invariant no_hidden_simulation_state          { severity: critical }
invariant time_travel_preserve_causality      { severity: legal }
invariant fork_consistency                    { severity: critical }

# ====================== RECEIPTS ======================
receipt SimulationStepReceipt {
  simulation_id: UUID
  step_number: Integer
  states_before: Map[UUID, SimulationState]
  states_after: Map[UUID, SimulationState]
  interactions_applied: List[Interaction]
  epistemic_transition: :simulated → :executed
  assumptions_hash: Hash
  audit_reference: Optional[PostAuditReceipt]
}

receipt ForkReceipt {
  fork: SimulationFork
  parent_step: Integer
  branch_name: String
  epistemic_transition: :decided → :forked
  audit_reference: Optional[PostAuditReceipt]
}

receipt PostAuditReceipt {
  predicted_vs_actual_delta: Decimal[2]
  closed_loop: Boolean
  honesty_statement: String
}

# ====================== WHAT THIS PROVES ======================

# 1. Igniter Lang can be used as a full-fledged framework producer
# 2. The user defines models and interactions themselves (framework extensibility)
# 3. Built-in time-traveling + step forking (like git for simulations)
# 4. Full compliance with all Postulates 22–28 of the Covenant
# 5. External Progression controls simulation steps
# 6. Every branch, every step, every fork is fully auditable
# 7. Multi-module architecture + include + .iform-ready
# 8. Political scientists/researchers can write their own models without knowing the low-level details of Igniter

end module