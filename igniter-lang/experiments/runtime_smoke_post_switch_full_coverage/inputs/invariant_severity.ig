module Fixture.InvariantSeverity
contract DrugOrderGate {
  input is_safe: Bool
  input has_warning: Bool
  compute approved = is_safe
  invariant safety_block
    predicate: approved
    severity: :error
    label: "REQ-SAFE-01"
    message: "Safety block"
  invariant interaction_warn
    predicate: has_warning
    severity: :warn
    message: "Interaction warning"
    overridable_with: :documented_justification
  invariant confidence_soft
    predicate: is_safe
    severity: :soft
  invariant latency_metric
    predicate: has_warning
    severity: :metric
  output approved: Bool
}
