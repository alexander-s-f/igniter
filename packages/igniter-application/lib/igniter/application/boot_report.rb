# frozen_string_literal: true

module Igniter
  module Application
    class BootReport
      attr_reader :base_dir, :phases, :snapshot

      def initialize(base_dir:, phases:, snapshot:)
        @base_dir = base_dir
        @phases = phases.dup.freeze
        @snapshot = snapshot
        freeze
      end

      def loaded_code?
        phase_completed?(:load_code)
      end

      def providers_resolved?
        phase_completed?(:resolve_providers)
      end

      def scheduler_started?
        phase_completed?(:start_scheduler)
      end

      def transport_activated?
        phase_completed?(:activate_transport)
      end

      def actions
        phases.select(&:completed?).map(&:name)
      end

      def to_h
        {
          base_dir: base_dir,
          phases: phases.map(&:to_h),
          actions: actions,
          snapshot: snapshot.to_h
        }
      end

      private

      def phase_completed?(name)
        phase = phases.find { |entry| entry.name == name.to_sym }
        phase&.completed? == true
      end
    end
  end
end
