# frozen_string_literal: true

module Igniter
  module Agents
    # Processes items in configurable batches with error tracking.
    #
    # Items are enqueued via :enqueue and processed synchronously via
    # :process_next (one batch) or :drain (all remaining items).
    # Failed items are tracked with their errors for inspection.
    #
    # @example
    #   processor = ->(item:) { DataStore.upsert(item) }
    #
    #   ref = BatchProcessorAgent.start(initial_state: { batch_size: 50 })
    #   ref.send(:enqueue, items: records, callable: processor)
    #   ref.send(:drain)
    #
    #   status = ref.call(:status)
    #   puts "processed=#{status.processed} failed=#{status.failed}"
    class BatchProcessorAgent < Igniter::Agent
      # Returned by the sync :status query.
      Status = Struct.new(:queue_size, :processed, :failed, keyword_init: true)

      initial_state queue: [], processed: 0, failed: 0, errors: [], batch_size: 10

      # Add items to the processing queue.
      #
      # Payload keys:
      #   items    [Array]  — required; items to process
      #   callable [#call]  — receives (item:); required unless set via :configure
      on :enqueue do |state:, payload:|
        items    = Array(payload.fetch(:items))
        callable = payload[:callable] || state[:callable]
        raise ArgumentError, ":callable required" unless callable

        jobs     = items.map { |item| { item: item, callable: callable } }
        state.merge(queue: state[:queue] + jobs)
      end

      # Process the next batch_size items.
      #
      # Payload keys:
      #   batch_size [Integer] — override class default (optional)
      on :process_next do |state:, payload:|
        size  = payload.fetch(:batch_size, state[:batch_size])
        agent = new
        agent.send(:run_batch, state, size)
      end

      # Process all remaining items synchronously (blocks until queue is empty).
      on :drain do |state:, payload:|
        size  = payload.fetch(:batch_size, state[:batch_size])
        agent = new
        agent.send(:run_all, state, size)
      end

      # Sync status query.
      #
      # @return [Status]
      on :status do |state:, **|
        Status.new(
          queue_size: state[:queue].size,
          processed:  state[:processed],
          failed:     state[:failed]
        )
      end

      # Return error log for failed items.
      #
      # @return [Array<Hash>]
      on :errors do |state:, **|
        state[:errors]
      end

      # Reset counters and clear errors (queue is preserved).
      on :reset_stats do |state:, **|
        state.merge(processed: 0, failed: 0, errors: [])
      end

      # Set default batch_size and/or default callable.
      #
      # Payload keys:
      #   batch_size [Integer]  — new default
      #   callable   [#call]    — new default callable
      on :configure do |state:, payload:|
        state.merge(
          batch_size: payload.fetch(:batch_size, state[:batch_size]),
          callable:   payload.fetch(:callable, state[:callable])
        )
      end

      private

      def run_batch(state, size)
        batch     = state[:queue].first(size)
        remaining = state[:queue].drop(size)
        result    = process_jobs(batch)
        apply_result(state, remaining, result)
      end

      def run_all(state, size)
        current = state
        current = run_batch(current, size) until current[:queue].empty?
        current
      end

      def process_jobs(batch)
        processed = 0
        failed    = 0
        errors    = []
        batch.each do |job|
          job[:callable].call(item: job[:item])
          processed += 1
        rescue StandardError => e
          failed += 1
          errors << { item: job[:item], error: e.message }
        end
        { processed: processed, failed: failed, errors: errors }
      end

      def apply_result(state, remaining, result)
        state.merge(
          queue:     remaining,
          processed: state[:processed] + result[:processed],
          failed:    state[:failed]    + result[:failed],
          errors:    state[:errors]    + result[:errors]
        )
      end
    end
  end
end
