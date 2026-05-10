module Proof.ContractModifiers.OofM1

pure contract BrokenPure {
  input sensor_id: String
  escape sensor_read
  output sensor_id: String
}
