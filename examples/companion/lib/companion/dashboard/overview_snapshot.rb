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
        schemas = view_schemas
        submissions = view_submissions(schemas)

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
            notification_preferences: preferences.size,
            view_schemas: schemas.size,
            view_submissions: submissions.size
          },
          notes: notes,
          reminders: reminders,
          telegram: {
            preferred_chat_id: Companion::TelegramBindingsStore.preferred_chat_id,
            latest_chat_id: Companion::TelegramBindingsStore.latest_chat_id,
            bindings: bindings
          },
          notification_preferences: preferences,
          execution_stores: execution_store_summary,
          view_schemas: schemas,
          view_submissions: submissions
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

      def view_schemas
        ViewSchemaCatalog.store.all.values
          .sort_by { |schema| schema.id.to_s }
          .map do |schema|
            {
              id: schema.id,
              title: schema.title,
              version: schema.version,
              kind: schema.kind,
              action_ids: schema.actions.keys.sort,
              view_path: "/views/#{schema.id}",
              api_path: "/api/views/#{schema.id}"
            }
          end
      end

      def view_submissions(schema_summaries)
        schema_index = schema_summaries.each_with_object({}) do |schema, memo|
          memo[schema.fetch(:id).to_s] = schema
        end

        ViewSubmissionStore.recent(limit: 8).map do |submission|
          schema = schema_index[submission.fetch("view_id")]
          {
            id: submission.fetch("id"),
            view_id: submission.fetch("view_id"),
            view_title: schema ? schema.fetch(:title) : submission.fetch("view_id"),
            action_id: submission.fetch("action_id"),
            status: submission.fetch("status"),
            schema_version: submission.fetch("schema_version"),
            created_at: submission.fetch("created_at"),
            processed_at: submission["processed_at"],
            processing_type: submission.dig("processing_result", "type"),
            detail_path: "/submissions/#{submission.fetch("id")}",
            view_path: schema ? schema.fetch(:view_path) : "/views/#{submission.fetch("view_id")}",
            api_path: schema ? schema.fetch(:api_path) : "/api/views/#{submission.fetch("view_id")}"
          }
        end
      end
    end
  end
end
