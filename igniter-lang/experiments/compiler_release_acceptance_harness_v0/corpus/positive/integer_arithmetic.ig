-- Harness positive corpus: Integer arithmetic with three inputs.
-- Compile unit 3 of 5. Computed node depends on more than two inputs.

module Harness.IntegerArithmetic

contract IntegerArithmetic {
  input base: Integer
  input offset: Integer
  input multiplier: Integer

  compute shifted = base + offset
  compute scaled = shifted + multiplier

  output shifted: Integer
  output scaled: Integer
}
