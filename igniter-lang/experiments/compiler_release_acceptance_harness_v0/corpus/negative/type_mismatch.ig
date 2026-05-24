-- Harness negative corpus: Type mismatch refusal specimen.
-- Adding Integer + Bool triggers OOF-TY0 typechecker_oof diagnostic.

module Harness.TypeMismatch

contract TypeMismatchTest {
  input count: Integer
  input flag: Bool

  compute bad_sum = count + flag

  output bad_sum: Integer
}
