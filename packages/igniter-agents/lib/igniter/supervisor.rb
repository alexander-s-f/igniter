# frozen_string_literal: true

require "igniter/errors"
require_relative "agent"

module Igniter
  # Supervises a group of agents and restarts them when they crash.
  #
  # Subclass Supervisor and declare children with the class-level DSL:
  #
  #   class AppSupervisor < Igniter::Supervisor
  #     strategy     :one_for_one   # default
  #     max_restarts 5, within: 60  # default
  #
  #     children do |c|
  #       c.worker :counter, CounterAgent
  #       c.worker :logger,  LoggerAgent, initial_state: { level: :info }
  #     end
  #   end
  #
  #   sup = AppSupervisor.start
  #   sup.child(:counter).send(:increment, by: 1)
  #   sup.stop
  #
  # Restart strategies:
  #   :one_for_one  — restart only the crashed agent (default)
  #   :one_for_all  — stop all agents and restart them all when any one crashes
  #
  # Restart budget: if more than +max_restarts+ crashes happen within +within+
  # seconds, the supervisor logs the failure and stops trying to restart.
  #
  class Supervisor
    class RestartBudgetExceeded < Igniter::Error; end

    # ── ChildSpec ────────────────────────────────────────────────────────────

    ChildSpec = Struct.new(:name, :agent_class, :init_opts, keyword_init: true)

    class ChildSpecBuilder
      attr_reader :specs

      def initialize
        @specs = []
      end

      def worker(name, agent_class, **opts)
        @specs << ChildSpec.new(name: name.to_sym, agent_class: agent_class, init_opts: opts)
      end
    end

    # ── Class-level defaults ─────────────────────────────────────────────────

    @strategy        = :one_for_one
    @max_restarts    = 5
    @restart_window  = 60
    @spec_builder    = ChildSpecBuilder.new

    class << self
      def inherited(subclass)
        super
        subclass.instance_variable_set(:@strategy,       :one_for_one)
        subclass.instance_variable_set(:@max_restarts,   5)
        subclass.instance_variable_set(:@restart_window, 60)
        subclass.instance_variable_set(:@spec_builder,   ChildSpecBuilder.new)
      end

      def strategy(sym)
        @strategy = sym
      end

      def max_restarts(count, within:)
        @max_restarts   = count
        @restart_window = within
      end

      def children(&block)
        block.call(@spec_builder)
      end

      def child_specs
        @spec_builder.specs
      end

      def start
        new.tap(&:start_all)
      end
    end

    # ── Instance ─────────────────────────────────────────────────────────────

    def initialize
      @refs          = {}
      @specs_by_name = {}
      @restart_log   = []
      @mutex         = Mutex.new
    end

    def start_all
      self.class.child_specs.each do |spec|
        @specs_by_name[spec.name] = spec
        start_child(spec)
      end
    end

    # Return the Ref for a named child. Returns nil if not found.
    def child(name)
      @mutex.synchronize { @refs[name.to_sym] }
    end

    # Stop all children gracefully.
    def stop
      refs = @mutex.synchronize { @refs.values.dup }
      refs.each do |ref|
        ref.stop
      rescue StandardError
        nil
      end
      self
    end

    private

    def start_child(spec)
      opts = spec.init_opts.dup
      opts[:on_crash] = ->(error) { handle_crash(spec, error) }
      ref = spec.agent_class.start(**opts)
      @mutex.synchronize { @refs[spec.name] = ref }
      ref
    end

    def handle_crash(spec, _error)
      check_restart_budget!

      case self.class.instance_variable_get(:@strategy)
      when :one_for_one
        start_child(spec)
      when :one_for_all
        stop_all_children
        self.class.child_specs.each { |s| start_child(s) }
      end
    rescue RestartBudgetExceeded => e
      warn "Igniter::Supervisor #{self.class.name}: #{e.message}"
    end

    def check_restart_budget! # rubocop:disable Metrics/MethodLength
      now    = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      window = self.class.instance_variable_get(:@restart_window).to_f
      max    = self.class.instance_variable_get(:@max_restarts)

      @mutex.synchronize do
        @restart_log.reject! { |t| now - t > window }
        @restart_log << now

        if @restart_log.size > max
          raise RestartBudgetExceeded,
                "#{@restart_log.size} crashes in #{window}s (max=#{max})"
        end
      end
    end

    def stop_all_children
      refs = @mutex.synchronize { @refs.values.dup }
      refs.each do |ref|
        ref.stop(timeout: 2)
      rescue StandardError
        nil
      end
    end
  end
end
