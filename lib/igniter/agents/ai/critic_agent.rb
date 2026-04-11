# frozen_string_literal: true

module Igniter
  module Agents
    # Evaluates output quality and optionally retries generation until a score
    # threshold is met.
    #
    # Two evaluation modes:
    # * **Rule-based** (default) — heuristics based on length and emptiness;
    #   no external dependencies.
    # * **LLM-assisted** — delegates to any callable that accepts +output:+ and
    #   +criteria:+ and returns +{ score: Float, feedback: String }+ or a
    #   String that will be parsed for a numeric score.
    #
    # Scores are on a 0–10 scale. The default passing threshold is 7.0.
    #
    # @example Rule-based gate
    #   ref = CriticAgent.start
    #   ref.send(:evaluate, output: "Short answer", criteria: "completeness")
    #   ev = ref.call(:last_evaluation)
    #   puts ev.passed  # => false (too short)
    #
    # @example LLM-assisted with retry
    #   evaluator = ->(output:, criteria:) {
    #     result = MyGraderSkill.call(output: output, criteria: criteria)
    #     { score: result.score, feedback: result.feedback }
    #   }
    #   ref = CriticAgent.start(initial_state: { evaluator: evaluator, threshold: 8.0 })
    #   ref.send(:evaluate_and_retry,
    #     output:         first_draft,
    #     criteria:       "accuracy, completeness",
    #     max_retries:    2,
    #     generator:      ->(draft:) { improve_draft(draft) },
    #     generator_args: { draft: first_draft }
    #   )
    class CriticAgent < Igniter::Agent
      # Immutable evaluation result.
      Evaluation = Struct.new(:score, :feedback, :passed, :criteria, keyword_init: true)

      initial_state evaluator: nil, threshold: 7.0, evaluations: []

      # Evaluate a single output.
      #
      # Payload keys:
      #   output    [String, Object]  — required; the artifact to evaluate
      #   criteria  [String]          — evaluation criteria (default: "quality, relevance")
      #   evaluator [#call, nil]      — override state evaluator for this call
      #   threshold [Float, nil]      — override state threshold for this call
      on :evaluate do |state:, payload:|
        agent = new
        ev    = agent.send(:run_evaluation, payload, state)
        state.merge(evaluations: state[:evaluations] + [ev])
      end

      # Evaluate and re-generate until the score passes or retries are exhausted.
      #
      # Payload keys:
      #   output          [String]   — initial output to evaluate
      #   criteria        [String]   — evaluation criteria
      #   generator       [#call]    — required; called with **generator_args to produce a new output
      #   generator_args  [Hash]     — arguments forwarded to generator (default: {})
      #   max_retries     [Integer]  — maximum re-generation attempts (default: 3)
      #   evaluator       [#call]    — override state evaluator
      #   threshold       [Float]    — override state threshold
      on :evaluate_and_retry do |state:, payload:|
        agent = new
        agent.send(:run_evaluate_and_retry, state, payload)
      end

      # Set default evaluator and/or threshold.
      #
      # Payload keys:
      #   evaluator [#call]  — new default evaluator
      #   threshold [Float]  — new default threshold
      on :configure do |state:, payload:|
        state.merge(
          evaluator: payload.fetch(:evaluator, state[:evaluator]),
          threshold: payload.fetch(:threshold, state[:threshold]).to_f
        )
      end

      # Sync query — returns the most recent Evaluation, or nil.
      on :last_evaluation do |state:, **|
        state[:evaluations].last
      end

      # Sync query — returns all recorded Evaluation structs.
      on :evaluations do |state:, **|
        state[:evaluations]
      end

      # Clear evaluation history.
      on :clear do |state:, **|
        state.merge(evaluations: [])
      end

      private

      # @return [Evaluation]
      def run_evaluation(payload, state)
        output    = payload.fetch(:output)
        criteria  = payload.fetch(:criteria, "quality, relevance")
        evaluator = payload.fetch(:evaluator, state[:evaluator])
        threshold = payload.fetch(:threshold, state[:threshold]).to_f

        score, feedback = evaluator ? llm_score(evaluator, output, criteria)
                                    : rule_score(output)

        Evaluation.new(
          score:    score.to_f,
          feedback: feedback.to_s,
          passed:   score.to_f >= threshold,
          criteria: criteria
        )
      end

      # @return [Hash] updated state with all evaluations recorded
      def run_evaluate_and_retry(state, payload)
        max_retries    = payload.fetch(:max_retries, 3)
        generator      = payload.fetch(:generator)
        generator_args = payload.fetch(:generator_args, {})
        output         = payload.fetch(:output)
        all_evals      = []

        (max_retries + 1).times do |attempt|
          output = generator.call(**generator_args) if attempt.positive?
          ev     = run_evaluation(payload.merge(output: output), state)
          all_evals << ev
          break if ev.passed
        end

        state.merge(evaluations: state[:evaluations] + all_evals)
      end

      # Call the user-supplied evaluator. Accepts two return shapes:
      #   Hash  with :score / :feedback keys
      #   String  (we scan for the first number in the text as the score)
      def llm_score(evaluator, output, criteria)
        result = evaluator.call(output: output, criteria: criteria)
        case result
        when Hash
          [result.fetch(:score, 5.0), result.fetch(:feedback, "")]
        else
          text  = result.to_s
          score = text.match(/\b(\d+(?:\.\d+)?)\b/)&.captures&.first&.to_f || 5.0
          [score, text]
        end
      rescue StandardError => e
        [0.0, "Evaluator error: #{e.message}"]
      end

      # Minimal rule-based heuristic (no LLM required).
      def rule_score(output)
        text = output.to_s.strip
        return [0.0, "Output is empty"]          if text.empty?
        return [3.0, "Output is very short"]     if text.length < 50
        return [5.5, "Output is below average length"] if text.length < 200

        [7.5, "Output meets basic length criteria"]
      end
    end
  end
end
