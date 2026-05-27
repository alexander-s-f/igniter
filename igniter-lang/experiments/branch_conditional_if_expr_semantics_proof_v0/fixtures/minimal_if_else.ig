module Proof.IfExpr

contract MinimalIfElse {
  input flag: Bool
  input a: Integer
  input b: Integer

  compute chosen = if flag { a } else { b }

  output chosen: Integer
}
