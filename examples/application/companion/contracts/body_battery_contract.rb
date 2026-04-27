# frozen_string_literal: true

require_relative "../contracts"

module Companion
  module Contracts
    contracts :BodyBatteryContract, outputs: %i[score status recommendation] do
      input :snapshot

      compute :sleep_hours, depends_on: [:snapshot] do |snapshot:|
        Float(snapshot.fetch(:sleep_hours_today, 0))
      rescue ArgumentError, TypeError
        0.0
      end

      compute :training_minutes, depends_on: [:snapshot] do |snapshot:|
        Float(snapshot.fetch(:training_minutes_today, 0))
      rescue ArgumentError, TypeError
        0.0
      end

      compute :score, depends_on: %i[sleep_hours training_minutes] do |sleep_hours:, training_minutes:|
        sleep_score = [[sleep_hours / 8.0, 1.0].min * 40, 0].max
        training_score = if training_minutes.zero?
                           0
                         elsif training_minutes <= 45
                           10
                         elsif training_minutes <= 90
                           2
                         else
                           -12
                         end
        [[45 + sleep_score + training_score, 100].min, 0].max.round
      end

      compute :status, depends_on: [:score] do |score:|
        if score >= 80
          "charged"
        elsif score >= 60
          "steady"
        elsif score >= 40
          "low"
        else
          "recovery"
        end
      end

      compute :recommendation, depends_on: %i[score sleep_hours training_minutes] do |score:, sleep_hours:, training_minutes:|
        if sleep_hours < 6
          "Protect recovery today: keep the plan small and finish early."
        elsif training_minutes > 90
          "Training load is high. Add food, water, and a lighter evening."
        elsif score >= 80
          "Good energy window: schedule one focused block."
        else
          "Keep momentum with one low-friction task and a short walk."
        end
      end

      output :score
      output :status
      output :recommendation
    end
  end
end
