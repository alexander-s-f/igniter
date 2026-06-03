-- stdlib_extension.ig
-- Conformance fixture verifying count, first, last, filter, sum, zip, and range.

module SparkCRM.Marketing

type Lead {
  lead_id: Integer,
  bid_amount: Integer,
  bid_decimal: Decimal[2]
}

type Pair {
  first: Integer,
  second: Integer
}

contract LeadConversionRate {
  input leads: Collection[Lead]
  input threshold: Integer

  compute total_high_value_bids =
    if count(leads) > 0 {
      if count(zip(range(0, count(leads)), range(0, count(leads)))) > 0 {
        if or_else(first(map(leads, l -> l.bid_amount)), 0) > 0 {
          if or_else(last(map(leads, l -> l.bid_amount)), 0) > 0 {
            sum(filter(leads, l -> l.bid_amount > threshold), :bid_decimal)
          } else {
            sum(leads, :bid_decimal)
          }
        } else {
          sum(leads, :bid_decimal)
        }
      } else {
        sum(leads, :bid_decimal)
      }
    } else {
      sum(leads, :bid_decimal)
    }

  output total_high_value_bids: Decimal[2]
}
