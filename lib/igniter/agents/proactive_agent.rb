# frozen_string_literal: true

require_relative "../integrations/agents"

module Igniter
  module Agents
    # Base class for proactive (self-initiating) agents.
    #
    # A reactive agent waits for messages. A *proactive* agent acts without
    # being asked — it polls conditions on a schedule, evaluates triggers, and
    # fires actions when conditions are met.
    #
    # == Design
    #
    # ProactiveAgent extends the standard Agent DSL with four new keywords:
    #
    #   intent      "Human-readable description of the agent's mission"
    #   scan_interval 5.0          # seconds between automatic scans
    #   watch  :metric, poll: ->   # callable returning a current reading
    #   trigger :name,             # rule: condition + action
    #     condition: ->(ctx) { ... },
    #     action:    ->(state:, context:) { ... }
    #
    # == Execution model
    #
    # Every +scan_interval+ seconds the agent's timer fires +:_scan+, which:
    #   1. Calls each registered watcher to build a +context+ snapshot.
    #   2. Evaluates every trigger's +condition+ against the context.
    #   3. Calls the +action+ of every condition that returns truthy.
    #   4. Merges context, scan count, and fired-trigger history into state.
    #
    # +:_scan+ can also be invoked programmatically (useful in specs):
    #   described_class.handlers[:_scan].call(state: state, payload: {})
    #
    # == Built-in message handlers (injected into every subclass)
    #
    #   :_scan           — run one scan cycle
    #   :pause           — suspend automatic reactions (scans still run)
    #   :resume          — resume reactions
    #   :status          — sync query → Status struct
    #   :context         — sync query → last context snapshot Hash
    #   :trigger_history — sync query → Array<FiredTrigger>
    #
    # == Initial state
    #
    # Call +proactive_initial_state+ instead of +initial_state+ to include
    # the required ProactiveAgent keys while also adding your own:
    #
    #   proactive_initial_state queue: [], threshold: 0.9
    #
    # == Example
    #
    #   class ErrorRateMonitor < Igniter::Agents::ProactiveAgent
    #     intent "Alert when error rate exceeds 5%"
    #     scan_interval 10.0
    #
    #     watch :error_rate, poll: -> { ErrorMetrics.current_rate }
    #
    #     trigger :high_errors,
    #       condition: ->(ctx) { ctx[:error_rate].to_f > 0.05 },
    #       action:    ->(state:, context:) {
    #         Notifier.alert("Error rate: #{context[:error_rate]}")
    #         state.merge(last_alert_at: Time.now)
    #       }
    #
    #     proactive_initial_state last_alert_at: nil
    #   end
    #
    #   ref = ErrorRateMonitor.start
    #   ref.call(:status)   # => Status(active: true, scan_count: 0, ...)
    #
    class ProactiveAgent < Igniter::Agent
      # Recorded when a trigger fires during a scan cycle.
      FiredTrigger = Struct.new(:name, :fired_at, :context, keyword_init: true)

      # Returned by the +:status+ sync query.
      Status = Struct.new(:active, :scan_count, :intent,
                          :watchers, :triggers, :last_scan_at,
                          keyword_init: true)

      class << self
        # ── DSL ─────────────────────────────────────────────────────────────

        # Declare the agent's human-readable mission (metadata only).
        def intent(desc = nil)
          return @intent if desc.nil?

          @intent = desc
        end

        # Set the scan interval in seconds and register the recurring timer.
        # The timer delegates to the +:_scan+ message handler so both the
        # production path and specs share identical logic.
        def scan_interval(seconds)
          klass = self
          schedule(:_scan, every: seconds.to_f) do |state:|
            h = klass.handlers[:_scan]
            h ? h.call(state: state, payload: {}) : nil
          end
        end

        # Register a watcher: a named, zero-argument callable that returns a
        # current reading of some value.  Called at the start of every scan.
        #
        # @param name [Symbol]
        # @param poll [#call]  — should never raise (errors are rescued to nil)
        def watch(name, poll:)
          (@watchers ||= {})[name.to_sym] = poll
        end

        # Register a trigger: evaluated on every scan cycle.
        # +condition+ receives the context Hash; +action+ receives
        # +state:+ and +context:+ and must return a new state Hash or nil.
        #
        # @param name      [Symbol]
        # @param condition [#call]  — (ctx) → truthy/falsy
        # @param action    [#call]  — (state:, context:) → Hash | nil
        def trigger(name, condition:, action:)
          (@proactive_triggers ||= {})[name.to_sym] = {
            condition: condition,
            action:    action
          }
        end

        # Read accessors (safe even before any DSL calls).
        def watchers            = @watchers           || {}
        def proactive_triggers  = @proactive_triggers || {}

        # Convenience: set the initial state including the ProactiveAgent keys.
        # Use instead of +initial_state+ to avoid forgetting required keys.
        #
        # @param extra [Hash]  additional subclass-specific keys
        def proactive_initial_state(extra = {})
          initial_state({
            active:          true,
            context:         {},
            scan_count:      0,
            last_scan_at:    nil,
            trigger_history: []
          }.merge(extra))
        end

        # ── Inheritance ──────────────────────────────────────────────────────

        def inherited(subclass)
          super  # Agent.inherited: resets @handlers, @timers, @default_state, …
          inject_proactive_handlers!(subclass)
        end

        private

        # Inject all ProactiveAgent-level handlers into +klass+.
        # Uses a captured +klass+ variable so the Procs access the correct
        # subclass even though their lexical +self+ is ProactiveAgent.
        def inject_proactive_handlers!(klass) # rubocop:disable Metrics/MethodLength
          # ── :_scan ────────────────────────────────────────────────────────
          klass.on(:_scan) do |state:, **|
            next state unless state.fetch(:active, true)

            ctx = klass.watchers.transform_values do |poll|
              poll.call
            rescue StandardError
              nil
            end

            fired     = []
            new_state = klass.proactive_triggers.reduce(state) do |s, (name, t)|
              next s unless t[:condition].call(ctx)

              fired << FiredTrigger.new(name: name, fired_at: Time.now, context: ctx)
              result = t[:action].call(state: s, context: ctx)
              result.is_a?(Hash) ? result : s
            end

            new_state.merge(
              context:         ctx,
              scan_count:      new_state.fetch(:scan_count, 0) + 1,
              last_scan_at:    Time.now,
              trigger_history: (new_state.fetch(:trigger_history, []) + fired).last(100)
            )
          end

          # ── :pause / :resume ──────────────────────────────────────────────
          klass.on(:pause)  { |state:, **| state.merge(active: false) }
          klass.on(:resume) { |state:, **| state.merge(active: true) }

          # ── :status ───────────────────────────────────────────────────────
          klass.on(:status) do |state:, **|
            Status.new(
              active:       state.fetch(:active, true),
              scan_count:   state.fetch(:scan_count, 0),
              intent:       klass.intent,
              watchers:     klass.watchers.keys,
              triggers:     klass.proactive_triggers.keys,
              last_scan_at: state[:last_scan_at]
            )
          end

          # ── :context ─────────────────────────────────────────────────────
          klass.on(:context) { |state:, **| state.fetch(:context, {}).dup }

          # ── :trigger_history ─────────────────────────────────────────────
          klass.on(:trigger_history) { |state:, **| state.fetch(:trigger_history, []).dup }
        end
      end
    end
  end
end
