# frozen_string_literal: true

require_relative "../proactive_agent"

module Igniter
  module Agents
    # Threshold-based alerting agent.
    #
    # AlertAgent extends ProactiveAgent with an opinionated DSL for declaring
    # numeric thresholds.  A single +monitor+ / +threshold+ pair registers both
    # the watcher and the trigger automatically.
    #
    # @example
    #   class ApiAlerts < Igniter::Agents::AlertAgent
    #     intent "Alert when API error rate or latency spikes"
    #     scan_interval 15.0
    #
    #     monitor :error_rate,  source: -> { Metrics.error_rate }
    #     monitor :p99_latency, source: -> { Metrics.p99 }
    #
    #     threshold :error_rate,  above: 0.05
    #     threshold :p99_latency, above: 500
    #   end
    #
    #   ref    = ApiAlerts.start
    #   alerts = ref.call(:alerts)   # => Array<AlertRecord>
    class AlertAgent < ProactiveAgent
      # Immutable record created when a threshold is breached.
      AlertRecord = Struct.new(:metric, :value, :kind, :threshold,
                               :fired_at, keyword_init: true)

      proactive_initial_state alerts: [], silenced: false

      class << self
        # Register a polling source for a named metric.
        # Usually called before +threshold+ for the same metric name.
        #
        # @param metric [Symbol, String]
        # @param source [#call]  — zero-argument callable returning a Numeric
        def monitor(metric, source:)
          watch(metric.to_sym, poll: source)
        end

        # Declare a threshold for a watched metric.
        # Automatically registers a trigger that fires when the condition is met.
        #
        # @param metric [Symbol, String]
        # @param above  [Numeric, nil]  — breach if value > above
        # @param below  [Numeric, nil]  — breach if value < below
        def threshold(metric, above: nil, below: nil)
          name = metric.to_sym

          trigger(:"threshold_#{name}",
            condition: ->(ctx) {
              val = ctx[name]
              return false if val.nil?

              (above && val.to_f > above.to_f) ||
                (below && val.to_f < below.to_f)
            },
            action: ->(state:, context:) {
              next state if state[:silenced]

              val  = context[name]
              kind = above && val.to_f > above.to_f ? :above : :below
              rec  = AlertRecord.new(
                metric:    name,
                value:     val,
                kind:      kind,
                threshold: kind == :above ? above : below,
                fired_at:  Time.now
              )
              state.merge(alerts: (state[:alerts] + [rec]).last(200))
            }
          )
        end
      end

      # ── Inheritance ────────────────────────────────────────────────────────
      # Re-inject AlertAgent-specific handlers into every subclass so that
      # anonymous test classes (Class.new(AlertAgent)) also have them.
      def self.inherited(subclass)
        super  # ProactiveAgent.inherited → resets @handlers, injects proactive ones
        inject_alert_handlers!(subclass)
      end

      private_class_method def self.inject_alert_handlers!(klass)
        klass.on(:silence)      { |state:, **| state.merge(silenced: true)  }
        klass.on(:unsilence)    { |state:, **| state.merge(silenced: false) }
        klass.on(:alerts)       { |state:, **| state.fetch(:alerts, []).dup }
        klass.on(:clear_alerts) { |state:, **| state.merge(alerts: []) }
      end

      # Suppress alert creation (scans and condition checks still run).
      on :silence   do |state:, **| state.merge(silenced: true)  end
      on :unsilence do |state:, **| state.merge(silenced: false) end

      # Sync query — all recorded AlertRecord objects.
      #
      # @return [Array<AlertRecord>]
      on :alerts do |state:, **|
        state.fetch(:alerts, []).dup
      end

      # Clear alert history.
      on :clear_alerts do |state:, **|
        state.merge(alerts: [])
      end
    end
  end
end
