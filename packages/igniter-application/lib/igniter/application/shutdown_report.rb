# frozen_string_literal: true

module Igniter
  module Application
    class ShutdownReport
      attr_reader :phases, :provider_shutdown_report, :snapshot

      def initialize(phases:, provider_shutdown_report:, snapshot:)
        @phases = phases.dup.freeze
        @provider_shutdown_report = provider_shutdown_report
        @snapshot = snapshot
        freeze
      end

      def scheduler_stopped?
        phase_completed?(:stop_scheduler)
      end

      def providers_shutdown?
        phase_completed?(:shutdown_providers)
      end

      def actions
        phases.select(&:completed?).map(&:name)
      end

      def to_h
        {
          phases: phases.map(&:to_h),
          actions: actions,
          provider_shutdown: provider_shutdown_report.to_h,
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
