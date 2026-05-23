-- Synthetic order/channel economics toy model.
-- Independent compile unit 2 of 4.

module PocMvp.OrderReadiness

contract OrderReadinessGate {
  input inventory_ready: Bool
  input payment_ready: Bool

  compute ready = inventory_ready && payment_ready

  output ready: Bool
}
