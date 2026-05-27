module Proof.IfExpr

contract NonBoolCondition {
  input a: Integer
  input b: Integer

  compute chosen = if a { a } else { b }

  output chosen: Integer
}
