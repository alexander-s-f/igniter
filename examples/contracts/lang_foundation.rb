#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))

require "igniter/lang"

backend = Igniter::Lang.ruby_backend
history_type = Igniter::Lang::History[Numeric]

compiled = backend.compile do
  input :price_history, type: history_type

  compute :latest_price,
          depends_on: [:price_history],
          return_type: Numeric,
          deadline: 50,
          wcet: 20 do |price_history:|
    price_history.fetch(:latest)
  end

  output :latest_price
end

result = backend.execute(compiled, inputs: { price_history: { latest: 120.0 } })
report = backend.verify(compiled)

puts "lang_foundation_latest_price=#{result.output(:latest_price)}"
puts "lang_foundation_descriptor=#{history_type.to_h.fetch(:kind)}"
puts "lang_foundation_report_ok=#{report.ok?}"
puts "lang_foundation_manifest_report_only=#{report.metadata_manifest.report_only?}"
