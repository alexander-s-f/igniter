module IgniterSwarmRescuePrimitives

profile rescue_primitives
  time: bitemporal
  evidence: required
  trust: system

-- ====================== SHARED TYPES ======================
type VictimSignature {
  id: UUID
  last_seen: Timestamp
  thermal_signature: Vector[8]
  movement_vector: Vector[3]
  uncertainty_m: Decimal[2]
  confidence: Decimal[2]
  epistemic_kind: :observed | :inferred | :estimated
}

type GlobalMap { ... }          -- stub for Collaborative SLAM
type LocalMap  { ... }

type RescueDecision {
  victim: VictimSignature
  assigned_drones: Set[DroneID]
  action: :hover | :drop_supplies | :evacuate | :mark_hazard
  priority: Decimal[2]
  rejected_alternatives: List[RejectedOption]     -- Postulate 24
  assumptions_used: AssumptionSet
  constraints_obeyed: ConstraintSet
}

-- ====================== ASSUMPTIONS & CONSTRAINTS (Postulate 22 + 25) ======================
assumptions rescue_operation {
  assumption battery_degradation { kind: :empirical; strength: 0.82; ... }
  assumption communication_blackout_probability { kind: :heuristic; strength: 0.65; ... }
}

constraints rescue_operation {
  constraint no_total_abandonment { kind: :ethical; priority: 0.98; ... }
  constraint max_drones_per_victim { kind: :resource; priority: 1.0; ... }
}

-- ====================== CORE PURE CONTRACTS ======================
pure contract FuseEKFAndSLAM
  input signatures: List[VictimSignature]
  input current_map: GlobalMap
  output fused: List[VictimSignature] evidence [signatures, current_map]

pure contract ComputeFlockingForces
  input drones: List[DronePose]
  input target: VictimSignature
  output forces: List[Vector[3]]

-- ====================== RECEIPT TYPES ======================
receipt FusionReceipt { ... }
receipt FlockingReceipt { ... }
