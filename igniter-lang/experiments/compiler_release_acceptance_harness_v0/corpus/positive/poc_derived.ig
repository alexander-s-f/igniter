-- Harness positive corpus: POC-derived synthetic micro-app unit.
-- Compile unit 5 of 5. Channel signal scoring model inspired by POC domain.

module Harness.ChannelScore

contract ChannelScore {
  input visits: Integer
  input conversions: Integer

  compute signal = visits + conversions

  output signal: Integer
}
