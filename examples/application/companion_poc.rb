#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-ai/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-hub/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-ledger/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-durable-model/lib", __dir__))

require_relative "companion/runtime"

Companion::Runtime.call(ARGV)
