module Proof.IfExpr

contract MissingElse {
  input flag: Bool
  input a: Integer

  compute chosen = if flag { a }

  output chosen: Integer
}
