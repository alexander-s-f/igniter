module Fixture.SourceToSemanticIR.ClaimEvidence

type Claim {
  claim_id: String
  subject_ref: String
  predicate: String
  object_value: String
}

type EvidenceLink {
  link_id: String
  source_ref: String
  target_ref: String
  relation: String
  strength: String
}

contract ClaimEvidenceBundle {
  input claim: Claim
  input evidence: EvidenceLink
  compute linked_claim_ref = evidence.target_ref
  output linked_claim_ref: String
}
