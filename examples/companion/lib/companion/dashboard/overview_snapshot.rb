# frozen_string_literal: true

module Companion
  module Dashboard
    module OverviewSnapshot
      module_function

      def build
        notes = Companion::NotesStore.all
        reminders = Companion::ReminderStore.active
        bindings = Companion::TelegramBindingsStore.all.values.sort_by { |binding| binding["updated_at"].to_s }.reverse
        preferences = notification_preferences

        {
          generated_at: Time.now.utc.iso8601,
          stack: {
            apps: Companion::Stack.app_names.map(&:to_s),
            default_app: Companion::Stack.default_app.to_s
          },
          counts: {
            notes: notes.size,
            active_reminders: reminders.size,
            telegram_bindings: bindings.size,
            notification_preferences: preferences.size
          },
          notes: notes,
          reminders: reminders,
          telegram: {
            preferred_chat_id: Companion::TelegramBindingsStore.preferred_chat_id,
            latest_chat_id: Companion::TelegramBindingsStore.latest_chat_id,
            bindings: bindings
          },
          notification_preferences: preferences,
          execution_stores: execution_store_summary
        }
      end

      def notification_preferences
        Companion::NotificationPreferencesStore.all
      end

      def execution_store_summary
        Companion::Stack.app_names.each_with_object({}) do |app_name, memo|
          store = Companion::Boot.default_execution_store(app_name: app_name)
          memo[app_name.to_s] = {
            class: store.class.name,
            total: safe_store_ids(store, :list_all).size,
            pending: safe_store_ids(store, :list_pending).size
          }
        end
      end

      def safe_store_ids(store, method_name)
        return [] unless store.respond_to?(method_name)

        Array(store.public_send(method_name))
      rescue StandardError
        []
      end
    end
  end
end
