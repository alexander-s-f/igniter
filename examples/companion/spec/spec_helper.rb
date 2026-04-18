# frozen_string_literal: true

require "rspec"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require_relative "../stack"

Companion::Stack.setup_load_paths!

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
