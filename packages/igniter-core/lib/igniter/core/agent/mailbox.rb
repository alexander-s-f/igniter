# frozen_string_literal: true

module Igniter
  class Agent
    # Thread-safe bounded queue for passing Messages between threads.
    #
    # Overflow policies (applied when capacity is reached):
    #   :block      — block the caller until space is available (default)
    #   :drop_oldest — discard the oldest message and enqueue the new one
    #   :drop_newest — discard the incoming message silently
    #   :error      — raise Igniter::Agent::MailboxFullError
    class Mailbox
      DEFAULT_CAPACITY = 256

      def initialize(capacity: DEFAULT_CAPACITY, overflow: :block)
        @capacity = capacity
        @overflow = overflow
        @queue    = []
        @mutex    = Mutex.new
        @not_empty = ConditionVariable.new
        @not_full  = ConditionVariable.new
        @closed    = false
      end

      # Enqueue a message. Returns self (chainable).
      def push(message) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
        @mutex.synchronize do
          return self if @closed

          if @queue.size >= @capacity
            case @overflow
            when :block
              @not_full.wait(@mutex) while @queue.size >= @capacity && !@closed
              return self if @closed
            when :drop_oldest
              @queue.shift
            when :drop_newest
              return self
            when :error
              raise MailboxFullError, "Mailbox full (capacity=#{@capacity})"
            end
          end

          @queue << message
          @not_empty.signal
        end
        self
      end

      # Dequeue the next message. Blocks until a message arrives or the mailbox
      # is closed. Returns nil if closed and empty, or if +timeout+ expires.
      def pop(timeout: nil) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
        @mutex.synchronize do
          if timeout
            deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
            while @queue.empty? && !@closed
              remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
              return nil if remaining <= 0

              @not_empty.wait(@mutex, remaining)
            end
          else
            @not_empty.wait(@mutex) while @queue.empty? && !@closed
          end

          return nil if @queue.empty?

          msg = @queue.shift
          @not_full.signal
          msg
        end
      end

      # Close the mailbox. Blocked callers in +pop+ wake up and return nil.
      def close
        @mutex.synchronize do
          @closed = true
          @not_empty.broadcast
          @not_full.broadcast
        end
      end

      def closed?
        @mutex.synchronize { @closed }
      end

      def size
        @mutex.synchronize { @queue.size }
      end

      def empty?
        @mutex.synchronize { @queue.empty? }
      end
    end
  end
end
