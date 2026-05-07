olap_point Revenue {
  dimensions: {
    date: String,
    region: String,
    channel: String
  }
  measure: Decimal[2]
  granularity: { date: :daily }
  indexed: [:date, :region]
}

contract RegionalDailyRevenuePoint {
  input date: String
  input region: String
  input channel: String

  compute revenue_point: OLAPPoint[Decimal[2], {date: String, region: String, channel: String}] =
    Revenue[date: date, region: region, channel: channel]

  output revenue_point: Decimal[2]
}
