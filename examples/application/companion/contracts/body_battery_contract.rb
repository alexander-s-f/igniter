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

      piecewise :training_score, on: :training_minutes do
        eq 0, id: :none, value: 0
        between 1..45, id: :moderate, value: 10
        between 46..90, id: :heavy, value: 2
        default id: :overload, value: -12
      end

      scale :sleep_score, from: :sleep_hours do
        divide_by 8
        clamp 0, 1
        multiply_by 40
        round
      end

      formula :score do
        base 45
        add :sleep_score
        add :training_score
        clamp 0, 100
        round
      end

      piecewise :status, on: :score do
        between 80..100, id: :charged, value: "charged"
        between 60...80, id: :steady, value: "steady"
        between 40...60, id: :low, value: "low"
        default id: :recovery, value: "recovery"
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
