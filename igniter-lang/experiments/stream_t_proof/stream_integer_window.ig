contract IntegerWindowSum {
  in device_id: String
  stream readings: Integer

  window "integer/{device_id}" {
    kind: :count,
    size: 3,
    on_close: :snapshot
  }

  compute total: Integer =
    fold_stream(readings, 0, (acc, reading) -> acc + reading) @window_bounded

  out snapshot: IntegerWindowSnapshot = {
    device_id: device_id,
    total: total,
    count: 3
  }
    lifecycle :durable
}
