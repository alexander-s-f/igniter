# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contract :CountdownContract, outputs: %i[result mutation] do
      input :title
      input :target_date
      input :countdowns

      compute :normalized_title, depends_on: [:title] do |title:|
        title.to_s.strip
      end

      compute :normalized_target_date, depends_on: [:target_date] do |target_date:|
        target_date.to_s.strip
      end

      compute :next_id, depends_on: %i[normalized_title countdowns] do |normalized_title:, countdowns:|
        base = normalized_title.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-+\z/, "")
        base = "countdown" if base.empty?
        candidate = base
        suffix = 2
        while countdowns.any? { |entry| entry.id == candidate }
          candidate = "#{base}-#{suffix}"
          suffix += 1
        end
        candidate
      end

      compute :result, depends_on: %i[normalized_title normalized_target_date next_id] do |normalized_title:, normalized_target_date:, next_id:|
        if normalized_title.empty?
          Companion::Contracts.command_result(:failure, :blank_countdown_title, nil, :countdown_create_refused, :refused)
        elsif normalized_target_date.empty?
          Companion::Contracts.command_result(:failure, :blank_countdown_target, next_id, :countdown_create_refused, :refused)
        else
          Companion::Contracts.command_result(:success, :countdown_created, next_id, :countdown_created, :open)
        end
      end

      compute :mutation, depends_on: %i[result normalized_title normalized_target_date] do |result:, normalized_title:, normalized_target_date:|
        if result.fetch(:success)
          {
            operation: :append,
            record: {
              id: result.fetch(:subject_id),
              title: normalized_title,
              target_date: normalized_target_date
            }
          }
        else
          { operation: :none }
        end
      end

      output :result
      output :mutation
    end
  end
end
