-- Harness negative corpus: Unresolved symbol refusal specimen.
-- Reference to undefined_var triggers OOF-P1 typechecker_oof diagnostic.

module Harness.UnresolvedSymbol

contract UnresolvedSymbolTest {
  input a: Integer

  compute bad_ref = a + undefined_var

  output bad_ref: Integer
}
