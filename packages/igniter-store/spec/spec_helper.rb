# frozen_string_literal: true

require "rspec"

require_relative "../lib/igniter-store"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
