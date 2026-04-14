# frozen_string_literal: true

require_relative "scheduler_adapter"
require_relative "scheduler"

module Igniter
  class Application
    # Default in-process scheduler adapter backed by one thread per job.
    class ThreadedSchedulerAdapter < SchedulerAdapter
      def start(config:, jobs:)
        return self if jobs.empty?

        @scheduler ||= Scheduler.new(logger: config.logger)
        configure_jobs_once!(jobs)
        @scheduler.start
        self
      end

      def stop
        @scheduler&.stop
      end

      private

      def configure_jobs_once!(jobs)
        return if @configured

        jobs.each do |job|
          @scheduler.add(job[:name], every: job[:every], at: job[:at], &job[:block])
        end
        @configured = true
      end
    end
  end
end
