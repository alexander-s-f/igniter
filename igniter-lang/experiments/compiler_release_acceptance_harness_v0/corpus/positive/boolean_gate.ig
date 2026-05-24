-- Harness positive corpus: Boolean gate / conjunction case.
-- Compile unit 2 of 5. Two Bool inputs, conjunction output.

module Harness.BooleanGate

contract BooleanGate {
  input flag_a: Bool
  input flag_b: Bool

  compute both_set = flag_a && flag_b

  output both_set: Bool
}
