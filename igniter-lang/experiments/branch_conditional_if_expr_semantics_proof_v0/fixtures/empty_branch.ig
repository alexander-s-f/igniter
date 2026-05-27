module Proof.IfExpr

contract EmptyBranch {
  input flag: Bool
  input a: Integer

  compute chosen = if flag { } else { a }

  output chosen: Integer
}
