module Fixture.SourceToSemanticIR.NegativeAlert

type EvidenceLinkedAlertInput {
  signal_count: Integer
  claim_count: Integer
  valid_until: String
  confidence_label: ConfidenceLabel
}

contract BadEvidenceLessAlertGate {
  input alert: EvidenceLinkedAlertInput
  compute signal_present = alert.signal_count > 0
  compute claim_present = alert.claim_count > 0
  compute allowed = signal_present && claim_present
  output allowed: Bool
}
