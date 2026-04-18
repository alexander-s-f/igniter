# frozen_string_literal: true

module Igniter
  module Cluster
    module Trust
      class AdmissionResult
        attr_reader :applied, :blocked, :summary

        def initialize(applied:, blocked:, summary:)
          @applied = Array(applied).map(&:freeze).freeze
          @blocked = Array(blocked).map(&:freeze).freeze
          @summary = Hash(summary).freeze
          freeze
        end

        def applied?
          applied.any?
        end

        def blocked?
          blocked.any?
        end

        def to_h
          {
            applied: applied,
            blocked: blocked,
            summary: summary
          }
        end
      end
    end
  end
end
