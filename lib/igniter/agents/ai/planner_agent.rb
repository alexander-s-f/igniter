# frozen_string_literal: true

module Igniter
  module Agents
    # Decomposes a goal into an ordered sequence of steps and executes them.
    #
    # Implements a lightweight ReAct-style planning loop:
    # 1. +:plan+ — decompose a goal into steps (LLM or rule-based fallback)
    # 2. +:execute_next+ — execute one step and advance the cursor
    # 3. +:run_to_completion+ — plan + execute all steps in a single call
    #
    # == Step decomposition
    #
    # When a +planner:+ callable is configured it receives +goal:+ and
    # +context:+ and must return one of:
    # * +Array<String>+ — one element per step description
    # * +String+ — newline-separated or numbered list; parsed automatically
    # * +Hash+ with +:steps+ key
    #
    # Without a planner the goal itself becomes a single-step plan.
    #
    # == Step execution
    #
    # When a +step_handler:+ callable is configured it receives:
    #   step:    [String]  — step description
    #   index:   [Integer] — zero-based step index
    #   context: [Hash]    — shared execution context
    #   results: [Array]   — results from previous steps
    #
    # Without a handler, steps are marked :skipped.
    #
    # @example
    #   planner = ->(goal:, context:) { MyDecomposerSkill.call(goal: goal).steps }
    #   executor = ->(step:, index:, context:, results:) { RunStep.call(step) }
    #
    #   ref = PlannerAgent.start(initial_state: {
    #     planner:      planner,
    #     step_handler: executor
    #   })
    #   ref.send(:run_to_completion, goal: "Build a landing page", context: { tone: :casual })
    #   puts ref.call(:status).inspect
    class PlannerAgent < Igniter::Agent
      # Immutable step record.
      Step = Struct.new(:index, :description, :status, :result, keyword_init: true)

      # Returned by the sync :status query.
      PlanStatus = Struct.new(:goal, :total_steps, :current_step,
                               :completed, :failed, keyword_init: true)

      initial_state planner: nil, step_handler: nil, plan: [], current_step: 0,
                    goal: nil, context: {}, results: []

      # Decompose a goal into a plan.
      # Replaces any existing plan; resets cursor and results.
      #
      # Payload keys:
      #   goal         [String]        — required
      #   context      [Hash]          — shared context forwarded to all steps (default: {})
      #   planner      [#call, nil]    — override state planner
      #   step_handler [#call, nil]    — set/override step handler
      on :plan do |state:, payload:|
        agent = new
        agent.send(:create_plan, state, payload)
      end

      # Execute the next pending step.
      # No-op when the plan is complete or no plan has been created.
      #
      # Payload keys:
      #   step_handler [#call, nil]  — override state step_handler for this call
      on :execute_next do |state:, payload:|
        agent = new
        agent.send(:execute_one_step, state, payload)
      end

      # Plan and execute all steps in one call (blocks until done).
      #
      # Accepts the same payload as :plan plus any :execute_next overrides.
      on :run_to_completion do |state:, payload:|
        agent = new
        agent.send(:run_all, state, payload)
      end

      # Sync query — current plan progress.
      #
      # @return [PlanStatus]
      on :status do |state:, **|
        PlanStatus.new(
          goal:         state[:goal],
          total_steps:  state[:plan].size,
          current_step: state[:current_step],
          completed:    state[:plan].count { |s| s.status == :done },
          failed:       state[:plan].count { |s| s.status == :failed }
        )
      end

      # Sync query — step results from the last run.
      #
      # @return [Array<Hash>]
      on :results do |state:, **|
        state[:results]
      end

      # Clear plan, cursor, and results.
      on :reset do |state:, **|
        state.merge(plan: [], current_step: 0, goal: nil, results: [])
      end

      # Update planner and/or step_handler.
      #
      # Payload keys:
      #   planner      [#call]
      #   step_handler [#call]
      on :configure do |state:, payload:|
        state.merge(
          planner:      payload.fetch(:planner,      state[:planner]),
          step_handler: payload.fetch(:step_handler, state[:step_handler])
        )
      end

      private

      def create_plan(state, payload)
        goal         = payload.fetch(:goal)
        context      = payload.fetch(:context, state[:context])
        planner      = payload.fetch(:planner, state[:planner])
        step_handler = payload.fetch(:step_handler, state[:step_handler])

        descriptions = planner ? decompose_with_planner(planner, goal, context)
                                : [goal.to_s]

        plan = descriptions.each_with_index.map do |desc, i|
          Step.new(index: i, description: desc, status: :pending, result: nil)
        end

        state.merge(
          goal:         goal,
          context:      context,
          plan:         plan,
          current_step: 0,
          results:      [],
          step_handler: step_handler || state[:step_handler]
        )
      end

      def execute_one_step(state, payload)
        idx          = state[:current_step]
        plan         = state[:plan]
        return state if idx >= plan.size

        step         = plan[idx]
        step_handler = payload.fetch(:step_handler, state[:step_handler])

        result, status = run_step(step_handler, step, state)

        updated_plan    = plan.dup
        updated_plan[idx] = Step.new(
          index:       step.index,
          description: step.description,
          status:      status,
          result:      result
        )

        state.merge(
          plan:         updated_plan,
          current_step: idx + 1,
          results:      state[:results] + [{ step: step.description, result: result, status: status }]
        )
      end

      def run_all(state, payload)
        planned = create_plan(state, payload)
        planned[:plan].size.times.reduce(planned) { |s, _| execute_one_step(s, payload) }
      end

      # @return [[result, status]]
      def run_step(step_handler, step, state)
        return ["No handler configured", :skipped] unless step_handler

        result = step_handler.call(
          step:    step.description,
          index:   step.index,
          context: state[:context],
          results: state[:results]
        )
        [result, :done]
      rescue StandardError => e
        [e.message, :failed]
      end

      # Parse planner output into Array<String> step descriptions.
      def decompose_with_planner(planner, goal, context)
        raw = planner.call(goal: goal, context: context)
        case raw
        when Array  then raw.map(&:to_s).reject(&:empty?)
        when Hash   then Array(raw[:steps] || raw["steps"]).map(&:to_s).reject(&:empty?)
        when String then parse_step_list(raw)
        else             [raw.to_s]
        end
      end

      # Split a numbered or newline-delimited string into step descriptions.
      def parse_step_list(text)
        text.split("\n")
            .map { |l| l.sub(/\A\s*\d+[\.\)\-]\s*/, "").strip }
            .reject(&:empty?)
      end
    end
  end
end
