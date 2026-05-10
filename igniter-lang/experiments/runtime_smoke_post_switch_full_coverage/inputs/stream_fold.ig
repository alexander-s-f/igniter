observed contract IntegerWindowSum {
  input device_id: String
  stream readings: Integer

  window "integer/{device_id}" {
    kind: :count,
    size: 3,
    on_close: :snapshot
  }

  compute total: Integer =
    fold_stream(readings, 0, (acc, reading) -> acc + reading) @window_bounded

  output total: Integer
}
