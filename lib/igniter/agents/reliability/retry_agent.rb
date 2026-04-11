# frozen_string_literal: true

module Igniter
  module Agents
    # Executes a callable with automatic retry on failure.
    #
    # Supports three backoff strategies:
    # * :immediate   — retry without delay (useful in tests)
    # * :linear      — delay grows linearly: base_delay × attempt
    # * :exponential — delay doubles each time: base_delay × 2^(attempt-1)
    #                  Add jitter: true to randomise delay ±50%
    #
    # Messages that exhaust all retries are stored in the dead letter queue
    # and retrievable via the sync :dead_letters query.
    #
    # NOTE: The handler blocks the agent thread for the duration of all retries
    # plus sleep intervals. For long-running retries, consider a dedicated
    # RetryAgent instance per task.
    #
    # @example
    #   ref = RetryAgent.start
    #   ref.send(:with_retry,
    #     callable:    ->(x:) { ExternalService.call(x) },
    #     args:        { x: 42 },
    #     max_retries: 3,
    #     backoff:     :exponential,
    #     base_delay:  0.5
    #   )
    #   dead = ref.call(:dead_letters)  # => []  (on success)
    class RetryAgent < Igniter::Agent
      # Returned as a sync reply from :dead_letters.
      DeadLetter = Struct.new(:callable, :args, :error, :attempts, :ts, keyword_init: true)

      initial_state dead_letters: []

      # Execute +callable+ with retry.
      #
      # Payload keys:
      #   callable    [#call]           — required; receives **args
      #   args        [Hash]            — keyword arguments for callable (default: {})
      #   max_retries [Integer]         — maximum retry count (default: 3)
      #   backoff     [Symbol]          — :immediate / :linear / :exponential (default: :exponential)
      #   base_delay  [Float]           — base sleep time in seconds (default: 1.0)
      #   jitter      [Boolean]         — add random ±50% jitter to delay (default: false)
      on :with_retry do |state:, payload:|
        agent  = new
        letter = agent.send(:run_with_retry, payload)
        letter ? state.merge(dead_letters: state[:dead_letters] + [letter]) : state
      end

      # Sync query — returns Array<DeadLetter>.
      on :dead_letters do |state:, **|
        state[:dead_letters]
      end

      # Clear the dead letter queue.
      on :clear_dead_letters do |state:, **|
        state.merge(dead_letters: [])
      end

      private

      def run_with_retry(payload)
        callable    = payload.fetch(:callable)
        args        = payload.fetch(:args, {})
        max_retries = payload.fetch(:max_retries, 3).to_i
        backoff     = payload.fetch(:backoff, :exponential).to_sym
        base_delay  = payload.fetch(:base_delay, 1.0).to_f
        jitter      = payload.fetch(:jitter, false)

        attempt = 0
        begin
          attempt += 1
          callable.call(**args)
          nil # success
        rescue StandardError => e
          if attempt <= max_retries
            sleep compute_delay(backoff, base_delay, attempt, jitter)
            retry
          else
            DeadLetter.new(callable: callable, args: args,
                           error: e.message, attempts: attempt,
                           ts: Time.now.to_i)
          end
        end
      end

      def compute_delay(strategy, base, attempt, jitter)
        raw = case strategy
              when :immediate    then 0.0
              when :linear       then base * attempt
              when :exponential  then base * (2**(attempt - 1))
              else                    0.0
              end
        jitter ? raw * (0.5 + rand * 0.5) : raw
      end
    end
  end
end
