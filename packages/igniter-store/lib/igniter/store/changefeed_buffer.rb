# frozen_string_literal: true

require "securerandom"

module Igniter
  module Store
    # Bounded in-memory Changefeed buffer.
    #
    # Receives committed facts via +emit+, builds ChangeEvent objects with
    # monotonic sequence cursors, retains recent events in a bounded ring, and
    # fans out to registered subscriber handlers.
    #
    # Delivery semantics: best-effort live push.
    # - Slow or failing subscribers do not block the emit path (synchronous
    #   fan-out; if a handler raises it is removed and counted as failed).
    # - When the ring is full the oldest retained event is dropped and
    #   +dropped_total+ is incremented.
    # - No durable checkpoints in this v0 slice.
    #
    # Usage:
    #   buf    = ChangefeedBuffer.new(max_size: 1_000)
    #   handle = buf.subscribe(stores: [:tasks]) { |event| deliver(event) }
    #   buf.emit(fact)      # called after every committed fact write
    #   handle.close        # unsubscribes cleanly
    class ChangefeedBuffer
      DEFAULT_MAX_SIZE = 1_000

      # Returned by #subscribe. Call #close to unsubscribe.
      class Subscription
        def initialize(record, buffer)
          @record = record
          @buffer = buffer
        end

        def close
          @buffer.__send__(:remove_record, @record)
        end
      end

      SubscriptionRecord = Struct.new(:id, :stores, :handler, keyword_init: true)

      def initialize(max_size: DEFAULT_MAX_SIZE)
        @max_size        = max_size
        @ring            = []
        @records         = []
        @mutex           = Mutex.new
        @sequence        = 0
        @emitted_total   = 0
        @delivered_total = 0
        @dropped_total   = 0
        @failed_total    = 0
      end

      # Register a subscriber handler for one or more store names.
      # Returns a Subscription handle; call handle.close to unsubscribe.
      def subscribe(stores:, &handler)
        raise ArgumentError, "subscribe requires a block" unless handler

        record = SubscriptionRecord.new(
          id:      SecureRandom.hex(8),
          stores:  Array(stores).map(&:to_s),
          handler: handler
        )
        @mutex.synchronize { @records << record }
        Subscription.new(record, self)
      end

      # Build a ChangeEvent from +fact+, add to the ring buffer, and fan out
      # to all matching subscribers. Returns the emitted ChangeEvent.
      def emit(fact)
        event = @mutex.synchronize do
          @sequence += 1
          e = ChangeEvent.from_fact(fact, sequence: @sequence)
          @emitted_total += 1
          if @ring.size >= @max_size
            @ring.shift
            @dropped_total += 1
          end
          @ring << e
          e
        end

        fan_out(event)
        event
      end

      # Number of active subscribers, optionally filtered by store name.
      def subscriber_count(store = nil)
        @mutex.synchronize do
          if store
            @records.count { |r| r.stores.include?(store.to_s) }
          else
            @records.size
          end
        end
      end

      # Compact snapshot of current changefeed state for observability.
      def snapshot
        @mutex.synchronize do
          {
            emitted_total:    @emitted_total,
            delivered_total:  @delivered_total,
            dropped_total:    @dropped_total,
            failed_total:     @failed_total,
            buffered:         @ring.size,
            max_size:         @max_size,
            subscriber_count: @records.size,
            oldest_sequence:  @ring.first&.cursor&.fetch(:sequence, nil),
            newest_sequence:  @ring.last&.cursor&.fetch(:sequence, nil)
          }
        end
      end

      protected

      def remove_record(record)
        return unless record
        @mutex.synchronize { @records.reject! { |r| r.equal?(record) } }
      end

      private

      def fan_out(event)
        store_s  = event.store.to_s
        matching = @mutex.synchronize { @records.select { |r| r.stores.include?(store_s) }.dup }
        dead     = []
        matching.each do |record|
          record.handler.call(event)
          @mutex.synchronize { @delivered_total += 1 }
        rescue StandardError
          @mutex.synchronize { @failed_total += 1 }
          dead << record
        end
        dead.each { |r| remove_record(r) } unless dead.empty?
      end
    end
  end
end
