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
    # - Fan-out is synchronous: a handler that raises is removed and counted as
    #   failed, but a handler that merely blocks will stall the emit call.
    # - When the ring is full the oldest retained event is dropped and
    #   +dropped_total+ is incremented.
    # - No durable checkpoints in this v0 slice.
    #
    # Ordering policy:
    # - Sequences are assigned in emit-call order (monotonically increasing).
    # - IgniterStore emits the source fact BEFORE triggering derivations/scatters,
    #   so subscribers always see cause before effects.
    #
    # Replay cursor semantics (see #replay):
    # - nil cursor    → all retained events from oldest retained sequence.
    # - {sequence: N} → events with sequence > N.
    # - N < oldest-1  → :cursor_too_old (gap due to ring overflow).
    # - N >= newest   → empty :ok (caller is already at the head).
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

      # Replay retained ChangeEvents from the in-memory ring.
      #
      # +cursor+  — nil or { sequence: Integer }
      # +stores+  — nil (all) or Array of store name symbols/strings to filter
      # +limit+   — nil (all matching) or Integer cap on returned events
      #
      # Returns a Hash:
      #   {
      #     status:        :ok | :cursor_too_old,
      #     events:        [ChangeEvent, ...],
      #     cursor:        { sequence: N } | nil,
      #     oldest_cursor: { sequence: N } | nil,
      #     newest_cursor: { sequence: N } | nil,
      #     dropped_total: Integer
      #   }
      #
      # status :cursor_too_old means the requested sequence is older than the
      # oldest retained event AND there are dropped events in between — the
      # caller must recover from the fact log instead of relying on replay.
      def replay(cursor: nil, stores: nil, limit: nil)
        @mutex.synchronize do
          if @ring.empty?
            return {
              status:        :ok,
              events:        [],
              cursor:        nil,
              oldest_cursor: nil,
              newest_cursor: nil,
              dropped_total: @dropped_total
            }
          end

          oldest_seq = @ring.first.cursor[:sequence]
          newest_seq = @ring.last.cursor[:sequence]

          candidates =
            if cursor.nil?
              @ring.dup
            else
              req_seq = Integer(cursor[:sequence])

              # Gap check: there are events between req_seq+1 and oldest_seq-1
              # that were dropped from the ring.
              if req_seq < oldest_seq - 1
                return {
                  status:        :cursor_too_old,
                  events:        [],
                  cursor:        { sequence: newest_seq },
                  oldest_cursor: { sequence: oldest_seq },
                  newest_cursor: { sequence: newest_seq },
                  dropped_total: @dropped_total
                }
              end

              # Caller is already at or beyond the head — nothing new.
              if req_seq >= newest_seq
                return {
                  status:        :ok,
                  events:        [],
                  cursor:        { sequence: newest_seq },
                  oldest_cursor: { sequence: oldest_seq },
                  newest_cursor: { sequence: newest_seq },
                  dropped_total: @dropped_total
                }
              end

              @ring.select { |e| e.cursor[:sequence] > req_seq }
            end

          # Store filter
          if stores && !stores.empty?
            store_strs = Array(stores).map(&:to_s)
            candidates = candidates.select { |e| store_strs.include?(e.store.to_s) }
          end

          # Limit
          candidates = candidates.first(limit) if limit

          result_cursor =
            if candidates.last
              { sequence: candidates.last.cursor[:sequence] }
            else
              { sequence: newest_seq }
            end

          {
            status:        :ok,
            events:        candidates,
            cursor:        result_cursor,
            oldest_cursor: { sequence: oldest_seq },
            newest_cursor: { sequence: newest_seq },
            dropped_total: @dropped_total
          }
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
