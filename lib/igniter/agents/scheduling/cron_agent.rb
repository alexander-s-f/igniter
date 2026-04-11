# frozen_string_literal: true

module Igniter
  module Agents
    # Interval-based job scheduler with cron-like semantics.
    #
    # Jobs are registered with a name, an interval (seconds), and a callable.
    # A built-in schedule fires every second to advance due jobs.
    # The :_tick handler is also exposed for deterministic testing.
    #
    # @example
    #   ref = CronAgent.start
    #   ref.send(:add_job,
    #     name:     :cleanup,
    #     every:    3600,
    #     callable: -> { DataStore.purge_old_records }
    #   )
    #   status = ref.call(:list_jobs)  # => [{ name: :cleanup, every: 3600, runs: 0 }]
    class CronAgent < Igniter::Agent
      # Returned by :list_jobs sync query.
      JobInfo = Struct.new(:name, :every, :runs, :next_in, keyword_init: true)

      initial_state jobs: {}

      # Auto-advance due jobs every second.
      schedule(:tick, every: 1.0) do |state:|
        agent = new
        agent.send(:advance_jobs, state)
      end

      # Register or replace a job.
      #
      # Payload keys:
      #   name     [Symbol, String]  — unique job identifier
      #   every    [Numeric]         — interval in seconds
      #   callable [#call]           — called with no arguments when due
      on :add_job do |state:, payload:|
        name     = payload.fetch(:name).to_sym
        every    = payload.fetch(:every).to_f
        callable = payload.fetch(:callable)

        job = {
          name:      name,
          every:     every,
          callable:  callable,
          next_at:   Time.now.to_f + every,
          runs:      0
        }
        state.merge(jobs: state[:jobs].merge(name => job))
      end

      # Remove a job by name.
      #
      # Payload keys:
      #   name [Symbol, String]
      on :remove_job do |state:, payload:|
        name = payload.fetch(:name).to_sym
        state.merge(jobs: state[:jobs].reject { |k, _| k == name })
      end

      # Sync query — list registered jobs.
      #
      # @return [Array<JobInfo>]
      on :list_jobs do |state:, **|
        now = Time.now.to_f
        state[:jobs].values.map do |j|
          JobInfo.new(
            name:    j[:name],
            every:   j[:every],
            runs:    j[:runs],
            next_in: [j[:next_at] - now, 0].max.round(2)
          )
        end
      end

      # Manually advance jobs — useful for testing without real time delays.
      # Pass +at:+ to simulate a specific point in time.
      #
      # Payload keys:
      #   at [Float, nil] — Unix timestamp to use as "now" (default: Time.now.to_f)
      on :_tick do |state:, payload:|
        agent = new
        agent.send(:advance_jobs, state, payload[:at])
      end

      private

      # Run all jobs whose next_at has passed and reschedule them.
      # Errors in job callables are swallowed to keep the scheduler alive.
      #
      # @param state [Hash]
      # @param now   [Float, nil]
      # @return [Hash] updated state
      def advance_jobs(state, now = nil)
        now  = now || Time.now.to_f
        jobs = state[:jobs].transform_values do |job|
          next job if job[:next_at] > now

          begin
            job[:callable].call
          rescue StandardError
            nil # scheduler must not crash
          end
          job.merge(next_at: now + job[:every], runs: job[:runs] + 1)
        end
        state.merge(jobs: jobs)
      end
    end
  end
end
