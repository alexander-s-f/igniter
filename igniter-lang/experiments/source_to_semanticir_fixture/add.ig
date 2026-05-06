module Fixture.SourceToSemanticIR.Add

contract Add {
  input a: Integer
  input b: Integer
  compute sum = a + b
  output sum: Integer
}
