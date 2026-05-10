module Proof.ContractModifiers.ObservedBasic

observed contract ReadSensor {
  input sensor_id: String
  escape sensor_read
  output sensor_id: String
}
