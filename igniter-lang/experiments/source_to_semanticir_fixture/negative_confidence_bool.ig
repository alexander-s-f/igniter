module Fixture.SourceToSemanticIR.NegativeConfidence

type ConfidenceAssessment {
  assessment_id: String
  confidence_label: ConfidenceLabel
}

contract BadConfidenceAsBool {
  input confidence: ConfidenceAssessment
  compute allowed = confidence.confidence_label
  output allowed: Bool
}
