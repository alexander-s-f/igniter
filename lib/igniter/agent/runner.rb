# frozen_string_literal: true

module Igniter
  class Agent
    # Runs an agent's message loop in a dedicated Ruby Thread.
    #
    # Responsibilities:
    #   - Pop messages from the Mailbox and dispatch to registered handlers
    #   - Fire scheduled timers when their interval elapses
    #   - Apply handler return-value semantics to StateHolder
    #   - Invoke the on_crash callback when the thread dies unexpectedly
    #   - Fire lifecycle hooks (after_start, after_crash, after_stop)
    #
    # Handler return-value semantics:
    #   Hash  → replace agent state with the returned hash
    #   :stop → close the mailbox and exit the loop cleanly
    #   nil   → leave state unchanged (no reply sent to sync caller)
    #   other → leave state unchanged; if message has reply_to, send value as reply
    class Runner
      def initialize(agent_class:, mailbox:, state_holder:, on_crash: nil)
        @agent_class   = agent_class
        @mailbox       = mailbox
        @state_holder  = state_holder
        @on_crash      = on_crash
        @thread        = nil
        @timers        = build_timers
      end

      # Start the message loop in a background thread. Returns the Thread.
      def start
        @thread = Thread.new { run_loop }
        @thread.abort_on_exception = false
        @thread
      end

      attr_reader :thread

      private

      def run_loop # rubocop:disable Metrics/MethodLength
        fire_hooks(:start)
        loop do
          delay   = nearest_timer_delay
          message = @mailbox.pop(timeout: delay)
          fire_due_timers
          break if message.nil? && @mailbox.closed?

          dispatch(message) if message
        end
      rescue StandardError => e
        @on_crash&.call(e)
        fire_hooks(:crash, error: e)
      ensure
        fire_hooks(:stop)
      end

      def dispatch(message) # rubocop:disable Metrics/MethodLength
        handler = @agent_class.handlers[message.type]

        unless handler
          # Unknown message type — send nil reply if caller is waiting
          send_reply(message, nil)
          return
        end

        state  = @state_holder.get
        result = handler.call(state: state, payload: message.payload)

        case result
        when Hash
          @state_holder.set(result)
          send_reply(message, nil)
        when :stop
          send_reply(message, nil)
          @mailbox.close
        when nil
          send_reply(message, nil)
        else
          # Non-state return value — treat as sync reply payload
          send_reply(message, result)
        end
      end

      def send_reply(message, value)
        return unless message.reply_to

        message.reply_to.push(
          Message.new(type: :reply, payload: { value: value })
        )
      end

      # Returns seconds until the next timer fires, or nil if no timers.
      def nearest_timer_delay
        return nil if @timers.empty?

        now      = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        next_at  = @timers.map { |t| t[:next_at] }.min
        [next_at - now, 0].max
      end

      def fire_due_timers
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        @timers.each do |timer|
          next if timer[:next_at] > now

          state  = @state_holder.get
          result = timer[:handler].call(state: state)
          @state_holder.set(result) if result.is_a?(Hash)
          timer[:next_at] = now + timer[:interval]
        end
      end

      def build_timers
        now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        @agent_class.timers.map do |t|
          t.merge(next_at: now + t[:interval])
        end
      end

      def fire_hooks(type, **args)
        @agent_class.hooks[type]&.each do |hook|
          hook.call(**args)
        rescue StandardError
          nil # hooks must not crash the runner
        end
      end
    end
  end
end
