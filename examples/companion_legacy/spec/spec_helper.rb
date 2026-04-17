# frozen_string_literal: true

require_relative "../lib/companion/boot"
require_relative "../stack"

Companion::Boot.setup_load_path!

require "igniter"
require "igniter/core"
require "igniter/sdk/ai"
require "base64"

COMPANION_ROOT = Companion::Boot.root unless defined?(COMPANION_ROOT)

Companion::Boot.configure_persistence!(app_name: :main)
Companion::Boot.load_demo!(real_llm: false)

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }

  config.after(:each) do
    Companion::NotesStore.reset! if defined?(Companion::NotesStore)
    Companion::ConversationStore.reset! if defined?(Companion::ConversationStore)
    Companion::TelegramBindingsStore.reset! if defined?(Companion::TelegramBindingsStore)
    Companion::ReminderStore.reset! if defined?(Companion::ReminderStore)
    Companion::NotificationPreferencesStore.reset! if defined?(Companion::NotificationPreferencesStore)
    Companion::CurrentSession.reset! if defined?(Companion::CurrentSession)
    Companion::Dashboard::ViewSubmissionStore.reset! if defined?(Companion::Dashboard::ViewSubmissionStore)
    Companion::Dashboard::TrainingCheckinStore.reset! if defined?(Companion::Dashboard::TrainingCheckinStore)
    Igniter::Plugins::View::SchemaStore.new.reset! if defined?(Igniter::Plugins::View::SchemaStore)
  end

  config.after(:suite) do
    Companion::Boot.reset_persistence!
  end
end
