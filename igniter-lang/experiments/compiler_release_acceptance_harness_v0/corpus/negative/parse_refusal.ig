-- Harness negative corpus: Parse refusal specimen.
-- Missing colon after input name triggers ParseError.

module Harness.ParseRefusal

contract ParseRefusalTest {
  input a Integer
  output a: Integer
}
