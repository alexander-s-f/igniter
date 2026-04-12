# frozen_string_literal: true

require_relative "../lib/companion/boot"
require_relative "../workspace"

Companion::Boot.setup_load_path!

require "igniter"
require "igniter/core"
require "igniter/ai"
require "base64"

COMPANION_ROOT = Companion::Boot.root unless defined?(COMPANION_ROOT)

Companion::Boot.load_demo!(real_llm: false)

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.after(:each) do
    Companion::NotesStore.reset! if defined?(Companion::NotesStore)
    Companion::ConversationStore.reset! if defined?(Companion::ConversationStore)
  end
end
