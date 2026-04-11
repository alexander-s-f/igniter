# frozen_string_literal: true

# Companion spec helper.
# Can be run standalone:  cd examples/companion && bundle exec rspec spec/
# Or via main suite:      bundle exec rake spec  (from repo root)

require "igniter"
require "igniter/tool"
require "igniter/skill"
require "igniter/integrations/agents"

COMPANION_ROOT = File.expand_path("..", __dir__) unless defined?(COMPANION_ROOT)

# Load companion code immediately — describe blocks reference constants at load time.

Dir[File.join(COMPANION_ROOT, "app/tools/**/*.rb")].sort.each  { |f| require f }
Dir[File.join(COMPANION_ROOT, "app/skills/**/*.rb")].sort.each { |f| require f }

require File.join(COMPANION_ROOT, "app/executors/mock_executors")

module Companion
  const_set(:WhisperExecutor, MockWhisperExecutor) unless const_defined?(:WhisperExecutor)
  const_set(:PiperExecutor,   MockPiperExecutor)   unless const_defined?(:PiperExecutor)
  const_set(:IntentExecutor,  MockIntentExecutor)  unless const_defined?(:IntentExecutor)
  const_set(:ChatExecutor,    MockChatExecutor)    unless const_defined?(:ChatExecutor)
end

Dir[File.join(COMPANION_ROOT, "app/contracts/**/*.rb")].sort.each { |f| require f }
Dir[File.join(COMPANION_ROOT, "app/agents/**/*.rb")].sort.each    { |f| require f }

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.after(:each) do
    Companion::NotesStore.reset! if defined?(Companion::NotesStore)
  end
end
