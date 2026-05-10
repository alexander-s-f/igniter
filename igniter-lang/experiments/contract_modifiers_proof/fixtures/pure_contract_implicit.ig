module Proof.ContractModifiers.PureImplicit

contract ScoreRisk {
  input contradiction_count: Integer
  input corroboration_count: Integer
  compute raw = contradiction_count + corroboration_count
  output raw: Integer
}
