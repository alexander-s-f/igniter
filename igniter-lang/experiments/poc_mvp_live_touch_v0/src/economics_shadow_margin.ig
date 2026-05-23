-- Synthetic order/channel economics toy model.
-- Independent compile unit 3 of 4.

module PocMvp.EconomicsShadow

contract EconomicsShadowMargin {
  input unit_margin: Integer
  input order_count: Integer

  compute margin_signal = unit_margin + order_count

  output margin_signal: Integer
}
