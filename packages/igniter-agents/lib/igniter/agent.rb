# frozen_string_literal: true

require "igniter/core/errors"
require "igniter/core/runtime/agent_adapter"
require_relative "registry"
require_relative "agent/message"
require_relative "agent/mailbox"
require_relative "agent/state_holder"
require_relative "agent/runner"
require_relative "agent/ref"
require_relative "runtime/registry_agent_adapter"

module Igniter
  # Base class for stateful, message-driven actors.
  #
  # Subclass Agent and use the class-level DSL to declare:
  #   - `initial_state`  — default state hash for new instances
  #   - `on`             — handler for a named message type
  #   - `schedule`       — recurring timer handler
  #   - `mailbox_size`   — queue capacity (default: 256)
  #   - `mailbox_overflow` — policy when queue is full (:block/:drop_oldest/
  #                          :drop_newest/:error, default: :block)
  #   - `after_start`    — hook called when the agent thread begins
  #   - `after_crash`    — hook called with the error when the thread crashes
  #   - `after_stop`     — hook called when the agent thread exits
  #
  # Handler return-value semantics:
  #   Hash  → new state (replaces current state)
  #   :stop → shut down the agent cleanly
  #   nil   → unchanged state
  #   other → unchanged state; sent as reply to sync `call()` callers
  #
  # Example:
  #
  #   class CounterAgent < Igniter::Agent
  #     initial_state counter: 0
  #
  #     on :increment do |state:, payload:, **|
  #       state.merge(counter: state[:counter] + payload.fetch(:by, 1))
  #     end
  #
  #     on :count do |state:, **|
  #       state[:counter]   # returned as sync reply
  #     end
  #   end
  #
  #   ref = CounterAgent.start
  #   ref.send(:increment, by: 5)
  #   ref.call(:count)  # => 5
  #   ref.stop
  #
  class Agent
    # ── Custom error types ────────────────────────────────────────────────────

    class MailboxFullError < Igniter::Error; end
    class TimeoutError     < Igniter::Error; end

    # ── Class-level defaults ──────────────────────────────────────────────────

    @handlers         = {}
    @timers           = []
    @default_state    = {}
    @mailbox_capacity = Mailbox::DEFAULT_CAPACITY
    @mailbox_overflow = :block
    @hooks            = { start: [], crash: [], stop: [] }

    class << self
      attr_reader :handlers, :timers, :mailbox_capacity, :hooks

      # ── Inheritance ─────────────────────────────────────────────────────────

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@handlers,         {})
        subclass.instance_variable_set(:@timers,           [])
        subclass.instance_variable_set(:@default_state,    {})
        subclass.instance_variable_set(:@mailbox_capacity, Mailbox::DEFAULT_CAPACITY)
        subclass.instance_variable_set(:@mailbox_overflow, :block)
        subclass.instance_variable_set(:@hooks,            { start: [], crash: [], stop: [] })
      end

      # ── DSL ─────────────────────────────────────────────────────────────────

      # Set the initial state hash. Pass a plain Hash or a block returning one.
      def initial_state(hash = nil, &block)
        if block
          @default_state_proc = block
        else
          @default_state = (hash || {}).freeze
        end
      end

      # Return the resolved default state (evaluated fresh when a block was given).
      def default_state
        @default_state_proc ? @default_state_proc.call : @default_state
      end

      # Register a handler for messages of the given +type+.
      def on(type, &handler)
        @handlers[type.to_sym] = handler
      end

      # Register a recurring timer. The handler is called every +every+ seconds.
      # Returning a Hash from the handler updates state; nil leaves it unchanged.
      def schedule(name, every:, &handler)
        @timers << { name: name.to_sym, interval: every.to_f, handler: handler }
      end

      # Maximum number of messages in the mailbox before overflow policy applies.
      def mailbox_size(capacity)
        @mailbox_capacity = capacity
      end

      # Overflow policy when the mailbox is full.
      # One of: :block (default), :drop_oldest, :drop_newest, :error
      def mailbox_overflow(policy)
        @mailbox_overflow = policy
      end

      def after_start(&hook)
        @hooks[:start] << hook
      end

      def after_crash(&hook)
        @hooks[:crash] << hook
      end

      def after_stop(&hook)
        @hooks[:stop] << hook
      end

      # ── Factory ─────────────────────────────────────────────────────────────

      # Start the agent and return a Ref. The agent runs in a background Thread.
      #
      # Options:
      #   initial_state:  Hash — override class-level default state
      #   on_crash:       callable(error) — supervisor crash hook
      #   name:           Symbol/String — register in Igniter::Registry under this name
      #
      def start(initial_state: nil, on_crash: nil, name: nil) # rubocop:disable Metrics/MethodLength
        state_holder = StateHolder.new(initial_state || default_state)
        mailbox      = Mailbox.new(capacity: mailbox_capacity, overflow: @mailbox_overflow)
        runner       = Runner.new(
          agent_class: self,
          mailbox: mailbox,
          state_holder: state_holder,
          on_crash: on_crash
        )
        thread = runner.start
        ref    = Ref.new(thread: thread, mailbox: mailbox, state_holder: state_holder)

        Igniter::Registry.register!(name, ref) if name

        ref
      end
    end
  end
end

Igniter::Runtime.activate_agent_adapter! if Igniter::Runtime.agent_adapter.instance_of?(Igniter::Runtime::AgentAdapter)
