# frozen_string_literal: true

module Igniter
  module Cluster
    module Trust
      class AdmissionPlan
        attr_reader :actions, :summary, :source

        def initialize(actions:, summary:, source: :mesh_trust_admission)
          @actions = Array(actions).map { |action| action.freeze }.freeze
          @summary = Hash(summary).freeze
          @source = source.to_sym
          freeze
        end

        def empty?
          actions.empty?
        end

        def approval_required?
          actions.any? { |action| action[:requires_approval] }
        end

        def to_h
          {
            source: source,
            actions: actions,
            summary: summary
          }
        end
      end
    end
  end
end
