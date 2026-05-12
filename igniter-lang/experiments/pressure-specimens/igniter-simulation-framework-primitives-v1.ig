module IgniterSimulationFrameworkPrimitives

profile simulation_primitives
  time: bitemporal
  evidence: required
  trust: system

# ====================== FRAMEWORK CORE TYPES ======================
type SimulationModel {
  id: UUID
  name: String
  state_type: TypeRef          # the user defines his own state type
  epistemic_kind: :observed | :inferred | :simulated
}

type SimulationState {
  model: SimulationModel
  data: Any                     # typed via state_type
  timestamp: Timestamp
  version: Integer
}

type Interaction {
  id: UUID
  from: SimulationModel
  to: SimulationModel
  action: String
  parameters: Map[String, Any]
  result: SimulationState
  evidence_bundle: EvidenceBundle
}

type SimulationFork {
  id: UUID
  parent_step: UUID
  branch_name: String
  reason: String
  assumptions_used: AssumptionSet
  constraints_obeyed: ConstraintSet
  rejected_alternatives: List[String]   # Postulate 24
}

# ====================== ASSUMPTIONS & CONSTRAINTS ======================
assumptions simulation_framework {
  assumption deterministic_by_default {
    kind: :empirical
    statement "In the absence of randomness, the step is deterministic"
    strength: 0.92
  }
}

constraints simulation_framework {
  constraint every_fork_audited {
    kind: :epistemic
    priority: 1.0
    statement "Every fork must have an auditable PostAuditReceipt"
  }
  constraint no_hidden_state {
    kind: :ethical
    priority: 0.99
    statement "All model states must be explicitly declared."
  }
}

# ====================== FRAMEWORK CONTRACTS (the user expands) ======================
pure contract DefineModel
  input model: SimulationModel
  output registered: Boolean evidence [model]

pure contract DefineInteraction
  input interaction: Interaction
  output registered: Boolean evidence [interaction]

pure contract ComputeNextState
  input current: SimulationState
  input interaction: Interaction
  output next: SimulationState evidence [current, interaction]

# ====================== TIME-TRAVEL & FORKING ======================
pure contract TimeTravelTo
  input simulation_id: UUID
  input target_version: Integer
  output state_snapshot: SimulationState evidence [simulation_id, target_version]

pure contract ForkSimulationAt
  input simulation_id: UUID
  input step: Integer
  input branch_name: String
  input reason: String
  output fork: SimulationFork evidence [simulation_id, step]

receipt SimulationStepReceipt { ... }
receipt ForkReceipt { ... }

end module