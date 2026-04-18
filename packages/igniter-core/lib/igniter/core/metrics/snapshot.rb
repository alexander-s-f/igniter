# frozen_string_literal: true

module Igniter
  module Metrics
    # Immutable snapshot of collected metrics, safe to read from any thread.
    Snapshot = Struct.new(:counters, :histograms, keyword_init: true)
  end
end
