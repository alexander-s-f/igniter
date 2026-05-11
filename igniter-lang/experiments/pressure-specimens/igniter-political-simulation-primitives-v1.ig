module IgniterPoliticalSimulationPrimitives

profile political_primitives
  time: bitemporal
  evidence: required
  trust: system

-- ====================== CORE TYPES ======================
type PoliticalActor {
  id: UUID
  name: String
  ideology_vector: Vector[7]          -- 7-dimensional ideological spectrum
  influence: Decimal[2]
  epistemic_kind: :observed | :inferred | :simulated
  uncertainty: Decimal[2]
}

type PolicyProposal {
  id: UUID
  title: String
  overton_position: Decimal[2]        -- 0.0 = unacceptable → 1.0 = consensus
  expected_impact: Map[String, Decimal[2]]
}

type DebateRound {
  topic: String
  participants: Set[PoliticalActor]
  clarity_score: Decimal[2]
  rejected_claims: List[ClaimRef]
}

-- ====================== ASSUMPTIONS & CONSTRAINTS (Postulate 22+25) ======================
assumptions political_dynamics {
  assumption homophily {
    kind: :empirical
    statement "People with similar views interact more often"
    strength: 0.78
  }
  assumption overton_shift_speed {
    kind: :heuristic
    statement "The Overton window moves no faster than 0.12 points per cycle."
    strength: 0.71
  }
}

constraints political_simulation {
  constraint no_silent_manipulation {
    kind: :ethical
    priority: 0.99
    statement "It is prohibited to hide synthetic data as observed"
  }
  constraint evidence_for_every_claim {
    kind: :epistemic
    priority: 1.0
    statement "Every statement in a simulation must have evidence"
  }
}

-- ====================== PURE CONTRACTS ======================
pure contract SimulateActorInteraction
  input actor_a: PoliticalActor
  input actor_b: PoliticalActor
  output influence_delta: Decimal[2] evidence [actor_a, actor_b]

pure contract DetectOvertonShift
  input proposals: List[PolicyProposal]
  output shifts: List[PolicyProposal] evidence [proposals]

receipt DebateReceipt { ... }

end module