# frozen_string_literal: true

module Igniter
  class App
    # Lightweight pure-Ruby scheduler for recurring background jobs.
    # Uses one Thread per job — no external dependencies.
    #
    # Usage:
    #   s = Scheduler.new
    #   s.add :cleanup, every: "1h" do ... end
    #   s.add :report,  every: "1d", at: "09:00" do ... end
    #   s.start
    #   # later:
    #   s.stop
    #
    # Interval formats accepted by `every:`:
    #   Integer / Float  — seconds
    #   "30s"            — 30 seconds
    #   "5m"             — 5 minutes
    #   "2h"             — 2 hours
    #   "1d"             — 1 day
    #   { hours: 1, minutes: 30 }
    class Scheduler
      Job = ::Data.define(:name, :interval, :at_time, :block)

      def initialize(logger: nil)
        @jobs    = []
        @threads = []
        @logger  = logger
        @mu      = Mutex.new
        @running = false
      end

      def add(name, every:, at: nil, &block)
        @jobs << Job.new(
          name: name.to_sym,
          interval: parse_interval(every),
          at_time: at,
          block: block
        )
      end

      def start
        @mu.synchronize { @running = true }
        @jobs.each { |job| @threads << Thread.new { run_job(job) } }
        self
      end

      def stop
        @mu.synchronize { @running = false }
        @threads.each(&:kill)
        @threads.clear
      end

      def job_names
        @jobs.map(&:name)
      end

      private

      def run_job(job)
        sleep initial_delay(job)
        loop do
          break unless @mu.synchronize { @running }

          begin
            job.block.call
          rescue => e # rubocop:disable Style/RescueStandardError
            @logger&.error("Scheduler job failed", name: job.name, error: e.message)
          end

          sleep job.interval
        end
      end

      # If `at:` is given (e.g. "09:00"), delay until the next occurrence of that time.
      def initial_delay(job)
        return 0 unless job.at_time

        h, m   = job.at_time.split(":").map(&:to_i)
        now    = Time.now
        target = Time.new(now.year, now.month, now.day, h, m, 0)
        target += 86_400 if target <= now
        target - now
      end

      def parse_interval(val) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity
        case val
        when Integer, Float then val.to_f
        when String
          case val
          when /\A(\d+)s\z/i then Regexp.last_match(1).to_f
          when /\A(\d+)m\z/i then Regexp.last_match(1).to_f * 60
          when /\A(\d+)h\z/i then Regexp.last_match(1).to_f * 3600
          when /\A(\d+)d\z/i then Regexp.last_match(1).to_f * 86_400
          else raise ArgumentError, "Unknown interval: #{val.inspect} (use 30s / 5m / 2h / 1d)"
          end
        when Hash
          val.fetch(:seconds, 0) +
            val.fetch(:minutes, 0) * 60 +
            val.fetch(:hours, 0) * 3600 +
            val.fetch(:days, 0) * 86_400
        else
          raise ArgumentError, "Interval must be Integer, String, or Hash; got #{val.class}"
        end
      end
    end
  end
end
