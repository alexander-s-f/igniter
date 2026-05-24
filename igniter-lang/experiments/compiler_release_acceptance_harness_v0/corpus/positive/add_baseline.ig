-- Harness positive corpus: Add-style baseline.
-- Compile unit 1 of 5. Minimal two-input integer sum.

module Harness.AddBaseline

contract AddBaseline {
  input a: Integer
  input b: Integer

  compute sum = a + b

  output sum: Integer
}
