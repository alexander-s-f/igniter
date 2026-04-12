# frozen_string_literal: true

# Companion spec helper.
# Can be run standalone:  cd examples/companion_legacy && bundle exec rspec spec/
# Or via main suite:      bundle exec rake spec  (from repo root)

require_relative "../lib/companion/boot"

Companion::Boot.setup_load_path!

require "igniter"
require "igniter/core"
require "igniter/ai"

COMPANION_ROOT = Companion::Boot.root unless defined?(COMPANION_ROOT)

# Load companion code immediately — describe blocks reference constants at load time.
Companion::Boot.load_demo!(real_llm: false)

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.after(:each) do
    Companion::NotesStore.reset! if defined?(Companion::NotesStore)
  end
end
