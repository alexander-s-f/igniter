# frozen_string_literal: true

module Igniter
  class Agent
    # External handle to a running agent.
    #
    # Callers interact with agents exclusively through Ref — they never touch
    # the Mailbox, StateHolder, or Thread directly. This allows the Supervisor
    # to swap out internals on restart without invalidating existing Ref objects.
    class Ref
      def initialize(thread:, mailbox:, state_holder:)
        @thread        = thread
        @mailbox       = mailbox
        @state_holder  = state_holder
        @mutex         = Mutex.new
      end

      # Asynchronous fire-and-forget. Returns self.
      def send(type, payload = {})
        mailbox.push(Message.new(type: type.to_sym, payload: payload))
        self
      end

      # Synchronous request-reply. Blocks until the handler responds or timeout
      # elapses. Raises Igniter::Agent::TimeoutError on timeout.
      def call(type, payload = {}, timeout: 5)
        reply_box = Mailbox.new(capacity: 1, overflow: :drop_newest)
        mailbox.push(Message.new(type: type.to_sym, payload: payload, reply_to: reply_box))
        reply = reply_box.pop(timeout: timeout)
        raise TimeoutError, "Agent did not reply within #{timeout}s" unless reply

        reply.payload[:value]
      end

      # Request graceful shutdown. Closes the mailbox so the runner exits after
      # processing any in-flight message. Blocks until the thread finishes.
      def stop(timeout: 5)
        mailbox.close
        thread&.join(timeout)
        self
      end

      # Forcefully terminate the agent thread.
      def kill
        thread&.kill
        mailbox.close
        self
      end

      def alive?
        thread&.alive? || false
      end

      # Read the current state snapshot without blocking the agent.
      def state
        state_holder.get
      end

      # Supervisor-internal: swap out internals when the agent restarts.
      # Callers keep the same Ref object; the new thread/mailbox/state_holder
      # are transparently injected.
      def rebind(thread:, mailbox:, state_holder:)
        @mutex.synchronize do
          @thread        = thread
          @mailbox       = mailbox
          @state_holder  = state_holder
        end
        self
      end

      private

      def thread
        @mutex.synchronize { @thread }
      end

      def mailbox
        @mutex.synchronize { @mailbox }
      end

      def state_holder
        @mutex.synchronize { @state_holder }
      end
    end
  end
end
