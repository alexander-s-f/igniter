-- Harness positive corpus: Multi-input diversity case.
-- Compile unit 4 of 5.
-- Satisfies NB-1: mixed input types (Integer + Bool) in the same contract.
-- raw_score depends on two Integer inputs; is_valid passes through the Bool input.

module Harness.RiskScore

contract RiskScoreGate {
  input base: Integer
  input adjustment: Integer
  input active: Bool

  compute raw_score = base + adjustment
  compute is_valid = active

  output raw_score: Integer
  output is_valid: Bool
}
