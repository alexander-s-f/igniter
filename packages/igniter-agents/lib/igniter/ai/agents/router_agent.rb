# frozen_string_literal: true

module Igniter
  module AI
    module Agents
    # Classifies incoming tasks by intent and dispatches to registered handlers.
    #
    # Two classification modes:
    # * **Keyword** (default) — checks whether the task string contains the
    #   intent name (case-insensitive). Zero external dependencies.
    # * **LLM-assisted** — uses an Igniter LLM executor to classify; falls back
    #   to keyword mode when the LLM returns an unrecognised intent.
    #
    # Handlers are callables that receive +task:+, +intent:+, and +context:+.
    # A fallback handler can be registered for unmatched tasks.
    #
    # @example Keyword routing
    #   ref = RouterAgent.start
    #   ref.send(:register_route, intent: :refund,   handler: RefundSkill.new)
    #   ref.send(:register_route, intent: :shipping, handler: ShippingSkill.new)
    #   ref.send(:set_fallback,   handler: ->(task:, **) { puts "Unknown: #{task}" })
    #   ref.send(:route, task: "I want a refund", context: { user_id: 42 })
    #
    # @example LLM routing
    #   ref = RouterAgent.start
    #   ref.send(:configure_llm, executor: MyLLMClassifier.new)
    #   ref.send(:register_route, intent: :billing, handler: BillingSkill.new)
    #   ref.send(:route, task: "charge me for the premium plan")
      class RouterAgent < Igniter::Agent
      # Returned by :routes sync query.
      RouteInfo = Struct.new(:intent, :handler_class, keyword_init: true)

      initial_state routes: {}, fallback_handler: nil, llm: nil

      # Register a handler for a named intent.
      #
      # Payload keys:
      #   intent  [Symbol, String]  — intent identifier
      #   handler [#call]           — receives (task:, intent:, context:)
      on :register_route do |state:, payload:|
        intent  = payload.fetch(:intent).to_sym
        handler = payload.fetch(:handler)
        state.merge(routes: state[:routes].merge(intent => handler))
      end

      # Remove a route.
      #
      # Payload keys:
      #   intent [Symbol, String]
      on :remove_route do |state:, payload:|
        intent = payload.fetch(:intent).to_sym
        state.merge(routes: state[:routes].reject { |k, _| k == intent })
      end

      # Set the fallback handler for unmatched tasks.
      #
      # Payload keys:
      #   handler [#call]  — receives (task:, intent:, context:)
      on :set_fallback do |state:, payload:|
        state.merge(fallback_handler: payload.fetch(:handler))
      end

      # Configure an LLM executor for intent classification.
      # The executor must respond to :call and receive a Hash with:
      #   task:, context:, intents: (Array<String> of registered intent names)
      # It must return a Hash with :intent key (String or Symbol).
      #
      # Payload keys:
      #   executor [#call]
      on :configure_llm do |state:, payload:|
        state.merge(llm: payload.fetch(:executor))
      end

      # Route a task to the appropriate handler.
      #
      # Payload keys:
      #   task       [String]        — the task or query to route
      #   context    [Hash]          — additional context forwarded to the handler
      #   on_unrouted [#call, nil]   — called with (task:, intent:) when no handler found
      on :route do |state:, payload:|
        agent = new
        agent.send(:dispatch, payload, state)
        state
      end

      # Sync query — list registered intents.
      #
      # @return [Array<RouteInfo>]
      on :routes do |state:, **|
        state[:routes].map { |intent, handler|
          RouteInfo.new(intent: intent, handler_class: handler.class.name)
        }
      end

      private

      def dispatch(payload, state)
        task        = payload.fetch(:task)
        context     = payload.fetch(:context, {})
        on_unrouted = payload[:on_unrouted] || state[:on_unrouted]
        routes      = state[:routes]
        llm         = state[:llm]

        intent  = llm ? classify_llm(task, context, routes, llm) : nil
        intent  = classify_keyword(task, routes) if intent.nil? || !routes.key?(intent)
        handler = routes[intent] || state[:fallback_handler]

        if handler
          handler.call(task: task, intent: intent, context: context)
        elsif on_unrouted
          on_unrouted.call(task: task, intent: intent)
        end
      end

      def classify_llm(task, context, routes, llm)
        result = llm.call(
          task:    task,
          context: context,
          intents: routes.keys.map(&:to_s)
        )
        result[:intent]&.to_sym
      rescue StandardError
        nil # fall through to keyword classification
      end

      def classify_keyword(task, routes)
        task_lower = task.to_s.downcase
        routes.keys.find { |intent| task_lower.include?(intent.to_s.downcase) }
      end
      end
    end
  end
end
