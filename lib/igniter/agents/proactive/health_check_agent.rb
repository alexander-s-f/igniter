# frozen_string_literal: true

require_relative "../proactive_agent"

module Igniter
  module Agents
    # Polls a set of named services and tracks their health status.
    #
    # HealthCheckAgent wraps ProactiveAgent with a +check+ DSL keyword that
    # registers both the watcher (poll callable) and a trigger that fires
    # when a service transitions to an unhealthy state.
    #
    # The poll callable should:
    # * Return a truthy value when the service is healthy.
    # * Return falsy OR raise when the service is unhealthy.
    #
    # @example
    #   class InfraHealth < Igniter::Agents::HealthCheckAgent
    #     intent "Monitor database, cache, and payment gateway"
    #     scan_interval 30.0
    #
    #     check :database,        poll: -> { DB.ping }
    #     check :redis,           poll: -> { Redis.current.ping == "PONG" }
    #     check :payment_gateway, poll: -> { PaymentClient.health_check }
    #   end
    #
    #   ref    = InfraHealth.start
    #   status = ref.call(:health)    # => { database: :healthy, redis: :unhealthy, … }
    #   all_ok = ref.call(:all_healthy)
    class HealthCheckAgent < ProactiveAgent
      # Recorded when a service's health changes (healthy ↔ unhealthy).
      Transition = Struct.new(:service, :from, :to, :occurred_at, keyword_init: true)

      proactive_initial_state health: {}, transitions: []

      class << self
        # Register a service health check.
        # Calling +check+ registers both the watcher and an unhealthy trigger.
        #
        # @param service [Symbol, String]
        # @param poll    [#call]  — returns truthy = healthy, falsy/raises = unhealthy
        def check(service, poll:)
          name = service.to_sym

          # Watcher: map poll result to :healthy / :unhealthy symbol
          watch(name, poll: -> {
            begin
              poll.call ? :healthy : :unhealthy
            rescue StandardError
              :unhealthy
            end
          })

          # Trigger: fires when service is unhealthy AND previous status differs
          trigger(:"health_#{name}",
            condition: ->(ctx) { ctx[name] == :unhealthy },
            action: ->(state:, context:) {
              prev   = state[:health][name]
              status = context[name]
              health = state[:health].merge(name => status)

              # Only record a transition when the status actually changes
              if prev != status
                t = Transition.new(
                  service:     name,
                  from:        prev || :unknown,
                  to:          status,
                  occurred_at: Time.now
                )
                transitions = (state[:transitions] + [t]).last(100)
                state.merge(health: health, transitions: transitions)
              else
                state.merge(health: health)
              end
            }
          )
        end
      end

      # ── Inheritance ────────────────────────────────────────────────────────
      # Re-inject HealthCheckAgent-specific handlers so that anonymous test
      # classes (Class.new(HealthCheckAgent)) also receive them.
      def self.inherited(subclass)
        super  # ProactiveAgent.inherited → resets @handlers, injects proactive ones
        inject_health_handlers!(subclass)
      end

      private_class_method def self.inject_health_handlers!(klass)
        klass.on(:health)      { |state:, **| state.fetch(:health, {}).dup }
        klass.on(:all_healthy) { |state:, **| state.fetch(:health, {}).values.all? { |v| v == :healthy } }
        klass.on(:transitions) { |state:, **| state.fetch(:transitions, []).dup }
        klass.on(:reset)       { |state:, **| state.merge(health: {}, transitions: []) }
      end

      # Sync query — current health status per service.
      #
      # @return [Hash<Symbol, :healthy | :unhealthy>]
      on :health do |state:, **|
        state.fetch(:health, {}).dup
      end

      # Sync query — true when all polled services are healthy.
      #
      # @return [Boolean]
      on :all_healthy do |state:, **|
        state.fetch(:health, {}).values.all? { |v| v == :healthy }
      end

      # Sync query — list of recorded health transitions.
      #
      # @return [Array<Transition>]
      on :transitions do |state:, **|
        state.fetch(:transitions, []).dup
      end

      # Reset health status and transition history.
      on :reset do |state:, **|
        state.merge(health: {}, transitions: [])
      end
    end
  end
end
