module Proof.IfExpr

contract NestedIfExpr {
  input flag: Bool
  input other: Bool
  input a: Integer
  input b: Integer
  input c: Integer

  compute chosen = if flag { if other { a } else { b } } else { c }

  output chosen: Integer
}
