module Fixture.SourceToSemanticIR.Negative

contract BadUnresolvedSymbol {
  input a: Integer
  compute sum = a + missing_b
  output sum: Integer
}
