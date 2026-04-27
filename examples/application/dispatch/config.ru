# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../../packages/igniter-application/lib", __dir__))

require_relative "app"

run ->(_env) { [404, { "content-type" => "text/plain" }, ["Dispatch Web surface is implemented by the Web slice.\n"]] }
