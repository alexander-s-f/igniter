-- Synthetic order/channel economics toy model.
-- Independent compile unit 1 of 4.

module PocMvp.ChannelSignal

contract ChannelSignalScore {
  input visits: Integer
  input add_to_cart: Integer

  compute signal_score = visits + add_to_cart

  output signal_score: Integer
}
