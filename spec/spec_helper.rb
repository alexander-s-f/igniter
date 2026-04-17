# frozen_string_literal: true

require "igniter"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.around do |example|
    runtime_context_defined = defined?(Igniter::App::RuntimeContext)
    previous_context = Igniter::App::RuntimeContext.current if runtime_context_defined
    Igniter::App::RuntimeContext.current = nil if runtime_context_defined
    example.run
  ensure
    next unless defined?(Igniter::App::RuntimeContext)

    Igniter::App::RuntimeContext.current = runtime_context_defined ? previous_context : nil
  end
end
