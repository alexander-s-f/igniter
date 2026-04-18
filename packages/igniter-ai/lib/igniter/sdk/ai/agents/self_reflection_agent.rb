# frozen_string_literal: true

module Igniter
  module AI
    module Agents
    # Reflects on a rolling window of past action episodes, surfaces patterns
    # in failures and successes, and proposes behavioural patches.
    #
    # Two reflection modes:
    # * **Heuristic** (default) — computes success rate and top failing actions;
    #   requires no external dependencies.
    # * **LLM-assisted** — delegates to any callable that accepts
    #   +reflection_prompt: String+ and returns a String summary.
    #
    # @example Record episodes and reflect
    #   ref = SelfReflectionAgent.start
    #   ref.send(:record_episode, action: :process_order, outcome: :success)
    #   ref.send(:record_episode, action: :send_email,    outcome: :failure, details: { reason: "timeout" })
    #   ref.send(:reflect)
    #   status = ref.call(:status)   # => StatusInfo struct
    #   recs   = ref.call(:reflections)
      class SelfReflectionAgent < Igniter::Agent
      # Sync-query return type.
      StatusInfo = Struct.new(:episodes, :reflections, :patches_applied,
                              :last_reflected_at, keyword_init: true)

      # A single recorded activity.
      Episode = Struct.new(:action, :outcome, :details, :occurred_at, keyword_init: true)

      # One completed reflection cycle.
      ReflectionRecord = Struct.new(:summary, :insights, :patch,
                                    :reflected_at, keyword_init: true)

      initial_state \
        episodes: [],
        reflections: [],
        patches: [],
        llm: nil,
        window: 50,
        patches_applied: 0

      # Record a single action outcome.
      #
      # Payload keys:
      #   action  [Symbol, String]  — name of the action performed
      #   outcome [Symbol]          — :success | :failure | any meaningful symbol
      #   details [Hash]            — optional extra context
      on :record_episode do |state:, payload:|
        ep = Episode.new(
          action:      payload.fetch(:action),
          outcome:     payload.fetch(:outcome),
          details:     payload.fetch(:details, {}),
          occurred_at: Time.now
        )
        # keep at most 2× the reflection window to avoid unbounded growth
        kept = (state[:episodes] + [ep]).last(state[:window] * 2)
        state.merge(episodes: kept)
      end

      # Run a reflection cycle over the latest +window+ episodes.
      # Appends a ReflectionRecord to the reflection log.
      on :reflect do |state:, payload:|
        agent = new
        rec   = agent.send(:run_reflection, state, payload || {})
        state.merge(reflections: state[:reflections] + [rec])
      end

      # Store an externally generated or LLM-proposed behavioural patch.
      #
      # Payload keys:
      #   patch [String]  — description of the proposed change
      on :apply_patch do |state:, payload:|
        entry   = { patch: payload.fetch(:patch), applied_at: Time.now }
        patches = state[:patches] + [entry]
        state.merge(patches: patches, patches_applied: state[:patches_applied] + 1)
      end

      # Sync query — current operational summary.
      #
      # @return [StatusInfo]
      on :status do |state:, **|
        last_r = state[:reflections].last
        StatusInfo.new(
          episodes:          state[:episodes].size,
          reflections:       state[:reflections].size,
          patches_applied:   state[:patches_applied],
          last_reflected_at: last_r&.reflected_at
        )
      end

      # Sync query — all ReflectionRecord objects.
      on :reflections do |state:, **|
        state[:reflections].dup
      end

      # Sync query — all recorded Episode objects.
      on :episodes do |state:, **|
        state[:episodes].dup
      end

      # Update agent configuration.
      #
      # Payload keys:
      #   llm    [#call, nil]  — optional LLM callable
      #   window [Integer]     — number of recent episodes to reflect on
      on :configure do |state:, payload:|
        state.merge(payload.slice(:llm, :window).compact)
      end

      # Clear all recorded state (does not reset configuration).
      on :reset do |state:, **|
        state.merge(episodes: [], reflections: [], patches: [], patches_applied: 0)
      end

      private

      def run_reflection(state, _payload)
        episodes = state[:episodes].last(state[:window])
        llm      = state[:llm]

        summary, insights, patch =
          if llm
            reflect_with_llm(llm, episodes)
          else
            reflect_heuristic(episodes)
          end

        ReflectionRecord.new(
          summary:      summary,
          insights:     insights,
          patch:        patch,
          reflected_at: Time.now
        )
      end

      def reflect_with_llm(llm, episodes)
        successes = episodes.count { |e| [:success, "success"].include?(e.outcome) }
        failures  = episodes.count { |e| [:failure, "failure"].include?(e.outcome) }
        digest    = episodes.map { |e| "#{e.action}:#{e.outcome}" }.join(", ")

        prompt = "Reflect on #{episodes.size} recent episodes " \
                 "(#{successes} succeeded, #{failures} failed): #{digest}. " \
                 "Provide a brief summary, up to 3 key insights, " \
                 "and one suggested behavioural patch."

        summary = llm.call(reflection_prompt: prompt).to_s
        [summary, [], nil]
      rescue StandardError
        reflect_heuristic(episodes)
      end

      def reflect_heuristic(episodes)
        return ["No episodes to reflect on.", [], nil] if episodes.empty?

        total    = episodes.size
        failures = episodes.select { |e| [:failure, "failure"].include?(e.outcome) }
        rate     = ((total - failures.size).to_f / total * 100).round(1)

        top_failing = failures.map(&:action).tally
                              .sort_by { |_, c| -c }
                              .first(3)

        insights = ["Success rate: #{rate}%"]
        unless top_failing.empty?
          insights << "Top failing actions: #{top_failing.map { |a, c| "#{a}(×#{c})" }.join(", ")}"
        end

        patch = if rate < 50
          "Consider retries or simplification for: #{top_failing.map(&:first).join(", ")}"
        end

        ["Reflected on #{total} episodes. #{rate}% success rate.", insights, patch]
      end
      end
    end
  end
end
