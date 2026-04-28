# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :ReminderContract, outputs: %i[result mutation] do
      input :operation
      input :id
      input :title
      input :reminders

      compute :normalized_title, depends_on: [:title] do |title:|
        title.to_s.strip
      end

      compute :existing_reminder, depends_on: %i[reminders id] do |reminders:, id:|
        reminders.find { |entry| entry.id == id.to_s }
      end

      compute :next_id, depends_on: %i[normalized_title reminders] do |normalized_title:, reminders:|
        base = normalized_title.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-+\z/, "")
        base = "item" if base.empty?
        candidate = base
        suffix = 2
        while reminders.any? { |entry| entry.id == candidate }
          candidate = "#{base}-#{suffix}"
          suffix += 1
        end
        candidate
      end

      compute :result, depends_on: %i[operation normalized_title existing_reminder next_id id] do |operation:, normalized_title:, existing_reminder:, next_id:, id:|
        case operation.to_sym
        when :create
          if normalized_title.empty?
            Companion::Contracts.command_result(:failure, :blank_reminder, nil, :reminder_create_refused, :refused)
          else
            Companion::Contracts.command_result(:success, :reminder_created, next_id, :reminder_created, :open)
          end
        when :complete
          if existing_reminder
            Companion::Contracts.command_result(:success, :reminder_completed, existing_reminder.id, :reminder_completed, :done)
          else
            Companion::Contracts.command_result(:failure, :reminder_not_found, id.to_s, :reminder_complete_refused, :refused)
          end
        else
          Companion::Contracts.command_result(:failure, :reminder_operation_unknown, operation.to_s, :reminder_operation_refused, :refused)
        end
      end

      compute :mutation, depends_on: %i[operation result normalized_title] do |operation:, result:, normalized_title:|
        if result.fetch(:success)
          case operation.to_sym
          when :create
            {
              operation: :append,
              record: {
                id: result.fetch(:subject_id),
                title: normalized_title,
                due: "today",
                status: :open
              }
            }
          when :complete
            { operation: :update, id: result.fetch(:subject_id), changes: { status: :done } }
          else
            { operation: :none }
          end
        else
          { operation: :none }
        end
      end

      output :result
      output :mutation
    end
  end
end
