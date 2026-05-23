-- Synthetic order/channel economics toy model.
-- Independent compile unit 4 of 4.

module PocMvp.FulfillmentAttention

contract FulfillmentAttentionTrace {
  input late_count: Integer
  input exception_count: Integer

  compute attention_score = late_count + exception_count

  output attention_score: Integer
}
