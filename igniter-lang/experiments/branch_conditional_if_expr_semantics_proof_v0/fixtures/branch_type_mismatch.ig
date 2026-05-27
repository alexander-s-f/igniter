module Proof.IfExpr

contract BranchTypeMismatch {
  input flag: Bool
  input a: Integer
  input title: String

  compute chosen = if flag { a } else { title }

  output chosen: Integer
}
